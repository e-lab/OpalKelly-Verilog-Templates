/***************************************************************************************************
 * Module: signal_sync
 *
 * Description: Synchronizers a signal from a slow clock domain to a fast clock domain using a
                Dual Flip-Flop.
 *
 * Test bench: tester_signal_sync.v
 *
 * Time-stamp: Thu 29 Oct 2009 17:32:27 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 * http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 49)
 **************************************************************************************************/
`ifndef _signal_sync_ `define _signal_sync_

module signal_sync
  #(parameter
    USE_RESET = 0)
   (input       o_clk,
    input       rst,
    input       i_signal,
    output reg  o_signal);

    reg q;

    generate
        if (USE_RESET) begin

            always @(posedge o_clk)
                if (rst)    {o_signal, q} <= 'b0;
                else        {o_signal, q} <= {q, i_signal};

        end
        else begin

            always @(posedge o_clk)
                {o_signal, q} <= {q, i_signal};

        end
    endgenerate


endmodule

`endif //  `ifndef _signal_sync_
