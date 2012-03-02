/***************************************************************************************************
 * TEST BENCH : sdram_stream_interface2
 *
 * Created: Mon 12 Jul 2010 23:11:33 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/

`timescale 1ns/10ps

//`define VERBOSE
`define TB_VERBOSE

`include "sdram_stream_interface.v"
`include "reset_sync.v"


module tester_sdram_stream_interface2;

    initial $display("Testbench for unit 'sdram_stream_interface2'");


    /************************************************************************************
     * Parameters and signal definitions for the test bench
     ************************************************************************************/

    localparam SDRAM_ADDR_WIDTH = 13;

    integer         counter;
    reg             clk;
    reg             reset;

    // System Side
    reg             sys_clk;
    wire            sys_rst;

    wire            sys_wr_ready;
    reg             sys_wr_valid;
    reg   [15:0]    sys_wr_data;

    reg             sys_rd_ready;
    wire            sys_rd_valid;
    wire  [15:0]    sys_rd_data;

    wire            sys_fault_ifull;
    wire            sys_fault_oempty;

    // SDRAM Side
    wire            sdram_clk;
    wire            sdram_rst;

    reg             sdram_wren;
    reg             sdram_rden;

    wire            sdram_fault_ofull;
    wire            sdram_fault_iempty;

    reg             sdram_cmd_ack;
    reg             sdram_cmd_done;
    wire            sdram_cmd_wr;
    wire            sdram_cmd_rd;
    wire  [14:0]    sdram_addr;

    wire  [15:0]    sdram_wr_data;
    reg             sdram_wr_data_en;
    reg   [15:0]    sdram_rd_data;
    reg             sdram_rd_data_en;


    /************************************************************************************
     * Unit under test and test processes
     ************************************************************************************/

    // Generate a clk
    always #1 clk       = !clk;
    always #4 sys_clk   = !sys_clk;
    assign sdram_clk    = clk;

    // End of simulation event definition
    event end_trigger;
    always @(end_trigger) display_header();
    always @(end_trigger) $finish;

    // And strobe signals at each clk
    always @(posedge clk) display_signals();


//    initial begin
//        $dumpfile("result.vcd"); // Waveform file
//        $dumpvars;
//    end

    reset_sync
    reset_a2sys (
        .clk    (sys_clk),
        .arst   (reset),
        .rst    (sys_rst) );


    reset_sync
    reset_a2sdram (
        .clk    (sdram_clk),
        .arst   (reset),
        .rst    (sdram_rst) );


    sdram_stream_interface #(
        .SDRAM_ADDR_WIDTH (SDRAM_ADDR_WIDTH))
    uut (// System Side
        .sys_clk                (sys_clk),
        .sys_rst                (sys_rst),

        //.sys_fault_ifull        (sys_fault_ifull),
        //.sys_fault_oempty       (sys_fault_oempty),

        .sys_wr_ready           (sys_wr_ready),
        .sys_wr_valid           (sys_wr_valid),
        .sys_wr_data            (sys_wr_data),

        .sys_rd_ready           (sys_rd_ready),
        .sys_rd_valid           (sys_rd_valid),
        .sys_rd_data            (sys_rd_data),

        // SDRAM Side
        .sdram_clk              (sdram_clk),
        .sdram_rst              (sdram_rst),

        //.sdram_wren             (sdram_wren),
        //.sdram_rden             (sdram_rden),

        //.sdram_fault_ofull      (sdram_fault_ofull),
        //.sdram_fault_iempty     (sdram_fault_iempty),

        .sdram_cmd_ack          (sdram_cmd_ack),
        .sdram_cmd_done         (sdram_cmd_done),
        .sdram_cmd_wr           (sdram_cmd_wr),
        .sdram_cmd_rd           (sdram_cmd_rd),
        .sdram_addr             (sdram_addr),
        .sdram_wr_data          (sdram_wr_data),
        .sdram_wr_data_en       (sdram_wr_data_en),
        .sdram_rd_data          (sdram_rd_data),
        .sdram_rd_data_en       (sdram_rd_data_en) );


    /************************************************************************************
     * USER Defined wire
     ************************************************************************************/
    task display_signals;
        $display({"%d\t%d",
                  "\t%d\t%d\t%d",
                  "\t%b\t%d\t%d",
                  ""},
            $time, reset,
            sys_wr_ready,
            sys_wr_valid,
            sys_wr_data,

            uut.state,
            uut.sdram_full,
            uut.sdram_empty,
            );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime\trst",
            "\twr_r\twr_v\twr_d",
            "\tstate\tsdr_f\tsdr_e",
            ""});
    endtask

    /************************************************************************************
     * ALL the User TESTS defined here:
     ************************************************************************************/

    initial begin
        counter             = 'b1;
        clk                 = 'b0;
        reset               = 'b0;

        sys_clk             = 'b0;
        sys_wr_valid        = 'b0;
        sys_wr_data         = 'b0;
        sys_rd_ready        = 'b0;

        sdram_wren          = 'b0;
        sdram_rden          = 'b0;
        sdram_cmd_ack       = 'b0;
        sdram_cmd_done      = 'b0;
        sdram_wr_data_en    = 'b0;
        sdram_rd_data       = 'b0;
        sdram_rd_data_en    = 'b0;
    end

    initial begin
        #1 display_header();

        $display("HARD RESET");
        @(negedge clk);
        reset <= 'b1;
        repeat(2) @(negedge clk);
        reset <= 'b0;
        repeat(10) @(negedge clk);


        $display("TEST pipe data in");
        @(negedge sys_clk);
        repeat (512) begin
            sys_wr_valid    <= 1'b1;
            sys_wr_data     <= counter;
            counter         <= counter + 1;

            @(negedge sys_clk);
        end
//        ti_data_in_en   <= 1'b0;
//        ti_data_in      <= 'b0;
//        counter         <= 1;
//        repeat(5) @(negedge sys_clk);
//
//        $display("TEST pipe data out");
//        @(negedge sys_clk);
//        ti_data_out_en <= 1'b1;
//        repeat(16) @(negedge sys_clk);
//        ti_data_out_en <= 1'b0;
//        repeat(5) @(negedge sys_clk);


        repeat(50) @(negedge sdram_clk);

        $display("END");
        -> end_trigger;
    end



endmodule
