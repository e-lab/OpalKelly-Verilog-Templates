/***************************************************************************************************
 * Module: flow_bus_deserializer
 *
 * Description: Concatenates the muitiple flow bus data words into a larger data word.
 *
 * Test bench: tester_flow_bus_deserializer.v
 *
 * Time-stamp: Wed 10 Nov 2010 22:44:53 EST
 *
 * Authors: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _flow_bus_deserializer_ `define _flow_bus_deserializer_

`include "flow_bus_register.v"

module flow_bus_deserializer
  #(parameter
    DATA_WIDTH      = 8,
    DATA_NUM        = 2,
    REG_DEPTH_DATA  = 0,
    REG_DEPTH_READY = 0,
    USE_READY       = 0,
    USE_ENABLE      = 0)
   (input                               clk,
    input                               rst,
    input                               enable,

    output                              up_ready,
    input                               up_valid,
    input  [DATA_WIDTH-1:0]             up_data,

    input                               down_ready,
    output                              down_valid,
    output [(DATA_WIDTH*DATA_NUM)-1:0]  down_data
   );

`include "common_functions.v"


    /**************************************************************************************
     * Private parameters for 'flow_bus_logical_mux'
     **************************************************************************************/

`ifdef VERBOSE
    initial $display("\using 'flow_bus_deserializer' with %0d word concatenation\n", DATA_NUM);
`endif


    /**************************************************************************************
     * Internal signals
     **************************************************************************************/

    genvar ii;

    reg                                 concat_valid;
    reg  [(DATA_WIDTH*DATA_NUM)-1:0]    concat_data;
    reg  [DATA_NUM-1:0]                 token;


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH*DATA_NUM),
        .REG_DEPTH_DATA     (REG_DEPTH_DATA),
        .REG_DEPTH_READY    (REG_DEPTH_READY),
        .USE_READY          (USE_READY),
        .USE_VALID          (1),
        .USE_ENABLE         (USE_ENABLE),
        .USE_RESET          (0))
    ready_flag (
        .clk        (clk),
        .rst        (rst),
        .enable     (enable),
        .up_ready   (up_ready),
        .up_valid   (concat_valid),
        .up_data    (concat_data),
        .down_ready (down_ready),
        .down_valid (down_valid),
        .down_data  (down_data) );


    /**************************************************************************************
     * Implementation
     **************************************************************************************/


    generate
        if (USE_ENABLE) begin : ENABLE_

            always @(posedge clk)
                if (enable) concat_valid <= (token[DATA_NUM-1] & up_valid);


            always @(posedge clk)
                if      (rst)               token <= 'b1;
                else if (up_valid & enable) token <= {token, token[DATA_NUM-1]};


            for (ii=0; ii<DATA_NUM; ii=ii+1) begin : CONCAT_

                always @(posedge clk)
                    if (token[ii] & enable) begin
                        concat_data[((ii+1)*DATA_WIDTH)-1:ii*DATA_WIDTH] <= up_data;
                    end

            end
        end
        else begin : NO_ENABLE_

            always @(posedge clk)
                concat_valid <= (token[DATA_NUM-1] & up_valid);


            always @(posedge clk)
                if      (rst)       token <= 'b1;
                else if (up_valid)  token <= {token, token[DATA_NUM-1]};


            for (ii=0; ii<DATA_NUM; ii=ii+1) begin : CONCAT_

                always @(posedge clk)
                    if (token[ii]) concat_data[((ii+1)*DATA_WIDTH)-1:ii*DATA_WIDTH] <= up_data;

            end
        end
    endgenerate


endmodule

`endif //  `ifndef _flow_bus_deserializer_
