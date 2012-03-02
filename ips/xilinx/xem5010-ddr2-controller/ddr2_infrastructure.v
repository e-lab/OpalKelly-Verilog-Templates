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
// \   \   \/     Version: 2.1
//  \   \         Application: MIG
//  /   /         Filename: infrastructure.v
// /___/   /\     Date Last Modified: $Date: 2007/11/28 13:20:55 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Clock generation/distribution and reset synchronization
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps
`default_nettype none

module infrastructure #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module ddr2_sdram module. Please refer to
   // the ddr2_sdram module for actual values.
   parameter CLK_PERIOD    = 3000,
   parameter DLL_FREQ_MODE = "HIGH",
   parameter RST_ACT_LOW  = 1
   )
  (
   input  wire  sys_clk_p,
   input  wire  sys_clk_n,
   output wire  clk0,
   output wire  clk90,
   output wire  clk200,
   output wire  clkdiv0,
   output wire  clk_cpu,
   output wire  clk_cpu_180,
   input  wire  sys_rst_n,
   input  wire  idelay_ctrl_rdy,
   output wire  rst0,
   output wire  rst90,
   output wire  rst200,
   output wire  rstdiv0,
   output wire  rst_cpu,
   output reg   rst_cpu_180,
   output wire  pll_lock
   );

  // # of clock cycles to delay deassertion of reset. Needs to be a fairly
  // high number not so much for metastability protection, but to give time
  // for reset (i.e. stable clock cycles) to propagate through all state
  // machines and to all control signals (i.e. not all control signals have
  // resets, instead they rely on base state logic being reset, and the effect
  // of that reset propagating through the logic). Need this because we may not
  // be getting stable clock cycles while reset asserted (i.e. since reset
  // depends on DCM lock status)
  localparam RST_SYNC_NUM = 25;
  localparam CLK_PERIOD_NS = CLK_PERIOD / 1000.0;

    wire                       clk0_bufg;
    wire                       clk90_bufg;
    wire                       clk200_bufg;
    wire                       clkdiv0_bufg;
    wire                       clk_cpu_bufg;
    wire                       clk_cpu_180_bufg;
    wire                       dcm_clkfb, dcm_clkfb_bufg;
    wire                       pll_clkfb;
    wire                       dcm_lock;
    reg [RST_SYNC_NUM-1:0]     rst0_sync_r    /* synthesis syn_maxfan = 10 */;
    reg [RST_SYNC_NUM-1:0]     rst200_sync_r  /* synthesis syn_maxfan = 10 */;
    reg [RST_SYNC_NUM-1:0]     rst90_sync_r   /* synthesis syn_maxfan = 10 */;
    reg [(RST_SYNC_NUM/2)-1:0] rstdiv0_sync_r /* synthesis syn_maxfan = 10 */;
    wire                       rst_tmp;
    wire                       sys_clk_ibufg;
    wire                       sys_rst;

  assign sys_rst = RST_ACT_LOW ? ~sys_rst_n: sys_rst_n;

  //***************************************************************************
  // Differential input clock input buffers
  //***************************************************************************
  IBUFGDS_LVDS_25 u_ibufg_sys_clk(.I(sys_clk_p), .IB (sys_clk_n), .O(sys_clk_ibufg));

  //***************************************************************************
  // Global clock generation and distribution
  //***************************************************************************
  DCM_BASE #
    (
     .CLKIN_PERIOD          (10),
     .DFS_FREQUENCY_MODE    ("HIGH"),     // DFS output range 140 - 350 MHz
     .DLL_FREQUENCY_MODE    ("LOW"),      // DCM input range 1 - 140 MHz (DFS output only)
     .CLKFX_MULTIPLY        (2),
     .CLKFX_DIVIDE          (1),
     .DUTY_CYCLE_CORRECTION ("TRUE"),
     .FACTORY_JF            (16'hF0F0)
     )
    u_dcm_base
      (
       .CLKIN   (sys_clk_ibufg),
       .CLKFB   (dcm_clkfb),
       .CLK0    (dcm_clkfb_bufg),
       .CLKFX   (clk200_bufg),
       .LOCKED  (dcm_lock),
       .RST     (sys_rst)
       );
  BUFG u_bufg_clk200(.I(clk200_bufg), .O(clk200));
  BUFG u_bufg_clkfb(.I(dcm_clkfb_bufg), .O(dcm_clkfb));


  PLL_BASE #(
      .COMPENSATION("INTERNAL"),
      .CLKIN_PERIOD(10),              // 100 MHz
      .DIVCLK_DIVIDE(4),              // Divide by 3 (25 MHz)
      .CLKFBOUT_MULT(16),             // 400 MHz VCO
      .CLKOUT0_DIVIDE(2),             // SYS_CLK = 200 MHz
      .CLKOUT1_DIVIDE(2),             // SYS_CLK - 90degrees
      .CLKOUT1_PHASE(90.0),
      .CLKOUT2_DIVIDE(4),             // CLKDIV0
      .CLKOUT3_DIVIDE(8),             // CLK_CPU 50 MHz
      .CLKOUT4_DIVIDE(8),             // CLK_CPU_180
      .CLKOUT4_PHASE(180.0)           // CLK_CPU_180 - phased
    )
  u_pll_base (
      .CLKIN    (sys_clk_ibufg),
      .CLKFBIN  (pll_clkfb),
      .RST      (sys_rst),
      .CLKOUT0  (clk0_bufg),
      .CLKOUT1  (clk90_bufg),
      .CLKOUT2  (clkdiv0_bufg),
      .CLKOUT3  (clk_cpu_bufg),
      .CLKOUT4  (clk_cpu_180_bufg),
      .CLKFBOUT (pll_clkfb),
      .LOCKED   (pll_lock)
    );

  BUFG u_bufg_clk0         (.I(clk0_bufg),          .O(clk0));
  BUFG u_bufg_clk90        (.I(clk90_bufg),         .O(clk90));
  BUFG u_bufg_clkdiv0      (.I(clkdiv0_bufg),       .O(clkdiv0));
  BUFG u_bufg_clkcpu     (.I(clk_cpu_bufg),     .O(clk_cpu));
  BUFG u_bufg_clkcpu_180 (.I(clk_cpu_180_bufg), .O(clk_cpu_180));


  //***************************************************************************
  // Reset synchronization
  // NOTES:
  //   1. shut down the whole operation if the DCM hasn't yet locked (and by
  //      inference, this means that external SYS_RST_IN has been asserted -
  //      DCM deasserts DCM_LOCK as soon as SYS_RST_IN asserted)
  //   2. In the case of all resets except rst200, also assert reset if the
  //      IDELAY master controller is not yet ready
  //   3. asynchronously assert reset. This was we can assert reset even if
  //      there is no clock (needed for things like 3-stating output buffers).
  //      reset deassertion is synchronous.
  //***************************************************************************

  assign rst_tmp = sys_rst | ~pll_lock | ~dcm_lock | ~idelay_ctrl_rdy;

  // synthesis attribute max_fanout of rst0_sync_r is 10
  always @(posedge clk0 or posedge rst_tmp)
    if (rst_tmp)
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      // logical left shift by one (pads with 0)
      rst0_sync_r <= rst0_sync_r << 1;

  // synthesis attribute max_fanout of rstdiv0_sync_r is 10
  always @(posedge clkdiv0 or posedge rst_tmp)
    if (rst_tmp)
      rstdiv0_sync_r <= {(RST_SYNC_NUM/2){1'b1}};
    else
      // logical left shift by one (pads with 0)
      rstdiv0_sync_r <= rstdiv0_sync_r << 1;

  // synthesis attribute max_fanout of rst90_sync_r is 10
  always @(posedge clk90 or posedge rst_tmp)
    if (rst_tmp)
      rst90_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst90_sync_r <= rst90_sync_r << 1;

  // make sure CLK200 doesn't depend on IDELAY_CTRL_RDY, else chicken n' egg
   // synthesis attribute max_fanout of rst200_sync_r is 10
  always @(posedge clk200 or negedge dcm_lock)
    if (!dcm_lock)
      rst200_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst200_sync_r <= rst200_sync_r << 1;


  assign rst0    = rst0_sync_r[RST_SYNC_NUM-1];
  assign rst90   = rst90_sync_r[RST_SYNC_NUM-1];
  assign rst200  = rst200_sync_r[RST_SYNC_NUM-1];
  assign rstdiv0 = rstdiv0_sync_r[(RST_SYNC_NUM/2)-1];


    // CLEMENT: Custom Resets
    // This defines the length of the reset.
    parameter INIT_RST_LENGTH = 32;

    // Sync the reset through a series of flip-flops: for metastability issues,
    // and to hold the reset for a couple of cycles.
    // We use clk_cpu for that, as it is the slowest.
    reg [INIT_RST_LENGTH-1:0] temp_rst_f;
    always @(posedge clk_cpu or posedge rst_tmp)
      if (rst_tmp) temp_rst_f <= {INIT_RST_LENGTH{1'b1}};
      else temp_rst_f <= {1'b0, temp_rst_f[INIT_RST_LENGTH-1:1]};

    // deassert resets in sequence:
    // (1) cpu peripherals :
    reg rst_cpu_180_f;
    always @(posedge clk_cpu_180 or posedge temp_rst_f[INIT_RST_LENGTH/2])
      if (temp_rst_f[INIT_RST_LENGTH/2]) {rst_cpu_180_f, rst_cpu_180} <= 2'b11;
      else {rst_cpu_180_f, rst_cpu_180} <= {1'b0, rst_cpu_180_f};

    // (2) streamer / ddr mem / calculator:
/* -----\/----- EXCLUDED -----\/-----
    reg rst_streamer_f;
    always @(posedge clk_streamer or posedge temp_rst_f[INIT_RST_LENGTH/4])
      if (temp_rst_f[INIT_RST_LENGTH/4]) {rst_streamer_f, rst_streamer} <= 2'b11;
      else {rst_streamer_f, rst_streamer} <= {1'b0, rst_streamer_f};
 -----/\----- EXCLUDED -----/\----- */

    //assign rst_calculator = rst_streamer;

    // (3) cpu and dvi:
    assign rst_cpu = temp_rst_f[0];
    //assign rst_dvi = rst_cpu;

endmodule
