/***************************************************************************************************
 * Module: dual_circular_buffer
 *
 * Description: Moves data from one 2 clks which are the same freq but different phases.
 *
 * Test bench: tester_dual_circular_buffer.v
 *
 * Time-stamp: Wed 20 Jul 2011 12:15:33 EDT
 *
 * Author: Berin Martini (berin.martini@gmail.com)
 **************************************************************************************************/
`ifndef _dual_circular_buffer_ `define _dual_circular_buffer_

`include "reset_sync.v"

module dual_circular_buffer
  #(parameter
    DATA_WIDTH          = 16,
    ADDR_WIDTH          = 4,
    DIFFERENCE          = 3)
   (input                           arst,
    input                           up_clk,
    input                           up_valid,
    input       [DATA_WIDTH-1:0]    up_data,
    input                           down_clk,
    output reg                      down_valid,
    output reg  [DATA_WIDTH-1:0]    down_data
   );

    /************************************************************************************
     * Message
     ************************************************************************************/

`ifdef VERBOSE
    initial $display("sync memory useage: %d", DEPTH);
`endif


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    localparam DEPTH        = 1<<ADDR_WIDTH;

    reg  [0:DEPTH-1]        mem_v;
    reg  [DATA_WIDTH-1:0]   mem_d  [0:DEPTH-1];

    wire                    up_rst;
    reg  [ADDR_WIDTH-1:0]   up_addr;

    wire                    down_rst;
    reg  [ADDR_WIDTH-1:0]   down_addr;


    reset_sync
    rst_a2up (
        .clk      (up_clk),
        .arst     (arst),
        .rst      (up_rst));


    reset_sync
    rst_a2down (
        .clk      (down_clk),
        .arst     (arst),
        .rst      (down_rst));


    /************************************************************************************
     * Implementation
     ************************************************************************************/


    always @(posedge up_clk)
        if (up_rst) up_addr <= DIFFERENCE;
        else        up_addr <= up_addr + 1'b1;


    always @(posedge down_clk)
        if (down_rst)   down_addr <= 'b0;
        else            down_addr <= down_addr + 1'b1;


    always @(posedge up_clk)
        if (up_rst) mem_v           <= 'b0;
        else        mem_v[up_addr]  <= up_valid;


    always @(posedge up_clk)
        mem_d[up_addr] <= up_data;


    always @(posedge down_clk) begin
        down_valid  <= mem_v[down_addr];
        down_data   <= mem_d[down_addr];
    end



endmodule

`endif //  `ifndef _dual_circular_buffer_
