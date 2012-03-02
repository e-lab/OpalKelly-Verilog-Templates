///------------------------------------------------------------------------
// okFrontPanelDLL.h
//
// This is the header file for C/C++ compilation of the FrontPanel DLL
// import library.  This file must be included within any C/C++ source
// which references the FrontPanel DLL methods.
//
//------------------------------------------------------------------------
// Copyright (c) 2005-2009 Opal Kelly Incorporated
// $Rev: 640 $ $Date: 2009-02-26 20:55:49 -0800 (Thu, 26 Feb 2009) $
//------------------------------------------------------------------------

#ifndef __okFrontPanelDLL_h__
#define __okFrontPanelDLL_h__

#if defined(_WIN32)
#include <windows.h>
#elif defined(LINUX)
#elif defined(MACOSX)
#endif

// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler. All files within this DLL are compiled with the FRONTPANELDLL_EXPORTS
// symbol defined on the command line.  This symbol should not be defined on any project
// that uses this DLL.
#if defined(_WIN32)
#if defined(FRONTPANELDLL_EXPORTS)
#define okDLLEXPORT __declspec(dllexport)
#define DLL_ENTRY   __stdcall
#else
#define okDLLEXPORT
#define DLL_ENTRY   __stdcall
#endif
#elif defined(LINUX) || defined(MACOSX)
#define okDLLEXPORT
#define DLL_ENTRY
#endif


typedef void (* DLL_EP) (void);

#ifdef __cplusplus
#include <string>
extern "C"
{
#endif // __cplusplus

	typedef void* okPLL22150_HANDLE;
	typedef void* okPLL22393_HANDLE;
	typedef void* okUSBFRONTPANEL_HANDLE;
	typedef int Bool;

#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

	typedef enum {
		ok_ClkSrc22150_Ref=0,
		ok_ClkSrc22150_Div1ByN=1,
		ok_ClkSrc22150_Div1By2=2,
		ok_ClkSrc22150_Div1By3=3,
		ok_ClkSrc22150_Div2ByN=4,
		ok_ClkSrc22150_Div2By2=5,
		ok_ClkSrc22150_Div2By4=6
	} ok_ClockSource_22150;

	typedef enum {
		ok_ClkSrc22393_Ref=0,
		ok_ClkSrc22393_PLL0_0=2,
		ok_ClkSrc22393_PLL0_180=3,
		ok_ClkSrc22393_PLL1_0=4,
		ok_ClkSrc22393_PLL1_180=5,
		ok_ClkSrc22393_PLL2_0=6,
		ok_ClkSrc22393_PLL2_180=7
	} ok_ClockSource_22393;

	typedef enum {
		ok_DivSrc_Ref = 0,
		ok_DivSrc_VCO = 1
	} ok_DividerSource;

	typedef enum {
		ok_brdUnknown = 0,
		ok_brdXEM3001v1 = 1,
		ok_brdXEM3001v2 = 2,
		ok_brdXEM3010 = 3,
		ok_brdXEM3005 = 4,
		ok_brdXEM3001CL = 5,
		ok_brdXEM3020 = 6,
		ok_brdXEM3050 = 7,
		ok_brdXEM9002 = 8,
		ok_brdXEM3001RB = 9,
		ok_brdXEM5010 = 10
	} ok_BoardModel;

	typedef enum {
		ok_NoError                    = 0,
		ok_Failed                     = -1,
		ok_Timeout                    = -2,
		ok_DoneNotHigh                = -3,
		ok_TransferError              = -4,
		ok_CommunicationError         = -5,
		ok_InvalidBitstream           = -6,
		ok_FileError                  = -7,
		ok_DeviceNotOpen              = -8,
		ok_InvalidEndpoint            = -9,
		ok_InvalidBlockSize           = -10,
		ok_I2CRestrictedAddress       = -11,
		ok_I2CBitError                = -12,
		ok_I2CNack                    = -13,
		ok_I2CUnknownStatus           = -14,
		ok_UnsupportedFeature         = -15
	} ok_ErrorCode;

//
// Define the LoadLib and FreeLib methods for the IMPORT side.
//
#ifndef FRONTPANELDLL_EXPORTS
	Bool okFrontPanelDLL_LoadLib (char *libname);
	void okFrontPanelDLL_FreeLib (void);
#endif

//
// General
//
	okDLLEXPORT void DLL_ENTRY okFrontPanelDLL_GetVersion (char *date, char *time);

//
// okPLL22393
//
	okDLLEXPORT okPLL22393_HANDLE DLL_ENTRY okPLL22393_Construct();
	okDLLEXPORT void DLL_ENTRY okPLL22393_Destruct (okPLL22393_HANDLE pll);
	okDLLEXPORT void DLL_ENTRY okPLL22393_SetCrystalLoad (okPLL22393_HANDLE pll, double capload);
	okDLLEXPORT void DLL_ENTRY okPLL22393_SetReference (okPLL22393_HANDLE pll, double freq);
	okDLLEXPORT double DLL_ENTRY okPLL22393_GetReference (okPLL22393_HANDLE pll);
	okDLLEXPORT Bool DLL_ENTRY okPLL22393_SetPLLParameters (okPLL22393_HANDLE pll, int n, int p, int q, Bool enable);
	okDLLEXPORT Bool DLL_ENTRY okPLL22393_SetPLLLF (okPLL22393_HANDLE pll, int n, int lf);
	okDLLEXPORT Bool DLL_ENTRY okPLL22393_SetOutputDivider (okPLL22393_HANDLE pll, int n, int div);
	okDLLEXPORT Bool DLL_ENTRY okPLL22393_SetOutputSource (okPLL22393_HANDLE pll, int n, ok_ClockSource_22393 clksrc);
	okDLLEXPORT void DLL_ENTRY okPLL22393_SetOutputEnable (okPLL22393_HANDLE pll, int n, Bool enable);
	okDLLEXPORT int DLL_ENTRY okPLL22393_GetPLLP (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT int DLL_ENTRY okPLL22393_GetPLLQ (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT double DLL_ENTRY okPLL22393_GetPLLFrequency (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT int DLL_ENTRY okPLL22393_GetOutputDivider (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT ok_ClockSource_22393 DLL_ENTRY okPLL22393_GetOutputSource (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT double DLL_ENTRY okPLL22393_GetOutputFrequency (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT Bool DLL_ENTRY okPLL22393_IsOutputEnabled (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT Bool DLL_ENTRY okPLL22393_IsPLLEnabled (okPLL22393_HANDLE pll, int n);
	okDLLEXPORT void DLL_ENTRY okPLL22393_InitFromProgrammingInfo (okPLL22393_HANDLE pll, unsigned char *buf);
	okDLLEXPORT void DLL_ENTRY okPLL22393_GetProgrammingInfo (okPLL22393_HANDLE pll, unsigned char *buf);


//
// okPLL22150
//
	okDLLEXPORT okPLL22150_HANDLE DLL_ENTRY okPLL22150_Construct();
	okDLLEXPORT void DLL_ENTRY okPLL22150_Destruct (okPLL22150_HANDLE pll);
	okDLLEXPORT void DLL_ENTRY okPLL22150_SetCrystalLoad (okPLL22150_HANDLE pll, double capload);
	okDLLEXPORT void DLL_ENTRY okPLL22150_SetReference (okPLL22150_HANDLE pll, double freq, Bool extosc);
	okDLLEXPORT double DLL_ENTRY okPLL22150_GetReference (okPLL22150_HANDLE pll);
	okDLLEXPORT Bool DLL_ENTRY okPLL22150_SetVCOParameters (okPLL22150_HANDLE pll, int p, int q);
	okDLLEXPORT int DLL_ENTRY okPLL22150_GetVCOP (okPLL22150_HANDLE pll);
	okDLLEXPORT int DLL_ENTRY okPLL22150_GetVCOQ (okPLL22150_HANDLE pll);
	okDLLEXPORT double DLL_ENTRY okPLL22150_GetVCOFrequency (okPLL22150_HANDLE pll);
	okDLLEXPORT void DLL_ENTRY okPLL22150_SetDiv1 (okPLL22150_HANDLE pll, ok_DividerSource divsrc, int n);
	okDLLEXPORT void DLL_ENTRY okPLL22150_SetDiv2 (okPLL22150_HANDLE pll, ok_DividerSource divsrc, int n);
	okDLLEXPORT ok_DividerSource DLL_ENTRY okPLL22150_GetDiv1Source (okPLL22150_HANDLE pll);
	okDLLEXPORT ok_DividerSource DLL_ENTRY okPLL22150_GetDiv2Source (okPLL22150_HANDLE pll);
	okDLLEXPORT int DLL_ENTRY okPLL22150_GetDiv1Divider (okPLL22150_HANDLE pll);
	okDLLEXPORT int DLL_ENTRY okPLL22150_GetDiv2Divider (okPLL22150_HANDLE pll);
	okDLLEXPORT void DLL_ENTRY okPLL22150_SetOutputSource (okPLL22150_HANDLE pll, int output, ok_ClockSource_22150 clksrc);
	okDLLEXPORT void DLL_ENTRY okPLL22150_SetOutputEnable (okPLL22150_HANDLE pll, int output, Bool enable);
	okDLLEXPORT ok_ClockSource_22150 DLL_ENTRY okPLL22150_GetOutputSource (okPLL22150_HANDLE pll, int output);
	okDLLEXPORT double DLL_ENTRY okPLL22150_GetOutputFrequency (okPLL22150_HANDLE pll, int output);
	okDLLEXPORT Bool DLL_ENTRY okPLL22150_IsOutputEnabled (okPLL22150_HANDLE pll, int output);
	okDLLEXPORT void DLL_ENTRY okPLL22150_InitFromProgrammingInfo (okPLL22150_HANDLE pll, unsigned char *buf);
	okDLLEXPORT void DLL_ENTRY okPLL22150_GetProgrammingInfo (okPLL22150_HANDLE pll, unsigned char *buf);


//
// okUsbFrontPanel
//
	okDLLEXPORT okUSBFRONTPANEL_HANDLE DLL_ENTRY okUsbFrontPanel_Construct();
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_Destruct (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_WriteI2C (okUSBFRONTPANEL_HANDLE hnd, const int addr, int length, unsigned char *data);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_ReadI2C (okUSBFRONTPANEL_HANDLE hnd, const int addr, int length, unsigned char *data);
	okDLLEXPORT Bool DLL_ENTRY okUsbFrontPanel_Has16BitHostInterface (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT Bool DLL_ENTRY okUsbFrontPanel_IsHighSpeed (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT ok_BoardModel DLL_ENTRY okUsbFrontPanel_GetBoardModel (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT int DLL_ENTRY okUsbFrontPanel_GetDeviceCount (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT ok_BoardModel DLL_ENTRY okUsbFrontPanel_GetDeviceListModel (okUSBFRONTPANEL_HANDLE hnd, int num);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_GetDeviceListSerial (okUSBFRONTPANEL_HANDLE hnd, int num, char *buf, int len);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_OpenBySerial (okUSBFRONTPANEL_HANDLE hnd, const char *serial);
	okDLLEXPORT Bool DLL_ENTRY okUsbFrontPanel_IsOpen (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_EnableAsynchronousTransfers (okUSBFRONTPANEL_HANDLE hnd, Bool enable);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_SetBTPipePollingInterval (okUSBFRONTPANEL_HANDLE hnd, int interval);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_SetTimeout (okUSBFRONTPANEL_HANDLE hnd, int timeout);
	okDLLEXPORT int DLL_ENTRY okUsbFrontPanel_GetDeviceMajorVersion (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT int DLL_ENTRY okUsbFrontPanel_GetDeviceMinorVersion (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_ResetFPGA (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_GetSerialNumber (okUSBFRONTPANEL_HANDLE hnd, char *buf);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_GetDeviceID (okUSBFRONTPANEL_HANDLE hnd, char *buf);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_SetDeviceID (okUSBFRONTPANEL_HANDLE hnd, const char *strID);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_ConfigureFPGA (okUSBFRONTPANEL_HANDLE hnd, const char *strFilename);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_ConfigureFPGAFromMemory (okUSBFRONTPANEL_HANDLE hnd, unsigned char *data, unsigned long length);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_GetPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_SetPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_GetEepromPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_SetEepromPLL22150Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22150_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_GetPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_SetPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_GetEepromPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_SetEepromPLL22393Configuration (okUSBFRONTPANEL_HANDLE hnd, okPLL22393_HANDLE pll);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_LoadDefaultPLLConfiguration (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT Bool DLL_ENTRY okUsbFrontPanel_IsFrontPanelEnabled (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT Bool DLL_ENTRY okUsbFrontPanel_IsFrontPanel3Supported (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_UpdateWireIns (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_SetWireInValue (okUSBFRONTPANEL_HANDLE hnd, int ep, int val, int mask);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_UpdateWireOuts (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT int DLL_ENTRY okUsbFrontPanel_GetWireOutValue (okUSBFRONTPANEL_HANDLE hnd, int epAddr);
	okDLLEXPORT ok_ErrorCode DLL_ENTRY okUsbFrontPanel_ActivateTriggerIn (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int bit);
	okDLLEXPORT void DLL_ENTRY okUsbFrontPanel_UpdateTriggerOuts (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT Bool DLL_ENTRY okUsbFrontPanel_IsTriggered (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int mask);
	okDLLEXPORT long DLL_ENTRY okUsbFrontPanel_GetLastTransferLength (okUSBFRONTPANEL_HANDLE hnd);
	okDLLEXPORT long DLL_ENTRY okUsbFrontPanel_WriteToPipeIn (okUSBFRONTPANEL_HANDLE hnd, int epAddr, long length, unsigned char *data);
	okDLLEXPORT long DLL_ENTRY okUsbFrontPanel_ReadFromPipeOut (okUSBFRONTPANEL_HANDLE hnd, int epAddr, long length, unsigned char *data);
	okDLLEXPORT long DLL_ENTRY okUsbFrontPanel_WriteToBlockPipeIn (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int blockSize, long length, unsigned char *data);
	okDLLEXPORT long DLL_ENTRY okUsbFrontPanel_ReadFromBlockPipeOut (okUSBFRONTPANEL_HANDLE hnd, int epAddr, int blockSize, long length, unsigned char *data);


#ifdef __cplusplus
#if !defined(FRONTPANELDLL_EXPORTS)
//------------------------------------------------------------------------
// okCPLL22150 C++ wrapper class
//------------------------------------------------------------------------

	class okCPLL22150
	{
	public:
		okPLL22150_HANDLE h;
		enum ClockSource {
			ClkSrc_Ref=0,
			ClkSrc_Div1ByN=1,
			ClkSrc_Div1By2=2,
			ClkSrc_Div1By3=3,
			ClkSrc_Div2ByN=4,
			ClkSrc_Div2By2=5,
			ClkSrc_Div2By4=6
		};

		enum DividerSource {
			DivSrc_Ref = 0,
			DivSrc_VCO = 1
		};
	private:
		bool to_bool (Bool x);
		Bool from_bool (bool x);
	public:
		okCPLL22150();
		void SetCrystalLoad (double capload);
		void SetReference (double freq, bool extosc);
		double GetReference();
		bool SetVCOParameters (int p, int q);
		int GetVCOP();
		int GetVCOQ();
		double GetVCOFrequency();
		void SetDiv1 (DividerSource divsrc, int n);
		void SetDiv2 (DividerSource divsrc, int n);
		DividerSource GetDiv1Source();
		DividerSource GetDiv2Source();
		int GetDiv1Divider();
		int GetDiv2Divider();
		void SetOutputSource (int output, ClockSource clksrc);
		void SetOutputEnable (int output, bool enable);
		ClockSource GetOutputSource (int output);
		double GetOutputFrequency (int output);
		bool IsOutputEnabled (int output);
		void InitFromProgrammingInfo (unsigned char *buf);
		void GetProgrammingInfo (unsigned char *buf);
	};

//------------------------------------------------------------------------
// okCPLL22150 C++ wrapper class
//------------------------------------------------------------------------

	class okCPLL22393
	{
	public:
		okPLL22393_HANDLE h;
		enum ClockSource {
			ClkSrc_Ref=0,
			ClkSrc_PLL0_0=2,
			ClkSrc_PLL0_180=3,
			ClkSrc_PLL1_0=4,
			ClkSrc_PLL1_180=5,
			ClkSrc_PLL2_0=6,
			ClkSrc_PLL2_180=7
		};
	private:
		bool to_bool (Bool x);
		Bool from_bool (bool x);
	public:
		okCPLL22393();
		void SetCrystalLoad (double capload);
		void SetReference (double freq);
		double GetReference();
		bool SetPLLParameters (int n, int p, int q, bool enable=true);
		bool SetPLLLF (int n, int lf);
		bool SetOutputDivider (int n, int div);
		bool SetOutputSource (int n, ClockSource clksrc);
		void SetOutputEnable (int n, bool enable);
		int GetPLLP (int n);
		int GetPLLQ (int n);
		double GetPLLFrequency (int n);
		int GetOutputDivider (int n);
		ClockSource GetOutputSource (int n);
		double GetOutputFrequency (int n);
		bool IsOutputEnabled (int n);
		bool IsPLLEnabled (int n);
		void InitFromProgrammingInfo (unsigned char *buf);
		void GetProgrammingInfo (unsigned char *buf);
	};

//------------------------------------------------------------------------
// okCFrontPanel C++ wrapper class
//------------------------------------------------------------------------

	class okCUsbFrontPanel
	{
	public:
		okUSBFRONTPANEL_HANDLE h;
		enum BoardModel {
			brdUnknown=0,
			brdXEM3001v1=1,
			brdXEM3001v2=2,
			brdXEM3010=3,
			brdXEM3005=4,
			brdXEM3001CL=5,
			brdXEM3020=6,
			brdXEM3050=7,
			brdXEM9002=8,
			brdXEM3001RB=9,
			brdXEM5010=10
		};
		enum ErrorCode {
			NoError                    = 0,
			Failed                     = -1,
			Timeout                    = -2,
			DoneNotHigh                = -3,
			TransferError              = -4,
			CommunicationError         = -5,
			InvalidBitstream           = -6,
			FileError                  = -7,
			DeviceNotOpen              = -8,
			InvalidEndpoint            = -9,
			InvalidBlockSize           = -10,
			I2CRestrictedAddress       = -11,
			I2CBitError                = -12,
			I2CNack                    = -13,
			I2CUnknownStatus           = -14,
			UnsupportedFeature         = -15
		};
	private:
		bool to_bool (Bool x);
		Bool from_bool (bool x);
	public:
		okCUsbFrontPanel();
		~okCUsbFrontPanel();
		bool Has16BitHostInterface();
		BoardModel GetBoardModel();
		int GetDeviceCount();
		BoardModel GetDeviceListModel (int num);
		std::string GetDeviceListSerial (int num);
		void EnableAsynchronousTransfers (bool enable);
		ErrorCode OpenBySerial (std::string str = "");
		bool IsOpen();
		int GetDeviceMajorVersion();
		int GetDeviceMinorVersion();
		std::string GetSerialNumber();
		std::string GetDeviceID();
		void SetDeviceID (const std::string str);
		ErrorCode SetBTPipePollingInterval (int interval);
		void SetTimeout (int timeout);
		ErrorCode ResetFPGA();
		ErrorCode ConfigureFPGAFromMemory (unsigned char *data, const unsigned long length,
		                                   void (*callback) (int, int, void *) = NULL, void *arg = NULL);
		ErrorCode ConfigureFPGA (const std::string strFilename,
		                         void (*callback) (int, int, void *) = NULL, void *arg = NULL);
		ErrorCode WriteI2C (const int addr, int length, unsigned char *data);
		ErrorCode ReadI2C (const int addr, int length, unsigned char *data);
		ErrorCode GetPLL22150Configuration (okCPLL22150& pll);
		ErrorCode SetPLL22150Configuration (okCPLL22150& pll);
		ErrorCode GetEepromPLL22150Configuration (okCPLL22150& pll);
		ErrorCode SetEepromPLL22150Configuration (okCPLL22150& pll);
		ErrorCode GetPLL22393Configuration (okCPLL22393& pll);
		ErrorCode SetPLL22393Configuration (okCPLL22393& pll);
		ErrorCode GetEepromPLL22393Configuration (okCPLL22393& pll);
		ErrorCode SetEepromPLL22393Configuration (okCPLL22393& pll);
		ErrorCode LoadDefaultPLLConfiguration();
		bool IsHighSpeed();
		bool IsFrontPanelEnabled();
		bool IsFrontPanel3Supported();
		void UpdateWireIns();
		ErrorCode SetWireInValue (int ep, int val, int mask = 0xffff);
		void UpdateWireOuts();
		int GetWireOutValue (int epAddr);
		ErrorCode ActivateTriggerIn (int epAddr, int bit);
		void UpdateTriggerOuts();
		bool IsTriggered (int epAddr, int mask);
		long GetLastTransferLength();
		long WriteToPipeIn (int epAddr, long length, unsigned char *data);
		long ReadFromPipeOut (int epAddr, long length, unsigned char *data);
		long WriteToBlockPipeIn (int epAddr, int blockSize, long length, unsigned char *data);
		long ReadFromBlockPipeOut (int epAddr, int blockSize, long length, unsigned char *data);
	};

#endif // !defined(FRONTPANELDLL_EXPORTS)

}

#endif // __cplusplus

#endif // __okFrontPanelDLL_h__
