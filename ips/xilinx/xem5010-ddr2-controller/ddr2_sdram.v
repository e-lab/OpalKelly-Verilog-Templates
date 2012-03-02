//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This text/file contains proprietary, confidential
// information of Xilinx, Inc., is distributed under license
// from Xilinx, Inc., and may be used, copied and/or
// disclosed only pursuant to the terms of a valid license
// agreement with Xilinx, Inc. Xilinx hereby grants you a
// license to use this text/file solely for design, simulation,
// implementation and creation of design files limited
// to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and
// immediately terminates your license unless covered by
// a separate agreement.
//
// Xilinx is providing this design, code, or information
// "as-is" solely for use in developing programs and
// solutions for Xilinx devices, with no obligation on the
// part of Xilinx to provide support. By providing this design,
// code, or information as one possible implementation of
// this feature, application or standard, Xilinx is making no
// representation that this implementation is free from any
// claims of infringement. You are responsible for
// obtaining any rights you may require for your implementation.
// Xilinx expressly disclaims any warranty whatsoever with
// respect to the adequacy of the implementation, including
// but not limited to any warranties or representations that this
// implementation is free from claims of infringement, implied
// warranties of merchantability or fitness for a particular
// purpose.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications is
// expressly prohibited.
//
// Any modifications that are made to the Source Code are
// done at the user’s sole risk and will be unsupported.
//
// Copyright (c) 2006-2007 Xilinx, Inc. All rights reserved.
//
// This copyright and support notice must be retained as part
// of this text at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 2.3
//  \   \         Application: MIG
//  /   /         Filename: ddr2_sdram.v
// /___/   /\     Date Last Modified: $Date: 2008/07/09 12:33:12 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Top-level  module. This module serves both as an example, 
//   and allows the user to synthesize a self-contained design, 
//   which they can use to test their hardware.
//   In addition to the memory controller, the module instantiates:
//     1. Clock generation/distribution, reset logic
//     2. IDELAY control block
//     3. Synthesizable testbench - used to model user's backend logic
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

(* X_CORE_INFO = "mig_v2_3_ddr2_sdram_v5, Coregen 10.1.02" , CORE_GENERATION_INFO = "ddr2_sdram_v5,mig_v2_3,{component_name=ddr2_sdram, C0_BANK_WIDTH=2, C0_CKE_WIDTH=1, C0_CLK_WIDTH=1, C0_COL_WIDTH=10, C0_CS_NUM=1, C0_CS_WIDTH=1, C0_DM_WIDTH=2, C0_DQ_WIDTH=16, C0_DQ_PER_DQS=8, C0_DQS_WIDTH=2, C0_ODT_WIDTH=1, C0_ROW_WIDTH=13, C0_ADDITIVE_LAT=0, C0_BURST_LEN=4, C0_BURST_TYPE=0, C0_CAS_LAT=4, C0_ECC_ENABLE=0, C0_MULTI_BANK_EN=1, C0_TWO_T_TIME_EN=0, C0_ODT_TYPE=1, C0_REDUCE_DRV=1, C0_REG_ENABLE=0, C0_TREFI_NS=7800, C0_TRAS=40000, C0_TRCD=15000, C0_TRFC=105000, C0_TRP=15000, C0_TRTP=7500, C0_TWR=15000, C0_TWTR=7500, DDR2_CLK_PERIOD=3750, RST_ACT_LOW=1,C1_BANK_WIDTH=2, C1_CKE_WIDTH=1, C1_CLK_WIDTH=1, C1_COL_WIDTH=10, C1_CS_NUM=1, C1_CS_WIDTH=1, C1_DM_WIDTH=2, C1_DQ_WIDTH=16, C1_DQ_PER_DQS=8, C1_DQS_WIDTH=2, C1_ODT_WIDTH=1, C1_ROW_WIDTH=13, C1_ADDITIVE_LAT=0, C1_BURST_LEN=4, C1_BURST_TYPE=0, C1_CAS_LAT=4, C1_ECC_ENABLE=0, C1_MULTI_BANK_EN=1, C1_TWO_T_TIME_EN=0, C1_ODT_TYPE=1, C1_REDUCE_DRV=1, C1_REG_ENABLE=0, C1_TREFI_NS=7800, C1_TRAS=40000, C1_TRCD=15000, C1_TRFC=105000, C1_TRP=15000, C1_TRTP=7500, C1_TWR=15000, C1_TWTR=7500, DDR2_CLK_PERIOD=3750, RST_ACT_LOW=1}" *)
module ddr2_sdram #
  (
   parameter C0_DDR2_BANK_WIDTH      = 2,       
                                       // # of memory bank addr bits.
   parameter C0_DDR2_CKE_WIDTH       = 1,       
                                       // # of memory clock enable outputs.
   parameter C0_DDR2_CLK_WIDTH       = 1,       
                                       // # of clock outputs.
   parameter C0_DDR2_COL_WIDTH       = 10,       
                                       // # of memory column bits.
   parameter C0_DDR2_CS_NUM          = 1,       
                                       // # of separate memory chip selects.
   parameter C0_DDR2_CS_WIDTH        = 1,       
                                       // # of total memory chip selects.
   parameter C0_DDR2_CS_BITS         = 0,       
                                       // set to log2(CS_NUM) (rounded up).
   parameter C0_DDR2_DM_WIDTH        = 2,       
                                       // # of data mask bits.
   parameter C0_DDR2_DQ_WIDTH        = 16,       
                                       // # of data width.
   parameter C0_DDR2_DQ_PER_DQS      = 8,       
                                       // # of DQ data bits per strobe.
   parameter C0_DDR2_DQS_WIDTH       = 2,       
                                       // # of DQS strobes.
   parameter C0_DDR2_DQ_BITS         = 4,       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   parameter C0_DDR2_DQS_BITS        = 1,       
                                       // set to log2(DQS_WIDTH).
   parameter C0_DDR2_ODT_WIDTH       = 1,       
                                       // # of memory on-die term enables.
   parameter C0_DDR2_ROW_WIDTH       = 13,       
                                       // # of memory row and # of addr bits.
   parameter C0_DDR2_ADDITIVE_LAT    = 0,       
                                       // additive write latency.
   parameter C0_DDR2_BURST_LEN       = 4,       
                                       // burst length (in double words).
   parameter C0_DDR2_BURST_TYPE      = 0,       
                                       // burst type (=0 seq; =1 interleaved).
   parameter C0_DDR2_CAS_LAT         = 4,       
                                       // CAS latency.
   parameter C0_DDR2_ECC_ENABLE      = 0,       
                                       // enable ECC (=1 enable).
   parameter C0_DDR2_APPDATA_WIDTH   = 32,       
                                       // # of usr read/write data bus bits.
   parameter C0_DDR2_MULTI_BANK_EN   = 1,       
                                       // Keeps multiple banks open. (= 1 enable).
   parameter C0_DDR2_TWO_T_TIME_EN   = 0,       
                                       // 2t timing for unbuffered dimms.
   parameter C0_DDR2_ODT_TYPE        = 1,       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   parameter C0_DDR2_REDUCE_DRV      = 1,       
                                       // reduced strength mem I/O (=1 yes).
   parameter C0_DDR2_REG_ENABLE      = 0,       
                                       // registered addr/ctrl (=1 yes).
   parameter C0_DDR2_TREFI_NS        = 7800,       
                                       // auto refresh interval (ns).
   parameter C0_DDR2_TRAS            = 40000,       
                                       // active->precharge delay.
   parameter C0_DDR2_TRCD            = 15000,       
                                       // active->read/write delay.
   parameter C0_DDR2_TRFC            = 105000,       
                                       // refresh->refresh, refresh->active delay.
   parameter C0_DDR2_TRP             = 15000,       
                                       // precharge->command delay.
   parameter C0_DDR2_TRTP            = 7500,       
                                       // read->precharge delay.
   parameter C0_DDR2_TWR             = 15000,       
                                       // used to determine write->precharge.
   parameter C0_DDR2_TWTR            = 7500,       
                                       // write->read delay.
   parameter HIGH_PERFORMANCE_MODE   = "TRUE",       
                              // # = TRUE, the IODELAY performance mode is set
                              // to high.
                              // # = FALSE, the IODELAY performance mode is set
                              // to low.
   parameter C0_DDR2_SIM_ONLY        = 0,       
                                       // = 1 to skip SDRAM power up delay.
   parameter C0_DDR2_DEBUG_EN        = 0,       
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
   parameter DDR2_CLK_PERIOD         = 3750,       
                                       // Core/Memory clock period (in ps).
   parameter C0_DDR2_DQS_IO_COL      = 4'b1010,       
                                       // I/O column location of DQS groups
                                       // (=0, left; =1 center, =2 right).
   parameter C0_DDR2_DQ_IO_MS        = 16'b10100101_10100101,       
                                       // Master/Slave location of DQ I/O (=0 slave).
   parameter CLK_TYPE                = "DIFFERENTIAL",       
                                       // # = "DIFFERENTIAL " ->; Differential input clocks ,
                                       // # = "SINGLE_ENDED" -> Single ended input clocks.
   parameter DDR2_DLL_FREQ_MODE      = "HIGH",       
                                       // DCM Frequency range.
   parameter RST_ACT_LOW             = 1,       
                                       // =1 for active low reset, =0 for active high.
   parameter C1_DDR2_BANK_WIDTH      = 2,       
                                       // # of memory bank addr bits.
   parameter C1_DDR2_CKE_WIDTH       = 1,       
                                       // # of memory clock enable outputs.
   parameter C1_DDR2_CLK_WIDTH       = 1,       
                                       // # of clock outputs.
   parameter C1_DDR2_COL_WIDTH       = 10,       
                                       // # of memory column bits.
   parameter C1_DDR2_CS_NUM          = 1,       
                                       // # of separate memory chip selects.
   parameter C1_DDR2_CS_WIDTH        = 1,       
                                       // # of total memory chip selects.
   parameter C1_DDR2_CS_BITS         = 0,       
                                       // set to log2(CS_NUM) (rounded up).
   parameter C1_DDR2_DM_WIDTH        = 2,       
                                       // # of data mask bits.
   parameter C1_DDR2_DQ_WIDTH        = 16,       
                                       // # of data width.
   parameter C1_DDR2_DQ_PER_DQS      = 8,       
                                       // # of DQ data bits per strobe.
   parameter C1_DDR2_DQS_WIDTH       = 2,       
                                       // # of DQS strobes.
   parameter C1_DDR2_DQ_BITS         = 4,       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   parameter C1_DDR2_DQS_BITS        = 1,       
                                       // set to log2(DQS_WIDTH).
   parameter C1_DDR2_ODT_WIDTH       = 1,       
                                       // # of memory on-die term enables.
   parameter C1_DDR2_ROW_WIDTH       = 13,       
                                       // # of memory row and # of addr bits.
   parameter C1_DDR2_ADDITIVE_LAT    = 0,       
                                       // additive write latency.
   parameter C1_DDR2_BURST_LEN       = 4,       
                                       // burst length (in double words).
   parameter C1_DDR2_BURST_TYPE      = 0,       
                                       // burst type (=0 seq; =1 interleaved).
   parameter C1_DDR2_CAS_LAT         = 4,       
                                       // CAS latency.
   parameter C1_DDR2_ECC_ENABLE      = 0,       
                                       // enable ECC (=1 enable).
   parameter C1_DDR2_APPDATA_WIDTH   = 32,       
                                       // # of usr read/write data bus bits.
   parameter C1_DDR2_MULTI_BANK_EN   = 1,       
                                       // Keeps multiple banks open. (= 1 enable).
   parameter C1_DDR2_TWO_T_TIME_EN   = 0,       
                                       // 2t timing for unbuffered dimms.
   parameter C1_DDR2_ODT_TYPE        = 1,       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   parameter C1_DDR2_REDUCE_DRV      = 1,       
                                       // reduced strength mem I/O (=1 yes).
   parameter C1_DDR2_REG_ENABLE      = 0,       
                                       // registered addr/ctrl (=1 yes).
   parameter C1_DDR2_TREFI_NS        = 7800,       
                                       // auto refresh interval (ns).
   parameter C1_DDR2_TRAS            = 40000,       
                                       // active->precharge delay.
   parameter C1_DDR2_TRCD            = 15000,       
                                       // active->read/write delay.
   parameter C1_DDR2_TRFC            = 105000,       
                                       // refresh->refresh, refresh->active delay.
   parameter C1_DDR2_TRP             = 15000,       
                                       // precharge->command delay.
   parameter C1_DDR2_TRTP            = 7500,       
                                       // read->precharge delay.
   parameter C1_DDR2_TWR             = 15000,       
                                       // used to determine write->precharge.
   parameter C1_DDR2_TWTR            = 7500,       
                                       // write->read delay.
   parameter C1_DDR2_SIM_ONLY        = 0,       
                                       // = 1 to skip SDRAM power up delay.
   parameter C1_DDR2_DEBUG_EN        = 0,       
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
   parameter C1_DDR2_DQS_IO_COL      = 4'b0000,       
                                       // I/O column location of DQS groups
                                       // (=0, left; =1 center, =2 right).
   parameter C1_DDR2_DQ_IO_MS        = 16'b10100101_10100101        
                                       // Master/Slave location of DQ I/O (=0 slave).
   )
  (
   inout  [C0_DDR2_DQ_WIDTH-1:0]               c0_ddr2_dq,
   output [C0_DDR2_ROW_WIDTH-1:0]              c0_ddr2_a,
   output [C0_DDR2_BANK_WIDTH-1:0]             c0_ddr2_ba,
   output                                      c0_ddr2_ras_n,
   output                                      c0_ddr2_cas_n,
   output                                      c0_ddr2_we_n,
   output [C0_DDR2_CS_WIDTH-1:0]               c0_ddr2_cs_n,
   output [C0_DDR2_ODT_WIDTH-1:0]              c0_ddr2_odt,
   output [C0_DDR2_CKE_WIDTH-1:0]              c0_ddr2_cke,
   output [C0_DDR2_DM_WIDTH-1:0]               c0_ddr2_dm,
   input                                       sys_clk_p,
   input                                       sys_clk_n,
   input                                       clk200_p,
   input                                       clk200_n,
   input                                       sys_rst_n,
   output                                      c0_phy_init_done,
   output                                      c0_error,
   inout  [C0_DDR2_DQS_WIDTH-1:0]              c0_ddr2_dqs,
   inout  [C0_DDR2_DQS_WIDTH-1:0]              c0_ddr2_dqs_n,
   output [C0_DDR2_CLK_WIDTH-1:0]              c0_ddr2_ck,
   output [C0_DDR2_CLK_WIDTH-1:0]              c0_ddr2_ck_n,
   inout  [C1_DDR2_DQ_WIDTH-1:0]               c1_ddr2_dq,
   output [C1_DDR2_ROW_WIDTH-1:0]              c1_ddr2_a,
   output [C1_DDR2_BANK_WIDTH-1:0]             c1_ddr2_ba,
   output                                      c1_ddr2_ras_n,
   output                                      c1_ddr2_cas_n,
   output                                      c1_ddr2_we_n,
   output [C1_DDR2_CS_WIDTH-1:0]               c1_ddr2_cs_n,
   output [C1_DDR2_ODT_WIDTH-1:0]              c1_ddr2_odt,
   output [C1_DDR2_CKE_WIDTH-1:0]              c1_ddr2_cke,
   output [C1_DDR2_DM_WIDTH-1:0]               c1_ddr2_dm,
   output                                      c1_phy_init_done,
   output                                      c1_error,
   inout  [C1_DDR2_DQS_WIDTH-1:0]              c1_ddr2_dqs,
   inout  [C1_DDR2_DQS_WIDTH-1:0]              c1_ddr2_dqs_n,
   output [C1_DDR2_CLK_WIDTH-1:0]              c1_ddr2_ck,
   output [C1_DDR2_CLK_WIDTH-1:0]              c1_ddr2_ck_n
   );

  /////////////////////////////////////////////////////////////////////////////
  // The following parameter "IDELAYCTRL_NUM" indicates the number of
  // IDELAYCTRLs that are LOCed for the design. The IDELAYCTRL LOCs are
  // provided in the UCF file of par folder. MIG provides the parameter value
  // and the LOCs in the UCF file based on the selected Data Read banks for
  // the design. You must not alter this value unless it is needed. If you
  // modify this value, you should make sure that the value of "IDELAYCTRL_NUM"
  // and IDELAYCTRL LOCs in UCF file are same and are relavent to the Data Read
  // banks used.
  /////////////////////////////////////////////////////////////////////////////

  localparam IDELAYCTRL_NUM = 2;



localparam [C0_DDR2_DQ_BITS-1:0] C0_DQ_ZEROS = {C0_DDR2_DQ_BITS{1'b0}};
localparam [C0_DDR2_DQS_BITS:0] C0_DQS_ZEROS = {C0_DDR2_DQS_BITS{1'b0}};
localparam [C1_DDR2_DQ_BITS-1:0] C1_DQ_ZEROS = {C1_DDR2_DQ_BITS{1'b0}};
localparam [C1_DDR2_DQS_BITS:0] C1_DQS_ZEROS = {C1_DDR2_DQS_BITS{1'b0}};

  wire                              sys_clk;
  wire                              idly_clk_200;
  wire                              c0_error_cmp;
  wire                              rst0;
  wire                              rst90;
  wire                              rstdiv0;
  wire                              rst200;
  wire                              clk0;
  wire                              clk90;
  wire                              clkdiv0;
  wire                              clk200;
  wire                              idelay_ctrl_rdy;
  wire                              c0_app_wdf_afull;
  wire                              c0_app_af_afull;
  wire                              c0_rd_data_valid;
  wire                              c0_app_wdf_wren;
  wire                              c0_app_af_wren;
  wire  [30:0]                      c0_app_af_addr;
  wire  [2:0]                       c0_app_af_cmd;
  wire  [(C0_DDR2_APPDATA_WIDTH)-1:0] c0_rd_data_fifo_out;
  wire  [(C0_DDR2_APPDATA_WIDTH)-1:0] c0_app_wdf_data;
  wire  [(C0_DDR2_APPDATA_WIDTH/8)-1:0] c0_app_wdf_mask_data;
  wire                              c1_error_cmp;
  wire                              c1_app_wdf_afull;
  wire                              c1_app_af_afull;
  wire                              c1_rd_data_valid;
  wire                              c1_app_wdf_wren;
  wire                              c1_app_af_wren;
  wire  [30:0]                      c1_app_af_addr;
  wire  [2:0]                       c1_app_af_cmd;
  wire  [(C1_DDR2_APPDATA_WIDTH)-1:0] c1_rd_data_fifo_out;
  wire  [(C1_DDR2_APPDATA_WIDTH)-1:0] c1_app_wdf_data;
  wire  [(C1_DDR2_APPDATA_WIDTH/8)-1:0] c1_app_wdf_mask_data;

    // Debug signals (optional use)

  //***********************************
  // PHY Debug Port demo
  //***********************************
  wire [35:0]                        cs_control0;
  wire [35:0]                        cs_control1;
  wire [35:0]                        cs_control2;
  wire [35:0]                        cs_control3;
  wire [191:0]                       vio0_in;
  wire [95:0]                        vio1_in;
  wire [99:0]                        vio2_in;
  wire [31:0]                        vio3_out;



  //***************************************************************************


  assign sys_clk = 1'b0;
  assign idly_clk_200 = 1'b0;

   ddr2_idelay_ctrl #
   (
    .IDELAYCTRL_NUM         (IDELAYCTRL_NUM)
   )
   u_ddr2_idelay_ctrl
   (
   .rst200                 (rst200),
   .clk200                 (clk200),
   .idelay_ctrl_rdy        (idelay_ctrl_rdy)
   );

 ddr2_infrastructure #
 (
   .CLK_PERIOD             (DDR2_CLK_PERIOD),
   .CLK_TYPE               (CLK_TYPE),
   .DLL_FREQ_MODE          (DDR2_DLL_FREQ_MODE),
   .RST_ACT_LOW            (RST_ACT_LOW)
   )
u_ddr2_infrastructure
 (
   .sys_clk_p              (sys_clk_p),
   .sys_clk_n              (sys_clk_n),
   .sys_clk                (sys_clk),
   .clk200_p               (clk200_p),
   .clk200_n               (clk200_n),
   .idly_clk_200           (idly_clk_200),
   .sys_rst_n              (sys_rst_n),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .rst200                 (rst200),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .clk200                 (clk200),
   .idelay_ctrl_rdy        (idelay_ctrl_rdy)
   );

 ddr2_top #
 (
   .BANK_WIDTH             (C0_DDR2_BANK_WIDTH),
   .CKE_WIDTH              (C0_DDR2_CKE_WIDTH),
   .CLK_WIDTH              (C0_DDR2_CLK_WIDTH),
   .COL_WIDTH              (C0_DDR2_COL_WIDTH),
   .CS_NUM                 (C0_DDR2_CS_NUM),
   .CS_WIDTH               (C0_DDR2_CS_WIDTH),
   .CS_BITS                (C0_DDR2_CS_BITS),
   .DM_WIDTH               (C0_DDR2_DM_WIDTH),
   .DQ_WIDTH               (C0_DDR2_DQ_WIDTH),
   .DQ_PER_DQS             (C0_DDR2_DQ_PER_DQS),
   .DQS_WIDTH              (C0_DDR2_DQS_WIDTH),
   .DQ_BITS                (C0_DDR2_DQ_BITS),
   .DQS_BITS               (C0_DDR2_DQS_BITS),
   .ODT_WIDTH              (C0_DDR2_ODT_WIDTH),
   .ROW_WIDTH              (C0_DDR2_ROW_WIDTH),
   .ADDITIVE_LAT           (C0_DDR2_ADDITIVE_LAT),
   .BURST_LEN              (C0_DDR2_BURST_LEN),
   .BURST_TYPE             (C0_DDR2_BURST_TYPE),
   .CAS_LAT                (C0_DDR2_CAS_LAT),
   .ECC_ENABLE             (C0_DDR2_ECC_ENABLE),
   .APPDATA_WIDTH          (C0_DDR2_APPDATA_WIDTH),
   .MULTI_BANK_EN          (C0_DDR2_MULTI_BANK_EN),
   .TWO_T_TIME_EN          (C0_DDR2_TWO_T_TIME_EN),
   .ODT_TYPE               (C0_DDR2_ODT_TYPE),
   .REDUCE_DRV             (C0_DDR2_REDUCE_DRV),
   .REG_ENABLE             (C0_DDR2_REG_ENABLE),
   .TREFI_NS               (C0_DDR2_TREFI_NS),
   .TRAS                   (C0_DDR2_TRAS),
   .TRCD                   (C0_DDR2_TRCD),
   .TRFC                   (C0_DDR2_TRFC),
   .TRP                    (C0_DDR2_TRP),
   .TRTP                   (C0_DDR2_TRTP),
   .TWR                    (C0_DDR2_TWR),
   .TWTR                   (C0_DDR2_TWTR),
   .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
   .SIM_ONLY               (C0_DDR2_SIM_ONLY),
   .DEBUG_EN               (C0_DDR2_DEBUG_EN),
   .CLK_PERIOD             (DDR2_CLK_PERIOD),
   .DQS_IO_COL             (C0_DDR2_DQS_IO_COL),
   .DQ_IO_MS               (C0_DDR2_DQ_IO_MS),
   .USE_DM_PORT            (1)
   )
u_ddr2_top_0
(
   .ddr2_dq                (c0_ddr2_dq),
   .ddr2_a                 (c0_ddr2_a),
   .ddr2_ba                (c0_ddr2_ba),
   .ddr2_ras_n             (c0_ddr2_ras_n),
   .ddr2_cas_n             (c0_ddr2_cas_n),
   .ddr2_we_n              (c0_ddr2_we_n),
   .ddr2_cs_n              (c0_ddr2_cs_n),
   .ddr2_odt               (c0_ddr2_odt),
   .ddr2_cke               (c0_ddr2_cke),
   .ddr2_dm                (c0_ddr2_dm),
   .phy_init_done          (c0_phy_init_done),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .app_wdf_afull          (c0_app_wdf_afull),
   .app_af_afull           (c0_app_af_afull),
   .rd_data_valid          (c0_rd_data_valid),
   .app_wdf_wren           (c0_app_wdf_wren),
   .app_af_wren            (c0_app_af_wren),
   .app_af_addr            (c0_app_af_addr),
   .app_af_cmd             (c0_app_af_cmd),
   .rd_data_fifo_out       (c0_rd_data_fifo_out),
   .app_wdf_data           (c0_app_wdf_data),
   .app_wdf_mask_data      (c0_app_wdf_mask_data),
   .ddr2_dqs               (c0_ddr2_dqs),
   .ddr2_dqs_n             (c0_ddr2_dqs_n),
   .ddr2_ck                (c0_ddr2_ck),
   .rd_ecc_error           (),
   .ddr2_ck_n              (c0_ddr2_ck_n),

   .dbg_calib_done         (),
   .dbg_calib_err          (),
   .dbg_calib_dq_tap_cnt   (),
   .dbg_calib_dqs_tap_cnt  (),
   .dbg_calib_gate_tap_cnt  (),
   .dbg_calib_rd_data_sel  (),
   .dbg_calib_rden_dly     (),
   .dbg_calib_gate_dly     (),
   .dbg_idel_up_all        (1'b0),
   .dbg_idel_down_all      (1'b0),
   .dbg_idel_up_dq         (1'b0),
   .dbg_idel_down_dq       (1'b0),
   .dbg_idel_up_dqs        (1'b0),
   .dbg_idel_down_dqs      (1'b0),
   .dbg_idel_up_gate       (1'b0),
   .dbg_idel_down_gate     (1'b0),
   .dbg_sel_idel_dq        (C0_DQ_ZEROS),
   .dbg_sel_all_idel_dq    (1'b0),
   .dbg_sel_idel_dqs       (C0_DQS_ZEROS),
   .dbg_sel_all_idel_dqs   (1'b0),
   .dbg_sel_idel_gate      (C0_DQS_ZEROS),
   .dbg_sel_all_idel_gate  (1'b0)
   );
ddr2_top #
 (
   .BANK_WIDTH             (C1_DDR2_BANK_WIDTH),
   .CKE_WIDTH              (C1_DDR2_CKE_WIDTH),
   .CLK_WIDTH              (C1_DDR2_CLK_WIDTH),
   .COL_WIDTH              (C1_DDR2_COL_WIDTH),
   .CS_NUM                 (C1_DDR2_CS_NUM),
   .CS_WIDTH               (C1_DDR2_CS_WIDTH),
   .CS_BITS                (C1_DDR2_CS_BITS),
   .DM_WIDTH               (C1_DDR2_DM_WIDTH),
   .DQ_WIDTH               (C1_DDR2_DQ_WIDTH),
   .DQ_PER_DQS             (C1_DDR2_DQ_PER_DQS),
   .DQS_WIDTH              (C1_DDR2_DQS_WIDTH),
   .DQ_BITS                (C1_DDR2_DQ_BITS),
   .DQS_BITS               (C1_DDR2_DQS_BITS),
   .ODT_WIDTH              (C1_DDR2_ODT_WIDTH),
   .ROW_WIDTH              (C1_DDR2_ROW_WIDTH),
   .ADDITIVE_LAT           (C1_DDR2_ADDITIVE_LAT),
   .BURST_LEN              (C1_DDR2_BURST_LEN),
   .BURST_TYPE             (C1_DDR2_BURST_TYPE),
   .CAS_LAT                (C1_DDR2_CAS_LAT),
   .ECC_ENABLE             (C1_DDR2_ECC_ENABLE),
   .APPDATA_WIDTH          (C1_DDR2_APPDATA_WIDTH),
   .MULTI_BANK_EN          (C1_DDR2_MULTI_BANK_EN),
   .TWO_T_TIME_EN          (C1_DDR2_TWO_T_TIME_EN),
   .ODT_TYPE               (C1_DDR2_ODT_TYPE),
   .REDUCE_DRV             (C1_DDR2_REDUCE_DRV),
   .REG_ENABLE             (C1_DDR2_REG_ENABLE),
   .TREFI_NS               (C1_DDR2_TREFI_NS),
   .TRAS                   (C1_DDR2_TRAS),
   .TRCD                   (C1_DDR2_TRCD),
   .TRFC                   (C1_DDR2_TRFC),
   .TRP                    (C1_DDR2_TRP),
   .TRTP                   (C1_DDR2_TRTP),
   .TWR                    (C1_DDR2_TWR),
   .TWTR                   (C1_DDR2_TWTR),
   .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
   .SIM_ONLY               (C1_DDR2_SIM_ONLY),
   .DEBUG_EN               (C1_DDR2_DEBUG_EN),
   .CLK_PERIOD             (DDR2_CLK_PERIOD),
   .DQS_IO_COL             (C1_DDR2_DQS_IO_COL),
   .DQ_IO_MS               (C1_DDR2_DQ_IO_MS),
   .USE_DM_PORT            (1)
   )
u_ddr2_top_1
(
   .ddr2_dq                (c1_ddr2_dq),
   .ddr2_a                 (c1_ddr2_a),
   .ddr2_ba                (c1_ddr2_ba),
   .ddr2_ras_n             (c1_ddr2_ras_n),
   .ddr2_cas_n             (c1_ddr2_cas_n),
   .ddr2_we_n              (c1_ddr2_we_n),
   .ddr2_cs_n              (c1_ddr2_cs_n),
   .ddr2_odt               (c1_ddr2_odt),
   .ddr2_cke               (c1_ddr2_cke),
   .ddr2_dm                (c1_ddr2_dm),
   .phy_init_done          (c1_phy_init_done),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .app_wdf_afull          (c1_app_wdf_afull),
   .app_af_afull           (c1_app_af_afull),
   .rd_data_valid          (c1_rd_data_valid),
   .app_wdf_wren           (c1_app_wdf_wren),
   .app_af_wren            (c1_app_af_wren),
   .app_af_addr            (c1_app_af_addr),
   .app_af_cmd             (c1_app_af_cmd),
   .rd_data_fifo_out       (c1_rd_data_fifo_out),
   .app_wdf_data           (c1_app_wdf_data),
   .app_wdf_mask_data      (c1_app_wdf_mask_data),
   .ddr2_dqs               (c1_ddr2_dqs),
   .ddr2_dqs_n             (c1_ddr2_dqs_n),
   .ddr2_ck                (c1_ddr2_ck),
   .rd_ecc_error           (),
   .ddr2_ck_n              (c1_ddr2_ck_n),

   .dbg_calib_done         (),
   .dbg_calib_err          (),
   .dbg_calib_dq_tap_cnt   (),
   .dbg_calib_dqs_tap_cnt  (),
   .dbg_calib_gate_tap_cnt  (),
   .dbg_calib_rd_data_sel  (),
   .dbg_calib_rden_dly     (),
   .dbg_calib_gate_dly     (),
   .dbg_idel_up_all        (1'b0),
   .dbg_idel_down_all      (1'b0),
   .dbg_idel_up_dq         (1'b0),
   .dbg_idel_down_dq       (1'b0),
   .dbg_idel_up_dqs        (1'b0),
   .dbg_idel_down_dqs      (1'b0),
   .dbg_idel_up_gate       (1'b0),
   .dbg_idel_down_gate     (1'b0),
   .dbg_sel_idel_dq        (C1_DQ_ZEROS),
   .dbg_sel_all_idel_dq    (1'b0),
   .dbg_sel_idel_dqs       (C1_DQS_ZEROS),
   .dbg_sel_all_idel_dqs   (1'b0),
   .dbg_sel_idel_gate      (C1_DQS_ZEROS),
   .dbg_sel_all_idel_gate  (1'b0)
   );

 ddr2_tb_top #
 (
   .BANK_WIDTH             (C0_DDR2_BANK_WIDTH),
   .COL_WIDTH              (C0_DDR2_COL_WIDTH),
   .DM_WIDTH               (C0_DDR2_DM_WIDTH),
   .DQ_WIDTH               (C0_DDR2_DQ_WIDTH),
   .ROW_WIDTH              (C0_DDR2_ROW_WIDTH),
   .BURST_LEN              (C0_DDR2_BURST_LEN),
   .ECC_ENABLE             (C0_DDR2_ECC_ENABLE),
   .APPDATA_WIDTH          (C0_DDR2_APPDATA_WIDTH)
   )
u_ddr2_tb_top_0
(
   .phy_init_done          (c0_phy_init_done),
   .error                  (c0_error),
   .error_cmp              (c0_error_cmp),
   .rst0                   (rst0),
   .clk0                   (clk0),
   .app_wdf_afull          (c0_app_wdf_afull),
   .app_af_afull           (c0_app_af_afull),
   .rd_data_valid          (c0_rd_data_valid),
   .app_wdf_wren           (c0_app_wdf_wren),
   .app_af_wren            (c0_app_af_wren),
   .app_af_addr            (c0_app_af_addr),
   .app_af_cmd             (c0_app_af_cmd),
   .rd_data_fifo_out       (c0_rd_data_fifo_out),
   .app_wdf_data           (c0_app_wdf_data),
   .app_wdf_mask_data      (c0_app_wdf_mask_data)
   );
ddr2_tb_top #
 (
   .BANK_WIDTH             (C1_DDR2_BANK_WIDTH),
   .COL_WIDTH              (C1_DDR2_COL_WIDTH),
   .DM_WIDTH               (C1_DDR2_DM_WIDTH),
   .DQ_WIDTH               (C1_DDR2_DQ_WIDTH),
   .ROW_WIDTH              (C1_DDR2_ROW_WIDTH),
   .BURST_LEN              (C1_DDR2_BURST_LEN),
   .ECC_ENABLE             (C1_DDR2_ECC_ENABLE),
   .APPDATA_WIDTH          (C1_DDR2_APPDATA_WIDTH)
   )
u_ddr2_tb_top_1
(
   .phy_init_done          (c1_phy_init_done),
   .error                  (c1_error),
   .error_cmp              (c1_error_cmp),
   .rst0                   (rst0),
   .clk0                   (clk0),
   .app_wdf_afull          (c1_app_wdf_afull),
   .app_af_afull           (c1_app_af_afull),
   .rd_data_valid          (c1_rd_data_valid),
   .app_wdf_wren           (c1_app_wdf_wren),
   .app_af_wren            (c1_app_af_wren),
   .app_af_addr            (c1_app_af_addr),
   .app_af_cmd             (c1_app_af_cmd),
   .rd_data_fifo_out       (c1_rd_data_fifo_out),
   .app_wdf_data           (c1_app_wdf_data),
   .app_wdf_mask_data      (c1_app_wdf_mask_data)
   );

 
endmodule
