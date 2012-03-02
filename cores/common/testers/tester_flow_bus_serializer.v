/*******************************************************************************
 * TEST BENCH : flow_bus_serializer
 *
 * Time-stamp: Thu  9 Jun 2011 16:29:59 EST
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`define TB_VERBOSE

`include "flow_bus_serializer.v"

module tester_flow_bus_serializer;

    /******************************************************************
     * This file declares a couple of redundant functions
      ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/
    localparam DATA_WIDTH       = 8;
    localparam DATA_NUM         = 2;

    initial $display("Testbench for unit 'flow_bus_serializer'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/
    reg  clock;
    reg  reset;

    reg                                 enable;

    wire                                up_ready0;
    wire                                up_ready1;
    wire                                up_ready3;
    reg                                 up_valid0;
    reg                                 up_valid1;
    reg                                 up_valid2;
    reg  [(DATA_WIDTH*DATA_NUM)-1:0]    up_data;

    reg                                 down_ready;
    wire                                down_valid0;
    wire [DATA_WIDTH-1:0]               down_data0;
    wire                                down_valid1;
    wire [DATA_WIDTH-1:0]               down_data1;
    wire                                down_valid2;
    wire [DATA_WIDTH-1:0]               down_data2;


    flow_bus_serializer #(
        .DATA_WIDTH         (DATA_WIDTH),
        .DATA_NUM           (DATA_NUM),
        .REG_DEPTH_DATA     (0),
        .REG_DEPTH_READY    (0),
        .USE_READY          (0),
        .USE_ENABLE         (0))
    uut0 (
        .clk        (clock),
        .rst        (reset),
        .enable     (enable),
        .up_ready   (up_ready0),
        .up_valid   (up_valid0),
        .up_data    (up_data),
        .down_ready (down_ready),
        .down_valid (down_valid0),
        .down_data  (down_data0) );


    flow_bus_serializer #(
        .DATA_WIDTH         (DATA_WIDTH),
        .DATA_NUM           (DATA_NUM),
        .REG_DEPTH_DATA     (0),
        .REG_DEPTH_READY    (0),
        .USE_READY          (1),
        .USE_ENABLE         (1))
    uut1 (
        .clk          (clock),
        .rst          (reset),
        .enable       (enable),
        .up_ready     (up_ready1),
        .up_valid     (up_valid1),
        .up_data      (up_data),
        .down_ready   (down_ready),
        .down_valid   (down_valid1),
        .down_data    (down_data1) );


    flow_bus_serializer #(
        .DATA_WIDTH         (DATA_WIDTH),
        .DATA_NUM           (DATA_NUM),
        .REG_DEPTH_DATA     (2),
        .REG_DEPTH_READY    (0),
        .USE_READY          (1),
        .USE_ENABLE         (1))
    uut2 (
        .clk          (clock),
        .rst          (reset),
        .enable       (enable),
        .up_ready     (up_ready2),
        .up_valid     (up_valid2),
        .up_data      (up_data),
        .down_ready   (down_ready),
        .down_valid   (down_valid2),
        .down_data    (down_data2) );


    /******************************************************************
     * USER Defined output
     ******************************************************************/
    task display_signals;
        $display({"%d\t%d",
            "\t%d\t%d\t%d\t%d\t%d\t%d",
            "\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            ""},
        $time, reset,

        down_ready,
        up_valid0,
        up_valid1,
        up_valid2,
        up_data[(DATA_WIDTH*DATA_NUM)-1:(DATA_WIDTH*DATA_NUM/2)],
        up_data[(DATA_WIDTH*DATA_NUM/2)-1:0],

        enable,

        up_ready0,
        down_valid0,
        down_data0,

        up_ready1,
        down_valid1,
        down_data1,

        up_ready2,
        down_valid2,
        down_data2,
        );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime\trst",
            "\td_r\tu_v0\tu_v1\tu_v2\tu_da\tu_db",
            "\ten",
            "\tu_r0\td_v0\td_d0",
            "\tu_r1\td_v1\td_d1",
            "\tu_r2\td_v2\td_d2",
            ""});
    endtask


    /******************************************************************
     * ALL the User TESTS defined here:
     ******************************************************************/
    task init;
        begin
            clock       <= 0;
            reset       <= 0;
            enable      <= 1;

            down_ready  <= 1'b1;
            up_valid0   <= 1'b0;
            up_valid1   <= 1'b0;
            up_valid2   <= 1'b0;
            up_data     <= 'b0;
        end
    endtask // init


    task test_1;
        begin
            $display("TEST ");

            repeat (10) begin
                up_valid0 <= 1'b1;
                up_valid1 <= up_ready1;
                up_valid2 <= up_ready2;
                up_data[(DATA_WIDTH*DATA_NUM)-1:(DATA_WIDTH*DATA_NUM/2)]    <= $random;
                up_data[(DATA_WIDTH*DATA_NUM/2)-1:0]                        <= $random;

                `wait_1_cycle_n(clock);
            end
            enable <= 0;

            repeat (10) begin
                up_valid0 <= 1'b0;
                up_valid1 <= up_ready1;
                up_valid2 <= up_ready2;
                up_data[(DATA_WIDTH*DATA_NUM)-1:(DATA_WIDTH*DATA_NUM/2)]    <= $random;
                up_data[(DATA_WIDTH*DATA_NUM/2)-1:0]                        <= $random;

                `wait_1_cycle_n(clock);
            end

            repeat (10) begin
                enable <= 1;
                up_valid0 <= 1'b1;
                up_valid1 <= 1'b1;
                up_valid2 <= 1'b1;
                up_data[(DATA_WIDTH*DATA_NUM)-1:(DATA_WIDTH*DATA_NUM/2)]    <= $random;
                up_data[(DATA_WIDTH*DATA_NUM/2)-1:0]                        <= $random;

                `wait_1_cycle_n(clock);

                up_valid1 <= 1'b0;
                up_valid2 <= 1'b0;

                `wait_1_cycle_n(clock);
            end
            up_valid0 <= 1'b0;
            up_valid1 <= 1'b0;
            up_valid2 <= 1'b0;

            `wait_N_cycles_n(clock,5);
        end
    endtask


    task test_2;
        begin
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
            $display("OTHER TESTS");
            `wait_1_cycle_n(clock);
            `wait_N_cycles_n(clock,4);
        end
    endtask

    task test_7; begin end endtask
    task test_8; begin end endtask
    task test_9; begin end endtask
    task test_10; begin end endtask

endmodule
