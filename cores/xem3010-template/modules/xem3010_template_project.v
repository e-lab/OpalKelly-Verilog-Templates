/***************************************************************************************************
 * Module: xem3010_template_project
 *
 * Description: Contains the DDR2 controllers supplied in the Opal Kelly example and a module
 *              which contains the user logic which orchestrates the movement of data.
 *
 *
 * Created: Wed  7 Jul 2010 13:43:22 EDT
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem3010_template_project_ `define _xem3010_template_project_

`include "reset_sync.v"
`include "signal_sync.v"
`include "opalkelly_pipe.v"
`include "sdram_stream_interface.v"
`include "sdramctrl.v"


module xem3010_template_project
  #(parameter BUFF_ADDR_WIDTH = 6)
   (output [7:0]    led,
    input           ti_clk,
    input           sys_clk,
    input           sdram_clk,

    input           a_hard_rst_n,
    input           ti_soft_rst,
    input           ti_read_enable,

    output [15:0]   ti_in_available,
    input           ti_in_data_en,
    input  [15:0]   ti_in_data,

    output [15:0]   ti_out_available,
    input           ti_out_data_en,
    output [15:0]   ti_out_data,

    // SDRAM I/O
    output          sdram_cke,
    output          sdram_cs_n,
    output          sdram_we_n,
    output          sdram_cas_n,
    output          sdram_ras_n,
    output          sdram_ldqm,
    output          sdram_udqm,
    output [1:0]    sdram_ba,
    output [12:0]   sdram_a,
    inout  [15:0]   sdram_d
   );


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    wire                    a_rst;
    wire                    ti_rst;
    wire                    sys_rst;
    wire                    sdram_rst;

    wire                    sdram_full;
    wire                    sdram_empty;
    wire                    sys_rden;

    // SDRAM controller / negotiator connections
    wire                    sdram_cmd_rd;
    wire                    sdram_cmd_wr;
    wire                    sdram_cmd_ack;
    wire                    sdram_cmd_done;
    wire [14:0]             sdram_addr;

    // SDRAM controller / FIFO connections.
    wire                    sdram_wr_data_en;
    wire [15:0]             sdram_wr_data;
    wire                    sdram_rd_data_en;
    wire [15:0]             sdram_rd_data;

    wire                    sys_wr_ready;
    wire                    sys_wr_valid;
    wire [15:0]             sys_wr_data;

    wire                    sys_rd_ready;
    wire                    sys_rd_valid;
    wire [15:0]             sys_rd_data;


    // These signals come in on TI_CLK from the host interface.  We need
    // to make sure to resynchronize them to our state machine clock or
    // things strange things can happen (like hopping to unexpected states).

    assign a_rst = ~a_hard_rst_n & ti_soft_rst;

    reset_sync
    reset_a2ti (
        .clk    (ti_clk),
        .arst   (a_rst),
        .rst    (ti_rst) );


    reset_sync
    reset_a2sys (
        .clk    (sys_clk),
        .arst   (a_rst),
        .rst    (sys_rst) );


    reset_sync
    reset_a2sdram (
        .clk    ( ~sdram_clk),
        .arst   (a_rst),
        .rst    (sdram_rst) );


    signal_sync #(
        .USE_RESET (0))
    rden_ti2sys (
        .o_clk     (sys_clk),
        .rst       (sys_rst),
        .i_signal  (ti_read_enable),
        .o_signal  (sys_rden) );


    opalkelly_pipe #(
        .TX_ADDR_WIDTH   (BUFF_ADDR_WIDTH),
        .RX_ADDR_WIDTH   (BUFF_ADDR_WIDTH))
    pipe (// Opal Kelly Side
        .ti_clk             (ti_clk),
        .ti_rst             (ti_rst),

        .ti_in_available    (ti_in_available),
        .ti_in_data_en      (ti_in_data_en),
        .ti_in_data         (ti_in_data),

        .ti_out_available   (ti_out_available),
        .ti_out_data_en     (ti_out_data_en),
        .ti_out_data        (ti_out_data),

        // System Side
        .sys_clk            (sys_clk),
        .sys_rst            (sys_rst),

        .sys_rx_ready       (sys_wr_ready),
        .sys_rx_valid       (sys_wr_valid),
        .sys_rx             (sys_wr_data),

        .sys_tx_ready       (sys_rd_ready),
        .sys_tx_valid       (sys_rd_valid),
        .sys_tx             (sys_rd_data) );



    /************************************************************************************
     * Implementation
     ************************************************************************************/

     assign led = {3'b0, (~sys_wr_ready & sys_wr_valid), sys_rden, sdram_full, sdram_empty, a_rst};


    /************************************************************************************
     * SDRAM Streaming interface to the controller
     ************************************************************************************/

    sdram_stream_interface #(
        .SDRAM_ADDR_WIDTH (15))
    interface (// System Side
        .sys_clk            (sys_clk),
        .sys_rst            (sys_rst),

        .sys_wr_ready       (sys_wr_ready),
        .sys_wr_valid       (sys_wr_valid),
        .sys_wr_data        (sys_wr_data),

        .sys_rd_ready       (sys_rd_ready & sys_rden),
        .sys_rd_valid       (sys_rd_valid),
        .sys_rd_data        (sys_rd_data),

        // SDRAM Side
        .sdram_clk          (sdram_clk),
        .sdram_rst          (sdram_rst),

        .sdram_full         (sdram_full),
        .sdram_empty        (sdram_empty),

        .sdram_cmd_ack      (sdram_cmd_ack),
        .sdram_cmd_done     (sdram_cmd_done),
        .sdram_cmd_wr       (sdram_cmd_wr),
        .sdram_cmd_rd       (sdram_cmd_rd),
        .sdram_addr         (sdram_addr),
        .sdram_wr_data      (sdram_wr_data),
        .sdram_wr_data_en   (sdram_wr_data_en),
        .sdram_rd_data      (sdram_rd_data),
        .sdram_rd_data_en   (sdram_rd_data_en) );


    /************************************************************************************
     * SDRAM CONTROLLER
     ************************************************************************************/

    assign sdram_cke    = 1'b1;
    assign sdram_ldqm   = 1'b0;
    assign sdram_udqm   = 1'b0;

    sdramctrl
    c0 (
        .clk            ( ~sdram_clk),
        .clk_read       ( ~sdram_clk),
        .reset          (sdram_rst),

        .cmd_pagewrite  (sdram_cmd_wr),
        .cmd_pageread   (sdram_cmd_rd),
        .cmd_ack        (sdram_cmd_ack),
        .cmd_done       (sdram_cmd_done),
        .rowaddr_in     (sdram_addr),
        .fifo_din       (sdram_wr_data),
        .fifo_read      (sdram_wr_data_en),
        .fifo_dout      (sdram_rd_data),
        .fifo_write     (sdram_rd_data_en),

        .sdram_cmd      ({sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n}),
        .sdram_ba       (sdram_ba),
        .sdram_a        (sdram_a),
        .sdram_d        (sdram_d) );



endmodule


`endif //  `ifndef _xem3010_template_project_
