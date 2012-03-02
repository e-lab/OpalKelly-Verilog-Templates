/***************************************************************************************************
 * Module: pulse_gen
 *
 * Description: Generates a pulse from a change in a toggled signal.
 *
 * Test bench: tester_pulse_gen.v
 *
 * Time-stamp: Thu 29 Oct 2009 17:13:13 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 * http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 50)
 **************************************************************************************************/
`ifndef _pulse_gen_ `define _pulse_gen_

module pulse_gen
  #(parameter
    USE_RESET = 1)
   (input  clk,
    input  rst,
    input  toggle,
    output pulse);

    reg q;

    assign pulse = q ^ toggle;

    generate
        if (USE_RESET) begin

            always @(posedge clk)
                if (rst)    q <= 0;
                else        q <= toggle;

        end
        else begin

            always @(posedge clk)
                q <= toggle;

        end
    endgenerate


endmodule

`endif //  `ifndef _pulse_gen_
