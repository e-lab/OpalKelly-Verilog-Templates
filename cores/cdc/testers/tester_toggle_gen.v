/*******************************************************************************
 * TEST BENCH : toggle_gen
 *
 * Time-stamp: Wed 16 Jun 2010 23:21:28 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`include "toggle_gen.v"

`define TB_VERBOSE

module tester_toggle_gen;

    /******************************************************************
     * This file declares a couple of redundant functions
     ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/

    initial $display("Testbench for unit 'toggle_gen'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/

    reg clock;
    reg reset;

    wire toggle;
    reg  pulse;

    toggle_gen
    uut (
        .clk    (clock),
        .rst    (reset),
        .toggle (toggle),
        .pulse  (pulse) );


   /******************************************************************
    * USER Defined output
    ******************************************************************/

   task display_signals;
      $display("%d\t%b\t%d\t%d\t%d",
        $time, reset, uut.q, toggle, pulse);
   endtask // display_signals

   task display_header;
      $display("\t\ttime\trst\tq\ttoggle\tpulse");
   endtask


   /******************************************************************
    * ALL the User TESTS defined here:
    ******************************************************************/
    task init;
        begin
            clock   <= 0;
            reset   <= 0;
            pulse   <= 1'b0;
        end
    endtask // init


    task test_1;
        begin
            $display("TEST mux on the write address/word");
            `wait_N_cycles_n(clock,5);
            pulse <= 1'b1;
            `wait_1_cycle_n(clock);
            pulse <= 1'b0;
            `wait_N_cycles_n(clock,5);
            pulse <= 1'b1;
            `wait_1_cycle_n(clock);
            pulse <= 1'b0;
            `wait_N_cycles_n(clock,5);
            pulse <= 1'b1;
            `wait_1_cycle_n(clock);
            pulse <= 1'b0;
            `wait_N_cycles_n(clock,5);

        end
    endtask


    task test_2;
        begin
            $display("OTHER TESTS");

            //`wait_1_cycle_n(clock);
            //`wait_N_cycles_n(clock,5);
        end
    endtask

    task test_3; begin end endtask
    task test_4; begin end endtask
    task test_5; begin end endtask
    task test_6; begin end endtask
    task test_7; begin end endtask
    task test_8; begin end endtask
    task test_9; begin end endtask
    task test_10; begin end endtask

endmodule
