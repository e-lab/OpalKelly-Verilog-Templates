/*******************************************************************************
 * TEST BENCH : fifo_sync
 *
 * Time-stamp: Fri 21 Aug 2009 17:15:39 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`include "fifo_sync.v"

`define TB_VERBOSE

module tester_fifo_sync;

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
    parameter LEAD_ALMOST_FULL  = 2;
    parameter LEAD_ALMOST_EMPTY = 2;

    initial $display("Testbench for unit 'fifo_sync'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/
    reg clock;
    reg reset;
    reg pop;
    reg push;

    reg [DATA_WIDTH-1:0]    data_push;
    wire [DATA_WIDTH-1:0]   data_pop;
    wire                    empty;
    wire                    full;
    wire                    empty_almost;
    wire                    full_almost;

    wire [ADDR_WIDTH:0]     count;

    // Unit under test
    fifo_sync #(.DATA_WIDTH         (DATA_WIDTH),
                .ADDR_WIDTH         (ADDR_WIDTH),
                .FALL               (FALL),
                .LEAD_ALMOST_FULL   (LEAD_ALMOST_FULL),
                .LEAD_ALMOST_EMPTY  (LEAD_ALMOST_EMPTY))
    uut (.data_pop      (data_pop),
         .count         (count),
         .full          (full),
         .full_almost   (full_almost),
         .empty         (empty),
         .empty_almost  (empty_almost),
         .data_push     (data_push),
         .clk           (clock),
         .rst           (reset),
         .push          (push),
         .pop           (pop));


   /******************************************************************
    * USER Defined output
    ******************************************************************/
   task display_signals;
      $display("%d\t%b\t%b\t%d\t%b\t%b\t%b\t%d\t%b\t%b\t%d\t%d",
        $time, reset,
        push,
        data_push,
        full,
        //uut.FULL_.full_a,
        full_almost,
        pop,
        data_pop,
        empty,
        empty_almost,
        //uut.EMPTY_.empty_a,
        //uut.raddr,
        //uut.EMPTY_.raddr_a[0],
        //uut.waddr,
        count,
        |(count[ADDR_WIDTH:ADDR_WIDTH-1])
    );
   endtask // display_signals

   task display_header;
      $display("\t\ttime\trst\tpush\tdat\tfull\tfull_a\tpop\tdat\tempty\tempty_a\tcount");
   endtask


   /******************************************************************
    * ALL the User TESTS defined here:
    ******************************************************************/
    task init;
    begin
        clock = 0;
        reset = 0;
        push = 0;
        data_push = 0;
        pop = 0;
    end
    endtask // init


    task test_1;
    begin

        $display("TEST write to fifo");
        repeat (20) begin
            push        <= 1'b1;
            data_push   <= $random;
            `wait_1_cycle_n(clock);
        end
        push        <= 1'b0;
        data_push   <= 0;
        //`wait_N_cycles_n(clock,250);

    end
    endtask


    task test_2;
    begin
        $display("TEST read from fifo");
        `wait_1_cycle_n(clock);
        repeat (16) begin
            pop         <= 1'b1;
            `wait_N_cycles_n(clock,2);
        end
        pop         <= 1'b0;
    end
    endtask

    task test_3;
    begin
        $display("TEST write 5 data points to fifo");
        repeat (5) begin
            push        <= 1'b1;
            data_push   <= $random;
            `wait_1_cycle_n(clock);
        end
        push        <= 1'b0;
        data_push   <= 0;
        `wait_N_cycles_n(clock,5);

        $display("TEST read two data points from fifo");
        repeat (2) begin
            pop         <= 1'b1;
            `wait_N_cycles_n(clock,2);
        end
        pop         <= 1'b0;

        `wait_N_cycles_n(clock,5);
        $display("TEST write 15 data points to fifo");
        repeat (15) begin
            push        <= 1'b1;
            data_push   <= $random;
            `wait_1_cycle_n(clock);
        end
        push        <= 1'b0;
        data_push   <= 0;
        `wait_N_cycles_n(clock,5);

        $display("TEST read two data points from fifo");
        `wait_1_cycle_n(clock);
        repeat (8) begin
            pop         <= 1'b1;
            `wait_N_cycles_n(clock,2);
        end
        pop         <= 1'b0;

    end
    endtask

    task test_4;
    begin
        $display("TEST simaltaiouse read/write 15 data points to fifo");
        repeat (15) begin
            pop         <= 1'b1;
            push        <= 1'b1;
            data_push   <= $random;
            `wait_1_cycle_n(clock);
        end
        repeat (15) begin
            pop         <= 1'b1;
         //   push        <= 1'b1;
          //  data_push   <= $random;
            `wait_1_cycle_n(clock);
        end
    end
    endtask

    task test_5;
    begin
        $display("OTHER TESTS");
        push        <= 1'b0;
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
