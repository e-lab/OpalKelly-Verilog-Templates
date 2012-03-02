/***************************************************************************************************
 * Module: xem6010_template
 *
 * Description: This top module is for use with the Opal Kelly XEM6010 board.
 *
 * Created: Fri 22 Jul 2011 14:05:17 EDT
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem6010_template_ `define _xem6010_template_

`default_nettype none
`timescale 1ns / 1ps

`include "xem6010_template_project.v"
`include "okLibrary.v"


module xem6010_template
   (input  [7:0]    hi_in,
    output [1:0]    hi_out,
    inout  [15:0]   hi_inout,
    inout           hi_aa,
    output          hi_muxsel,

    output          i2c_scl,
    output          i2c_sda,

    input           clk1,
    output [7:0]    led
   );


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    localparam NUM_WIRE_IN      = 1; // start addr 8'h00, range 0 - 32
    localparam NUM_WIRE_OUT     = 2; // start addr 8'h20, range 0 - 32
    localparam NUM_TRIG_IN      = 0; // start addr 8'h40, range 0 - 32
    localparam NUM_TRIG_OUT     = 0; // start addr 8'h60, range 0 - 32
    localparam NUM_PIPE_IN      = 2; // start addr 8'h80, range 0 - 32
    localparam NUM_PIPE_OUT     = 2; // start addr 8'hA0, range 0 - 32
    localparam NUM_OR           = (NUM_WIRE_OUT + NUM_TRIG_OUT + NUM_PIPE_IN + NUM_PIPE_OUT);


    // Host interface connections
    wire                    ti_clk;
    wire [30:0]             ok1;
    wire [16:0]             ok2;

    wire [(17*NUM_OR)-1:0]  ok2x;

    wire [15:0]             epWireIn    [0:31];
    wire [15:0]             epWireOut   [0:31];

    wire [0:31]             trigInClk;
    wire [0:31]             trigOutClk;
    wire [15:0]             epTrigIn    [0:31];
    wire [15:0]             epTrigOut   [0:31];

    wire [0:31]             epPipeInEn;
    wire [0:31]             epPipeOutEn;
    wire [15:0]             epPipeInData    [0:31];
    wire [15:0]             epPipeOutData   [0:31];

    wire [7:0]              a_led;

    wire                    dcm_locked_out;
    wire                    sdram_clk;
    // synthesis attribute KEEP of sdram_clk is "true";


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    assign i2c_scl  = 1'bz;
    assign i2c_sda  = 1'bz;

//    assign trigInClk[0]     = ti_clk;
//    assign trigOutClk[0]    = ti_clk;

    assign led      = ~{a_led, dcm_locked_out};


    xem6010_template_project #(
        .MEM_ADDR_WIDTH (10)) // # of buffer addr bits
    project (
        .a_led              (led),
        .a_rst_hard         ( ~button[0]),

        .s_clk              (clk1),

        .ti_clk             (ti_clk),
        .ti_rst_soft        (epWireIn[0][0]),

        .ti_in_available    (epWireOut[0]),
        .ti_in_data_en      (epPipeInEn[0]),
        .ti_in_data         (epPipeInData[0]),

        .ti_out_available   (epWireOut[1]),
        .ti_out_data_en     (epPipeOutEn[0]),
        .ti_out_data        (epPipeOutData[0]),

        .ti_in_test_en      (epPipeInEn[1]),
        .ti_in_test         (epPipeInData[1]),
        .ti_out_test_en     (epPipeOutEn[1]),
        .ti_out_test        (epPipeOutData[1]) );


    /************************************************************************************
     * Instantiate the Opal Kelly okHost and okWireOR, connect endpoints
     ************************************************************************************/

    assign hi_muxsel = 1'b0;


    okHost
    okHI (
        .hi_in      (hi_in),
        .hi_out     (hi_out),
        .hi_inout   (hi_inout),
        .hi_aa      (hi_aa),
        .ti_clk     (ti_clk),
        .ok1        (ok1),
        .ok2        (ok2) );


    okWireOR #(.N(NUM_OR)) wireOR (ok2, ok2x);


    genvar wi;
    generate
        for (wi = 0; wi < NUM_WIRE_IN; wi = wi + 1) begin: WI_

            okWireIn
            wire_in (
                .ok1        (ok1),
                .ep_addr    (8'h00 + wi),
                .ep_dataout (epWireIn[wi]) );

        end
    endgenerate


    genvar wo;
    generate
        for (wo = 0; wo < NUM_WIRE_OUT; wo = wo + 1) begin: WO_

            okWireOut
            wire_out (
                .ok1        (ok1),
                .ok2        (ok2x[wo*17 +: 17]),
                .ep_addr    (8'h20 + wo),
                .ep_datain  (epWireOut[wo]) );

        end
    endgenerate


    genvar ti;
    generate
        for (ti = 0; ti < NUM_TRIG_IN; ti = ti + 1) begin: TI_

            okTriggerIn
            trigger_in (
                .ok1        (ok1),
                .ep_addr    (8'h40 + ti),
                .ep_clk     (trigInClk[ti]),
                .ep_trigger (epTrigIn[ti]) );

        end
    endgenerate


    genvar to;
    generate
        for (to = 0; to < NUM_TRIG_OUT; to = to + 1) begin: TO_

            okTriggerOut
            trigger_out (
                .ok1        (ok1),
                .ok2        (ok2x[(NUM_WIRE_OUT+to)*17 +: 17]),
                .ep_addr    (8'h60 + to),
                .ep_clk     (trigOutClk[to]),
                .ep_trigger (epTrigOut[to]) );

        end
    endgenerate


    genvar pi;
    generate
        for (pi = 0; pi < NUM_PIPE_IN; pi = pi + 1) begin: PI_

            okPipeIn
            pipe_in (
                .ok1        (ok1),
                .ok2        (ok2x[(NUM_WIRE_OUT+NUM_TRIG_OUT+pi)*17 +: 17]),
                .ep_addr    (8'h80 + pi),
                .ep_write   (epPipeInEn[pi]),
                .ep_dataout (epPipeInData[pi]) );

        end
    endgenerate


    genvar po;
    generate
        for (po = 0; po < NUM_PIPE_OUT; po = po + 1) begin: PO_

            okPipeOut
            pipe_out (
                .ok1        (ok1),
                .ok2        (ok2x[(NUM_WIRE_OUT+NUM_TRIG_OUT+NUM_PIPE_IN+po)*17 +: 17]),
                .ep_addr    (8'hA0 + po),
                .ep_read    (epPipeOutEn[po]),
                .ep_datain  (epPipeOutData[po]));

        end
    endgenerate


endmodule

`endif //  `ifndef _xem6010_template_
