/*******************************************************************************
 * TEST BENCH : flow_bus_register
 *
 * Time-stamp: Fri 28 May 2010 23:19:38 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 ******************************************************************************/

`timescale 1ns/10ps

`define TB_VERBOSE

`include "flow_bus_register.v"

module tester_flow_bus_register;

    /******************************************************************
     * This file declares a couple of redundant functions
      ******************************************************************/
`include "tester_skeleton.v"

    /******************************************************************
     * Parameters for the test bench
     ******************************************************************/
    localparam DATA_WIDTH   = 4;

    initial $display("Testbench for unit 'flow_bus_register'");

    /******************************************************************
     * Unit under test, and signals
     ******************************************************************/
    reg  clock;
    reg  reset;

    integer xx;

    reg                     enable;

    reg                     down_bus_ready;
    reg                     up_bus_valid;
    reg  [DATA_WIDTH-1:0]   up_bus;

    wire                    up_bus0_ready;
    wire                    down_bus0_valid;
    wire [DATA_WIDTH-1:0]   down_bus0;

    wire                    up_bus1_ready;
    wire                    down_bus1_valid;
    wire [DATA_WIDTH-1:0]   down_bus1;

    wire                    up_bus2_ready;
    wire                    down_bus2_valid;
    wire [DATA_WIDTH-1:0]   down_bus2;

    wire                    up_bus3_ready;
    wire                    down_bus3_valid;
    wire [DATA_WIDTH-1:0]   down_bus3;

    wire                    up_bus4_ready;
    wire                    down_bus4_valid;
    wire [DATA_WIDTH-1:0]   down_bus4;


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH),
        .REG_DEPTH_DATA     (0),
        .REG_DEPTH_READY    (0),
        .USE_READY          (0),
        .USE_VALID          (1),
        .USE_ENABLE         (0),
        .USE_RESET          (0))
    uut0 (
        .clk        (clock),
        .rst        (reset),
        .enable     (enable),
        .up_ready   (up_bus0_ready),
        .up_valid   (up_bus_valid),
        .up_data    (up_bus),
        .down_ready (down_bus_ready),
        .down_valid (down_bus0_valid),
        .down_data  (down_bus0) );


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH),
        .REG_DEPTH_DATA     (1),
        .REG_DEPTH_READY    (1),
        .USE_READY          (1),
        .USE_VALID          (1),
        .USE_ENABLE         (1),
        .USE_RESET          (1))
    uut1 (
        .clk        (clock),
        .rst        (reset),
        .enable     (enable),
        .up_ready   (up_bus1_ready),
        .up_valid   (up_bus_valid),
        .up_data    (up_bus),
        .down_ready (down_bus_ready),
        .down_valid (down_bus1_valid),
        .down_data  (down_bus1) );


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH),
        .REG_DEPTH_DATA     (8),
        .REG_DEPTH_READY    (1),
        .USE_READY          (1),
        .USE_VALID          (1),
        .USE_ENABLE         (1),
        .USE_RESET          (1))
    uut2 (
        .clk        (clock),
        .rst        (reset),
        .enable     (enable),
        .up_ready   (up_bus2_ready),
        .up_valid   (up_bus_valid),
        .up_data    (up_bus),
        .down_ready (down_bus_ready),
        .down_valid (down_bus2_valid),
        .down_data  (down_bus2) );


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH),
        .REG_DEPTH_DATA     (8),
        .REG_DEPTH_READY    (4),
        .USE_READY          (1),
        .USE_VALID          (1),
        .USE_ENABLE         (1),
        .USE_RESET          (1))
    uut3 (
        .clk        (clock),
        .rst        (reset),
        .enable     (enable),
        .up_ready   (up_bus3_ready),
        .up_valid   (up_bus_valid),
        .up_data    (up_bus),
        .down_ready (down_bus_ready),
        .down_valid (down_bus3_valid),
        .down_data  (down_bus3) );


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH),
        .REG_DEPTH_DATA     (1),
        .REG_DEPTH_READY    (1),
        .USE_READY          (1),
        .USE_VALID          (1),
        .USE_ENABLE         (1),
        .USE_RESET          (1))
    uut4 (
        .clk        (clock),
        .rst        (reset),
        .enable     (enable),
        .up_ready   (up_bus4_ready),
        .up_valid   (up_bus_valid),
        .up_data    (up_bus),
        .down_ready (down_bus_ready),
        .down_valid (down_bus4_valid),
        .down_data  (down_bus4) );


    /******************************************************************
     * USER Defined output
     ******************************************************************/
    task display_signals;
        $display({"%d\t%d",
            "\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            "\t%d\t%d\t%d",
            ""},
        $time, reset,

        enable,

        down_bus_ready,
        up_bus_valid,
        up_bus,

        up_bus0_ready,
        down_bus0_valid,
        down_bus0,

        up_bus1_ready,
        down_bus1_valid,
        down_bus1,

        up_bus2_ready,
        down_bus2_valid,
        down_bus2,

        up_bus3_ready,
        down_bus3_valid,
        down_bus3,

        up_bus4_ready,
        down_bus4_valid,
        down_bus4
        );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime\trst",
            "\ten",
            "\td_r\tu_v\tup_bus",
            "\t0 d_r\t0 u_v\t0 up",
            "\t1 d_r\t1 u_v\t1 up",
            "\t2 d_r\t2 u_v\t2 up",
            "\t3 d_r\t3 u_v\t3 up",
            "\t4 d_r\t4 u_v\t4 up",
            ""});
    endtask


    /******************************************************************
     * ALL the User TESTS defined here:
     ******************************************************************/
    task init;
        begin
            clock   <= 0;
            reset   <= 0;

            enable          <= 1'b1;
            down_bus_ready  <= 'b0;
            up_bus_valid    <= 'b0;
            up_bus          <= 'b0;
        end
    endtask // init


    task test_1;
        begin
            $display("TEST Static bus");

            up_bus <= 2;

            `wait_N_cycles_n(clock,5);
        end
    endtask


    task test_2;
        begin
            $display("TEST variable bus");

            down_bus_ready  <= 'b1;
            repeat (15) begin
                up_bus_valid    <= 1'b1;
                up_bus          <= $random;
                `wait_1_cycle_n(clock);
            end
        end
    endtask

    task test_3;
        begin
            $display("TEST turn enable low for 4");
            enable  <= 1'b0;
            `wait_N_cycles_n(clock,4);
            enable  <= 1'b1;
            `wait_N_cycles_n(clock,4);
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
            //`wait_1_cycle_n(clock);
            //`wait_N_cycles_n(clock,4);
        end
    endtask

    task test_7; begin end endtask
    task test_8; begin end endtask
    task test_9; begin end endtask
    task test_10; begin end endtask

endmodule
