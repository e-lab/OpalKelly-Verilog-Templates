/***************************************************************************************************
 * Module: pulse_sync
 *
 * Description: Synchronizers a pulse from a slow clock domain to a fast clock domain.
 *
 * Test bench: tester_pulse_sync.v
 *
 * Time-stamp: Thu 29 Oct 2009 17:13:13 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 * http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 50)
 **************************************************************************************************/
`ifndef _pulse_sync_ `define _pulse_sync_

module pulse_sync
   (input       o_clk,
    input       rst,
    input       i_pulse,
    output wire o_pulse);

    reg q;

    always @(posedge o_clk)
        if (rst)    q <= 0;
        else        q <= i_pulse;

    assign o_pulse = q ? 0 : q ^ i_pulse;

endmodule

`endif //  `ifndef _pulse_sync_
