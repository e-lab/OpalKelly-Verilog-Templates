/*******************************************************************************
 * TEST BENCH : fifo_async_1deep
 *
 * Time-stamp: Fri 21 Aug 2009 17:15:39 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/1ps

`include "fifo_async_1deep.v"

`define TB_VERBOSE

module tester_fifo_async_1deep;

    /******************************************************************
     * This file declares a couple of redundant functions
     ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/
    parameter DATA_WIDTH        = 6;

    initial $display("Testbench for unit 'fifo_async_1deep'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/

    reg                     clock;
    reg                     clock2;
    reg                     clock3;
    reg                     reset;
    wire                    pop;
    reg                     push;
    wire                    pop_clk;
    wire                    push_clk;

    reg  [DATA_WIDTH-1:0]   push_data;
    wire [DATA_WIDTH-1:0]   pop_data;
    wire                    pop_ready;
    wire                    push_ready;

    reg                     pop_rst;
    reg                     rrff;
    reg                     push_rst;
    reg                     wrff;

    always #5 clock2 = !clock2;
    always #10 clock3 = !clock3;

    assign pop_clk  = clock2;
    assign push_clk = clock3;

    // De-asserting reset synchronizer for asynchronous rd reset.
    always @(posedge pop_clk or posedge reset)
        if (reset)  {pop_rst, rrff} <= 2'b11;
        else        {pop_rst, rrff} <= {rrff, 1'b0};


    // De-asserting reset synchronizer for asynchronous wr reset.
    always @(posedge push_clk or posedge reset)
        if (reset)  {push_rst, wrff} <= 2'b11;
        else        {push_rst, wrff} <= {wrff, 1'b0};


    // Unit under test
    fifo_async_1deep  #(.DATA_WIDTH (DATA_WIDTH))
    uut (.pop_clk       (pop_clk),
         .pop_rst       (pop_rst),
         .pop           (pop),
         .pop_data      (pop_data),
         .pop_ready     (pop_ready),

         .push_clk      (push_clk),
         .push_rst      (push_rst),
         .push          (push),
         .push_data     (push_data),
         .push_ready    (push_ready));

    // auto pop
    assign pop = pop_ready;


    /******************************************************************
     * USER Defined output
     ******************************************************************/
    task display_signals;
        $display("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",
            $time, reset,
            push,
            push_data,
            push_ready,
            pop,
            pop_data,
            pop_ready);
    endtask // display_signals

    task display_header;
        $display("\t\ttime\trst\tpush\tdat\tready\tpop\tdat\tpop_ready");
    endtask


    /******************************************************************
     * ALL the User TESTS defined here:
     ******************************************************************/
    task init;
        begin
            clock       = 0;
            clock2      = 0;
            clock3      = 0;
            reset       = 0;
            push        = 0;
            push_data   = 0;
        end
    endtask // init


    task test_1;
        begin
            $display("TEST stream data through fifo");
            push        <= 1'b0;
            push_data   <= 'b0;
            `wait_N_cycles_n(push_clk, 2);

            repeat (10) begin
                push        <= 1'b1;
                push_data   <= $random;
                `wait_1_cycle_n(push_clk);
            end
        end
    endtask

    task test_2; begin end endtask
    task test_3; begin end endtask
    task test_4; begin end endtask
    task test_5; begin end endtask
    task test_6; begin end endtask
    task test_7; begin end endtask
    task test_8; begin end endtask
    task test_9; begin end endtask
    task test_10; begin end endtask

endmodule
