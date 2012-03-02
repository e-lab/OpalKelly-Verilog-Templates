/*******************************************************************************
 * TEST BENCH : dual_circular_buffer
 *
 * Time-stamp: Wed 20 Jul 2011 12:18:47 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`define TB_VERBOSE

`include "dual_circular_buffer.v"

module tester_dual_circular_buffer;

    /******************************************************************
     * This file declares a couple of redundant functions
     ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/
    localparam DATA_WIDTH   = 6;
    localparam ADDR_WIDTH   = 4;
    localparam DIFFERENCE   = 3;

    initial $display("Testbench for unit 'dual_circular_buffer'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/

    reg clock;
    reg reset;

    reg                     up_clk;
    reg                     up_valid;
    reg  [DATA_WIDTH-1:0]   up_data;

    reg                     down_clk1;
    reg                     down_clk;
    wire                    down_valid;
    wire [DATA_WIDTH-1:0]   down_data;

    // Unit under test
    dual_circular_buffer #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DIFFERENCE (DIFFERENCE))
    uut (
        .arst        (reset),
        .up_clk      (up_clk),
        .up_valid    (up_valid),
        .up_data     (up_data),
        .down_clk    (down_clk),
        .down_valid  (down_valid),
        .down_data   (down_data) );


   /******************************************************************
    * USER Defined output
    ******************************************************************/
    task display_signals;
        $display({"%d\t%b",
                "\t%d\t%d\t%d",
                "\t%d\t%d\t%d"},
            $time, reset,

            up_clk,
            up_valid,
            up_data,

            down_clk,
            down_valid,
            down_data,
        );
   endtask // display_signals

   task display_header;
      $display({"\t\ttime\trst",
                "\tup_clk\tup_v\tup_data",
                "\tdo_clk\tdo_v\tdo_data",
                ""});
   endtask

   /******************************************************************
    * ALL the User TESTS defined here:
    ******************************************************************/

   always #8 up_clk = !up_clk;
   always #8 down_clk1 = !down_clk1;

   always @(posedge clock)
        down_clk <= down_clk1;


   /******************************************************************
    * ALL the User TESTS defined here:
    ******************************************************************/
    task init;
    begin
        clock       = 0;
        reset       = 0;

        up_clk      = 0;
        down_clk    = 0;
        down_clk1   = 0;
    end
    endtask // init


    task test_1;
    begin
        `wait_N_cycles_n(up_clk, 10);

        $display("TEST write to buf");
        repeat (5) begin
            up_valid    <= 1'b1;
            up_data     <= $random;
            `wait_1_cycle_n(up_clk);
        end
        up_valid    <= 1'b0;
        up_data     <= 0;
        `wait_N_cycles_n(up_clk, 10);

    end
    endtask


    task test_2;
    begin
        repeat (5) begin
            up_valid    <= 1'b1;
            up_data     <= $random;
            `wait_1_cycle_n(up_clk);
        end
        up_valid    <= 1'b0;
        up_data     <= 0;
        `wait_N_cycles_n(up_clk, 10);

        repeat (5) begin
            up_valid    <= 1'b1;
            up_data     <= $random;
            `wait_1_cycle_n(up_clk);
        end
        up_valid    <= 1'b0;
        up_data     <= 0;
        `wait_N_cycles_n(up_clk, 1);

        repeat (5) begin
            up_valid    <= 1'b1;
            up_data     <= $random;
            `wait_1_cycle_n(up_clk);
        end
        up_valid    <= 1'b0;
        up_data     <= 0;
        `wait_N_cycles_n(up_clk, 10);
    end
    endtask

    task test_3;
    begin
    end
    endtask

    task test_4;
    begin
    end
    endtask

    task test_5;
    begin
    end
    endtask

    task test_6;
    begin
    end
    endtask

    task test_7; begin end endtask
    task test_8; begin end endtask
    task test_9; begin end endtask
    task test_10; begin end endtask

endmodule
