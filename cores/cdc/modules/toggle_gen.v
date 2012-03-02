/***************************************************************************************************
 * Module: toggle_gen
 *
 * Description: Generates a toggle that changes on a pulse signal.
 *
 * Test bench: tester_toggle_gen.v
 *
 * Time-stamp: Wed 16 Jun 2010 23:05:12 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 * http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 50)
 **************************************************************************************************/
`ifndef _toggle_gen_ `define _toggle_gen_

module toggle_gen
  #(parameter
    RST_TO_INPUT = 1)
   (input   clk,
    input   rst,
    input   pulse,
    output  toggle);

    reg q;

    assign toggle = q ^ pulse;


    generate
        if (RST_TO_INPUT) begin : RST_TO_INPUT_

            always @(posedge clk)
                if (rst)    q <= pulse;
                else        q <= toggle;

        end
        else begin : RST_TO_ZERO_

            always @(posedge clk)
                if (rst)    q <= 0;
                else        q <= toggle;

        end
    endgenerate

endmodule

`endif //  `ifndef _toggle_gen_
