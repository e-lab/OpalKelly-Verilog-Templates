/***************************************************************************************************
 * Module: xem6001_template_project
 *
 * Description: Simple project for use with a Opal Kelly board.  Takes data piped from the computer
 *              and stores it in an async input buffer.  Then transfers the data into an output
 *              buffer to be piped out to the computer.
 *
 * Created: Fri 22 Jul 2011 13:48:03 EDT
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem6001_template_project_ `define _xem6001_template_project_

`include "reset_sync.v"
`include "fifo_async.v"
`include "opalkelly_pipe.v"


module xem6001_template_project #(
     parameter
     MEM_ADDR_WIDTH = 6)
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

    output          s_rx_valid,
    output [15:0]   s_rx_data
   );


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

//    localparam CLK_DIVIDER    = 10;
//
//    localparam S_IDLE = 0,
//               S_COPY = 1;
//    integer state;

    wire        a_rst;
    wire        s_rst;
    wire        ti_rst;

    reg [15:0]  s_cnt;
    reg         s_cnt_valid;
    reg         s_start_tx;

    wire [15:0] s_tx_data;
    wire        s_tx_valid;
    wire        s_tx_ready;


    reset_sync
    rst_a2s (
        .clk    (s_clk),
        .arst   (a_rst),
        .rst    (s_rst) );

    reset_sync
    rst_a2ti (
        .clk    (ti_clk),
        .arst   (a_rst),
        .rst    (ti_rst) );


    opalkelly_pipe #(
        .TX_ADDR_WIDTH  (MEM_ADDR_WIDTH),
        .RX_ADDR_WIDTH  (MEM_ADDR_WIDTH))
    pipe_ (// Opal Kelly Side
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

        .sys_rx_ready       (1'b1),
        .sys_rx_valid       (s_rx_valid),
        .sys_rx             (s_rx_data),

        .sys_tx_ready       (s_tx_ready),
        .sys_tx_valid       (s_tx_valid),
        .sys_tx             (s_tx_data) );



    /************************************************************************************
     * Implementation
     ************************************************************************************/


    assign a_led        = {3'b101, s_start_tx, a_rst_hard , ti_rst_soft, ti_rst, s_rst};

    assign a_rst        = a_rst_hard | ti_rst_soft;

    assign s_tx_data    = s_cnt;

    assign s_tx_valid   = s_cnt_valid;


    always @(posedge s_clk)
        if      (s_rst)         s_start_tx <= 1'b0;
        else if (s_rx_valid)    s_start_tx <= 1'b1;


    always @(posedge s_clk)
        if (s_start_tx) s_cnt_valid <= 1'b1;
        else            s_cnt_valid <= 1'b0;


    always @(posedge s_clk)
        if (s_start_tx) s_cnt <= s_cnt + 1;
        else            s_cnt <= 'b0;



endmodule

`endif //  `ifndef _xem6001_template_project_
