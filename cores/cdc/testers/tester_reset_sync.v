/*******************************************************************************
 * TEST BENCH : reset_sync
 *
 * Time-stamp: <Thu 30 Jul 2009 16:48:13 EDT>
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`include "reset_sync.v"

`define TB_VERBOSE

module tester_reset_sync;

    /******************************************************************
     * This file declares a couple of redundant functions
     ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/

    initial $display("Testbench for unit 'reset_sync'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/
    reg     clock;
    reg     reset;
    wire    sinced_rst;

    reset_sync
    uut (
        .clk      (clock),
        .arst     (reset),
        .rst      (sinced_rst));



   /******************************************************************
    * USER Defined output
    ******************************************************************/
   task display_signals;
      $display("%d\t%b\t%b",
        $time, reset, sinced_rst);
   endtask // display_signals

   task display_header;
      $display("\t\ttime\tarst\trst");
   endtask


   /******************************************************************
    * ALL the User TESTS defined here:
    ******************************************************************/
    task init;
        begin
            clock   = 0;
            reset   = 0;
        end
    endtask // init


    task test_1;
        begin
            $display("TEST. Useless");
            `wait_N_cycles_n(clock,5);
        end
    endtask


    task test_2;
        begin
            $display("OTHER TESTS");
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
