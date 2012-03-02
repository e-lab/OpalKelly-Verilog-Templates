/***************************************************************************************************
 * TEST BENCH : xem3010_template_project
 *
 * Time-stamp: Sun 28 Mar 2010 17:28:04 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/

`timescale 1ns/10ps
`include "xem3010_template_project.v"

//`define VERBOSE
`define TB_VERBOSE

module tester_xem3010_template_project;

    initial $display("Testbench for unit 'xem3010_template_project'");


    /************************************************************************************
     * Parameters and signal definitions for the test bench
     ************************************************************************************/
    localparam BUFF_ADDR_WIDTH = 10;

    reg         clk;
    integer     counter;

    wire [7:0]  led;
    reg         ti_clk;

    reg  [15:0] ep00wire;

    wire [15:0] ti_in_available;
    reg         ti_in_data_en;
    reg  [15:0] ti_in_data;

    wire [15:0] ti_out_available;
    reg         ti_out_data_en;
    wire [15:0] ti_out_data;

    // SDRAM I/O
    wire        sdram_cke;
    wire        sdram_cs_n;
    wire        sdram_we_n;
    wire        sdram_cas_n;
    wire        sdram_ras_n;
    wire        sdram_ldqm;
    wire        sdram_udqm;
    wire [1:0]  sdram_ba;
    wire [12:0] sdram_a;
    wire [15:0] sdram_d;


    /************************************************************************************
     * Unit under test and test processes
     ************************************************************************************/

    // Generate a clk
    always #1  clk      = !clk;
    always #2  ti_clk   = !ti_clk;

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

    xem3010_template_project #(
        .BUFF_ADDR_WIDTH (BUFF_ADDR_WIDTH))
    uut (
        .led                (led),
        .ti_clk             (ti_clk),
        .sys_clk            (clk),
        .sdram_clk          (clk),

        .a_hard_rst_n       (1'b0),
        .ti_soft_rst        (ep00wire[2]),
        .ti_read_enable     (ep00wire[1]),

        .ti_in_available    (ti_in_available),
        .ti_in_data_en      (ti_in_data_en),
        .ti_in_data         (ti_in_data),

        .ti_out_available   (ti_out_available),
        .ti_out_data_en     (ti_out_data_en),
        .ti_out_data        (ti_out_data),

        // SDRAM I/O
        .sdram_cke          (sdram_cke),
        .sdram_cs_n         (sdram_cs_n),
        .sdram_we_n         (sdram_we_n),
        .sdram_cas_n        (sdram_cas_n),
        .sdram_ras_n        (sdram_ras_n),
        .sdram_ldqm         (sdram_ldqm),
        .sdram_udqm         (sdram_udqm),
        .sdram_ba           (sdram_ba),
        .sdram_a            (sdram_a),
        .sdram_d            (sdram_d) );


    assign sdram_d = (uut.c0.sdram_dir==1'b1) ? (counter) : (16'bz);


    /************************************************************************************
     * USER Defined output
     ************************************************************************************/
    task display_signals;
        $display({"%d\t%d\t%d",
                  "\t%b",
                  "\t%d\t%d\t%d",
                  "\t%d\t%d\t%d",
                  //"\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",
                  ""},
            $time, uut.ti_rst, uut.sdram_rst,
            led,

            ti_in_data_en,
            ti_in_data,
            uut.interface.sdram_wr_count,

            ti_out_data_en,
            ti_out_data,
            uut.interface.sdram_rd_count,

//            sdram_cke,
//            sdram_cs_n,
//            sdram_we_n,
//            sdram_cas_n,
//            sdram_ras_n,
//            sdram_ldqm,
//            sdram_udqm,
//            sdram_ba,
//            sdram_a,
//            sdram_d,
            );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime",
           "\tti_rst\tsdr_rst",
           "\t\tled",
           "\twr_en\trd_en",
           "\tin_en\tp_in\tin_cnt",
           "\tout_en\tp_out\tout_cnt",
           ""});
    endtask

    /************************************************************************************
     * ALL the User TESTS defined here:
     ************************************************************************************/

    initial begin
        counter     <= 1;
        clk         <= 'b0;
        ti_clk      <= 'b0;

        ep00wire    <= 'b0;
        ti_out_data_en   <= 'b0;
        ti_in_data_en  <= 'b0;
        ti_in_data   <= 'b0;
    end

    initial begin
        #1 display_header();

        $display("RESET");

        @(negedge ti_clk);
        ep00wire[2] <= 1'b1;
        repeat(5) @(negedge ti_clk);
        ep00wire[2] <= 1'b0;
        repeat(uut.c0.CNT_tINIT) @(negedge clk);

        @(negedge ti_clk);
        $display("Write enable");
        ep00wire[1] <= 1'b1;
        @(negedge ti_clk);

        repeat (512) begin
            ti_in_data_en  <= 1'b1;
            ti_in_data   <= counter;
            counter     <= counter +1;
            @(negedge ti_clk);
        end

        $display("Write enable OFF");
        ti_in_data_en  <= 1'b0;
        @(negedge ti_clk);

        repeat(50) @(negedge ti_clk);
        ep00wire[1] <= 1'b0;

        $display("Wait for write to SDRAM");
        repeat(450) @(negedge clk);

        @(negedge ti_clk);
        $display("Read enable");
        ep00wire[0] <= 1'b1;
        counter <= 'b1;
        @(negedge ti_clk);

        repeat (100) begin
            if ((uut.c0.state == uut.c0.s_blockread5)
                    | (uut.c0.state == uut.c0.s_blockread6)
                    | (uut.c0.state == uut.c0.s_blockread7)
                    | (uut.c0.state == uut.c0.s_blockread8)) begin
                counter <= counter + 1;
            end
            @(negedge clk);
        end

        ep00wire[0] <= 1'b0;

        repeat (450) begin
            if ((uut.c0.state == uut.c0.s_blockread5)
                    | (uut.c0.state == uut.c0.s_blockread6)
                    | (uut.c0.state == uut.c0.s_blockread7)
                    | (uut.c0.state == uut.c0.s_blockread8)) begin
                counter <= counter + 1;
            end
            @(negedge clk);
        end

        $display("Pipe OUT");
        @(negedge ti_clk);
        repeat (512) begin
            ti_out_data_en <= 'b1;
            @(negedge ti_clk);
        end

        ti_out_data_en <= 'b0;
        @(negedge ti_clk);


        repeat(50) @(negedge ti_clk);


        $display("END");
        -> end_trigger;
    end



endmodule
