/***************************************************************************************************
 * TEST BENCH : xem6001_template_project
 *
 * Time-stamp: Tue 28 Feb 2012 12:55:40 EST
 *
 * Author: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/

`timescale 1ns/10ps
`include "xem6001_template_project.v"

//`define VERBOSE
`define TB_VERBOSE

module tester_xem6001_template_project;

    initial $display("Testbench for unit 'xem6001_template_project'");


    /************************************************************************************
     * Parameters and signal definitions for the test bench
     ************************************************************************************/
    localparam MEM_ADDR_WIDTH    = 5;
    localparam MEM_DATA_WIDTH    = 16;

    integer     counter;
    reg         clk;

    wire [7:0]  a_led;

    reg         a_rst_hard;
    reg         ti_rst_soft;

    reg         s_clk;
    reg         ti_clk;

    wire [15:0] ti_in_available;
    reg         ti_in_data_en;
    reg  [15:0] ti_in_data;

    wire [15:0] ti_out_available;
    reg         ti_out_data_en;
    wire [15:0] ti_out_data;

    wire        s_rx_valid;
    wire [15:0] s_rx_data;


    /************************************************************************************
     * Unit under test and test processes
     ************************************************************************************/

    // Generate a clk
    always #1  clk      = !clk;
//    always #10 s_clk    = !s_clk;
    always #1 s_clk    = !s_clk;
//    always #5  ti_clk   = !ti_clk;
    always #1  ti_clk   = !ti_clk;

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

    xem6001_template_project #(
        .MEM_ADDR_WIDTH (MEM_ADDR_WIDTH))
    uut (
        .a_led              (a_led),
        .a_rst_hard         (a_rst_hard),

        .s_clk              (s_clk),

        .ti_clk             (ti_clk),
        .ti_rst_soft        (ti_rst_soft),

        .ti_in_available    (ti_in_available),
        .ti_in_data_en      (ti_in_data_en),
        .ti_in_data         (ti_in_data),

        .ti_out_available   (ti_out_available),
        .ti_out_data_en     (ti_out_data_en),
        .ti_out_data        (ti_out_data),

        .s_rx_valid         (s_rx_valid),
        .s_rx_data          (s_rx_data)
    );


    /************************************************************************************
     * USER Defined output
     ************************************************************************************/
    task display_signals;
        $display({"%d\t%b\t%b\t%b",
                  "\t%d\t%d\t%d",
                  "\t\t%d\t%d\t%d",
                  "\t\t%d\t%d",
                  ""},
            $time,
            a_rst_hard,
            ti_rst_soft,
            a_led,

            ti_in_available,
            ti_in_data,
            ti_in_data_en,

            ti_out_available,
            ti_out_data,
            ti_out_data_en,

            s_rx_valid,
            s_rx_data,
            );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime",
           "\trst_h",
           "\trst_s",
           "\tled",

           "\t\td_in_#",
           "\td_in",
           "\td_in_en",

           "\t\td_out_#",
           "\td_out",
           "\td_out_en",

           "\trx_v",
           "\trx_d",
           ""});
    endtask

    /************************************************************************************
     * ALL the User TESTS defined here:
     ************************************************************************************/

    initial begin
        counter             <= 1;
        clk                 <= 0;

        a_rst_hard          <= 0;
        ti_rst_soft         <= 0;

        s_clk               <= 0;
        ti_clk              <= 0;

        ti_in_data          <= 0;
        ti_in_data_en       <= 0;
        ti_out_data_en      <= 0;
    end

    initial begin
        #1 display_header();

        $display("HARD RESET");
        @(negedge clk);
        a_rst_hard <= 1;
        repeat(5) @(negedge clk);
        a_rst_hard <= 0;
        repeat(5) @(negedge clk);


//        $display("SOFT RESET");
//        @(negedge ti_clk);
//        a_rst_hard <= 1;
//        repeat(5) @(negedge ti_clk);
//        a_rst_hard <= 0;
//        repeat(5) @(negedge ti_clk);


        $display("TEST pipe data in");
        @(negedge ti_clk);
        repeat (10) begin
            ti_in_data_en   <= 1'b1;
            ti_in_data      <= counter;
            counter         <= counter + 1;

            @(negedge ti_clk);
        end
        ti_in_data_en   <= 1'b0;
        ti_in_data      <= 'b0;
        counter         <= 1;
        repeat(20) @(negedge ti_clk);

        repeat(50) @(negedge ti_clk);

        $display("TEST pipe data out");
        @(negedge ti_clk);
        ti_out_data_en <= 1'b1;
        repeat(16) @(negedge ti_clk);
        ti_out_data_en <= 1'b0;
        repeat(5) @(negedge ti_clk);

        repeat(50) @(negedge ti_clk);

        ti_out_data_en <= 1'b1;
        repeat(16) @(negedge ti_clk);
        ti_out_data_en <= 1'b0;
        repeat(5) @(negedge ti_clk);

        $display("END");
        -> end_trigger;
    end



endmodule
