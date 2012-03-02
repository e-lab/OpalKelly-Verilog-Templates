/***************************************************************************************************
 * Module: xem5010_template_project
 *
 * Description: Contains a loopback module that moves data from the pipe in to the ddr and then out
 *              of the ddr to a pipe out.
 *
 * Created: Thu  5 Nov 2009 13:56:17 EST
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem5010_template_project_ `define _xem5010_template_project_

`include "reset_sync.v"
`include "xem5010_loopback.v"

module xem5010_template_project
  #(parameter
    APPDATA_WIDTH   = 32,
    MASK_WIDTH      = 3)
   (output [3:0]                led,
    input                       s_clk,
    input                       ti_clk,

    // Reset
    input                       arst,

    // Pipe to Chip 'A'
    output [15:0]               ti_a_in_available,
    input                       ti_a_in_data_en,
    input  [15:0]               ti_a_in_data,

    output [15:0]               ti_a_out_available,
    input                       ti_a_out_data_en,
    output [15:0]               ti_a_out_data,

    // Pipe to Chip 'B'
    output [15:0]               ti_b_in_available,
    input                       ti_b_in_data_en,
    input  [15:0]               ti_b_in_data,

    output [15:0]               ti_b_out_available,
    input                       ti_b_out_data_en,
    output [15:0]               ti_b_out_data,

    // DDR2 Chip 'A' I/O
    input                       s_a_phy_init_done,
    input                       s_a_app_rd_data_valid,
    input  [APPDATA_WIDTH-1:0]  s_a_app_rd_data,
    input                       s_a_app_af_afull,
    input                       s_a_app_wdf_afull,
    output                      s_a_app_af_wren,
    output [2:0]                s_a_app_af_cmd,
    output [30:0]               s_a_app_af_addr,
    output                      s_a_app_wdf_wren,
    output [APPDATA_WIDTH-1:0]  s_a_app_wdf_data,
    output [MASK_WIDTH-1:0]     s_a_app_wdf_mask_data,

    // DDR2 Chip 'B' I/O
    input                       s_b_phy_init_done,
    input                       s_b_app_rd_data_valid,
    input  [APPDATA_WIDTH-1:0]  s_b_app_rd_data,
    input                       s_b_app_af_afull,
    input                       s_b_app_wdf_afull,
    output                      s_b_app_af_wren,
    output [2:0]                s_b_app_af_cmd,
    output [30:0]               s_b_app_af_addr,
    output                      s_b_app_wdf_wren,
    output [APPDATA_WIDTH-1:0]  s_b_app_wdf_data,
    output [MASK_WIDTH-1:0]     s_b_app_wdf_mask_data);

`include "common_functions.v"


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    wire    s_rst;
    wire    ti_rst;

    reset_sync
    reset_a2ti (
        .clk    (ti_clk),
        .arst   (arst),
        .rst    (ti_rst) );

    reset_sync
    reset_a2sys (
        .clk    (s_clk),
        .arst   (arst),
        .rst    (s_rst) );


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    assign led = ~{s_rst, ti_rst, arst, 1'b1};


    /************************************************************************************
     * Memory 'a' loopback
     ************************************************************************************/

    xem5010_loopback
    ddr2_a_loopback_ (
        .ti_clk                 (ti_clk),
        .ti_rst                 (ti_rst),

        .ti_in_available        (ti_a_in_available),
        .ti_in_data_en          (ti_a_in_data_en),
        .ti_in_data             (ti_a_in_data),

        .ti_out_available       (ti_a_out_available),
        .ti_out_data_en         (ti_a_out_data_en),
        .ti_out_data            (ti_a_out_data),

        .s_clk                  (s_clk),
        .s_rst                  (s_rst),

        .s_phy_init_done        (s_a_phy_init_done),
        .s_app_rd_data_valid    (s_a_app_rd_data_valid),
        .s_app_rd_data          (s_a_app_rd_data),
        .s_app_af_wren          (s_a_app_af_wren),
        .s_app_af_afull         (s_a_app_af_afull),
        .s_app_af_cmd           (s_a_app_af_cmd),
        .s_app_af_addr          (s_a_app_af_addr),
        .s_app_wdf_wren         (s_a_app_wdf_wren),
        .s_app_wdf_afull        (s_a_app_wdf_afull),
        .s_app_wdf_data         (s_a_app_wdf_data),
        .s_app_wdf_mask_data    (s_a_app_wdf_mask_data) );


    /************************************************************************************
     * Memory 'b' loopback
     ************************************************************************************/

    xem5010_loopback
    ddr2_b_loopback_ (
        .ti_clk                 (ti_clk),
        .ti_rst                 (ti_rst),

        .ti_in_available        (ti_b_in_available),
        .ti_in_data_en          (ti_b_in_data_en),
        .ti_in_data             (ti_b_in_data),

        .ti_out_available       (ti_b_out_available),
        .ti_out_data_en         (ti_b_out_data_en),
        .ti_out_data            (ti_b_out_data),

        .s_clk                  (s_clk),
        .s_rst                  (s_rst),

        .s_phy_init_done        (s_b_phy_init_done),
        .s_app_rd_data_valid    (s_b_app_rd_data_valid),
        .s_app_rd_data          (s_b_app_rd_data),
        .s_app_af_wren          (s_b_app_af_wren),
        .s_app_af_afull         (s_b_app_af_afull),
        .s_app_af_cmd           (s_b_app_af_cmd),
        .s_app_af_addr          (s_b_app_af_addr),
        .s_app_wdf_wren         (s_b_app_wdf_wren),
        .s_app_wdf_afull        (s_b_app_wdf_afull),
        .s_app_wdf_data         (s_b_app_wdf_data),
        .s_app_wdf_mask_data    (s_b_app_wdf_mask_data) );


endmodule


`endif //  `ifndef _xem5010_template_project_
