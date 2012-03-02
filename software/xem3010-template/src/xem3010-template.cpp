/* Program for opal kelly xem3010 server */

#include <signal.h>
#include <limits.h>
#include <stdio.h>
//#include <stdlib.h>
#include <errno.h>
#include <string.h>
//#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "okFrontPanelDLL.h"


//#define FIFO1 "uart.rx"
//#define FIFO2 "uart.tx"
//#define PERMS 0666
#define CONFIGURATION_FILE "xem3010_template.bit"

//#define BUFFER_SIZE PIPE_BUF

// That flag is used by SigInt, to notify the main loop to quit
static int processing_stopped = 0;


static okCPLL22393* pll;

void sigint_handler (int sig_no)
{
	printf ("\nreceived sigint...\n");
	processing_stopped = 1;
}

okCUsbFrontPanel* initialize_xem (const std::string filename)
{

	okCUsbFrontPanel *xem; // Pointer to the Opal Kelly library object.


	if (FALSE == okFrontPanelDLL_LoadLib (NULL)) {
		printf ("Initialization Failed: FrontPanel library could not be loaded\n");
		return NULL;
	}

	xem = new okCUsbFrontPanel;

	// Tries to open the first XEM.

	if (okCUsbFrontPanel::NoError != xem->OpenBySerial()) {
		delete xem;
		xem = (okCUsbFrontPanel*) NULL;
		printf ("Initialization Failed: A XEM board was not detected\n");
		return NULL;
	}

	if (okCUsbFrontPanel::brdXEM3010 != xem->GetBoardModel()) {
		delete xem;
		xem = (okCUsbFrontPanel*) NULL;
		printf ("Initialization Failed: The XEM board detected was not of type \"XEM3010\"\n");
		return NULL;
	}

	// Pointer to the Phased Locked Loop (pll) container object.
	pll = new okCPLL22393;

	// set to 100 mhz, 40 mhz
	// Setting the VCO (Voltage Controlled Oscillator) to 384MHzk
	pll->SetPLLParameters (0,400,48,TRUE);
	pll->SetOutputDivider (0,4); // Set Divider1 to 6.
	pll->SetOutputSource (0,okCPLL22393::ClkSrc_PLL0_0);
	pll->SetOutputEnable (0,TRUE);

	pll->SetOutputDivider (1,5);
	pll->SetOutputSource (1,okCPLL22393::ClkSrc_PLL0_0);
	pll->SetOutputEnable (1,TRUE);

	if (okCUsbFrontPanel::NoError != xem->SetPLL22393Configuration (*pll)) {
		delete xem;
		xem = (okCUsbFrontPanel*) NULL;
		delete pll;
		pll = (okCPLL22393*) NULL;
		printf ("Initialization Failed: The PLL could not be set.\n");
		return NULL;
	}

	// Upload the (bitstream) configuration file.
	if (okCUsbFrontPanel::NoError != xem->ConfigureFPGA (filename)) {
		delete xem;
		xem = (okCUsbFrontPanel*) NULL;
		printf ("Initialization Failed: Could not load the (bitstream) configuration file\n");
		return NULL;
	}

	return xem;
}

void reset_device (okCUsbFrontPanel *xem)
{

	// Assert reset
	xem->SetWireInValue (0x00, 0x0001, 0x00FF);
	xem->UpdateWireIns();

	// Deassert reset
	xem->SetWireInValue (0x00, 0x0000, 0x00FF);
	xem->UpdateWireIns();
}


int main (void)
{

	// Handles SIGINT cleanly (ctrl+c).
	struct sigaction sa;
	memset (&sa, 0, sizeof (sa));
	sa.sa_handler = &sigint_handler;
	sigaction (SIGINT, &sa, NULL);


	// Create pointer to the Opal Kelly library on connect to board.
	okCUsbFrontPanel *xem = initialize_xem (CONFIGURATION_FILE);

	if (NULL == xem) {
		printf ("server: could not initialize connection to opal kelly board.\n");
		return -1;
	}

	reset_device (xem);

	// TEST
//	int length = 512;
//	unsigned char* test_in_array = new unsigned char[2*length];
//	unsigned char* test_out_array = new unsigned char[2*length];
//
//	for (int xx = 0; xx < length; xx++) {
//		test_in_array[ (2*xx) ] = (xx & 0xFF);
//		test_in_array[ (2*xx) +1] = ( (xx +10) & 0xFF);
//		printf ("Test Data In:  %i, %i\n", xx,  xx+10);
//	}
//
//	// Test PipeIn transfer
//	xem->WriteToPipeIn (0x80, (2*length), test_in_array);
//
//	// Test PipeOut transfer
//	xem->ReadFromPipeOut (0xA0, (2*length), test_out_array);
//
//	for (int xx = 0; xx < length; xx++) {
//		printf ("Test Data Out: %i, %i\n", (int) (test_out_array[ (2*xx) ] & 0xFF), (int) (test_out_array[ (2*xx) +1] & 0xFF));
//	}
//
//	delete[] test_out_array;
//	test_out_array = NULL;
//
//	delete[] test_in_array;
//	test_in_array = NULL;
	// END TEST


	// PipeIn data buffer
	int data_in_array_length = 1024;
	int data_in_ptr_length = data_in_array_length;
	unsigned char* data_in_array = new unsigned char[2*data_in_array_length];
	unsigned char* data_in_ptr = &data_in_array[0];

	for (int xx = 0; xx < data_in_array_length; xx++) {
		data_in_array[ (2*xx) ]   = (xx & 0xFF);
		data_in_array[ (2*xx) +1] = (xx & 0xFF00) >> 8;
		//printf("Data In Buffer:  %i\n", xx);
	}

	// PipeOut data buffer
	int data_out_array_length = 1024;
	int data_out_ptr_length = 0;
	unsigned char* data_out_array = new unsigned char[2*data_out_array_length];
	unsigned char* data_out_ptr = &data_out_array[0];

//	printf("Enter while read loop\n");
//	for (int ii = 0; ii < 10; ii++) {
	while (1) {
		if (processing_stopped) break; // exit loop

		//printf("wireOut 0x20 control: %i\n", (int) xem->GetWireOutValue(0x20));

		/* Send in data
		 *
		 * Read in_available (wireOut 0x20) which provides the current rx buffer size.
		 * This size is the max # of data words that can currently be sent to device.
		 * Send in no more then in_available data words via pipeIn (0x80).
		 */
		xem->UpdateWireOuts();
		unsigned long in_available = xem->GetWireOutValue (0x20);

		if (in_available > ( (unsigned long) data_in_ptr_length)) {

			// PipeIn transfer
			xem->WriteToPipeIn (0x80, (2*data_in_ptr_length), data_in_ptr);

			for (int xx = 0; xx < (int) data_in_ptr_length; xx++) {
				int dat = (data_in_ptr[2*xx] & 0xFF) + ( (data_in_ptr[ (2*xx) +1] & 0xFF) << 8);

				printf ("Data In Buffer:  %i\n", dat);
			}

			data_in_ptr_length = data_in_array_length;
			data_in_ptr = &data_in_array[0];
		} else {

			// PipeIn transfer
			xem->WriteToPipeIn (0x80, (2*in_available), data_in_ptr);

			for (int xx = 0; xx < (int) in_available; xx++) {
				int dat = (data_in_ptr[2*xx] & 0xFF) + ( (data_in_ptr[ (2*xx) +1] & 0xFF) << 8);

				printf ("Data In Buffer:  %i\n", dat);
			}

			data_in_ptr_length = data_in_ptr_length - ( (int) in_available);
			data_in_ptr = &data_in_ptr[2*in_available];
		}

		if (data_in_ptr_length == data_in_array_length) {
			printf ("Written data_in buffer to device\n");

			// read enable
			xem->SetWireInValue (0x00, (1<<1), 0x00FF);
			xem->UpdateWireIns();
		}

		/* Read out data
		 *
		 * Read out_available (wireOut 0x21) which provides the current number of data
		 * words in tx buffer to be read out.  Read out as many data words as possible
		 * via pipeOut (0xA0).
		 */
		xem->UpdateWireOuts();

		unsigned long out_available = xem->GetWireOutValue (0x21);

		if (out_available > 0) {
			if (out_available >= ( (unsigned long) (data_out_array_length - data_out_ptr_length))) {

				// PipeOut transfer
				xem->ReadFromPipeOut (0xA0, (2* (data_out_array_length-data_out_ptr_length)), data_out_ptr);

				for (int xx = 0; xx < (int) (data_out_array_length-data_out_ptr_length); xx++) {
					int dat = (data_out_ptr[2*xx] & 0xFF) + ( (data_out_ptr[ (2*xx) +1] & 0xFF) << 8);

					printf ("Data Out Buffer:  %i\n", dat);
				}

				data_out_ptr_length = data_out_array_length;
				data_out_ptr = &data_out_array[0];

			} else {

				// PipeOut transfer
				xem->ReadFromPipeOut (0xA0, ( (int) 2*out_available), data_out_ptr);

				for (int xx = 0; xx < (int) out_available; xx++) {
					int dat = (data_out_ptr[2*xx] & 0xFF) + ( (data_out_ptr[ (2*xx) +1] & 0xFF) << 8);

					printf ("Data Out Buffer:  %i\n", dat);
				}

				data_out_ptr_length = data_out_ptr_length + ( (int) out_available);
				data_out_ptr = &data_out_ptr[2*out_available];

			}
		}

		if (data_out_ptr_length == data_out_array_length) {
			printf ("Full read buffer\n");

//			for (int xx = 0; xx < data_out_array_length; xx++) {
//				int dat = (data_out_array[2*xx] & 0xFF) + ((data_out_array[(2*xx)+1] & 0xFF) << 8);
//
//				printf ("Data Out Buffer: %i\n", dat);
//			}

			break;
		}
	}

	delete[] data_in_array;
	data_in_array = NULL;
	data_in_ptr = NULL;

	delete[] data_out_array;
	data_out_array = NULL;
	data_out_ptr = NULL;

	delete pll;
	pll = (okCPLL22393*) NULL;

	delete xem;
	xem = (okCUsbFrontPanel*) NULL;

	printf ("The End\n");

	return 0;
}


