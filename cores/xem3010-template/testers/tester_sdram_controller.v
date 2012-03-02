/***************************************************************************************************
 * TEST BENCH : sdram_controller
 *
 * Created: Tue  6 Jul 2010 11:24:26 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/

`timescale 1ns/10ps
`include "sdram_controller.v"

//`define VERBOSE
`define TB_VERBOSE

module tester_sdram_controller;

    initial $display("Testbench for unit 'sdram_controller'");


    /************************************************************************************
     * Parameters and signal definitions for the test bench
     ************************************************************************************/

    localparam SDRAM_DATA_WIDTH = 16;
    localparam SDRAM_BURST_MODE = 8;
    localparam SDRAM_BANK_WIDTH = 2;
    localparam SDRAM_ROW_WIDTH  = 13;
    localparam SDRAM_COL_WIDTH  = 9;

    localparam SDRAM_ADDR_WIDTH = SDRAM_BANK_WIDTH + SDRAM_ROW_WIDTH + SDRAM_COL_WIDTH;
    localparam SDRAM_MASK_WIDTH = `CLOG2(SDRAM_DATA_WIDTH*SDRAM_BURST_MODE);

    integer                     counter;
    reg                         clk;

    reg                         sdr_clk;
    reg                         sdr_rst;

    wire                        sdr_wr_ready;
    reg                         sdr_wr_valid;
    reg  [SDRAM_DATA_WIDTH-1:0] sdr_wr_data;
    reg  [SDRAM_MASK_WIDTH-1:0] sdr_wr_mask;
    reg  [SDRAM_ADDR_WIDTH-1:0] sdr_wr_addr;

    wire                        sdr_rd_ready;
    reg                         sdr_rd_valid;
    reg  [SDRAM_ADDR_WIDTH-1:0] sdr_rd_addr;
    reg  [SDRAM_MASK_WIDTH-1:0] sdr_rd_mask;

    reg                         sdr_rd_data_ready;
    wire                        sdr_rd_data_valid;
    wire [SDRAM_DATA_WIDTH-1:0] sdr_rd_data;

    wire                        sdr_cke;
    wire                        sdr_cs_n;
    wire                        sdr_we_n;
    wire                        sdr_cas_n;
    wire                        sdr_ras_n;
    wire                        sdr_ldqm;
    wire                        sdr_udqm;
    wire [1:0]                  sdr_ba;
    wire [12:0]                 sdr_a;
    wire [15:0]                 sdr_d;

    /************************************************************************************
     * Unit under test and test processes
     ************************************************************************************/

    // Generate a clk
    always #1  clk      = !clk;
    always #10 sdr_clk  = !sdr_clk;

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

    sdram_controller #(
        .SDRAM_DATA_WIDTH   (SDRAM_DATA_WIDTH),
        .SDRAM_BURST_MODE   (SDRAM_BURST_MODE),
        .SDRAM_BANK_WIDTH   (SDRAM_BANK_WIDTH),
        .SDRAM_ROW_WIDTH    (SDRAM_ROW_WIDTH),
        .SDRAM_COL_WIDTH    (SDRAM_COL_WIDTH))
    uut (
        .sdr_clk            (sdr_clk),
        .sdr_rst            (sdr_rst),

        .sdr_wr_ready       (sdr_wr_ready),
        .sdr_wr_valid       (sdr_wr_valid),
        .sdr_wr_data        (sdr_wr_data),
        .sdr_wr_mask        (sdr_wr_mask),
        .sdr_wr_addr        (sdr_wr_addr),

        .sdr_rd_ready       (sdr_rd_ready),
        .sdr_rd_valid       (sdr_rd_valid),
        .sdr_rd_mask        (sdr_rd_mask),
        .sdr_rd_addr        (sdr_rd_addr),

        .sdr_rd_data_ready  (sdr_rd_data_ready),
        .sdr_rd_data_valid  (sdr_rd_data_valid),
        .sdr_rd_data        (sdr_rd_data),

        .sdr_cke            (sdr_cke),
        .sdr_cs_n           (sdr_cs_n),
        .sdr_we_n           (sdr_we_n),
        .sdr_cas_n          (sdr_cas_n),
        .sdr_ras_n          (sdr_ras_n),
        .sdr_ldqm           (sdr_ldqm),
        .sdr_udqm           (sdr_udqm),
        .sdr_ba             (sdr_ba),
        .sdr_a              (sdr_a),
        .sdr_d              (sdr_d) );


    /************************************************************************************
     * USER Defined wire
     ************************************************************************************/
    task display_signals;
        $display({"%d",
                  "\t%d\t%d\t%d\t%d\t%d\t%d",
                  "\t%b",
                  //"\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",
                  //"\t%b\t%d",
                  ""},
            $time,
            //sdr_rst,

            //sdr_cke,
            sdr_cs_n,
            sdr_ras_n,
            sdr_cas_n,
            sdr_we_n,
            //sdr_ldqm,
            //sdr_udqm,
            sdr_ba,
            sdr_a,
            //sdr_d,

            uut.state
            //uut.cINIT
            );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime",
           //"\trst",
           //"\tcke",
           "\tcs_n",
           "\tras_n",
           "\tcas_n",
           "\twe_n",
           //"\tldqm",
           //"\tudqm",
           "\tba",
           "\tsdr_a",
           //"\tsdr_d",
           ""});
    endtask

    /************************************************************************************
     * ALL the User TESTS defined here:
     ************************************************************************************/

    initial begin
        counter             <= 'b1;
        clk                 <= 'b0;

        sdr_clk             <= 'b0;
        sdr_rst             <= 'b0;
    end

    initial begin
        #1 display_header();

        $display("HARD RESET");
        @(negedge sdr_clk);
        sdr_rst <= 'b1;
        repeat(2) @(negedge sdr_clk);
        sdr_rst <= 'b0;
        repeat(1) @(negedge sdr_clk);



        $display("TEST pipe data in");
//        @(negedge ti_clk);
//        repeat (10) begin
//            ti_data_in_en   <= 1'b1;
//            ti_data_in      <= counter;
//            counter         <= counter + 1;
//
//            @(negedge ti_clk);
//        end
//        ti_data_in_en   <= 1'b0;
//        ti_data_in      <= 'b0;
//        counter         <= 1;
//        repeat(5) @(negedge ti_clk);
//
//        $display("TEST pipe data out");
//        @(negedge ti_clk);
//        ti_data_out_en <= 1'b1;
//        repeat(16) @(negedge ti_clk);
//        ti_data_out_en <= 1'b0;
//        repeat(5) @(negedge ti_clk);
//

        repeat(50) @(negedge sdr_clk);

        $display("END");
        -> end_trigger;
    end



endmodule
