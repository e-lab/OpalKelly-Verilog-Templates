/***************************************************************************************************
 * TEST BENCH : system_xem3001v2
 *
 * Time-stamp: Sun 28 Mar 2010 17:28:04 EDT
 *
 * Author: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/

`timescale 1ns/10ps
`include "system_xem3001v2.v"

//`define VERBOSE
`define TB_VERBOSE

module tester_system_xem3001v2;

    initial $display("Testbench for unit 'system_xem3001v2'");


    /************************************************************************************
     * Parameters and signal definitions for the test bench
     ************************************************************************************/
    localparam MEM_ADDR_WIDTH    = 4;
    localparam MEM_DATA_WIDTH    = 16;

    integer                     counter;
    reg                         clk;

    wire [7:0]                  a_led;

    reg                         a_rst_hard;
    reg                         ti_rst_soft;

    reg                         s_clk;
    reg                         ti_clk;

    reg                         ti_data_in_en;
    reg  [MEM_DATA_WIDTH-1:0]   ti_data_in;

    reg                         ti_data_out_en;
    wire [MEM_DATA_WIDTH-1:0]   ti_data_out;


    /************************************************************************************
     * Unit under test and test processes
     ************************************************************************************/

    // Generate a clk
    always #1  clk      = !clk;
    always #10 s_clk    = !s_clk;
    always #5  ti_clk   = !ti_clk;

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

    system_xem3001v2 #(
        .MEM_ADDR_WIDTH  (MEM_ADDR_WIDTH),
        .MEM_DATA_WIDTH  (MEM_DATA_WIDTH))
    uut (
        .a_led          (a_led),
        .a_rst_hard     (a_rst_hard),

        .s_clk          (s_clk),

        .ti_clk         (ti_clk),
        .ti_rst_soft    (ti_rst_soft),
        .ti_data_in_en  (ti_data_in_en),
        .ti_data_in     (ti_data_in),
        .ti_data_out_en (ti_data_out_en),
        .ti_data_out    (ti_data_out));


    /************************************************************************************
     * USER Defined output
     ************************************************************************************/
    task display_signals;
        $display({"%d\t%b\t%b\t%b\t",
                  "%d\t%d\t%d\t%d"},
            $time,
            a_rst_hard,
            ti_rst_soft,
            a_led,

            ti_data_in,
            ti_data_in_en,
            ti_data_out,
            ti_data_out_en
            );

    endtask // display_signals

    task display_header;
        $display({"\t\ttime",
           "\trst_h",
           "\trst_s",
           "\tled",

           "\td_in",
           "\td_in_en",
           "\td_out",
           "\td_out_en"});
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

        ti_data_in          <= 0;
        ti_data_in_en       <= 0;
        ti_data_out_en      <= 0;
    end

    initial begin
        #1 display_header();

        $display("HARD RESET");
        @(negedge clk);
        a_rst_hard <= 1;
        repeat(5) @(negedge clk);
        a_rst_hard <= 0;
        repeat(5) @(negedge clk);


        $display("SOFT RESET");
        @(negedge ti_clk);
        a_rst_hard <= 1;
        repeat(5) @(negedge ti_clk);
        a_rst_hard <= 0;
        repeat(5) @(negedge ti_clk);


        $display("TEST pipe data in");
        @(negedge ti_clk);
        repeat (10) begin
            ti_data_in_en   <= 1'b1;
            ti_data_in      <= counter;
            counter         <= counter + 1;

            @(negedge ti_clk);
        end
        ti_data_in_en   <= 1'b0;
        ti_data_in      <= 'b0;
        counter         <= 1;
        repeat(5) @(negedge ti_clk);

        $display("TEST pipe data out");
        @(negedge ti_clk);
        ti_data_out_en <= 1'b1;
        repeat(16) @(negedge ti_clk);
        ti_data_out_en <= 1'b0;
        repeat(5) @(negedge ti_clk);


        $display("END");
        -> end_trigger;
    end



endmodule
