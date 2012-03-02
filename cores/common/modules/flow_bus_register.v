/***************************************************************************************************
 * Module: flow_bus_register
 *
 * Description: The flow_bus_register takes a flow bus (data, valid and ready flag) and intruduces
 *              registers along said bus.  The number of registers along each is a parameter and can
 *              be different along the ready path and the data/valid path.  The valid and ready
 *              flags can be removed using parameters.
 *
 * Test bench: tester_flow_bus_register.v
 *
 * Created: Fri 28 May 2010 23:00:51 EDT
 *
 * Author: Berin Martini
 **************************************************************************************************/

`ifndef _flow_bus_register_ `define _flow_bus_register_


module flow_bus_register
  #(parameter
    DATA_WIDTH      = 16,
    REG_DEPTH_DATA  = 0,
    REG_DEPTH_READY = 0,
    USE_READY       = 0,
    USE_VALID       = 0,
    USE_ENABLE      = 0,
    USE_RESET       = 0)
   (input                   clk,
    input                   rst,
    input                   enable,

    output                  up_ready,
    input                   up_valid,
    input  [DATA_WIDTH-1:0] up_data,

    input                   down_ready,
    output                  down_valid,
    output [DATA_WIDTH-1:0] down_data
   );


    /**************************************************************************************
     * Private parameters for 'flow_bus_register'
     **************************************************************************************/

`ifdef VERBOSE
    initial $display("\using 'flow_bus_register' with a %0d bus width and register depth %0d\n",
        DATA_WIDTH, REG_DEPTH_DATA);
`endif


    /**************************************************************************************
     * Internal signals
     **************************************************************************************/

    genvar xx;

    /**************************************************************************************
     * Implementation
     **************************************************************************************/

    generate // Multi-registering of the ready flag
        if (USE_READY) begin : READY_

            wire reg_ready;

            flow_bus_register #(
                .DATA_WIDTH     (1),
                .REG_DEPTH_DATA (REG_DEPTH_READY),
                .USE_READY      (0),
                .USE_VALID      (0),
                .USE_ENABLE     (USE_ENABLE),
                .USE_RESET      (USE_RESET))
            ready_flag (
                .clk        (clk),
                .rst        (rst),
                .enable     (enable),
                .up_data    (down_ready),
                .down_data  (reg_ready) );


            if (USE_ENABLE) begin : ENABLE_

                assign up_ready = reg_ready & enable;

            end
            else begin : NO_ENABLE_

                assign up_ready = reg_ready;

            end
        end
        else begin : NO_READY_

            assign up_ready = 'bx;

        end
    endgenerate


    generate // Multi-registering of the valid flag
        if (USE_VALID) begin : VALID_

            wire reg_valid;

            flow_bus_register #(
                .DATA_WIDTH     (1),
                .REG_DEPTH_DATA (REG_DEPTH_DATA),
                .USE_READY      (0),
                .USE_VALID      (0),
                .USE_ENABLE     (USE_ENABLE),
                .USE_RESET      (USE_RESET))
            valid_flag (
                .clk        (clk),
                .rst        (rst),
                .enable     (enable),
                .up_data    (up_valid),
                .down_data  (reg_valid) );


            if (USE_ENABLE) begin : ENABLE_

                assign down_valid = reg_valid & enable;

            end
            else begin : NO_ENABLE_

                assign down_valid = reg_valid;

            end
        end
        else begin : NO_VALID_

            assign down_valid = 'bx;

        end
    endgenerate


    generate // Multi-register piplining of data bus
        if (0 == REG_DEPTH_DATA) begin : DATA_NO_REG_

            assign down_data = up_data;

        end
        else begin : DATA_REG_

            reg  [DATA_WIDTH-1:0] reg_data [0:REG_DEPTH_DATA];

            assign down_data                    = reg_data[0];

            always @* reg_data[REG_DEPTH_DATA]  = up_data;

            if (USE_ENABLE) begin : ENABLE_
                if (USE_RESET) begin : RESET_
                    for (xx = 0; xx < REG_DEPTH_DATA; xx = xx + 1) begin : REG_

                        always @(posedge clk)
                            if      (rst)       reg_data[xx] <= 'b0;
                            else if (enable)    reg_data[xx] <= reg_data[xx+1];

                    end
                end
                else begin : NO_RESET_
                    for (xx = 0; xx < REG_DEPTH_DATA; xx = xx + 1) begin : REG_

                        always @(posedge clk)
                            if (enable) reg_data[xx] <= reg_data[xx+1];

                    end
                end
            end
            else begin : NO_ENABLE_
                if (USE_RESET) begin : RESET_
                    for (xx = 0; xx < REG_DEPTH_DATA; xx = xx + 1) begin : REG_

                        always @(posedge clk)
                            if (rst)    reg_data[xx] <= 'b0;
                            else        reg_data[xx] <= reg_data[xx+1];

                    end
                end
                else begin : NO_RESET_
                    for (xx = 0; xx < REG_DEPTH_DATA; xx = xx + 1) begin : REG_

                        always @(posedge clk)
                            reg_data[xx] <= reg_data[xx+1];

                    end
                end
            end
        end
    endgenerate


endmodule

`endif //  `ifndef _flow_bus_register_
