/*******************************************************************************
 * TEST BENCH : fifo_async
 *
 * Time-stamp: Fri 21 Aug 2009 17:15:39 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`include "fifo_async.v"

`define TB_VERBOSE

module tester_fifo_async;

    /******************************************************************
     * This file declares a couple of redundant functions
     ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/

    parameter DATA_WIDTH        = 6;
    parameter ADDR_WIDTH        = 4;
    parameter FALL              = 1;
    parameter LEAD_ALMOST_FULL  = 3;
    parameter LEAD_ALMOST_EMPTY = 1;

    initial $display("Testbench for unit 'fifo_async'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/

    reg                     clock;
    reg                     clock2;
    reg                     clock3;
    reg                     reset;
    reg                     pop;
    reg                     push;
    wire                    pop_clk;
    wire                    push_clk;

    reg  [DATA_WIDTH-1:0]   push_data;
    wire [DATA_WIDTH-1:0]   pop_data;
    wire                    pop_empty;
    wire [ADDR_WIDTH:0]     pop_count;
    wire                    pop_empty_a;
    wire                    push_full;
    wire                    push_full_a;
    wire [ADDR_WIDTH:0]     push_count;

    reg                     pop_rst;
    reg                     rrff;
    reg                     push_rst;
    reg                     wrff;

    always #10 clock2 = !clock2;
    always #15 clock3 = !clock3;

    assign pop_clk  = clock;
    assign push_clk = clock2;

    // De-asserting reset synchronizer for asynchronous rd reset.
    always @(posedge pop_clk or posedge reset)
        if (reset)  {pop_rst, rrff} <= 2'b11;
        else        {pop_rst, rrff} <= {rrff, 1'b0};


    // De-asserting reset synchronizer for asynchronous wr reset.
    always @(posedge push_clk or posedge reset)
        if (reset)  {push_rst, wrff} <= 2'b11;
        else        {push_rst, wrff} <= {wrff, 1'b0};


    // Unit under test
    fifo_async #(.DATA_WIDTH        (DATA_WIDTH),
                 .ADDR_WIDTH        (ADDR_WIDTH),
                 .FALL              (FALL),
                 .LEAD_ALMOST_FULL  (LEAD_ALMOST_FULL),
                 .LEAD_ALMOST_EMPTY (LEAD_ALMOST_EMPTY))
    uut (.pop_clk       (pop_clk),
         .pop_rst       (pop_rst),
         .pop           (pop),
         .pop_data      (pop_data),
         .pop_empty     (pop_empty),
         .pop_empty_a   (pop_empty_a),
         .pop_count     (pop_count),

         .push_clk      (push_clk),
         .push_rst      (push_rst),
         .push          (push),
         .push_data     (push_data),
         .push_full     (push_full),
         .push_full_a   (push_full_a),
         .push_count    (push_count) );




    /******************************************************************
     * USER Defined output
     ******************************************************************/
    task display_signals;
        $display({"%d\t%d",
                  "\t%d\t%d\t%d\t%d\t%d",
                  "\t%d\t%d\t%d\t%d\t%d",
                  ""},
            $time, reset,

            push,
            push_data,
            push_full,
            push_full_a,
            push_count,

            pop,
            pop_data,
            pop_empty,
            pop_empty_a,
            pop_count
        );
    endtask // display_signals

    task display_header;
        $display({"\t\ttime\trst",
                  "\tpush\tdat\tfull\tf_a\tpu_cnt",
                  "\tpop\tdat\tempty\te_a\tpo_cnt",
                  ""});
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
            pop         = 0;
        end
    endtask // init


    task test_1;
        begin
            `wait_N_cycles_n(push_clk,15);

            $display("TEST write to fifo");
            push        <= 1'b1;
            push_data   <= $random;
            `wait_1_cycle_n(push_clk);
            push        <= 1'b0;
            `wait_N_cycles_n(push_clk,4);
            push        <= 1'b1;
            push_data   <= $random;
            `wait_1_cycle_n(push_clk);
            push        <= 1'b0;
            `wait_N_cycles_n(push_clk,4);

            repeat (10) begin
                push        <= 1'b1;
                push_data   <= $random;
                `wait_1_cycle_n(push_clk);
            end
            push        <= 1'b0;
            push_data   <= 0;
            `wait_1_cycle_n(push_clk);
            //`wait_N_cycles_n(push_clk, 250);

        end
    endtask


    task test_2;
        begin

            $display("TEST read from fifo");
           `wait_1_cycle_n(pop_clk);
            repeat (16) begin
                pop         <= 1'b1;
                `wait_1_cycle_n(pop_clk);
            end
            pop         <= 1'b0;
            `wait_1_cycle_n(pop_clk);
        end
    endtask

    task test_3;
        begin

            $display("TEST write 5 data points to fifo");
            `wait_1_cycle_n(push_clk);
            repeat (5) begin
                push        <= 1'b1;
                push_data   <= $random;
                `wait_1_cycle_n(push_clk);
            end
            push        <= 1'b0;
            push_data   <= 0;
            `wait_N_cycles_n(push_clk,5);


            $display("TEST read two data points from fifo");
            `wait_1_cycle_n(pop_clk);
            repeat (2) begin
                pop         <= 1'b1;
                `wait_1_cycle_n(pop_clk);
            end
            pop         <= 1'b0;
            `wait_N_cycles_n(pop_clk,5);


            $display("TEST write 15 data points to fifo");
            `wait_1_cycle_n(push_clk);
            repeat (15) begin
                push        <= 1'b1;
                push_data   <= $random;
                `wait_1_cycle_n(push_clk);
            end
            push        <= 1'b0;
            push_data   <= 0;
            `wait_N_cycles_n(push_clk,5);


            $display("TEST read all the remaing data points from fifo");
            `wait_1_cycle_n(pop_clk);
            repeat (25) begin
                pop         <= 1'b1;
                `wait_1_cycle_n(pop_clk);
            end
            pop         <= 1'b0;
            `wait_1_cycle_n(pop_clk);

        end
    endtask

    task test_4;
        begin
            $display("OTHER TESTS");
        end
    endtask

    task test_5; begin end endtask
    task test_6; begin end endtask
    task test_7; begin end endtask
    task test_8; begin end endtask
    task test_9; begin end endtask
    task test_10; begin end endtask

endmodule
