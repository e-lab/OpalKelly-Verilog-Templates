//------------------------------------------------------------------------
// okFrontPanelDLL.c
//
// This is the import source for the FrontPanel API DLL.  If you are
// building an application using the DLL, this source should be included
// within your C++/C project.  It includes methods that will
// automatically load the DLL and map function calls to the DLL entry
// points.
//
// This library is not necessary when you call the DLL methods from
// another application or language such as LabVIEW or VisualBasic.
//
// This methods in this DLL correspond closely with the C++ API.
// Therefore, the C++ API documentation serves as the documentation for
// this DLL.
//
//
// NOTE: Before any API function calls are made, you MUST call:
//    okFrontPanelDLL_LoadLib
//
// When you are finished using the API methods, you should call:
//    okFrontPanelDLL_FreeLib
//
// The current DLL version can be retrieved by calling:
//    okFrontPanelDLL_GetVersionString
//
//------------------------------------------------------------------------
// Copyright (c) 2005-2009 Opal Kelly Incorporated
// $Rev: 643 $ $Date: 2009-02-27 11:10:22 -0800 (Fri, 27 Feb 2009) $
//------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>


#include "okFrontPanelDLL.h"

#if defined(_WIN32)
#if !defined(okLIB_NAME)
#define okLIB_NAME "okFrontPanel.dll"
#endif
#elif defined(MACOSX)
#include <dlfcn.h>
#define okLIB_NAME "libokFrontPanel.dylib"
#elif defined(LINUX)
#include <dlfcn.h>
#define okLIB_NAME "./libokFrontPanel.so"
#endif

typedef void   DLL;
static DLL    *hLib = NULL;
static DLL_EP  dll_entrypoint (DLL *dll, const char *name);
static DLL    *dll_load (char *libname);
static void    dll_unload (DLL *dll);
static char    VERSION_STRING[32];


#ifdef __cplusplus
#include <string>
//------------------------------------------------------------------------
// okCPLL22150 C++ wrapper class
//------------------------------------------------------------------------
bool okCPLL22150::to_bool (Bool x)
{
	return ( (x==TRUE) ? (true) : (false));
}

Bool okCPLL22150::from_bool (bool x)
{
	return ( (x==true) ? (TRUE) : (FALSE));
}

okCPLL22150::okCPLL22150()
{
	h=okPLL22150_Construct();
}

void okCPLL22150::SetCrystalLoad (double capload)
{
	okPLL22150_SetCrystalLoad (h, capload);
}

void okCPLL22150::SetReference (double freq, bool extosc)
{
	okPLL22150_SetReference (h, freq, from_bool (extosc));
}

double okCPLL22150::GetReference()
{
	return (okPLL22150_GetReference (h));
}

bool okCPLL22150::SetVCOParameters (int p, int q)
{
	return (to_bool (okPLL22150_SetVCOParameters (h,p,q)));
}

int okCPLL22150::GetVCOP()
{
	return (okPLL22150_GetVCOP (h));
}

int okCPLL22150::GetVCOQ()
{
	return (okPLL22150_GetVCOQ (h));
}

double okCPLL22150::GetVCOFrequency()
{
	return (okPLL22150_GetVCOFrequency (h));
}

void okCPLL22150::SetDiv1 (DividerSource divsrc, int n)
{
	okPLL22150_SetDiv1 (h, (ok_DividerSource) divsrc, n);
}

void okCPLL22150::SetDiv2 (DividerSource divsrc, int n)
{
	okPLL22150_SetDiv2 (h, (ok_DividerSource) divsrc, n);
}

okCPLL22150::DividerSource okCPLL22150::GetDiv1Source()
{
	return ( (DividerSource) okPLL22150_GetDiv1Source (h));
}

okCPLL22150::DividerSource okCPLL22150::GetDiv2Source()
{
	return ( (DividerSource) okPLL22150_GetDiv2Source (h));
}

int okCPLL22150::GetDiv1Divider()
{
	return (okPLL22150_GetDiv1Divider (h));
}

int okCPLL22150::GetDiv2Divider()
{
	return (okPLL22150_GetDiv2Divider (h));
}

void okCPLL22150::SetOutputSource (int output, okCPLL22150::ClockSource clksrc)
{
	okPLL22150_SetOutputSource (h, output, (ok_ClockSource_22150) clksrc);
}

void okCPLL22150::SetOutputEnable (int output, bool enable)
{
	okPLL22150_SetOutputEnable (h, output, to_bool (enable));
}

okCPLL22150::ClockSource okCPLL22150::GetOutputSource (int output)
{
	return ( (ClockSource) okPLL22150_GetOutputSource (h, output));
}

double okCPLL22150::GetOutputFrequency (int output)
{
	return (okPLL22150_GetOutputFrequency (h, output));
}

bool okCPLL22150::IsOutputEnabled (int output)
{
	return (to_bool (okPLL22150_IsOutputEnabled (h, output)));
}

void okCPLL22150::InitFromProgrammingInfo (unsigned char *buf)
{
	okPLL22150_InitFromProgrammingInfo (h, buf);
}

void okCPLL22150::GetProgrammingInfo (unsigned char *buf)
{
	okPLL22150_GetProgrammingInfo (h, buf);
}

//------------------------------------------------------------------------
// okCPLL22393 C++ wrapper class
//------------------------------------------------------------------------
bool okCPLL22393::to_bool (Bool x)
{
	return ( (x==TRUE) ? (true) : (false));
}

Bool okCPLL22393::from_bool (bool x)
{
	return ( (x==true) ? (TRUE) : (FALSE));
}

okCPLL22393::okCPLL22393()
{
	h=okPLL22393_Construct();
}

void okCPLL22393::SetCrystalLoad (double capload)
{
	okPLL22393_SetCrystalLoad (h, capload);
}

void okCPLL22393::SetReference (double freq)
{
	okPLL22393_SetReference (h, freq);
}

double okCPLL22393::GetReference()
{
	return (okPLL22393_GetReference (h));
}

bool okCPLL22393::SetPLLParameters (int n, int p, int q, bool enable)
{
	return (to_bool (okPLL22393_SetPLLParameters (h, n, p, q, from_bool (enable))));
}

bool okCPLL22393::SetPLLLF (int n, int lf)
{
	return (to_bool (okPLL22393_SetPLLLF (h, n, lf)));
}

bool okCPLL22393::SetOutputDivider (int n, int div)
{
	return (to_bool (okPLL22393_SetOutputDivider (h, n, div)));
}

bool okCPLL22393::SetOutputSource (int n, okCPLL22393::ClockSource clksrc)
{
	return (to_bool (okPLL22393_SetOutputSource (h, n, (ok_ClockSource_22393) clksrc)));
}

void okCPLL22393::SetOutputEnable (int n, bool enable)
{
	okPLL22393_SetOutputEnable (h, n, from_bool (enable));
}

int okCPLL22393::GetPLLP (int n)
{
	return (okPLL22393_GetPLLP (h, n));
}

int okCPLL22393::GetPLLQ (int n)
{
	return (okPLL22393_GetPLLQ (h, n));
}

double okCPLL22393::GetPLLFrequency (int n)
{
	return (okPLL22393_GetPLLFrequency (h, n));
}

int okCPLL22393::GetOutputDivider (int n)
{
	return (okPLL22393_GetOutputDivider (h, n));
}

okCPLL22393::ClockSource okCPLL22393::GetOutputSource (int n)
{
	return ( (ClockSource) okPLL22393_GetOutputSource (h, n));
}

double okCPLL22393::GetOutputFrequency (int n)
{
	return (okPLL22393_GetOutputFrequency (h, n));
}

bool okCPLL22393::IsOutputEnabled (int n)
{
	return (to_bool (okPLL22393_IsOutputEnabled (h, n)));
}

bool okCPLL22393::IsPLLEnabled (int n)
{
	return (to_bool (okPLL22393_IsPLLEnabled (h, n)));
}

void okCPLL22393::InitFromProgrammingInfo (unsigned char *buf)
{
	okPLL22393_InitFromProgrammingInfo (h, buf);
}

void okCPLL22393::GetProgrammingInfo (unsigned char *buf)
{
	okPLL22393_GetProgrammingInfo (h, buf);
}

//------------------------------------------------------------------------
// okCFrontPanel C++ wrapper class
//------------------------------------------------------------------------
bool okCUsbFrontPanel::to_bool (Bool x)
{
	return ( (x==TRUE) ? (true) : (false));
}

Bool okCUsbFrontPanel::from_bool (bool x)
{
	return ( (x==true) ? (TRUE) : (FALSE));
}

okCUsbFrontPanel::okCUsbFrontPanel()
{
	h=okUsbFrontPanel_Construct();
}

okCUsbFrontPanel::~okCUsbFrontPanel()
{
	okUsbFrontPanel_Destruct (h);
}

bool okCUsbFrontPanel::Has16BitHostInterface()
{
	return (to_bool (okUsbFrontPanel_Has16BitHostInterface (h)));
}

bool okCUsbFrontPanel::IsHighSpeed()
{
	return (to_bool (okUsbFrontPanel_IsHighSpeed (h)));
}

okCUsbFrontPanel::BoardModel okCUsbFrontPanel::GetBoardModel()
{
	return ( (okCUsbFrontPanel::BoardModel) okUsbFrontPanel_GetBoardModel (h));
}

int okCUsbFrontPanel::GetDeviceCount()
{
	return (okUsbFrontPanel_GetDeviceCount (h));
}

okCUsbFrontPanel::BoardModel okCUsbFrontPanel::GetDeviceListModel (int num)
{
	return ( (okCUsbFrontPanel::BoardModel) okUsbFrontPanel_GetDeviceListModel (h, num));
}

std::string okCUsbFrontPanel::GetDeviceListSerial (int num)
{
	char serial[32];
	okUsbFrontPanel_GetDeviceListSerial (h, num, serial, 32);
	return (std::string (serial));
}

void okCUsbFrontPanel::EnableAsynchronousTransfers (bool enable)
{
	okUsbFrontPanel_EnableAsynchronousTransfers (h, to_bool (enable));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::OpenBySerial (std::string str)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_OpenBySerial (h, str.c_str()));
}

bool okCUsbFrontPanel::IsOpen()
{
	return (to_bool (okUsbFrontPanel_IsOpen (h)));
}

int okCUsbFrontPanel::GetDeviceMajorVersion()
{
	return (okUsbFrontPanel_GetDeviceMajorVersion (h));
}

int okCUsbFrontPanel::GetDeviceMinorVersion()
{
	return (okUsbFrontPanel_GetDeviceMinorVersion (h));
}

std::string okCUsbFrontPanel::GetSerialNumber()
{
	char serial[32];
	okUsbFrontPanel_GetSerialNumber (h, serial);
	return (std::string (serial));
}

std::string okCUsbFrontPanel::GetDeviceID()
{
	char serial[32];
	okUsbFrontPanel_GetDeviceID (h, serial);
	return (std::string (serial));
}

void okCUsbFrontPanel::SetDeviceID (const std::string str)
{
	okUsbFrontPanel_SetDeviceID (h, str.c_str());
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::SetBTPipePollingInterval (int interval)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_SetBTPipePollingInterval (h, interval));
}

void okCUsbFrontPanel::SetTimeout (int timeout)
{
	okUsbFrontPanel_SetTimeout (h, timeout);
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::ResetFPGA()
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_ResetFPGA (h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::ConfigureFPGAFromMemory (unsigned char *data, const unsigned long length, void (*callback) (int, int, void *), void *arg)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_ConfigureFPGAFromMemory (h, data, length));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::ConfigureFPGA (const std::string strFilename, void (*callback) (int, int, void *), void *arg)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_ConfigureFPGA (h, strFilename.c_str()));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::WriteI2C (const int addr, int length, unsigned char *data)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_WriteI2C (h, addr, length, data));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::ReadI2C (const int addr, int length, unsigned char *data)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_ReadI2C (h, addr, length, data));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::GetPLL22150Configuration (okCPLL22150& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_GetPLL22150Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::SetPLL22150Configuration (okCPLL22150& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_SetPLL22150Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::GetEepromPLL22150Configuration (okCPLL22150& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_GetEepromPLL22150Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::SetEepromPLL22150Configuration (okCPLL22150& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_SetEepromPLL22150Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::GetPLL22393Configuration (okCPLL22393& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_GetPLL22393Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::SetPLL22393Configuration (okCPLL22393& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_SetPLL22393Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::GetEepromPLL22393Configuration (okCPLL22393& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_GetEepromPLL22393Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::SetEepromPLL22393Configuration (okCPLL22393& pll)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_SetEepromPLL22393Configuration (h, pll.h));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::LoadDefaultPLLConfiguration()
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_LoadDefaultPLLConfiguration (h));
}

bool okCUsbFrontPanel::IsFrontPanelEnabled()
{
	return (to_bool (okUsbFrontPanel_IsFrontPanelEnabled (h)));
}

bool okCUsbFrontPanel::IsFrontPanel3Supported()
{
	return (to_bool (okUsbFrontPanel_IsFrontPanel3Supported (h)));
}

//	void UnregisterAll();
//	void AddEventHandler(okCEventHandler *handler);
void okCUsbFrontPanel::UpdateWireIns()
{
	okUsbFrontPanel_UpdateWireIns (h);
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::SetWireInValue (int ep, int val, int mask)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_SetWireInValue (h, ep, val, mask));
}

void okCUsbFrontPanel::UpdateWireOuts()
{
	okUsbFrontPanel_UpdateWireOuts (h);
}

int okCUsbFrontPanel::GetWireOutValue (int epAddr)
{
	return (okUsbFrontPanel_GetWireOutValue (h, epAddr));
}

okCUsbFrontPanel::ErrorCode okCUsbFrontPanel::ActivateTriggerIn (int epAddr, int bit)
{
	return ( (okCUsbFrontPanel::ErrorCode) okUsbFrontPanel_ActivateTriggerIn (h, epAddr, bit));
}

void okCUsbFrontPanel::UpdateTriggerOuts()
{
	okUsbFrontPanel_UpdateTriggerOuts (h);
}

bool okCUsbFrontPanel::IsTriggered (int epAddr, int mask)
{
	return (to_bool (okUsbFrontPanel_IsTriggered (h, epAddr, mask)));
}

long okCUsbFrontPanel::GetLastTransferLength()
{
	return (okUsbFrontPanel_GetLastTransferLength (h));
}

long okCUsbFrontPanel::WriteToPipeIn (int epAddr, long length, unsigned char *data)
{
	return (okUsbFrontPanel_WriteToPipeIn (h, epAddr, length, data));
}

long okCUsbFrontPanel::ReadFromPipeOut (int epAddr, long length, unsigned char *data)
{
	return (okUsbFrontPanel_ReadFromPipeOut (h, epAddr, length, data));
}

long okCUsbFrontPanel::WriteToBlockPipeIn (int epAddr, int blockSize, long length, unsigned char *data)
{
	return (okUsbFrontPanel_WriteToBlockPipeIn (h, epAddr, blockSize, length, data));
}

long okCUsbFrontPanel::ReadFromBlockPipeOut (int epAddr, int blockSize, long length, unsigned char *data)
{
	return (okUsbFrontPanel_ReadFromBlockPipeOut (h, epAddr, blockSize, length, data));
}

#endif // __cplusplus


//------------------------------------------------------------------------
// Function prototypes
//------------------------------------------------------------------------
typedef void (DLL_ENTRY *OKFRONTPANELDLL_GETVERSION_FN) (char *, char *);

typedef okPLL22150_HANDLE (DLL_ENTRY *OKPLL22150_CONSTRUCT_FN) (void);
typedef void (DLL_ENTRY *OKPLL22150_DESTRUCT_FN) (okPLL22150_HANDLE);
typedef void (DLL_ENTRY *OKPLL22150_SETCRYSTALLOAD_FN) (okPLL22150_HANDLE, double);
typedef void (DLL_ENTRY *OKPLL22150_SETREFERENCE_FN) (okPLL22150_HANDLE, double, Bool);
typedef double (DLL_ENTRY *OKPLL22150_GETREFERENCE_FN) (okPLL22150_HANDLE);
typedef Bool (DLL_ENTRY *OKPLL22150_SETVCOPARAMETERS_FN) (okPLL22150_HANDLE, int, int);
typedef int (DLL_ENTRY *OKPLL22150_GETVCOP_FN) (okPLL22150_HANDLE);
typedef int (DLL_ENTRY *OKPLL22150_GETVCOQ_FN) (okPLL22150_HANDLE);
typedef double (DLL_ENTRY *OKPLL22150_GETVCOFREQUENCY_FN) (okPLL22150_HANDLE);
typedef void (DLL_ENTRY *OKPLL22150_SETDIV1_FN) (okPLL22150_HANDLE, ok_DividerSource, int);
typedef void (DLL_ENTRY *OKPLL22150_SETDIV2_FN) (okPLL22150_HANDLE, ok_DividerSource, int);
typedef ok_DividerSource (DLL_ENTRY *OKPLL22150_GETDIV1SOURCE_FN) (okPLL22150_HANDLE);
typedef ok_DividerSource (DLL_ENTRY *OKPLL22150_GETDIV2SOURCE_FN) (okPLL22150_HANDLE);
typedef int (DLL_ENTRY *OKPLL22150_GETDIV1DIVIDER_FN) (okPLL22150_HANDLE);
typedef int (DLL_ENTRY *OKPLL22150_GETDIV2DIVIDER_FN) (okPLL22150_HANDLE);
typedef void (DLL_ENTRY *OKPLL22150_SETOUTPUTSOURCE_FN) (okPLL22150_HANDLE, int, ok_ClockSource_22150);
typedef void (DLL_ENTRY *OKPLL22150_SETOUTPUTENABLE_FN) (okPLL22150_HANDLE, int, Bool);
typedef ok_ClockSource_22150 (DLL_ENTRY *OKPLL22150_GETOUTPUTSOURCE_FN) (okPLL22150_HANDLE, int);
typedef double (DLL_ENTRY *OKPLL22150_GETOUTPUTFREQUENCY_FN) (okPLL22150_HANDLE, int);
typedef Bool (DLL_ENTRY *OKPLL22150_ISOUTPUTENABLED_FN) (okPLL22150_HANDLE, int);
typedef void (DLL_ENTRY *OKPLL22150_INITFROMPROGRAMMINGINFO_FN) (okPLL22150_HANDLE, unsigned char *);
typedef void (DLL_ENTRY *OKPLL22150_GETPROGRAMMINGINFO_FN) (okPLL22150_HANDLE, unsigned char *);

typedef okPLL22393_HANDLE (DLL_ENTRY *OKPLL22393_CONSTRUCT_FN) (void);
typedef void (DLL_ENTRY *OKPLL22393_DESTRUCT_FN) (okPLL22393_HANDLE);
typedef void (DLL_ENTRY *OKPLL22393_SETCRYSTALLOAD_FN) (okPLL22393_HANDLE, double);
typedef void (DLL_ENTRY *OKPLL22393_SETREFERENCE_FN) (okPLL22393_HANDLE, double);
typedef double (DLL_ENTRY *OKPLL22393_GETREFERENCE_FN) (okPLL22393_HANDLE);
typedef Bool (DLL_ENTRY *OKPLL22393_SETPLLPARAMETERS_FN) (okPLL22393_HANDLE, int, int, int, Bool);
typedef Bool (DLL_ENTRY *OKPLL22393_SETPLLLF_FN) (okPLL22393_HANDLE, int, int);
typedef Bool (DLL_ENTRY *OKPLL22393_SETOUTPUTDIVIDER_FN) (okPLL22393_HANDLE, int, int);
typedef Bool (DLL_ENTRY *OKPLL22393_SETOUTPUTSOURCE_FN) (okPLL22393_HANDLE, int, ok_ClockSource_22393);
typedef void (DLL_ENTRY *OKPLL22393_SETOUTPUTENABLE_FN) (okPLL22393_HANDLE, int, Bool);
typedef int (DLL_ENTRY *OKPLL22393_GETPLLP_FN) (okPLL22393_HANDLE, int);
typedef int (DLL_ENTRY *OKPLL22393_GETPLLQ_FN) (okPLL22393_HANDLE, int);
typedef double (DLL_ENTRY *OKPLL22393_GETPLLFREQUENCY_FN) (okPLL22393_HANDLE, int);
typedef int (DLL_ENTRY *OKPLL22393_GETOUTPUTDIVIDER_FN) (okPLL22393_HANDLE, int);
typedef ok_ClockSource_22393 (DLL_ENTRY *OKPLL22393_GETOUTPUTSOURCE_FN) (okPLL22393_HANDLE, int);
typedef double (DLL_ENTRY *OKPLL22393_GETOUTPUTFREQUENCY_FN) (okPLL22393_HANDLE, int);
typedef Bool (DLL_ENTRY *OKPLL22393_ISOUTPUTENABLED_FN) (okPLL22393_HANDLE, int);
typedef Bool (DLL_ENTRY *OKPLL22393_ISPLLENABLED_FN) (okPLL22393_HANDLE, int);
typedef void (DLL_ENTRY *OKPLL22393_INITFROMPROGRAMMINGINFO_FN) (okPLL22393_HANDLE, unsigned char *);
typedef void (DLL_ENTRY *OKPLL22393_GETPROGRAMMINGINFO_FN) (okPLL22393_HANDLE, unsigned char *);

typedef okUSBFRONTPANEL_HANDLE (DLL_ENTRY *OKUSBFRONTPANEL_CONSTRUCT_FN) (void);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_DESTRUCT_FN) (okUSBFRONTPANEL_HANDLE);
typedef Bool (DLL_ENTRY *OKUSBFRONTPANEL_HAS16BITHOSTINTERFACE_FN) (okUSBFRONTPANEL_HANDLE);
typedef Bool (DLL_ENTRY *OKUSBFRONTPANEL_ISHIGHSPEED_FN) (okUSBFRONTPANEL_HANDLE);
typedef ok_BoardModel (DLL_ENTRY *OKUSBFRONTPANEL_GETBOARDMODEL_FN) (okUSBFRONTPANEL_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_WRITEI2C_FN) (okUSBFRONTPANEL_HANDLE, const int, int, unsigned char *);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_READI2C_FN) (okUSBFRONTPANEL_HANDLE, const int, int, unsigned char *);
typedef int (DLL_ENTRY *OKUSBFRONTPANEL_GETDEVICECOUNT_FN) (okUSBFRONTPANEL_HANDLE);
typedef ok_BoardModel (DLL_ENTRY *OKUSBFRONTPANEL_GETDEVICELISTMODEL_FN) (okUSBFRONTPANEL_HANDLE, int);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_GETDEVICELISTSERIAL_FN) (okUSBFRONTPANEL_HANDLE, int, char *, int);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_OPENBYSERIAL_FN) (okUSBFRONTPANEL_HANDLE, const char *);
typedef Bool (DLL_ENTRY *OKUSBFRONTPANEL_ISOPEN_FN) (okUSBFRONTPANEL_HANDLE);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_ENABLEASYNCHRONOUSTRANSFERS_FN) (okUSBFRONTPANEL_HANDLE, Bool);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_SETBTPIPEPOLLINGINTERVAL_FN) (okUSBFRONTPANEL_HANDLE, int);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_SETTIMEOUT_FN) (okUSBFRONTPANEL_HANDLE, int);
typedef int (DLL_ENTRY *OKUSBFRONTPANEL_GETDEVICEMAJORVERSION_FN) (okUSBFRONTPANEL_HANDLE);
typedef int (DLL_ENTRY *OKUSBFRONTPANEL_GETDEVICEMINORVERSION_FN) (okUSBFRONTPANEL_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_RESETFPGA_FN) (okUSBFRONTPANEL_HANDLE);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_GETSERIALNUMBER_FN) (okUSBFRONTPANEL_HANDLE, char *);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_GETDEVICEID_FN) (okUSBFRONTPANEL_HANDLE, char *);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_SETDEVICEID_FN) (okUSBFRONTPANEL_HANDLE, const char *);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_CONFIGUREFPGA_FN) (okUSBFRONTPANEL_HANDLE, const char *);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_CONFIGUREFPGAFROMMEMORY_FN) (okUSBFRONTPANEL_HANDLE, unsigned char *, unsigned long);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_GETPLL22150CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22150_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_SETPLL22150CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22150_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_GETEEPROMPLL22150CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22150_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_SETEEPROMPLL22150CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22150_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_GETPLL22393CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22393_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_SETPLL22393CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22393_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_GETEEPROMPLL22393CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22393_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_SETEEPROMPLL22393CONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE, okPLL22393_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_LOADDEFAULTPLLCONFIGURATION_FN) (okUSBFRONTPANEL_HANDLE);
typedef Bool (DLL_ENTRY *OKUSBFRONTPANEL_ISFRONTPANELENABLED_FN) (okUSBFRONTPANEL_HANDLE);
typedef Bool (DLL_ENTRY *OKUSBFRONTPANEL_ISFRONTPANEL3SUPPORTED_FN) (okUSBFRONTPANEL_HANDLE);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_UPDATEWIREINS_FN) (okUSBFRONTPANEL_HANDLE);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_SETWIREINVALUE_FN) (okUSBFRONTPANEL_HANDLE, int, int, int);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_UPDATEWIREOUTS_FN) (okUSBFRONTPANEL_HANDLE);
typedef int (DLL_ENTRY *OKUSBFRONTPANEL_GETWIREOUTVALUE_FN) (okUSBFRONTPANEL_HANDLE, int);
typedef ok_ErrorCode (DLL_ENTRY *OKUSBFRONTPANEL_ACTIVATETRIGGERIN_FN) (okUSBFRONTPANEL_HANDLE, int, int);
typedef void (DLL_ENTRY *OKUSBFRONTPANEL_UPDATETRIGGEROUTS_FN) (okUSBFRONTPANEL_HANDLE);
typedef Bool (DLL_ENTRY *OKUSBFRONTPANEL_ISTRIGGERED_FN) (okUSBFRONTPANEL_HANDLE, int, int);
typedef long (DLL_ENTRY *OKUSBFRONTPANEL_GETLASTTRANSFERLENGTH_FN) (okUSBFRONTPANEL_HANDLE);
typedef long (DLL_ENTRY *OKUSBFRONTPANEL_WRITETOPIPEIN_FN) (okUSBFRONTPANEL_HANDLE, int, long, unsigned char *);
typedef long (DLL_ENTRY *OKUSBFRONTPANEL_WRITETOBLOCKPIPEIN_FN) (okUSBFRONTPANEL_HANDLE, int, long, int, unsigned char *);
typedef long (DLL_ENTRY *OKUSBFRONTPANEL_READFROMPIPEOUT_FN) (okUSBFRONTPANEL_HANDLE, int, long, unsigned char *);
typedef long (DLL_ENTRY *OKUSBFRONTPANEL_READFROMBLOCKPIPEOUT_FN) (okUSBFRONTPANEL_HANDLE, int, long, int, unsigned char *);

//------------------------------------------------------------------------
// Function pointers
//------------------------------------------------------------------------
OKFRONTPANELDLL_GETVERSION_FN                  _okFrontPanelDLL_GetVersion = NULL;

OKPLL22393_CONSTRUCT_FN                        _okPLL22393_Construct = NULL;
OKPLL22393_DESTRUCT_FN                         _okPLL22393_Destruct = NULL;
OKPLL22393_SETCRYSTALLOAD_FN                   _okPLL22393_SetCrystalLoad = NULL;
OKPLL22393_SETREFERENCE_FN                     _okPLL22393_SetReference = NULL;
OKPLL22393_GETREFERENCE_FN                     _okPLL22393_GetReference = NULL;
OKPLL22393_SETPLLPARAMETERS_FN                 _okPLL22393_SetPLLParameters = NULL;
OKPLL22393_SETPLLLF_FN                         _okPLL22393_SetPLLLF = NULL;
OKPLL22393_SETOUTPUTDIVIDER_FN                 _okPLL22393_SetOutputDivider = NULL;
OKPLL22393_SETOUTPUTSOURCE_FN                  _okPLL22393_SetOutputSource = NULL;
OKPLL22393_SETOUTPUTENABLE_FN                  _okPLL22393_SetOutputEnable = NULL;
OKPLL22393_GETPLLP_FN                          _okPLL22393_GetPLLP = NULL;
OKPLL22393_GETPLLQ_FN                          _okPLL22393_GetPLLQ = NULL;
OKPLL22393_GETPLLFREQUENCY_FN                  _okPLL22393_GetPLLFrequency = NULL;
OKPLL22393_GETOUTPUTDIVIDER_FN                 _okPLL22393_GetOutputDivider = NULL;
OKPLL22393_GETOUTPUTSOURCE_FN                  _okPLL22393_GetOutputSource = NULL;
OKPLL22393_GETOUTPUTFREQUENCY_FN               _okPLL22393_GetOutputFrequency = NULL;
OKPLL22393_ISOUTPUTENABLED_FN                  _okPLL22393_IsOutputEnabled = NULL;
OKPLL22393_ISPLLENABLED_FN                     _okPLL22393_IsPLLEnabled = NULL;
OKPLL22393_INITFROMPROGRAMMINGINFO_FN          _okPLL22393_InitFromProgrammingInfo = NULL;
OKPLL22393_GETPROGRAMMINGINFO_FN               _okPLL22393_GetProgrammingInfo = NULL;

OKPLL22150_CONSTRUCT_FN                        _okPLL22150_Construct = NULL;
OKPLL22150_DESTRUCT_FN                         _okPLL22150_Destruct = NULL;
OKPLL22150_SETCRYSTALLOAD_FN                   _okPLL22150_SetCrystalLoad = NULL;
OKPLL22150_SETREFERENCE_FN                     _okPLL22150_SetReference = NULL;
OKPLL22150_GETREFERENCE_FN                     _okPLL22150_GetReference = NULL;
OKPLL22150_SETVCOPARAMETERS_FN                 _okPLL22150_SetVCOParameters = NULL;
OKPLL22150_GETVCOP_FN                          _okPLL22150_GetVCOP = NULL;
OKPLL22150_GETVCOQ_FN                          _okPLL22150_GetVCOQ = NULL;
OKPLL22150_GETVCOFREQUENCY_FN                  _okPLL22150_GetVCOFrequency = NULL;
OKPLL22150_SETDIV1_FN                          _okPLL22150_SetDiv1 = NULL;
OKPLL22150_SETDIV2_FN                          _okPLL22150_SetDiv2 = NULL;
OKPLL22150_GETDIV1SOURCE_FN                    _okPLL22150_GetDiv1Source = NULL;
OKPLL22150_GETDIV2SOURCE_FN                    _okPLL22150_GetDiv2Source = NULL;
OKPLL22150_GETDIV1DIVIDER_FN                   _okPLL22150_GetDiv1Divider = NULL;
OKPLL22150_GETDIV2DIVIDER_FN                   _okPLL22150_GetDiv2Divider = NULL;
OKPLL22150_SETOUTPUTSOURCE_FN                  _okPLL22150_SetOutputSource = NULL;
OKPLL22150_SETOUTPUTENABLE_FN                  _okPLL22150_SetOutputEnable = NULL;
OKPLL22150_GETOUTPUTSOURCE_FN                  _okPLL22150_GetOutputSource = NULL;
OKPLL22150_GETOUTPUTFREQUENCY_FN               _okPLL22150_GetOutputFrequency = NULL;
OKPLL22150_ISOUTPUTENABLED_FN                  _okPLL22150_IsOutputEnabled = NULL;
OKPLL22150_INITFROMPROGRAMMINGINFO_FN          _okPLL22150_InitFromProgrammingInfo = NULL;
OKPLL22150_GETPROGRAMMINGINFO_FN               _okPLL22150_GetProgrammingInfo = NULL;

OKUSBFRONTPANEL_CONSTRUCT_FN                        _okUsbFrontPanel_Construct = NULL;
OKUSBFRONTPANEL_DESTRUCT_FN                         _okUsbFrontPanel_Destruct = NULL;
OKUSBFRONTPANEL_HAS16BITHOSTINTERFACE_FN            _okUsbFrontPanel_Has16BitHostInterface = NULL;
OKUSBFRONTPANEL_ISHIGHSPEED_FN                      _okUsbFrontPanel_IsHighSpeed = NULL;
OKUSBFRONTPANEL_GETBOARDMODEL_FN                    _okUsbFrontPanel_GetBoardModel = NULL;
OKUSBFRONTPANEL_WRITEI2C_FN                         _okUsbFrontPanel_WriteI2C = NULL;
OKUSBFRONTPANEL_READI2C_FN                          _okUsbFrontPanel_ReadI2C = NULL;
OKUSBFRONTPANEL_GETDEVICECOUNT_FN                   _okUsbFrontPanel_GetDeviceCount = NULL;
OKUSBFRONTPANEL_GETDEVICELISTMODEL_FN               _okUsbFrontPanel_GetDeviceListModel = NULL;
OKUSBFRONTPANEL_GETDEVICELISTSERIAL_FN              _okUsbFrontPanel_GetDeviceListSerial = NULL;
OKUSBFRONTPANEL_OPENBYSERIAL_FN                     _okUsbFrontPanel_OpenBySerial = NULL;
OKUSBFRONTPANEL_ISOPEN_FN                           _okUsbFrontPanel_IsOpen = NULL;
OKUSBFRONTPANEL_ENABLEASYNCHRONOUSTRANSFERS_FN      _okUsbFrontPanel_EnableAsynchronousTransfers = NULL;
OKUSBFRONTPANEL_SETBTPIPEPOLLINGINTERVAL_FN         _okUsbFrontPanel_SetBTPipePollingInterval = NULL;
OKUSBFRONTPANEL_SETTIMEOUT_FN                       _okUsbFrontPanel_SetTimeout = NULL;
OKUSBFRONTPANEL_GETDEVICEMAJORVERSION_FN            _okUsbFrontPanel_GetDeviceMajorVersion = NULL;
OKUSBFRONTPANEL_GETDEVICEMINORVERSION_FN            _okUsbFrontPanel_GetDeviceMinorVersion = NULL;
OKUSBFRONTPANEL_RESETFPGA_FN                        _okUsbFrontPanel_ResetFPGA = NULL;
OKUSBFRONTPANEL_GETSERIALNUMBER_FN                  _okUsbFrontPanel_GetSerialNumber = NULL;
OKUSBFRONTPANEL_GETDEVICEID_FN                      _okUsbFrontPanel_GetDeviceID = NULL;
OKUSBFRONTPANEL_SETDEVICEID_FN                      _okUsbFrontPanel_SetDeviceID = NULL;
OKUSBFRONTPANEL_CONFIGUREFPGA_FN                    _okUsbFrontPanel_ConfigureFPGA = NULL;
OKUSBFRONTPANEL_CONFIGUREFPGAFROMMEMORY_FN          _okUsbFrontPanel_ConfigureFPGAFromMemory = NULL;
OKUSBFRONTPANEL_GETPLL22150CONFIGURATION_FN         _okUsbFrontPanel_GetPLL22150Configuration = NULL;
OKUSBFRONTPANEL_SETPLL22150CONFIGURATION_FN         _okUsbFrontPanel_SetPLL22150Configuration = NULL;
OKUSBFRONTPANEL_GETEEPROMPLL22150CONFIGURATION_FN   _okUsbFrontPanel_GetEepromPLL22150Configuration = NULL;
OKUSBFRONTPANEL_SETEEPROMPLL22150CONFIGURATION_FN   _okUsbFrontPanel_SetEepromPLL22150Configuration = NULL;
OKUSBFRONTPANEL_GETPLL22393CONFIGURATION_FN         _okUsbFrontPanel_GetPLL22393Configuration = NULL;
OKUSBFRONTPANEL_SETPLL22393CONFIGURATION_FN         _okUsbFrontPanel_SetPLL22393Configuration = NULL;
OKUSBFRONTPANEL_GETEEPROMPLL22393CONFIGURATION_FN   _okUsbFrontPanel_GetEepromPLL22393Configuration = NULL;
OKUSBFRONTPANEL_SETEEPROMPLL22393CONFIGURATION_FN   _okUsbFrontPanel_SetEepromPLL22393Configuration = NULL;
OKUSBFRONTPANEL_LOADDEFAULTPLLCONFIGURATION_FN      _okUsbFrontPanel_LoadDefaultPLLConfiguration = NULL;
OKUSBFRONTPANEL_ISFRONTPANELENABLED_FN              _okUsbFrontPanel_IsFrontPanelEnabled = NULL;
OKUSBFRONTPANEL_ISFRONTPANEL3SUPPORTED_FN           _okUsbFrontPanel_IsFrontPanel3Supported = NULL;
OKUSBFRONTPANEL_UPDATEWIREINS_FN                    _okUsbFrontPanel_UpdateWireIns = NULL;
OKUSBFRONTPANEL_SETWIREINVALUE_FN                   _okUsbFrontPanel_SetWireInValue = NULL;
OKUSBFRONTPANEL_UPDATEWIREOUTS_FN                   _okUsbFrontPanel_UpdateWireOuts = NULL;
OKUSBFRONTPANEL_GETWIREOUTVALUE_FN                  _okUsbFrontPanel_GetWireOutValue = NULL;
OKUSBFRONTPANEL_ACTIVATETRIGGERIN_FN                _okUsbFrontPanel_ActivateTriggerIn = NULL;
OKUSBFRONTPANEL_UPDATETRIGGEROUTS_FN                _okUsbFrontPanel_UpdateTriggerOuts = NULL;
OKUSBFRONTPANEL_ISTRIGGERED_FN                      _okUsbFrontPanel_IsTriggered = NULL;
OKUSBFRONTPANEL_GETLASTTRANSFERLENGTH_FN            _okUsbFrontPanel_GetLastTransferLength = NULL;
OKUSBFRONTPANEL_WRITETOPIPEIN_FN                    _okUsbFrontPanel_WriteToPipeIn = NULL;
OKUSBFRONTPANEL_WRITETOBLOCKPIPEIN_FN               _okUsbFrontPanel_WriteToBlockPipeIn = NULL;
OKUSBFRONTPANEL_READFROMPIPEOUT_FN                  _okUsbFrontPanel_ReadFromPipeOut = NULL;
OKUSBFRONTPANEL_READFROMBLOCKPIPEOUT_FN             _okUsbFrontPanel_ReadFromBlockPipeOut = NULL;


//------------------------------------------------------------------------

/// Returns the version number of the DLL.
const char *
okFrontPanelDLL_GetVersionString()
{
	return (VERSION_STRING);
}


/// Loads the FrontPanel API DLL.  This function returns False if the
/// DLL did not load for some reason, True otherwise.
Bool
okFrontPanelDLL_LoadLib (char *libname)
{
	// Return TRUE if the DLL is already loaded.
	if (hLib)
		return (TRUE);

	if (NULL == libname)
		hLib = dll_load (okLIB_NAME);
	else
		hLib = dll_load (libname);

	if (hLib) {
		_okFrontPanelDLL_GetVersion                   = (OKFRONTPANELDLL_GETVERSION_FN)                    dll_entrypoint (hLib, "okFrontPanelDLL_GetVersion");

		_okPLL22150_Construct                         = (OKPLL22150_CONSTRUCT_FN)                          dll_entrypoint (hLib, "okPLL22150_Construct");
		_okPLL22150_Destruct                          = (OKPLL22150_DESTRUCT_FN)                           dll_entrypoint (hLib, "okPLL22150_Destruct");
		_okPLL22150_SetCrystalLoad                    = (OKPLL22150_SETCRYSTALLOAD_FN)                     dll_entrypoint (hLib, "okPLL22150_SetCrystalLoad");
		_okPLL22150_SetReference                      = (OKPLL22150_SETREFERENCE_FN)                       dll_entrypoint (hLib, "okPLL22150_SetReference");
		_okPLL22150_GetReference                      = (OKPLL22150_GETREFERENCE_FN)                       dll_entrypoint (hLib, "okPLL22150_GetReference");
		_okPLL22150_SetVCOParameters                  = (OKPLL22150_SETVCOPARAMETERS_FN)                   dll_entrypoint (hLib, "okPLL22150_SetVCOParameters");
		_okPLL22150_GetVCOP                           = (OKPLL22150_GETVCOP_FN)                            dll_entrypoint (hLib, "okPLL22150_GetVCOP");
		_okPLL22150_GetVCOQ                           = (OKPLL22150_GETVCOQ_FN)                            dll_entrypoint (hLib, "okPLL22150_GetVCOQ");
		_okPLL22150_GetVCOFrequency                   = (OKPLL22150_GETVCOFREQUENCY_FN)                    dll_entrypoint (hLib, "okPLL22150_GetVCOFrequency");
		_okPLL22150_SetDiv1                           = (OKPLL22150_SETDIV1_FN)                            dll_entrypoint (hLib, "okPLL22150_SetDiv1");
		_okPLL22150_SetDiv2                           = (OKPLL22150_SETDIV2_FN)                            dll_entrypoint (hLib, "okPLL22150_SetDiv2");
		_okPLL22150_GetDiv1Source                     = (OKPLL22150_GETDIV1SOURCE_FN)                      dll_entrypoint (hLib, "okPLL22150_GetDiv1Source");
		_okPLL22150_GetDiv2Source                     = (OKPLL22150_GETDIV2SOURCE_FN)                      dll_entrypoint (hLib, "okPLL22150_GetDiv2Source");
		_okPLL22150_GetDiv1Divider                    = (OKPLL22150_GETDIV1DIVIDER_FN)                     dll_entrypoint (hLib, "okPLL22150_GetDiv1Divider");
		_okPLL22150_GetDiv2Divider                    = (OKPLL22150_GETDIV2DIVIDER_FN)                     dll_entrypoint (hLib, "okPLL22150_GetDiv2Divider");
		_okPLL22150_SetOutputSource                   = (OKPLL22150_SETOUTPUTSOURCE_FN)                    dll_entrypoint (hLib, "okPLL22150_SetOutputSource");
		_okPLL22150_SetOutputEnable                   = (OKPLL22150_SETOUTPUTENABLE_FN)                    dll_entrypoint (hLib, "okPLL22150_SetOutputEnable");
		_okPLL22150_GetOutputSource                   = (OKPLL22150_GETOUTPUTSOURCE_FN)                    dll_entrypoint (hLib, "okPLL22150_GetOutputSource");
		_okPLL22150_GetOutputFrequency                = (OKPLL22150_GETOUTPUTFREQUENCY_FN)                 dll_entrypoint (hLib, "okPLL22150_GetOutputFrequency");
		_okPLL22150_IsOutputEnabled                   = (OKPLL22150_ISOUTPUTENABLED_FN)                    dll_entrypoint (hLib, "okPLL22150_IsOutputEnabled");
		_okPLL22150_InitFromProgrammingInfo           = (OKPLL22150_INITFROMPROGRAMMINGINFO_FN)            dll_entrypoint (hLib, "okPLL22150_InitFromProgrammingInfo");
		_okPLL22150_GetProgrammingInfo                = (OKPLL22150_GETPROGRAMMINGINFO_FN)                 dll_entrypoint (hLib, "okPLL22150_GetProgrammingInfo");

		_okPLL22393_Construct                         = (OKPLL22393_CONSTRUCT_FN)                          dll_entrypoint (hLib, "okPLL22393_Construct");
		_okPLL22393_Destruct                          = (OKPLL22393_DESTRUCT_FN)                           dll_entrypoint (hLib, "okPLL22393_Destruct");
		_okPLL22393_SetCrystalLoad                    = (OKPLL22393_SETCRYSTALLOAD_FN)                     dll_entrypoint (hLib, "okPLL22393_SetCrystalLoad");
		_okPLL22393_SetReference                      = (OKPLL22393_SETREFERENCE_FN)                       dll_entrypoint (hLib, "okPLL22393_SetReference");
		_okPLL22393_GetReference                      = (OKPLL22393_GETREFERENCE_FN)                       dll_entrypoint (hLib, "okPLL22393_GetReference");
		_okPLL22393_SetPLLParameters                  = (OKPLL22393_SETPLLPARAMETERS_FN)                   dll_entrypoint (hLib, "okPLL22393_SetPLLParameters");
		_okPLL22393_SetPLLLF                          = (OKPLL22393_SETPLLLF_FN)                           dll_entrypoint (hLib, "okPLL22393_SetPLLLF");
		_okPLL22393_SetOutputDivider                  = (OKPLL22393_SETOUTPUTDIVIDER_FN)                   dll_entrypoint (hLib, "okPLL22393_SetOutputDivider");
		_okPLL22393_SetOutputSource                   = (OKPLL22393_SETOUTPUTSOURCE_FN)                    dll_entrypoint (hLib, "okPLL22393_SetOutputSource");
		_okPLL22393_SetOutputEnable                   = (OKPLL22393_SETOUTPUTENABLE_FN)                    dll_entrypoint (hLib, "okPLL22393_SetOutputEnable");
		_okPLL22393_GetPLLP                           = (OKPLL22393_GETPLLP_FN)                            dll_entrypoint (hLib, "okPLL22393_GetPLLP");
		_okPLL22393_GetPLLQ                           = (OKPLL22393_GETPLLQ_FN)                            dll_entrypoint (hLib, "okPLL22393_GetPLLQ");
		_okPLL22393_GetPLLFrequency                   = (OKPLL22393_GETPLLFREQUENCY_FN)                    dll_entrypoint (hLib, "okPLL22393_GetPLLFrequency");
		_okPLL22393_GetOutputDivider                  = (OKPLL22393_GETOUTPUTDIVIDER_FN)                   dll_entrypoint (hLib, "okPLL22393_GetOutputDivider");
		_okPLL22393_GetOutputSource                   = (OKPLL22393_GETOUTPUTSOURCE_FN)                    dll_entrypoint (hLib, "okPLL22393_GetOutputSource");
		_okPLL22393_GetOutputFrequency                = (OKPLL22393_GETOUTPUTFREQUENCY_FN)                 dll_entrypoint (hLib, "okPLL22393_GetOutputFrequency");
		_okPLL22393_IsOutputEnabled                   = (OKPLL22393_ISOUTPUTENABLED_FN)                    dll_entrypoint (hLib, "okPLL22393_IsOutputEnabled");
		_okPLL22393_IsPLLEnabled                      = (OKPLL22393_ISPLLENABLED_FN)                       dll_entrypoint (hLib, "okPLL22393_IsPLLEnabled");
		_okPLL22393_InitFromProgrammingInfo           = (OKPLL22393_INITFROMPROGRAMMINGINFO_FN)            dll_entrypoint (hLib, "okPLL22393_InitFromProgrammingInfo");
		_okPLL22393_GetProgrammingInfo                = (OKPLL22393_GETPROGRAMMINGINFO_FN)                 dll_entrypoint (hLib, "okPLL22393_GetProgrammingInfo");

		_okUsbFrontPanel_Construct                         = (OKUSBFRONTPANEL_CONSTRUCT_FN)                          dll_entrypoint (hLib, "okUsbFrontPanel_Construct");
		_okUsbFrontPanel_Destruct                          = (OKUSBFRONTPANEL_DESTRUCT_FN)                           dll_entrypoint (hLib, "okUsbFrontPanel_Destruct");
		_okUsbFrontPanel_Has16BitHostInterface             = (OKUSBFRONTPANEL_HAS16BITHOSTINTERFACE_FN)              dll_entrypoint (hLib, "okUsbFrontPanel_Has16BitHostInterface");
		_okUsbFrontPanel_IsHighSpeed                       = (OKUSBFRONTPANEL_ISHIGHSPEED_FN)                        dll_entrypoint (hLib, "okUsbFrontPanel_IsHighSpeed");
		_okUsbFrontPanel_GetBoardModel                     = (OKUSBFRONTPANEL_GETBOARDMODEL_FN)                      dll_entrypoint (hLib, "okUsbFrontPanel_GetBoardModel");
		_okUsbFrontPanel_WriteI2C                          = (OKUSBFRONTPANEL_WRITEI2C_FN)                           dll_entrypoint (hLib, "okUsbFrontPanel_WriteI2C");
		_okUsbFrontPanel_ReadI2C                           = (OKUSBFRONTPANEL_READI2C_FN)                            dll_entrypoint (hLib, "okUsbFrontPanel_ReadI2C");
		_okUsbFrontPanel_GetDeviceCount                    = (OKUSBFRONTPANEL_GETDEVICECOUNT_FN)                     dll_entrypoint (hLib, "okUsbFrontPanel_GetDeviceCount");
		_okUsbFrontPanel_GetDeviceListModel                = (OKUSBFRONTPANEL_GETDEVICELISTMODEL_FN)                 dll_entrypoint (hLib, "okUsbFrontPanel_GetDeviceListModel");
		_okUsbFrontPanel_GetDeviceListSerial               = (OKUSBFRONTPANEL_GETDEVICELISTSERIAL_FN)                dll_entrypoint (hLib, "okUsbFrontPanel_GetDeviceListSerial");
		_okUsbFrontPanel_OpenBySerial                      = (OKUSBFRONTPANEL_OPENBYSERIAL_FN)                       dll_entrypoint (hLib, "okUsbFrontPanel_OpenBySerial");
		_okUsbFrontPanel_IsOpen                            = (OKUSBFRONTPANEL_ISOPEN_FN)                             dll_entrypoint (hLib, "okUsbFrontPanel_IsOpen");
		_okUsbFrontPanel_SetBTPipePollingInterval          = (OKUSBFRONTPANEL_SETBTPIPEPOLLINGINTERVAL_FN)           dll_entrypoint (hLib, "okUsbFrontPanel_SetBTPipePollingInterval");
		_okUsbFrontPanel_SetTimeout                        = (OKUSBFRONTPANEL_SETTIMEOUT_FN)                         dll_entrypoint (hLib, "okUsbFrontPanel_SetTimeout");
		_okUsbFrontPanel_EnableAsynchronousTransfers       = (OKUSBFRONTPANEL_ENABLEASYNCHRONOUSTRANSFERS_FN)        dll_entrypoint (hLib, "okUsbFrontPanel_EnableAsynchronousTransfers");
		_okUsbFrontPanel_GetDeviceMajorVersion             = (OKUSBFRONTPANEL_GETDEVICEMAJORVERSION_FN)              dll_entrypoint (hLib, "okUsbFrontPanel_GetDeviceMajorVersion");
		_okUsbFrontPanel_GetDeviceMinorVersion             = (OKUSBFRONTPANEL_GETDEVICEMINORVERSION_FN)              dll_entrypoint (hLib, "okUsbFrontPanel_GetDeviceMinorVersion");
		_okUsbFrontPanel_ResetFPGA                         = (OKUSBFRONTPANEL_RESETFPGA_FN)                          dll_entrypoint (hLib, "okUsbFrontPanel_ResetFPGA");
		_okUsbFrontPanel_GetSerialNumber                   = (OKUSBFRONTPANEL_GETSERIALNUMBER_FN)                    dll_entrypoint (hLib, "okUsbFrontPanel_GetSerialNumber");
		_okUsbFrontPanel_GetDeviceID                       = (OKUSBFRONTPANEL_GETDEVICEID_FN)                        dll_entrypoint (hLib, "okUsbFrontPanel_GetDeviceID");
		_okUsbFrontPanel_SetDeviceID                       = (OKUSBFRONTPANEL_SETDEVICEID_FN)                        dll_entrypoint (hLib, "okUsbFrontPanel_SetDeviceID");
		_okUsbFrontPanel_ConfigureFPGA                     = (OKUSBFRONTPANEL_CONFIGUREFPGA_FN)                      dll_entrypoint (hLib, "okUsbFrontPanel_ConfigureFPGA");
		_okUsbFrontPanel_ConfigureFPGAFromMemory           = (OKUSBFRONTPANEL_CONFIGUREFPGAFROMMEMORY_FN)            dll_entrypoint (hLib, "okUsbFrontPanel_ConfigureFPGAFromMemory");
		_okUsbFrontPanel_GetPLL22150Configuration          = (OKUSBFRONTPANEL_GETPLL22150CONFIGURATION_FN)           dll_entrypoint (hLib, "okUsbFrontPanel_GetPLL22150Configuration");
		_okUsbFrontPanel_SetPLL22150Configuration          = (OKUSBFRONTPANEL_SETPLL22150CONFIGURATION_FN)           dll_entrypoint (hLib, "okUsbFrontPanel_SetPLL22150Configuration");
		_okUsbFrontPanel_GetEepromPLL22150Configuration    = (OKUSBFRONTPANEL_GETEEPROMPLL22150CONFIGURATION_FN)     dll_entrypoint (hLib, "okUsbFrontPanel_GetEepromPLL22150Configuration");
		_okUsbFrontPanel_SetEepromPLL22150Configuration    = (OKUSBFRONTPANEL_SETEEPROMPLL22150CONFIGURATION_FN)     dll_entrypoint (hLib, "okUsbFrontPanel_SetEepromPLL22150Configuration");
		_okUsbFrontPanel_GetPLL22393Configuration          = (OKUSBFRONTPANEL_GETPLL22393CONFIGURATION_FN)           dll_entrypoint (hLib, "okUsbFrontPanel_GetPLL22393Configuration");
		_okUsbFrontPanel_SetPLL22393Configuration          = (OKUSBFRONTPANEL_SETPLL22393CONFIGURATION_FN)           dll_entrypoint (hLib, "okUsbFrontPanel_SetPLL22393Configuration");
		_okUsbFrontPanel_GetEepromPLL22393Configuration    = (OKUSBFRONTPANEL_GETEEPROMPLL22393CONFIGURATION_FN)     dll_entrypoint (hLib, "okUsbFrontPanel_GetEepromPLL22393Configuration");
		_okUsbFrontPanel_SetEepromPLL22393Configuration    = (OKUSBFRONTPANEL_SETEEPROMPLL22393CONFIGURATION_FN)     dll_entrypoint (hLib, "okUsbFrontPanel_SetEepromPLL22393Configuration");
		_okUsbFrontPanel_LoadDefaultPLLConfiguration       = (OKUSBFRONTPANEL_LOADDEFAULTPLLCONFIGURATION_FN)        dll_entrypoint (hLib, "okUsbFrontPanel_LoadDefaultPLLConfiguration");
		_okUsbFrontPanel_IsFrontPanelEnabled               = (OKUSBFRONTPANEL_ISFRONTPANELENABLED_FN)                dll_entrypoint (hLib, "okUsbFrontPanel_IsFrontPanelEnabled");
		_okUsbFrontPanel_IsFrontPanel3Supported            = (OKUSBFRONTPANEL_ISFRONTPANEL3SUPPORTED_FN)             dll_entrypoint (hLib, "okUsbFrontPanel_IsFrontPanel3Supported");
		_okUsbFrontPanel_UpdateWireIns                     = (OKUSBFRONTPANEL_UPDATEWIREINS_FN)                      dll_entrypoint (hLib, "okUsbFrontPanel_UpdateWireIns");
		_okUsbFrontPanel_SetWireInValue                    = (OKUSBFRONTPANEL_SETWIREINVALUE_FN)                     dll_entrypoint (hLib, "okUsbFrontPanel_SetWireInValue");
		_okUsbFrontPanel_UpdateWireOuts                    = (OKUSBFRONTPANEL_UPDATEWIREOUTS_FN)                     dll_entrypoint (hLib, "okUsbFrontPanel_UpdateWireOuts");
		_okUsbFrontPanel_GetWireOutValue                   = (OKUSBFRONTPANEL_GETWIREOUTVALUE_FN)                    dll_entrypoint (hLib, "okUsbFrontPanel_GetWireOutValue");
		_okUsbFrontPanel_ActivateTriggerIn                 = (OKUSBFRONTPANEL_ACTIVATETRIGGERIN_FN)                  dll_entrypoint (hLib, "okUsbFrontPanel_ActivateTriggerIn");
		_okUsbFrontPanel_UpdateTriggerOuts                 = (OKUSBFRONTPANEL_UPDATETRIGGEROUTS_FN)                  dll_entrypoint (hLib, "okUsbFrontPanel_UpdateTriggerOuts");
		_okUsbFrontPanel_IsTriggered                       = (OKUSBFRONTPANEL_ISTRIGGERED_FN)                        dll_entrypoint (hLib, "okUsbFrontPanel_IsTriggered");
		_okUsbFrontPanel_GetLastTransferLength             = (OKUSBFRONTPANEL_GETLASTTRANSFERLENGTH_FN)              dll_entrypoint (hLib, "okUsbFrontPanel_GetLastTransferLength");
		_okUsbFrontPanel_WriteToPipeIn                     = (OKUSBFRONTPANEL_WRITETOPIPEIN_FN)                      dll_entrypoint (hLib, "okUsbFrontPanel_WriteToPipeIn");
		_okUsbFrontPanel_WriteToBlockPipeIn                = (OKUSBFRONTPANEL_WRITETOBLOCKPIPEIN_FN)                 dll_entrypoint (hLib, "okUsbFrontPanel_WriteToBlockPipeIn");
		_okUsbFrontPanel_ReadFromPipeOut                   = (OKUSBFRONTPANEL_READFROMPIPEOUT_FN)                    dll_entrypoint (hLib, "okUsbFrontPanel_ReadFromPipeOut");
		_okUsbFrontPanel_ReadFromBlockPipeOut              = (OKUSBFRONTPANEL_READFROMBLOCKPIPEOUT_FN)               dll_entrypoint (hLib, "okUsbFrontPanel_ReadFromBlockPipeOut");
	}

	if (NULL == hLib) {
		return (FALSE);
	}

	return (TRUE);
}


void
okFrontPanelDLL_FreeLib (void)
{
	_okFrontPanelDLL_GetVersion                        = NULL;

	_okUsbFrontPanel_Construct                         = NULL;
	_okUsbFrontPanel_Destruct                          = NULL;
	_okUsbFrontPanel_Has16BitHostInterface             = NULL;
	_okUsbFrontPanel_IsHighSpeed                       = NULL;
	_okUsbFrontPanel_GetBoardModel                     = NULL;
	_okUsbFrontPanel_WriteI2C                          = NULL;
	_okUsbFrontPanel_ReadI2C                           = NULL;
	_okUsbFrontPanel_GetDeviceCount                    = NULL;
	_okUsbFrontPanel_GetDeviceListModel                = NULL;
	_okUsbFrontPanel_GetDeviceListSerial               = NULL;
	_okUsbFrontPanel_OpenBySerial                      = NULL;
	_okUsbFrontPanel_IsOpen                            = NULL;
	_okUsbFrontPanel_SetBTPipePollingInterval          = NULL;
	_okUsbFrontPanel_SetTimeout                        = NULL;
	_okUsbFrontPanel_EnableAsynchronousTransfers       = NULL;
	_okUsbFrontPanel_GetDeviceMajorVersion             = NULL;
	_okUsbFrontPanel_GetDeviceMinorVersion             = NULL;
	_okUsbFrontPanel_ResetFPGA                         = NULL;
	_okUsbFrontPanel_GetSerialNumber                   = NULL;
	_okUsbFrontPanel_GetDeviceID                       = NULL;
	_okUsbFrontPanel_SetDeviceID                       = NULL;
	_okUsbFrontPanel_ConfigureFPGA                     = NULL;
	_okUsbFrontPanel_ConfigureFPGAFromMemory           = NULL;
	_okUsbFrontPanel_GetPLL22150Configuration          = NULL;
	_okUsbFrontPanel_SetPLL22150Configuration          = NULL;
	_okUsbFrontPanel_GetEepromPLL22150Configuration    = NULL;
	_okUsbFrontPanel_SetEepromPLL22150Configuration    = NULL;
	_okUsbFrontPanel_GetPLL22393Configuration          = NULL;
	_okUsbFrontPanel_SetPLL22393Configuration          = NULL;
	_okUsbFrontPanel_GetEepromPLL22393Configuration    = NULL;
	_okUsbFrontPanel_SetEepromPLL22393Configuration    = NULL;
	_okUsbFrontPanel_IsFrontPanelEnabled               = NULL;
	_okUsbFrontPanel_IsFrontPanel3Supported            = NULL;
	_okUsbFrontPanel_UpdateWireIns                     = NULL;
	_okUsbFrontPanel_SetWireInValue                    = NULL;
	_okUsbFrontPanel_UpdateWireOuts                    = NULL;
	_okUsbFrontPanel_GetWireOutValue                   = NULL;
	_okUsbFrontPanel_ActivateTriggerIn                 = NULL;
	_okUsbFrontPanel_UpdateTriggerOuts                 = NULL;
	_okUsbFrontPanel_IsTriggered                       = NULL;
	_okUsbFrontPanel_GetLastTransferLength             = NULL;
	_okUsbFrontPanel_WriteToPipeIn                     = NULL;
	_okUsbFrontPanel_WriteToBlockPipeIn                = NULL;
	_okUsbFrontPanel_ReadFromPipeOut                   = NULL;
	_okUsbFrontPanel_ReadFromBlockPipeOut              = NULL;

	_okPLL22393_Construct                         = NULL;
	_okPLL22393_Destruct                          = NULL;
	_okPLL22393_SetCrystalLoad                    = NULL;
	_okPLL22393_SetReference                      = NULL;
	_okPLL22393_GetReference                      = NULL;
	_okPLL22393_SetPLLParameters                  = NULL;
	_okPLL22393_SetPLLLF                          = NULL;
	_okPLL22393_SetOutputDivider                  = NULL;
	_okPLL22393_SetOutputSource                   = NULL;
	_okPLL22393_SetOutputEnable                   = NULL;
	_okPLL22393_GetPLLP                           = NULL;
	_okPLL22393_GetPLLQ                           = NULL;
	_okPLL22393_GetPLLFrequency                   = NULL;
	_okPLL22393_GetOutputDivider                  = NULL;
	_okPLL22393_GetOutputSource                   = NULL;
	_okPLL22393_GetOutputFrequency                = NULL;
	_okPLL22393_IsOutputEnabled                   = NULL;
	_okPLL22393_IsPLLEnabled                      = NULL;
	_okPLL22393_InitFromProgrammingInfo           = NULL;
	_okPLL22393_GetProgrammingInfo                = NULL;

	_okPLL22150_Construct                         = NULL;
	_okPLL22150_Destruct                          = NULL;
	_okPLL22150_SetCrystalLoad                    = NULL;
	_okPLL22150_SetReference                      = NULL;
	_okPLL22150_GetReference                      = NULL;
	_okPLL22150_SetVCOParameters                  = NULL;
	_okPLL22150_GetVCOP                           = NULL;
	_okPLL22150_GetVCOQ                           = NULL;
	_okPLL22150_GetVCOFrequency                   = NULL;
	_okPLL22150_SetDiv1                           = NULL;
	_okPLL22150_SetDiv2                           = NULL;
	_okPLL22150_GetDiv1Source                     = NULL;
	_okPLL22150_GetDiv2Source                     = NULL;
	_okPLL22150_GetDiv1Divider                    = NULL;
	_okPLL22150_GetDiv2Divider                    = NULL;
	_okPLL22150_SetOutputSource                   = NULL;
	_okPLL22150_SetOutputEnable                   = NULL;
	_okPLL22150_GetOutputSource                   = NULL;
	_okPLL22150_GetOutputFrequency                = NULL;
	_okPLL22150_IsOutputEnabled                   = NULL;
	_okPLL22150_InitFromProgrammingInfo           = NULL;
	_okPLL22150_GetProgrammingInfo                = NULL;

	if (hLib) {
		dll_unload (hLib);
		hLib = NULL;
	}
}


static DLL_EP
dll_entrypoint (DLL *dll, const char *name)
{
#if defined(_WIN32)
	FARPROC proc;
	proc = GetProcAddress ( (HMODULE) dll, (LPCSTR) name);

	if (NULL == proc) {
		printf ("Failed to load %s. Error code %d\n", name, GetLastError());
	}

	return ( (DLL_EP) proc);

#else
	void *handle = (void *) dll;
	DLL_EP ep;
	ep = (DLL_EP) dlsym (handle, name);
	return ( (dlerror() ==0) ? (ep) : ( (DLL_EP) NULL));
#endif
}


static DLL *
dll_load (char *libname)
{
#if defined(_WIN32)
	return ( (DLL *) LoadLibrary (libname));
#else
	DLL *dll;
	dll = dlopen (libname, RTLD_NOW);

	if (!dll)
		printf ("%s\n", (char *) dlerror());

	return (dll);

#endif
}


static void
dll_unload (DLL *dll)
{
#if defined(_WIN32)
	HINSTANCE hInst = (HINSTANCE) dll;
	FreeLibrary (hInst);
#else
	void *handle = (void *) dll;
	dlclose (handle);
#endif
}


//------------------------------------------------------------------------
// Function calls - General
//------------------------------------------------------------------------
okDLLEXPORT void DLL_ENTRY
okFrontPanelDLL_GetVersion (char *date, char *time)
{

	if (_okFrontPanelDLL_GetVersion)
		(*_okFrontPanelDLL_GetVersion) (date, time);
}

//------------------------------------------------------------------------
// Function calls - okCPLL22393
//------------------------------------------------------------------------
okDLLEXPORT okPLL22393_HANDLE DLL_ENTRY
okPLL22393_Construct()
{
	if (_okPLL22393_Construct)
		return ( (*_okPLL22393_Construct) ());

	return (NULL);
}

okDLLEXPORT void DLL_ENTRY
okPLL22393_Destruct (okPLL22393_HANDLE pll)
{
	if (_okPLL22393_Destruct)
		(*_okPLL22393_Destruct) (pll);
}

okDLLEXPORT void DLL_ENTRY
okPLL22393_SetCrystalLoad (okPLL22393_HANDLE pll, double capload)
{
	if (_okPLL22393_SetCrystalLoad)
		(*_okPLL22393_SetCrystalLoad) (pll, capload);
}

okDLLEXPORT void DLL_ENTRY
okPLL22393_SetReference (okPLL22393_HANDLE pll, double freq)
{
	if (_okPLL22393_SetReference)
		(*_okPLL22393_SetReference) (pll, freq);
}

okDLLEXPORT double DLL_ENTRY
okPLL22393_GetReference (okPLL22393_HANDLE pll)
{
	if (_okPLL22393_GetReference)
		return ( (*_okPLL22393_GetReference) (pll));

	return (0.0);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22393_SetPLLParameters (okPLL22393_HANDLE pll, int n, int p, int q, Bool enable)
{
	if (_okPLL22393_SetPLLParameters)
		return ( (*_okPLL22393_SetPLLParameters) (pll, n, p, q, enable));

	return (FALSE);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22393_SetPLLLF (okPLL22393_HANDLE pll, int n, int lf)
{
	if (_okPLL22393_SetPLLLF)
		return ( (*_okPLL22393_SetPLLLF) (pll, n, lf));

	return (FALSE);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22393_SetOutputDivider (okPLL22393_HANDLE pll, int n, int div)
{
	if (_okPLL22393_SetOutputDivider)
		return ( (*_okPLL22393_SetOutputDivider) (pll, n, div));

	return (FALSE);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22393_SetOutputSource (okPLL22393_HANDLE pll, int n, ok_ClockSource_22393 clksrc)
{
	if (_okPLL22393_SetOutputSource)
		return ( (*_okPLL22393_SetOutputSource) (pll, n, clksrc));

	return (FALSE);
}

okDLLEXPORT void DLL_ENTRY
okPLL22393_SetOutputEnable (okPLL22393_HANDLE pll, int n, Bool enable)
{
	if (_okPLL22393_SetOutputEnable)
		(*_okPLL22393_SetOutputEnable) (pll, n, enable);
}

okDLLEXPORT int DLL_ENTRY
okPLL22393_GetPLLP (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_GetPLLP)
		return ( (*_okPLL22393_GetPLLP) (pll, n));

	return (0);
}

okDLLEXPORT int DLL_ENTRY
okPLL22393_GetPLLQ (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_GetPLLQ)
		return ( (*_okPLL22393_GetPLLQ) (pll, n));

	return (0);
}

okDLLEXPORT double DLL_ENTRY
okPLL22393_GetPLLFrequency (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_GetPLLFrequency)
		return ( (*_okPLL22393_GetPLLFrequency) (pll, n));

	return (0.0);
}

okDLLEXPORT int DLL_ENTRY
okPLL22393_GetOutputDivider (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_GetOutputDivider)
		return ( (*_okPLL22393_GetOutputDivider) (pll, n));

	return (0);
}

okDLLEXPORT ok_ClockSource_22393 DLL_ENTRY
okPLL22393_GetOutputSource (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_GetOutputSource)
		return ( (*_okPLL22393_GetOutputSource) (pll, n));

	return (ok_ClkSrc22393_Ref);
}

okDLLEXPORT double DLL_ENTRY
okPLL22393_GetOutputFrequency (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_GetOutputFrequency)
		return ( (*_okPLL22393_GetOutputFrequency) (pll, n));

	return (0.0);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22393_IsOutputEnabled (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_IsOutputEnabled)
		return ( (*_okPLL22393_IsOutputEnabled) (pll, n));

	return (FALSE);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22393_IsPLLEnabled (okPLL22393_HANDLE pll, int n)
{
	if (_okPLL22393_IsPLLEnabled)
		return ( (*_okPLL22393_IsPLLEnabled) (pll, n));

	return (FALSE);
}

okDLLEXPORT void DLL_ENTRY
okPLL22393_InitFromProgrammingInfo (okPLL22393_HANDLE pll, unsigned char *buf)
{
	if (_okPLL22393_InitFromProgrammingInfo)
		(*_okPLL22393_InitFromProgrammingInfo) (pll, buf);
}

okDLLEXPORT void DLL_ENTRY
okPLL22393_GetProgrammingInfo (okPLL22393_HANDLE pll, unsigned char *buf)
{
	if (_okPLL22393_GetProgrammingInfo)
		(*_okPLL22393_GetProgrammingInfo) (pll, buf);
}


//------------------------------------------------------------------------
// Function calls - okCPLL22150
//------------------------------------------------------------------------
okDLLEXPORT okPLL22150_HANDLE DLL_ENTRY
okPLL22150_Construct()
{
	if (_okPLL22150_Construct)
		return ( (*_okPLL22150_Construct) ());

	return (NULL);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_Destruct (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_Destruct)
		(*_okPLL22150_Destruct) (pll);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_SetCrystalLoad (okPLL22150_HANDLE pll, double capload)
{
	if (_okPLL22150_SetCrystalLoad)
		(*_okPLL22150_SetCrystalLoad) (pll, capload);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_SetReference (okPLL22150_HANDLE pll, double freq, Bool extosc)
{
	if (_okPLL22150_SetReference)
		(*_okPLL22150_SetReference) (pll, freq, extosc);
}

okDLLEXPORT double DLL_ENTRY
okPLL22150_GetReference (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetReference)
		return ( (*_okPLL22150_GetReference) (pll));

	return (0.0);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22150_SetVCOParameters (okPLL22150_HANDLE pll, int p, int q)
{
	if (_okPLL22150_SetVCOParameters)
		return ( (*_okPLL22150_SetVCOParameters) (pll, p, q));

	return (FALSE);
}

okDLLEXPORT int DLL_ENTRY
okPLL22150_GetVCOP (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetVCOP)
		return ( (*_okPLL22150_GetVCOP) (pll));

	return (0);
}

okDLLEXPORT int DLL_ENTRY
okPLL22150_GetVCOQ (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetVCOQ)
		return ( (*_okPLL22150_GetVCOQ) (pll));

	return (0);
}

okDLLEXPORT double DLL_ENTRY
okPLL22150_GetVCOFrequency (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetVCOFrequency)
		return ( (*_okPLL22150_GetVCOFrequency) (pll));

	return (0.0);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_SetDiv1 (okPLL22150_HANDLE pll, ok_DividerSource divsrc, int n)
{
	if (_okPLL22150_SetDiv1)
		(*_okPLL22150_SetDiv1) (pll, divsrc, n);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_SetDiv2 (okPLL22150_HANDLE pll, ok_DividerSource divsrc, int n)
{
	if (_okPLL22150_SetDiv2)
		(*_okPLL22150_SetDiv2) (pll, divsrc, n);
}

okDLLEXPORT ok_DividerSource  DLL_ENTRY
okPLL22150_GetDiv1Source (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetDiv1Source)
		return ( (*_okPLL22150_GetDiv1Source) (pll));

	return (ok_DivSrc_Ref);
}

okDLLEXPORT ok_DividerSource DLL_ENTRY
okPLL22150_GetDiv2Source (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetDiv2Source)
		return ( (*_okPLL22150_GetDiv2Source) (pll));

	return (ok_DivSrc_Ref);
}

okDLLEXPORT int DLL_ENTRY
okPLL22150_GetDiv1Divider (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetDiv1Divider)
		return ( (*_okPLL22150_GetDiv1Divider) (pll));

	return (0);
}

okDLLEXPORT int DLL_ENTRY
okPLL22150_GetDiv2Divider (okPLL22150_HANDLE pll)
{
	if (_okPLL22150_GetDiv2Divider)
		return ( (*_okPLL22150_GetDiv2Divider) (pll));

	return (0);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_SetOutputSource (okPLL22150_HANDLE pll, int output, ok_ClockSource_22150 clksrc)
{
	if (_okPLL22150_SetOutputSource)
		(*_okPLL22150_SetOutputSource) (pll, output, clksrc);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_SetOutputEnable (okPLL22150_HANDLE pll, int output, Bool enable)
{
	if (_okPLL22150_SetOutputEnable)
		(*_okPLL22150_SetOutputEnable) (pll, output, enable);
}

okDLLEXPORT ok_ClockSource_22150 DLL_ENTRY
okPLL22150_GetOutputSource (okPLL22150_HANDLE pll, int output)
{
	if (_okPLL22150_GetOutputSource)
		return ( (*_okPLL22150_GetOutputSource) (pll, output));

	return (ok_ClkSrc22150_Ref);
}

okDLLEXPORT double DLL_ENTRY
okPLL22150_GetOutputFrequency (okPLL22150_HANDLE pll, int output)
{
	if (_okPLL22150_GetOutputFrequency)
		return ( (*_okPLL22150_GetOutputFrequency) (pll, output));

	return (0.0);
}

okDLLEXPORT Bool DLL_ENTRY
okPLL22150_IsOutputEnabled (okPLL22150_HANDLE pll, int output)
{
	if (_okPLL22150_IsOutputEnabled)
		return ( (*_okPLL22150_IsOutputEnabled) (pll, output));

	return (FALSE);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_InitFromProgrammingInfo (okPLL22150_HANDLE pll, unsigned char *buf)
{
	if (_okPLL22150_InitFromProgrammingInfo)
		(*_okPLL22150_InitFromProgrammingInfo) (pll, buf);
}

okDLLEXPORT void DLL_ENTRY
okPLL22150_GetProgrammingInfo (okPLL22150_HANDLE pll, unsigned char *buf)
{
	if (_okPLL22150_GetProgrammingInfo)
		(*_okPLL22150_GetProgrammingInfo) (pll, buf);
}


//------------------------------------------------------------------------
// Function calls - okCFrontPanel
//------------------------------------------------------------------------
okDLLEXPORT okUSBFRONTPANEL_HANDLE DLL_ENTRY
okUsbFrontPanel_Construct()
{
	if (_okUsbFrontPanel_Construct)
		return ( (*_okUsbFrontPanel_Construct) ());

	return (NULL);
}


okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_Destruct (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_Destruct)
		(*_okUsbFrontPanel_Destruct) (hnd);
}


okDLLEXPORT Bool DLL_ENTRY
okUsbFrontPanel_Has16BitHostInterface (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_Has16BitHostInterface)
		return ( (*_okUsbFrontPanel_Has16BitHostInterface) (hnd));

	return (FALSE);
}


okDLLEXPORT Bool DLL_ENTRY
okUsbFrontPanel_IsHighSpeed (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_IsHighSpeed)
		return ( (*_okUsbFrontPanel_IsHighSpeed) (hnd));

	return (FALSE);
}


okDLLEXPORT ok_BoardModel DLL_ENTRY
okUsbFrontPanel_GetBoardModel (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_GetBoardModel)
		return ( (*_okUsbFrontPanel_GetBoardModel) (hnd));

	return (ok_brdUnknown);
}


okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_WriteI2C (okUSBFRONTPANEL_HANDLE hnd, const int addr, int length, unsigned char *data)
{
	if (_okUsbFrontPanel_WriteI2C)
		return ( (*_okUsbFrontPanel_WriteI2C) (hnd, addr, length, data));

	return (ok_UnsupportedFeature);
}


okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_ReadI2C (okUSBFRONTPANEL_HANDLE hnd, const int addr, int length, unsigned char *data)
{
	if (_okUsbFrontPanel_ReadI2C)
		return ( (*_okUsbFrontPanel_ReadI2C) (hnd, addr, length, data));

	return (ok_UnsupportedFeature);
}


okDLLEXPORT int DLL_ENTRY
okUsbFrontPanel_GetDeviceCount (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_GetDeviceCount)
		return ( (*_okUsbFrontPanel_GetDeviceCount) (hnd));

	return (0);
}


okDLLEXPORT ok_BoardModel DLL_ENTRY
okUsbFrontPanel_GetDeviceListModel (okUSBFRONTPANEL_HANDLE hnd, int num)
{
	if (_okUsbFrontPanel_GetDeviceListModel)
		return ( (*_okUsbFrontPanel_GetDeviceListModel) (hnd, num));

	return (ok_brdUnknown);
}


okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_GetDeviceListSerial (okUSBFRONTPANEL_HANDLE hnd, int num, char *serial, int len)
{
	if (_okUsbFrontPanel_GetDeviceListSerial)
		(*_okUsbFrontPanel_GetDeviceListSerial) (hnd, num, serial, len);
}


okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_OpenBySerial (okUSBFRONTPANEL_HANDLE hnd, const char *serial)
{
	if (_okUsbFrontPanel_OpenBySerial)
		return ( (*_okUsbFrontPanel_OpenBySerial) (hnd, serial));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT Bool DLL_ENTRY
okUsbFrontPanel_IsOpen (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_IsOpen)
		return ( (*_okUsbFrontPanel_IsOpen) (hnd));

	return (FALSE);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_EnableAsynchronousTransfers (okUSBFRONTPANEL_HANDLE hnd, Bool enable)
{
	if (_okUsbFrontPanel_EnableAsynchronousTransfers)
		(*_okUsbFrontPanel_EnableAsynchronousTransfers) (hnd, enable);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_SetBTPipePollingInterval (okUSBFRONTPANEL_HANDLE hnd, int interval)
{
	if (_okUsbFrontPanel_SetBTPipePollingInterval)
		return ( (*_okUsbFrontPanel_SetBTPipePollingInterval) (hnd, interval));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_SetTimeout (okUSBFRONTPANEL_HANDLE hnd, int timeout)
{
	if (_okUsbFrontPanel_SetTimeout)
		(*_okUsbFrontPanel_SetTimeout) (hnd, timeout);
}

okDLLEXPORT int DLL_ENTRY
okUsbFrontPanel_GetDeviceMajorVersion (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_GetDeviceMajorVersion)
		return ( (*_okUsbFrontPanel_GetDeviceMajorVersion) (hnd));

	return (0);
}

okDLLEXPORT int DLL_ENTRY
okUsbFrontPanel_GetDeviceMinorVersion (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_GetDeviceMinorVersion)
		return ( (*_okUsbFrontPanel_GetDeviceMinorVersion) (hnd));

	return (0);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_ResetFPGA (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_ResetFPGA)
		return ( (*_okUsbFrontPanel_ResetFPGA) (hnd));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_GetSerialNumber (okUSBFRONTPANEL_HANDLE hnd, char *buf)
{
	if (_okUsbFrontPanel_GetSerialNumber)
		(*_okUsbFrontPanel_GetSerialNumber) (hnd, buf);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_GetDeviceID (okUSBFRONTPANEL_HANDLE hnd, char *buf)
{
	if (_okUsbFrontPanel_GetDeviceID)
		(*_okUsbFrontPanel_GetDeviceID) (hnd, buf);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_SetDeviceID (okUSBFRONTPANEL_HANDLE hnd, const char *strID)
{
	if (_okUsbFrontPanel_SetDeviceID)
		(*_okUsbFrontPanel_SetDeviceID) (hnd, strID);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_ConfigureFPGA (okUSBFRONTPANEL_HANDLE hnd, const char *strFilename)
{
	if (_okUsbFrontPanel_ConfigureFPGA)
		return ( (*_okUsbFrontPanel_ConfigureFPGA) (hnd, strFilename));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_ConfigureFPGAFromMemory (okUSBFRONTPANEL_HANDLE hnd, unsigned char *data, unsigned long length)
{
	if (_okUsbFrontPanel_ConfigureFPGAFromMemory)
		return ( (*_okUsbFrontPanel_ConfigureFPGAFromMemory) (hnd, data, length));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_GetPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll)
{
	if (_okUsbFrontPanel_GetPLL22150Configuration)
		return ( (*_okUsbFrontPanel_GetPLL22150Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_SetPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll)
{
	if (_okUsbFrontPanel_SetPLL22150Configuration)
		return ( (*_okUsbFrontPanel_SetPLL22150Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_GetEepromPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll)
{
	if (_okUsbFrontPanel_GetEepromPLL22150Configuration)
		return ( (*_okUsbFrontPanel_GetEepromPLL22150Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_SetEepromPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll)
{
	if (_okUsbFrontPanel_SetEepromPLL22150Configuration)
		return ( (*_okUsbFrontPanel_SetEepromPLL22150Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_GetPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll)
{
	if (_okUsbFrontPanel_GetPLL22393Configuration)
		return ( (*_okUsbFrontPanel_GetPLL22393Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_SetPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll)
{
	if (_okUsbFrontPanel_SetPLL22393Configuration)
		return ( (*_okUsbFrontPanel_SetPLL22393Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_GetEepromPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll)
{
	if (_okUsbFrontPanel_GetEepromPLL22393Configuration)
		return ( (*_okUsbFrontPanel_GetEepromPLL22393Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_SetEepromPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll)
{
	if (_okUsbFrontPanel_SetEepromPLL22393Configuration)
		return ( (*_okUsbFrontPanel_SetEepromPLL22393Configuration) (hnd, pll));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_LoadDefaultPLLConfiguration (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_LoadDefaultPLLConfiguration)
		return ( (*_okUsbFrontPanel_LoadDefaultPLLConfiguration) (hnd));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT Bool DLL_ENTRY
okUsbFrontPanel_IsFrontPanelEnabled (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_IsFrontPanelEnabled)
		return ( (*_okUsbFrontPanel_IsFrontPanelEnabled) (hnd));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT Bool DLL_ENTRY
okUsbFrontPanel_IsFrontPanel3Supported (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_IsFrontPanel3Supported)
		return ( (*_okUsbFrontPanel_IsFrontPanel3Supported) (hnd));

	return (FALSE);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_UpdateWireIns (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_UpdateWireIns)
		(*_okUsbFrontPanel_UpdateWireIns) (hnd);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_SetWireInValue (okUSBFRONTPANEL_HANDLE hnd, int ep, int val, int mask)
{
	if (_okUsbFrontPanel_SetWireInValue)
		return ( (*_okUsbFrontPanel_SetWireInValue) (hnd, ep, val, mask));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_UpdateWireOuts (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_UpdateWireOuts)
		(*_okUsbFrontPanel_UpdateWireOuts) (hnd);
}

okDLLEXPORT int DLL_ENTRY
okUsbFrontPanel_GetWireOutValue (okUSBFRONTPANEL_HANDLE hnd, int epAddr)
{
	if (_okUsbFrontPanel_GetWireOutValue)
		return ( (*_okUsbFrontPanel_GetWireOutValue) (hnd, epAddr));

	return (0);
}

okDLLEXPORT ok_ErrorCode DLL_ENTRY
okUsbFrontPanel_ActivateTriggerIn (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int bit)
{
	if (_okUsbFrontPanel_ActivateTriggerIn)
		return ( (*_okUsbFrontPanel_ActivateTriggerIn) (hnd, epAddr, bit));

	return (ok_UnsupportedFeature);
}

okDLLEXPORT void DLL_ENTRY
okUsbFrontPanel_UpdateTriggerOuts (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_UpdateTriggerOuts)
		(*_okUsbFrontPanel_UpdateTriggerOuts) (hnd);
}

okDLLEXPORT Bool DLL_ENTRY
okUsbFrontPanel_IsTriggered (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int mask)
{
	if (_okUsbFrontPanel_IsTriggered)
		return ( (*_okUsbFrontPanel_IsTriggered) (hnd, epAddr, mask));

	return (FALSE);
}

okDLLEXPORT long DLL_ENTRY
okUsbFrontPanel_GetLastTransferLength (okUSBFRONTPANEL_HANDLE hnd)
{
	if (_okUsbFrontPanel_GetLastTransferLength)
		return ( (*_okUsbFrontPanel_GetLastTransferLength) (hnd));

	return (0);
}

okDLLEXPORT long DLL_ENTRY
okUsbFrontPanel_WriteToPipeIn (okUSBFRONTPANEL_HANDLE hnd, int epAddr, long length, unsigned char *data)
{
	if (_okUsbFrontPanel_WriteToPipeIn)
		return ( (*_okUsbFrontPanel_WriteToPipeIn) (hnd, epAddr, length, data));

	return (0);
}

okDLLEXPORT long DLL_ENTRY
okUsbFrontPanel_WriteToBlockPipeIn (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int blocksize, long length, unsigned char *data)
{
	if (_okUsbFrontPanel_WriteToBlockPipeIn)
		return ( (*_okUsbFrontPanel_WriteToBlockPipeIn) (hnd, epAddr, blocksize, length, data));

	return (0);
}

okDLLEXPORT long DLL_ENTRY
okUsbFrontPanel_ReadFromPipeOut (okUSBFRONTPANEL_HANDLE hnd, int epAddr, long length, unsigned char *data)
{
	if (_okUsbFrontPanel_ReadFromPipeOut)
		return ( (*_okUsbFrontPanel_ReadFromPipeOut) (hnd, epAddr, length, data));

	return (0);
}

okDLLEXPORT long DLL_ENTRY
okUsbFrontPanel_ReadFromBlockPipeOut (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int blocksize, long length, unsigned char *data)
{
	if (_okUsbFrontPanel_ReadFromBlockPipeOut)
		return ( (*_okUsbFrontPanel_ReadFromBlockPipeOut) (hnd, epAddr, blocksize, length, data));

	return (0);
}


