/***************************************************************************************************
 * Module: system_opalkelly
 *
 * Description: This top module is for use with the Opal Kelly XEM5010 board and uses the Xilinx MIG
 *              DDR2 controller and HDL provided by Opal Kelly in their sample.  It moves data from
 *              the PC to the DDR2 and vice-versa.
 *
 *              Host Interface registers:
 *              WireIn 0x00
 *                  0 - DDR2 read enable (0=disabled, 1=enabled)
 *                  1 - DDR2 write enable (0=disabled, 1=enabled)
 *                  2 - Reset
 *                  3 - Reset tests
 *
 *              PipeIn 0x80 - DDR2 write port (U15, DDR2 "A")
 *              PipeIn 0x81 - DDR2 write port (U14, DDR2 "B")
 *              PipeOut 0xA0 - DDR2 read port (U15, DDR2 "A")
 *              PipeOut 0xA1 - DDR2 read port (U14, DDR2 "B")
 *
 * Created: Thu  5 Nov 2009 17:35:31 EST
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem5010_template_ `define _xem5010_template_

`default_nettype none
`timescale 1ns / 1ps

`include "xem5010_template_project.v"
`include "okLibrary.v"

module system_opalkelly
  #(parameter
    DQ_WIDTH    = 16,   // # of data width
    ROW_WIDTH   = 13,   // # of memory row and # of addr bits
    BANK_WIDTH  = 3,    // # of memory bank addr bits
    CS_WIDTH    = 1,    // # of total memory chip selects
    ODT_WIDTH   = 1,    // # of memory on-die term enables
    CKE_WIDTH   = 1,    // # of memory clock enable outputs
    DM_WIDTH    = 2,    // # of data mask bits
    DQS_WIDTH   = 2,    // # of DQS strobes
    CLK_WIDTH   = 1)    // # of clock outputs
   (input  [7:0]            hi_in,
    output [1:0]            hi_out,
    inout  [15:0]           hi_inout,
    output                  hi_muxsel,

    output [3:0]            led,

    input                   sys_clk_p,
    input                   sys_clk_n,

    inout  [DQ_WIDTH-1:0]   ddr2a_dq,
    output [ROW_WIDTH-1:0]  ddr2a_a,
    output [BANK_WIDTH-1:0] ddr2a_ba,
    output                  ddr2a_ras_n,
    output                  ddr2a_cas_n,
    output                  ddr2a_we_n,
    output [CS_WIDTH-1:0]   ddr2a_cs_n,
    output [ODT_WIDTH-1:0]  ddr2a_odt,
    output [CKE_WIDTH-1:0]  ddr2a_cke,
    output [DM_WIDTH-1:0]   ddr2a_dm,
    inout  [DQS_WIDTH-1:0]  ddr2a_dqs,
    inout  [DQS_WIDTH-1:0]  ddr2a_dqs_n,
    output [CLK_WIDTH-1:0]  ddr2a_ck,
    output [CLK_WIDTH-1:0]  ddr2a_ck_n,

    inout  [DQ_WIDTH-1:0]   ddr2b_dq,
    output [ROW_WIDTH-1:0]  ddr2b_a,
    output [BANK_WIDTH-1:0] ddr2b_ba,
    output                  ddr2b_ras_n,
    output                  ddr2b_cas_n,
    output                  ddr2b_we_n,
    output [CS_WIDTH-1:0]   ddr2b_cs_n,
    output [ODT_WIDTH-1:0]  ddr2b_odt,
    output [CKE_WIDTH-1:0]  ddr2b_cke,
    output [DM_WIDTH-1:0]   ddr2b_dm,
    inout  [DQS_WIDTH-1:0]  ddr2b_dqs,
    inout  [DQS_WIDTH-1:0]  ddr2b_dqs_n,
    output [CLK_WIDTH-1:0]  ddr2b_ck,
    output [CLK_WIDTH-1:0]  ddr2b_ck_n);


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    localparam COL_WIDTH                = 10;      // # of memory column bits
    localparam CS_NUM                   = 1;       // # of separate memory chip selects
    localparam CS_BITS                  = 0;       // set to log2(CS_NUM) (rounded up)
    localparam DQ_PER_DQS               = 8;       // # of DQ data bits per strobe
    localparam DQ_BITS                  = 4;       // set to log2(DQS_WIDTH*DQ_PER_DQS)
    localparam DQS_BITS                 = 1;       // set to log2(DQS_WIDTH)
    localparam ADDITIVE_LAT             = 0;       // additive write latency
    localparam BURST_LEN                = 4;       // burst length (in double words)
    localparam BURST_TYPE               = 0;       // burst type (=0 seq; =1 interleaved)
    localparam CAS_LAT                  = 4;       // CAS latency
    localparam ECC_ENABLE               = 0;       // enable ECC (=1 enable)
    localparam APPDATA_WIDTH            = 32;      // # of usr read/write data bus bits
    localparam MULTI_BANK_EN            = 1;       // Keeps multiple banks open. (= 1 enable)
    localparam TWO_T_TIME_EN            = 0;       // 2t timing for unbuffered dimms
    localparam ODT_TYPE                 = 1;       // ODT (=0(none),=1(75),=2(150),=3(50))
    localparam REDUCE_DRV               = 1;       // reduced strength mem I/O (=1 yes)
    localparam REG_ENABLE               = 0;       // registered addr/ctrl (=1 yes)
    localparam TREFI_NS                 = 7800;    // auto refresh interval (ns)
    localparam TRAS                     = 40000;   // active->precharge delay
    localparam TRCD                     = 15000;   // active->read/write delay
    localparam TRFC                     = 127500;  // refresh->refresh, refresh->active delay
    localparam TRP                      = 15000;   // precharge->command delay
    localparam TRTP                     = 7500;    // read->precharge delay
    localparam TWR                      = 15000;   // used to determine write->precharge
    localparam TWTR                     = 7500;    // write->read delay
    localparam HIGH_PERFORMANCE_MODE    = "TRUE";  // # = TRUE, the IODELAY performance mode is set
                                                   //   to high.
                                                   // # = FALSE, the IODELAY performance mode is set
                                                   //   to low.

    localparam SIM_ONLY                 = 0;       // = 1 to skip SDRAM power up delay
    localparam DEBUG_EN                 = 2;       // Enable debug signals/controls. When this
                                                   //   parameter is changed from 0 to 1,

    localparam DQS_IO_COL               = 4'b1010; // I/O column location of DQS groups
                                                   //   (=0, left; =1 center, =2 right)
    localparam DQ_IO_MS                 = 16'b10100101_10100101;  // Master/Slave location of DQ I/O
                                                                  //    (=0 slave)

    localparam CLK_PERIOD               = 3750;    // Core/Memory clock period (in ps)
    localparam RST_ACT_LOW              = 0;       // =1 for active low reset, =0 for active high
    localparam DLL_FREQ_MODE            = "HIGH";  // DCM Frequency range

    localparam DDR_ADDR_WIDTH           = BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
    localparam DDR_WORD_WIDTH           = DQ_WIDTH * BURST_LEN;
    localparam STREAMER_ADDR_WIDTH      = DDR_ADDR_WIDTH - `CLOG2(BURST_LEN);

    localparam NUM_WIRE_IN              = 1; // start addr 8'h00, range 0 - 32
    localparam NUM_WIRE_OUT             = 4; // start addr 8'h20, range 0 - 32
    localparam NUM_TRIG_IN              = 0; // start addr 8'h40, range 0 - 32
    localparam NUM_TRIG_OUT             = 0; // start addr 8'h60, range 0 - 32
    localparam NUM_PIPE_IN              = 2; // start addr 8'h80, range 0 - 32
    localparam NUM_PIPE_OUT             = 2; // start addr 8'hA0, range 0 - 32
    localparam NUM_OR                   = NUM_WIRE_OUT + NUM_TRIG_OUT + NUM_PIPE_IN + NUM_PIPE_OUT;

    wire                            rst0;
    wire                            rst90;
    wire                            rst200;
    wire                            rstdiv0;
    wire                            rst_cpu;
    wire                            rst_cpu_180;
    wire                            pll_lock;
    wire                            clk0;
    wire                            clk90;
    wire                            clk200;
    wire                            clkdiv0;
    wire                            clk_cpu;
    wire                            clk_cpu_180;
    wire                            idelay_ctrl_rdy;

    wire                            s_a_phy_init_done;
    wire                            s_a_app_wdf_afull;
    wire                            s_a_app_af_afull;
    wire                            s_a_app_rd_data_valid;
    wire                            s_a_app_wdf_wren;
    wire                            s_a_app_af_wren;
    wire [30:0]                     s_a_app_af_addr;
    wire [2:0]                      s_a_app_af_cmd;
    wire [(APPDATA_WIDTH)-1:0]      s_a_app_rd_data;
    wire [(APPDATA_WIDTH)-1:0]      s_a_app_wdf_data;
    wire [(APPDATA_WIDTH/8)-1:0]    s_a_app_wdf_mask_data;

    wire                            s_b_phy_init_done;
    wire                            s_b_app_wdf_afull;
    wire                            s_b_app_af_afull;
    wire                            s_b_app_rd_data_valid;
    wire                            s_b_app_wdf_wren;
    wire                            s_b_app_af_wren;
    wire [30:0]                     s_b_app_af_addr;
    wire [2:0]                      s_b_app_af_cmd;
    wire [(APPDATA_WIDTH)-1:0]      s_b_app_rd_data;
    wire [(APPDATA_WIDTH)-1:0]      s_b_app_wdf_data;
    wire [(APPDATA_WIDTH/8)-1:0]    s_b_app_wdf_mask_data;

    // Host interface connections
    wire                            ti_clk;
    wire [30:0]                     ok1;
    wire [16:0]                     ok2;

    wire [(17*NUM_OR)-1:0]          ok2x;

    wire [15:0]                     epWireIn    [0:31];
    wire [15:0]                     epWireOut   [0:31];

    wire [0:31]                     trigInClk;
    wire [0:31]                     trigOutClk;
    wire [15:0]                     epTrigIn    [0:31];
    wire [15:0]                     epTrigOut   [0:31];

    wire [0:31]                     epWrite;
    wire [0:31]                     epRead;
    wire [15:0]                     epWriteData [0:31];
    wire [15:0]                     epReadData  [0:31];

    /************************************************************************************
     * Implementation
     ************************************************************************************/

//    assign trigInClk[0]     = ti_clk;
//    assign trigOutClk[0]    = ti_clk;


    xem5010_template_project #(
        .APPDATA_WIDTH  (APPDATA_WIDTH),
        .MASK_WIDTH     (APPDATA_WIDTH/8))
    project_ (
        .led                    (led),
        .s_clk                  (clk0),
        .ti_clk                 (ti_clk),

        // Reset
        .arst                   (epWireIn[0][0]),

        // Pipe to Chip 'A'
        .ti_in_available        (epWireOut[0]),
        .ti_in_data_en          (epWrite[0]),
        .ti_in_data             (epWriteData[0]),

        .ti_out_available       (epWireOut[1]),
        .ti_out_data_en         (epRead[0]),
        .ti_out_data            (epReadData[0]),

        // Pipe to Chip 'B'
        .ti_test_in_available   (epWireOut[2]),
        .ti_test_in_data_en     (epWrite[1]),
        .ti_test_in_data        (epWriteData[1]),

        .ti_test_out_available  (epWireOut[3]),
        .ti_test_out_data_en    (epRead[1]),
        .ti_test_out_data       (epReadData[1]),

        // DDR2 Chip 'A' I/O
        .s_a_phy_init_done      (s_a_phy_init_done),
        .s_a_app_rd_data_valid  (s_a_app_rd_data_valid),
        .s_a_app_rd_data        (s_a_app_rd_data),
        .s_a_app_af_afull       (s_a_app_af_afull),
        .s_a_app_wdf_afull      (s_a_app_wdf_afull),
        .s_a_app_af_wren        (s_a_app_af_wren),
        .s_a_app_af_cmd         (s_a_app_af_cmd),
        .s_a_app_af_addr        (s_a_app_af_addr),
        .s_a_app_wdf_wren       (s_a_app_wdf_wren),
        .s_a_app_wdf_data       (s_a_app_wdf_data),
        .s_a_app_wdf_mask_data  (s_a_app_wdf_mask_data),

        // DDR2 Chip 'B' I/O
        .s_b_phy_init_done      (s_b_phy_init_done),
        .s_b_app_rd_data_valid  (s_b_app_rd_data_valid),
        .s_b_app_rd_data        (s_b_app_rd_data),
        .s_b_app_af_afull       (s_b_app_af_afull),
        .s_b_app_wdf_afull      (s_b_app_wdf_afull),
        .s_b_app_af_wren        (s_b_app_af_wren),
        .s_b_app_af_cmd         (s_b_app_af_cmd),
        .s_b_app_af_addr        (s_b_app_af_addr),
        .s_b_app_wdf_wren       (s_b_app_wdf_wren),
        .s_b_app_wdf_data       (s_b_app_wdf_data),
        .s_b_app_wdf_mask_data  (s_b_app_wdf_mask_data) );


    /************************************************************************************
     * Instantiate the Opal Kelly okHost and okWireOR, connect endpoints
     ************************************************************************************/

    assign hi_muxsel = 1'b0;


    okHost_XEM5010
    okHI (
        .hi_in      (hi_in),
        .hi_out     (hi_out),
        .hi_inout   (hi_inout),
        .ti_clk     (ti_clk),
        .ok1        (ok1),
        .ok2        (ok2) );


    okWireOR #(.N(NUM_OR)) wireOR (ok2, ok2x);


    genvar wi;
    generate
        for (wi = 0; wi < NUM_WIRE_IN; wi = wi + 1) begin: WI_

            okWireIn
            wire_in (
                .ok1        (ok1),
                .ep_addr    (8'h00 + wi),
                .ep_dataout (epWireIn[wi]) );

        end
    endgenerate


    genvar wo;
    generate
        for (wo = 0; wo < NUM_WIRE_OUT; wo = wo + 1) begin: WO_

            okWireOut
            wire_out (
                .ok1        (ok1),
                .ok2        (ok2x[wo*17 +: 17]),
                .ep_addr    (8'h20 + wo),
                .ep_datain  (epWireOut[wo]) );

        end
    endgenerate


    genvar ti;
    generate
        for (ti = 0; ti < NUM_TRIG_IN; ti = ti + 1) begin: TI_

            okTriggerIn
            trigger_in (
                .ok1        (ok1),
                .ep_addr    (8'h40 + ti),
                .ep_clk     (trigInClk[ti]),
                .ep_trigger (epTrigIn[ti]) );

        end
    endgenerate


    genvar to;
    generate
        for (to = 0; to < NUM_TRIG_OUT; to = to + 1) begin: TO_

            okTriggerOut
            trigger_out (
                .ok1        (ok1),
                .ok2        (ok2x[(NUM_WIRE_OUT+to)*17 +: 17]),
                .ep_addr    (8'h60 + to),
                .ep_clk     (trigOutClk[to]),
                .ep_trigger (epTrigOut[to]) );

        end
    endgenerate


    genvar pi;
    generate
        for (pi = 0; pi < NUM_PIPE_IN; pi = pi + 1) begin: PI_

            okPipeIn
            pipe_in (
                .ok1        (ok1),
                .ok2        (ok2x[(NUM_WIRE_OUT+NUM_TRIG_OUT+pi)*17 +: 17]),
                .ep_addr    (8'h80 + pi),
                .ep_write   (epWrite[pi]),
                .ep_dataout (epWriteData[pi]) );

        end
    endgenerate


    genvar po;
    generate
        for (po = 0; po < NUM_PIPE_OUT; po = po + 1) begin: PO_

            okPipeOut
            pipe_out (
                .ok1        (ok1),
                .ok2        (ok2x[(NUM_WIRE_OUT+NUM_TRIG_OUT+NUM_PIPE_IN+po)*17 +: 17]),
                .ep_addr    (8'hA0 + po),
                .ep_read    (epRead[po]),
                .ep_datain  (epReadData[po]));

        end
    endgenerate


    /************************************************************************************
     * Clock generation and IDELAY for DDR2 controller
     * and logic...
     ************************************************************************************/

    ddr2_idelay_ctrl #(
        .IDELAYCTRL_NUM (2))
    u_idelay_ctrl (
        .rst200             (rst200),
        .clk200             (clk200),
        .idelay_ctrl_rdy    (idelay_ctrl_rdy) );


    infrastructure #(
        .CLK_PERIOD    (10000),
        .RST_ACT_LOW   (0),
        .DLL_FREQ_MODE (DLL_FREQ_MODE))
    u_infrastructure_ (
        .sys_clk_p          (sys_clk_p),
        .sys_clk_n          (sys_clk_n),
        .sys_rst_n          (arst),
        .rst0               (rst0),
        .rst90              (rst90),
        .rst200             (rst200),
        .rstdiv0            (rstdiv0),
        .rst_cpu            (rst_cpu),
        .rst_cpu_180        (rst_cpu_180),
        .clk0               (clk0),
        .clk90              (clk90),
        .clk200             (clk200),
        .clk_cpu            (clk_cpu),
        .clk_cpu_180        (clk_cpu_180),
        .clkdiv0            (clkdiv0),
        .idelay_ctrl_rdy    (idelay_ctrl_rdy),
        .pll_lock           (pll_lock) );


    /************************************************************************************
     * MIG Controllers
     ************************************************************************************/

    ddr2_top #(
        .BANK_WIDTH             (BANK_WIDTH),
        .CKE_WIDTH              (CKE_WIDTH),
        .CLK_WIDTH              (CLK_WIDTH),
        .COL_WIDTH              (COL_WIDTH),
        .CS_NUM                 (CS_NUM),
        .CS_WIDTH               (CS_WIDTH),
        .CS_BITS                (CS_BITS),
        .DM_WIDTH               (DM_WIDTH),
        .DQ_WIDTH               (DQ_WIDTH),
        .DQ_PER_DQS             (DQ_PER_DQS),
        .DQS_WIDTH              (DQS_WIDTH),
        .DQ_BITS                (DQ_BITS),
        .DQS_BITS               (DQS_BITS),
        .ODT_WIDTH              (ODT_WIDTH),
        .ROW_WIDTH              (ROW_WIDTH),
        .ADDITIVE_LAT           (ADDITIVE_LAT),
        .BURST_LEN              (BURST_LEN),
        .BURST_TYPE             (BURST_TYPE),
        .CAS_LAT                (CAS_LAT),
        .ECC_ENABLE             (ECC_ENABLE),
        .APPDATA_WIDTH          (APPDATA_WIDTH),
        .MULTI_BANK_EN          (MULTI_BANK_EN),
        .TWO_T_TIME_EN          (TWO_T_TIME_EN),
        .ODT_TYPE               (ODT_TYPE),
        .REDUCE_DRV             (REDUCE_DRV),
        .REG_ENABLE             (REG_ENABLE),
        .TREFI_NS               (TREFI_NS),
        .TRAS                   (TRAS),
        .TRCD                   (TRCD),
        .TRFC                   (TRFC),
        .TRP                    (TRP),
        .TRTP                   (TRTP),
        .TWR                    (TWR),
        .TWTR                   (TWTR),
        .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
        .SIM_ONLY               (SIM_ONLY),
        .DEBUG_EN               (DEBUG_EN),
        .DQS_IO_COL             (DQS_IO_COL),
        .DQ_IO_MS               (DQ_IO_MS),
        .CLK_PERIOD             (CLK_PERIOD),
        .USE_DM_PORT            (1))
    u_ddr2_top_0 (
        .ddr2_ck            (ddr2a_ck),
        .ddr2_ck_n          (ddr2a_ck_n),
        .ddr2_cke           (ddr2a_cke),
        .ddr2_odt           (ddr2a_odt),
        .ddr2_ras_n         (ddr2a_ras_n),
        .ddr2_cas_n         (ddr2a_cas_n),
        .ddr2_we_n          (ddr2a_we_n),
        .ddr2_cs_n          (ddr2a_cs_n),
        .ddr2_a             (ddr2a_a),
        .ddr2_ba            (ddr2a_ba),
        .ddr2_dm            (ddr2a_dm),
        .ddr2_dq            (ddr2a_dq),
        .ddr2_dqs           (ddr2a_dqs),
        .ddr2_dqs_n         (ddr2a_dqs_n),
        .rst0               (rst0),
        .rst90              (rst90),
        .rstdiv0            (rstdiv0),
        .clk0               (clk0),
        .clk90              (clk90),
        .clkdiv0            (clkdiv0),
        .phy_init_done      (a_phy_init_done),
        .app_wdf_afull      (a_app_wdf_afull),
        .app_af_afull       (a_app_af_afull),
        .rd_data_valid      (a_app_rd_data_valid),
        .app_wdf_wren       (a_app_wdf_wren),
        .app_af_wren        (a_app_af_wren),
        .app_af_addr        (a_app_af_addr),
        .app_af_cmd         (a_app_af_cmd),
        .rd_data_fifo_out   (a_app_rd_data),
        .app_wdf_data       (a_app_wdf_data),
        .app_wdf_mask_data  (a_app_wdf_mask_data),
        .rd_ecc_error       ());


     ddr2_top #(
         .BANK_WIDTH            (BANK_WIDTH),
         .CKE_WIDTH             (CKE_WIDTH),
         .CLK_WIDTH             (CLK_WIDTH),
         .COL_WIDTH             (COL_WIDTH),
         .CS_NUM                (CS_NUM),
         .CS_WIDTH              (CS_WIDTH),
         .CS_BITS               (CS_BITS),
         .DM_WIDTH              (DM_WIDTH),
         .DQ_WIDTH              (DQ_WIDTH),
         .DQ_PER_DQS            (DQ_PER_DQS),
         .DQS_WIDTH             (DQS_WIDTH),
         .DQ_BITS               (DQ_BITS),
         .DQS_BITS              (DQS_BITS),
         .ODT_WIDTH             (ODT_WIDTH),
         .ROW_WIDTH             (ROW_WIDTH),
         .ADDITIVE_LAT          (ADDITIVE_LAT),
         .BURST_LEN             (BURST_LEN),
         .BURST_TYPE            (BURST_TYPE),
         .CAS_LAT               (CAS_LAT),
         .ECC_ENABLE            (ECC_ENABLE),
         .APPDATA_WIDTH         (APPDATA_WIDTH),
         .MULTI_BANK_EN         (MULTI_BANK_EN),
         .TWO_T_TIME_EN         (TWO_T_TIME_EN),
         .ODT_TYPE              (ODT_TYPE),
         .REDUCE_DRV            (REDUCE_DRV),
         .REG_ENABLE            (REG_ENABLE),
         .TREFI_NS              (TREFI_NS),
         .TRAS                  (TRAS),
         .TRCD                  (TRCD),
         .TRFC                  (TRFC),
         .TRP                   (TRP),
         .TRTP                  (TRTP),
         .TWR                   (TWR),
         .TWTR                  (TWTR),
         .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
         .SIM_ONLY              (SIM_ONLY),
         .DEBUG_EN              (DEBUG_EN),
         .DQS_IO_COL            (DQS_IO_COL),
         .DQ_IO_MS              (DQ_IO_MS),
         .CLK_PERIOD            (CLK_PERIOD),
         .USE_DM_PORT           (1))
    u_ddr2_top_1 (
        .ddr2_ck            (ddr2b_ck),
        .ddr2_ck_n          (ddr2b_ck_n),
        .ddr2_cke           (ddr2b_cke),
        .ddr2_odt           (ddr2b_odt),
        .ddr2_ras_n         (ddr2b_ras_n),
        .ddr2_cas_n         (ddr2b_cas_n),
        .ddr2_we_n          (ddr2b_we_n),
        .ddr2_cs_n          (ddr2b_cs_n),
        .ddr2_a             (ddr2b_a),
        .ddr2_ba            (ddr2b_ba),
        .ddr2_dm            (ddr2b_dm),
        .ddr2_dq            (ddr2b_dq),
        .ddr2_dqs           (ddr2b_dqs),
        .ddr2_dqs_n         (ddr2b_dqs_n),
        .rst0               (rst0),
        .rst90              (rst90),
        .rstdiv0            (rstdiv0),
        .clk0               (clk0),
        .clk90              (clk90),
        .clkdiv0            (clkdiv0),
        .phy_init_done      (b_phy_init_done),
        .app_wdf_afull      (b_app_wdf_afull),
        .app_af_afull       (b_app_af_afull),
        .rd_data_valid      (b_app_rd_data_valid),
        .app_wdf_wren       (b_app_wdf_wren),
        .app_af_wren        (b_app_af_wren),
        .app_af_addr        (b_app_af_addr),
        .app_af_cmd         (b_app_af_cmd),
        .rd_data_fifo_out   (b_app_rd_data),
        .app_wdf_data       (b_app_wdf_data),
        .app_wdf_mask_data  (b_app_wdf_mask_data),
        .rd_ecc_error       ());


endmodule

`endif //  `ifndef _xem5010_template_
