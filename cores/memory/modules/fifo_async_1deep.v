/***************************************************************************************************
 * Module: fifo_async_1deep
 *
 * Description: A generic 1 word deep async FIFO. Only meant for clock domain crossing.
 *
 * Test bench: tester_fifo_async_1deep_1deep.v
 *
 * Time-stamp: April  7, 2010, 4:42AM
 *
 * Author: Clement Farabet
 * http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 55)
 **************************************************************************************************/
`ifndef _fifo_async_1deep_ `define _fifo_async_1deep_

`include "reset_sync.v"
`include "signal_sync.v"

module fifo_async_1deep
  #(parameter
    DATA_WIDTH = 8)
   (input                        pop_clk,
    input                        pop_rst,
    input                        pop,
    output wire [DATA_WIDTH-1:0] pop_data,
    output wire                  pop_ready,

    input                        push_clk,
    input                        push_rst,
    input                        push,
    input  [DATA_WIDTH-1:0]      push_data,
    output wire                  push_ready);

    /************************************************************************************
     * Message
     ************************************************************************************/
`ifdef VERBOSE
    initial $display("fifo async with depth: 1");
`endif

    /************************************************************************************
     * Internal signals
     ************************************************************************************/
    reg push_ptr, pop_ptr;
    wire push_we, wq2_pop_ptr, rq2_push_ptr;


    /************************************************************************************
     * Cross domain sync
     ************************************************************************************/
    signal_sync w2r_sync (.o_clk (pop_clk),
                          .rst (pop_rst),
                          .o_signal (rq2_push_ptr),
                          .i_signal (push_ptr));

    signal_sync r2w_sync (.o_clk (push_clk),
                          .rst (push_rst),
                          .o_signal (wq2_pop_ptr),
                          .i_signal (pop_ptr));


    /************************************************************************************
     * Write Control
     ************************************************************************************/
    assign push_we = push_ready & push;
    assign push_ready = ~(wq2_pop_ptr ^ push_ptr);

    always @(posedge push_clk)
      if (push_rst) push_ptr <= 'b0;
      else          push_ptr <= push_ptr ^ push_we;


    /************************************************************************************
     * Read Control
     ************************************************************************************/
    assign pop_rd = pop_ready & pop;
    assign pop_ready = (rq2_push_ptr ^ pop_ptr);

    always @(posedge pop_clk)
      if (pop_rst) pop_ptr <= 'b0;
      else         pop_ptr <= pop_ptr ^ pop_rd;


    /************************************************************************************
     * Dual port 2-deep RAM
     ************************************************************************************/
    reg [DATA_WIDTH-1:0] mem [0:1];

    always @(posedge push_clk)
      if (push_we) mem[push_ptr] <= push_data;

    assign pop_data = mem[pop_ptr];


endmodule

`endif //  `ifndef _fifo_async_1deep_
