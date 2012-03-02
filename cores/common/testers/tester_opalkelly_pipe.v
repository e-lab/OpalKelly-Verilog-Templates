/***************************************************************************************************
 * TEST BENCH : opalkelly_pipe
 *
 * Time-stamp: Fri 21 May 2010 12:40:39 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/

`timescale 1ns/10ps

//`define VERBOSE
`define TB_VERBOSE

`include "opalkelly_pipe.v"
`include "reset_sync.v"


module tester_opalkelly_pipe;

    /************************************************************************************
     * This file declares a couple of redundant functions
     ************************************************************************************/

`include "tester_skeleton.v"

    /************************************************************************************
     * Parameters for the test bench
     ************************************************************************************/

    localparam TX_ADDR_WIDTH   = 10;
    localparam RX_ADDR_WIDTH   = 10;


    initial $display("Testbench for unit 'opalkelly_pipe'");


    /************************************************************************************
     * Unit under test, and signals
     ************************************************************************************/

    reg         clock;
    reg         reset;

    reg         sys_clk;
    wire        sys_rst;
    reg         ti_clk;
    wire        ti_rst;


    reg         ti_in_data_en;
    reg  [15:0] ti_in_data;

    reg         ti_out_data_en;
    wire [15:0] ti_out_data;

    reg         ti_in_receive_toggle;
    reg  [15:0] ti_in_receive;
    reg         ti_out_receive_toggle;
    reg  [15:0] ti_out_receive;

    wire        ti_in_available_toggle;
    wire [15:0] ti_in_available;
    wire        ti_out_available_toggle;
    wire [15:0] ti_out_available;

    reg         sys_rx_ready;
    wire        sys_rx_valid;
    wire [15:0] sys_rx;

    wire        sys_tx_ready;
    reg         sys_tx_valid;
    reg  [15:0] sys_tx;


    always #5  sys_clk = !sys_clk;
    always #10 ti_clk  = !ti_clk;

    reset_sync
    reset_a2sys (
        .clk   (sys_clk),
        .arst  (reset),
        .rst   (sys_rst) );


    reset_sync
    reset_a2ti (
        .clk    (ti_clk),
        .arst   (reset),
        .rst    (ti_rst) );


    opalkelly_pipe #(
        .TX_ADDR_WIDTH  (TX_ADDR_WIDTH),
        .RX_ADDR_WIDTH  (RX_ADDR_WIDTH))
    uut (
        .sys_clk            (sys_clk),
        .sys_rst            (sys_rst),

        .ti_clk             (ti_clk),
        .ti_rst             (ti_rst),

        .ti_in_available    (ti_in_available),
        .ti_in_data_en      (ti_in_data_en),
        .ti_in_data         (ti_in_data),

        .ti_out_available   (ti_out_available),
        .ti_out_data_en     (ti_out_data_en),
        .ti_out_data        (ti_out_data),

        .sys_rx_ready       (sys_rx_ready),
        .sys_rx_valid       (sys_rx_valid),
        .sys_rx             (sys_rx),

        .sys_tx_ready       (sys_tx_ready),
        .sys_tx_valid       (sys_tx_valid),
        .sys_tx             (sys_tx) );


    /************************************************************************************
     * USER Defined output
     ************************************************************************************/

    task display_signals;
        $display({"%d\t%d",
                  "\t%d\t%d\t%d",
                  "\t%d\t%d\t%d",
                  "\t%d\t%d\t%d",
                  "\t%d\t%d\t%d",
                  ""},
            $time, reset,

            ti_in_available,
            ti_in_data_en,
            ti_in_data,

            sys_rx_ready,
            sys_rx_valid,
            sys_rx,

            ti_out_available,
            ti_out_data_en,
            ti_out_data,

            sys_tx_ready,
            sys_tx_valid,
            sys_tx,
            );
    endtask // display_signals

    task display_header;
        $display({"\t\ttime\trst",
                  "\tin_a\tin_en\tin",
                  "\trx_r\trx_v\trx",
                  "\tout_a\tout_en\tout",
                  "\ttx_r\ttx_v\ttx",

                  ""});
    endtask



    /************************************************************************************
     * ALL the User TESTS defined here:
     ************************************************************************************/

    task init;
        begin
            clock                   <= 0;
            reset                   <= 0;

            sys_clk                 <= 0;
            ti_clk                  <= 0;

            out_counter             <= 0;
            sys_tx_valid            <= 'b0;
            sys_tx                  <= 'b0;

            ti_in_receive_toggle     <= 'b0;
            ti_in_receive            <= 'b0;
            ti_out_receive_toggle    <= 'b0;
            ti_out_receive           <= 'b0;

            in_counter              <= 0;
            ti_in_data_en           <= 'b0;
            ti_out_data_en          <= 'b0;
            sys_rx_ready            <= 1'b1;

        end
    endtask // init

    integer     out_counter;
    integer     in_counter;
    reg  [15:0] buffer_size;
    reg         ti_out_available_toggle_previous;


    reg  [15:0] buffer_in_max;


    task test_1;
        begin

            `wait_N_cycles_n(ti_clk, 5);
            $display("TEST: send receive value");

            ti_in_receive           <= 100;
            ti_in_receive_toggle    <= ~ti_in_receive_toggle;

            `wait_1_cycle_n(ti_clk);

            repeat (100) begin
                ti_in_data_en   <= 1'b1;
                ti_in_data      <= in_counter;
                in_counter      <= in_counter + 1;
                `wait_1_cycle_n(ti_clk);
            end
            ti_in_data_en   <= 1'b0;

            `wait_N_cycles_n(ti_clk, 5);

        end
    endtask

    task test_2;
        begin
            $display("TEST: send data out");
            fork
                begin

                    repeat (100) begin
                        sys_tx_valid    <= 1'b1;
                        sys_tx          <= out_counter;
                        out_counter     <= out_counter+1;

                        `wait_1_cycle_n(sys_clk);
                    end

                    sys_tx_valid <= 1'b0;

                end

                begin

                    `wait_N_cycles_n(ti_clk, 15);


                    repeat (10) begin

                        ti_out_receive          <= ti_out_available;
                        ti_out_receive_toggle   <= ~ti_out_receive_toggle;
                        `wait_1_cycle_n(ti_clk);

                        repeat (ti_out_receive) begin
                            ti_out_data_en <= 1'b1;
                            `wait_1_cycle_n(ti_clk);
                        end
                        ti_out_data_en <= 1'b0;
                        `wait_1_cycle_n(ti_clk);

                    end
                end
            join
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
            $display("OTHER TESTS");

            //`wait_1_cycle_n(clock);
            //`wait_N_cycles_n(clock,5);
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
