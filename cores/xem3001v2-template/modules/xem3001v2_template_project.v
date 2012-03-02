/***************************************************************************************************
 * Module: xem3001v2_template_project
 *
 * Description: Simple project for use with a Opal Kelly board.  Takes data piped from the computer
 *              and stores it in an async input buffer.  Then transfers the data into an output
 *              buffer to be piped out to the computer.
 *
 * Created: Fri 26 Mar 2010 14:46:56 EDT
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem3001v2_template_project_ `define _xem3001v2_template_project_

`include "reset_sync.v"
`include "fifo_async.v"
`include "opalkelly_pipe.v"


module xem3001v2_template_project
  #(parameter MEM_ADDR_WIDTH = 6)
   (output [7:0]    a_led,
    input           a_rst_hard,

    input           s_clk,

    input           ti_clk,
    input           ti_rst_soft,

    output [15:0]   ti_in_available,
    input           ti_in_data_en,
    input  [15:0]   ti_in_data,

    output [15:0]   ti_out_available,
    input           ti_out_data_en,
    output [15:0]   ti_out_data,

    input           ti_in_test_en,
    input  [15:0]   ti_in_test,
    input           ti_out_test_en,
    output [15:0]   ti_out_test
   );


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

//    localparam CLK_DIVIDER    = 10;
//
//    localparam S_IDLE = 0,
//               S_COPY = 1;
//    integer state;


    // resets
    wire        a_rst;
    wire        s_rst;
    wire        ti_rst;

    wire [15:0] s_copy;
    wire        s_copy_pop;
    reg         s_copy_push;

    wire        s_in_empty;
    wire        s_out_full_a;

    wire        s_tmp_ready;
    wire        s_tmp_valid;
    wire [15:0] s_tmp;

    reg         s_rx_ready;
    wire        s_rx_valid;
    wire [15:0] s_rx;

    wire        s_tx_ready;
    reg         s_tx_valid;
    reg  [15:0] s_tx;


    reset_sync
    rst_a2s (
        .clk    (s_clk),
        .arst   (a_rst),
        .rst    (s_rst) );


    reset_sync
    rst_a2ti (
        .clk   (ti_clk),
        .arst  (a_rst),
        .rst    (ti_rst) );


    opalkelly_pipe #(
        .TX_ADDR_WIDTH  (MEM_ADDR_WIDTH),
        .RX_ADDR_WIDTH  (MEM_ADDR_WIDTH))
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
        .sys_clk            (s_clk),
        .sys_rst            (s_rst),

        .sys_rx_ready       (s_tmp_ready),
        .sys_rx_valid       (s_tmp_valid),
        .sys_rx             (s_tmp),

        .sys_tx_ready       (s_tmp_ready),
        .sys_tx_valid       (s_tmp_valid),
        .sys_tx             (s_tmp) );

//        .sys_rx_ready       (s_rx_ready),
//        .sys_rx_valid       (s_rx_valid),
//        .sys_rx             (s_rx),
//
//        .sys_tx_ready       (s_tx_ready),
//        .sys_tx_valid       (s_tx_valid),
//        .sys_tx             (s_tx) );


    fifo_async #(
        .DATA_WIDTH         (16),
        .ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .FALL               (0),
        .LEAD_ALMOST_FULL   (0),
        .LEAD_ALMOST_EMPTY  (0))
    data_in (
        .pop_clk        (s_clk),
        .pop_rst        (s_rst),
        .pop            (s_copy_pop),
        .pop_data       (s_copy),
        .pop_empty      (s_in_empty),
        .pop_empty_a    (),
        .pop_count      (),

        .push_clk       (ti_clk),
        .push_rst       (ti_rst),
        .push           (ti_in_test_en),
        .push_data      (ti_in_test),
        .push_full      (),
        .push_full_a    (),
        .push_count     () );


    fifo_async #(
        .DATA_WIDTH         (16),
        .ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .FALL               (0),
        .LEAD_ALMOST_FULL   (1),
        .LEAD_ALMOST_EMPTY  (0))
    data_out (
        .pop_clk        (ti_clk),
        .pop_rst        (ti_rst),
        .pop            (ti_out_test_en),
        .pop_data       (ti_out_test),
        .pop_empty      (),
        .pop_empty_a    (),
        .pop_count      (),

        .push_clk       (s_clk),
        .push_rst       (s_rst),
        .push           (s_copy_push),
        .push_data      (s_copy),
        .push_full      (),
        .push_full_a    (s_out_full_a),
        .push_count     () );


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    assign a_led        = ~{4'b0, s_in_empty, s_out_full_a, a_rst, 1'b1};

    assign a_rst        = a_rst_hard | ti_rst_soft;

    assign s_copy_pop   = ~s_in_empty & ~s_out_full_a;


    always @(posedge s_clk)
        if (s_rst)  s_copy_push <= 1'b0;
        else        s_copy_push <= s_copy_pop;


endmodule


`endif //  `ifndef _xem3001v2_template_project_
