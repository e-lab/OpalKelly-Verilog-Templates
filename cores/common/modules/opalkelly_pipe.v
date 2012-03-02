/***************************************************************************************************
 * Module: opalkelly_pipe
 *
 * Description: Contains the user logic which orchestrates the movement of data.
 *
 * Test bench: tester_opalkelly_pipe.v
 *
 * Created: Fri 20 Nov 2009 18:16:42 EST
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _opalkelly_pipe_ `define _opalkelly_pipe_

`include "fifo_async.v"
`include "pulse_gen.v"


module opalkelly_pipe
  #(parameter
    RX_ADDR_WIDTH   = 10,
    TX_ADDR_WIDTH   = 10)
   (input                       sys_clk,
    input                       sys_rst,

    input                       ti_clk,
    input                       ti_rst,

    output [RX_ADDR_WIDTH:0]    ti_in_available,
    input                       ti_in_data_en,
    input  [15:0]               ti_in_data,

    output [TX_ADDR_WIDTH:0]    ti_out_available,
    input                       ti_out_data_en,
    output [15:0]               ti_out_data,

    input                       sys_rx_ready,
    output reg                  sys_rx_valid,
    output [15:0]               sys_rx,

    output                      sys_tx_ready,
    input                       sys_tx_valid,
    input  [15:0]               sys_tx);


    /************************************************************************************
     * Internal signals
     ************************************************************************************/



    /************************************************************************************
     * Implementation
     ************************************************************************************/

    generate
        if (0 != TX_ADDR_WIDTH) begin : TX_ACTIVE_

            wire                    sys_tx_out_full_a;
            wire [TX_ADDR_WIDTH:0]  ti_tx_out_count;

            // Pipe Out FIFO
            fifo_async #(
                .DATA_WIDTH         (16),
                .ADDR_WIDTH         (TX_ADDR_WIDTH),
                .FALL               (0),
                .LEAD_ALMOST_FULL   (5),
                .LEAD_ALMOST_EMPTY  (0) )
            tx_out (
                .pop_clk        (ti_clk),
                .pop_rst        (ti_rst),
                .pop            (ti_out_data_en),
                .pop_data       (ti_out_data),
                .pop_empty      (),
                .pop_count      (ti_tx_out_count),

                .push_clk       (sys_clk),
                .push_rst       (sys_rst),
                .push           (sys_tx_valid),
                .push_data      (sys_tx),
                .push_full      (),
                .push_full_a    (sys_tx_out_full_a),
                .push_count     () );


            assign ti_out_available = ti_tx_out_count;

            assign sys_tx_ready = ~sys_tx_out_full_a & ~sys_rst;


        end
        else begin : TX_INACTIVE_

            assign ti_out_data      = 'b0;

            assign ti_out_available = 'b0;

            assign sys_tx_ready     = 'b0;

        end
    endgenerate


    generate
        if (0 != RX_ADDR_WIDTH) begin : RX_ACTIVE_

            wire                    sys_rx_in_empty;
            wire [RX_ADDR_WIDTH:0]  ti_rx_in_count;

            assign ti_in_available = {RX_ADDR_WIDTH{1'b1}} - ti_rx_in_count;

            always @(posedge sys_clk)
                sys_rx_valid <= sys_rx_ready & ~sys_rx_in_empty;


//            always @(posedge ti_clk)
//               if (ti_rst)  ti_in_available <= {RX_ADDR_WIDTH{1'b1}};
//               else         ti_in_available <= {RX_ADDR_WIDTH{1'b1}} - ti_rx_in_count;


            // Pipe In FIFO
            fifo_async #(
                .DATA_WIDTH         (16),
                .ADDR_WIDTH         (RX_ADDR_WIDTH),
                .FALL               (0),
                .LEAD_ALMOST_FULL   (0),
                .LEAD_ALMOST_EMPTY  (0) )
            rx_in (
                .pop_clk        (sys_clk),
                .pop_rst        (sys_rst),
                .pop            (sys_rx_ready & ~sys_rx_in_empty),
                .pop_data       (sys_rx),
                .pop_empty      (sys_rx_in_empty),
                .pop_empty_a    (),
                .pop_count      (),

                .push_clk       (ti_clk),
                .push_rst       (ti_rst),
                .push           (ti_in_data_en),
                .push_data      (ti_in_data),
                .push_full      (),
                .push_full_a    (),
                .push_count     (ti_rx_in_count) );


        end
        else begin : RX_INACTIVE_

            assign ti_in_available  = 'b0;

            assign sys_rx           = 'b0;

            always @(posedge sys_clk) sys_rx_valid <= 'b0;

        end
    endgenerate


endmodule

`endif //  `ifndef _opalkelly_pipe_
