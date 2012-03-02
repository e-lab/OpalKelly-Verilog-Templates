/***************************************************************************************************
 * Module: reset_sync
 *
 * Description: Synchronizes an async reset to a clock domain
 *
 * Test bench: tester_reset_sync.v
 *
 * Time-stamp: April  7, 2010, 2:34AM
 *
 * Author: none really :-)
 **************************************************************************************************/
`ifndef _reset_sync_ `define _reset_sync_

module reset_sync
   (input       clk,
    input       arst,
    output reg  rst);

    reg rst_r;

    always @(posedge clk or posedge arst)
        if (arst)    {rst, rst_r} <= 2'b11;
        else         {rst, rst_r} <= {rst_r, 1'b0};

endmodule

`endif //  `ifndef _reset_sync_
