/***************************************************************************************************
 * Module: flow_bus_serializer
 *
 * Description: Serializes the up flow bus data word into multiple smaller down data words.
 *
 * Test bench: tester_flow_bus_serializer.v
 *
 * Time-stamp: Thu  9 Jun 2011 03:13:15 EST
 *
 * Authors: Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _flow_bus_serializer_ `define _flow_bus_serializer_

`include "flow_bus_register.v"

module flow_bus_serializer
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
    input  [(DATA_WIDTH*DATA_NUM)-1:0]  up_data,

    input                               down_ready,
    output                              down_valid,
    output [DATA_WIDTH-1:0]             down_data
   );


    /**************************************************************************************
     * Private parameters for 'flow_bus_serializer'
     **************************************************************************************/

`ifdef VERBOSE
    initial $display("\using 'flow_bus_serializer' with %0d words\n", DATA_NUM);
`endif


    /**************************************************************************************
     * Internal signals
     **************************************************************************************/

    reg  [DATA_NUM-1:0]                 serial_ready;
    reg  [DATA_NUM-1:0]                 serial_valid;
    reg  [(DATA_WIDTH*DATA_NUM)-1:0]    serial_data;

    reg                                 down_valid_i;
    reg  [DATA_WIDTH-1:0]               down_data_i;


    flow_bus_register #(
        .DATA_WIDTH         (DATA_WIDTH),
        .REG_DEPTH_DATA     (REG_DEPTH_DATA),
        .REG_DEPTH_READY    (REG_DEPTH_READY),
        .USE_READY          (USE_READY),
        .USE_VALID          (1),
        .USE_ENABLE         (USE_ENABLE),
        .USE_RESET          (0))
    reg_outputs (
        .clk        (clk),
        .rst        (rst),
        .enable     (enable),
        .up_ready   (up_ready),
        .up_valid   (down_valid_i),
        .up_data    (down_data_i),
        .down_ready (down_ready & serial_ready[0]),
        .down_valid (down_valid),
        .down_data  (down_data) );


    /**************************************************************************************
     * Implementation
     **************************************************************************************/


    generate
        if (USE_ENABLE) begin : ENABLE_

            always @(posedge clk)
                if (rst) serial_ready <= 'b1;
                else if (enable & down_ready) begin
                    serial_ready <= {serial_ready, serial_ready[DATA_NUM-1]};
                end


            always @(posedge clk)
                if      (enable & up_valid) serial_data <= up_data;
                else if (enable)            serial_data <= serial_data >> DATA_WIDTH;


            always @(posedge clk)
                if      (rst)       serial_valid <= 'b0;
                else if (enable)    serial_valid <= {serial_valid, up_valid};


            always @(posedge clk)
                if (enable) down_data_i <= serial_data[DATA_WIDTH-1:0];


            always @(posedge clk)
                if      (rst)       down_valid_i <= 1'b0;
                else if (enable)    down_valid_i <= |(serial_valid);

        end
        else begin : NO_ENABLE_

            always @(posedge clk)
                if      (rst)           serial_ready <= 'b1;
                else if (down_ready)    serial_ready <= {serial_ready, serial_ready[DATA_NUM-1]};


            always @(posedge clk)
                if  (up_valid)  serial_data <= up_data;
                else            serial_data <= serial_data >> DATA_NUM;


            always @(posedge clk)
                if (rst)    serial_valid <= 'b0;
                else        serial_valid <= {serial_valid, up_valid};


            always @(posedge clk)
                down_data_i <= serial_data[DATA_WIDTH-1:0];


            always @(posedge clk)
                if (rst)    down_valid_i <= 1'b0;
                else        down_valid_i <= |(serial_valid);

        end
    endgenerate


endmodule

`endif //  `ifndef _flow_bus_serializer_
