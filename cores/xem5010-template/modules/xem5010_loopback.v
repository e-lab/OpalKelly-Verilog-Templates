/***************************************************************************************************
 * Module: xem5010_loopback
 *
 * Description: Contains the user logic which orchestrates the movement of data.
 *
 * Test bench: tester_xem5010_loopback.v
 *
 * Created: Fri 20 Nov 2009 18:16:42 EST
 *
 * Author:  Berin Martini // berin.martini@gmail.com
 **************************************************************************************************/
`ifndef _xem5010_loopback_ `define _xem5010_loopback_

`include "fifo_async.v"
`include "fifo_sync.v"
`include "opalkelly_pipe.v"


module xem5010_loopback
  #(parameter
    RX_ADDR_WIDTH   = 10,
    TX_ADDR_WIDTH   = 10)
   (input               ti_clk,
    input               ti_rst,

    input  [15:0]       ti_in_available,
    input               ti_in_data_en,
    input  [15:0]       ti_in_data,

    input  [15:0]       ti_out_available,
    input               ti_out_data_en,
    output [15:0]       ti_out_data,

    input               s_clk,
    input               s_rst,

    input               s_phy_init_done,
    input               s_app_rd_data_valid,
    input  [31:0]       s_app_rd_data,
    input               s_app_af_afull,
    input               s_app_wdf_afull,
    output reg          s_app_af_wren,
    output reg [2:0]    s_app_af_cmd,
    output reg [30:0]   s_app_af_addr,
    output reg          s_app_wdf_wren,
    output reg [31:0]   s_app_wdf_data,
    output [3:0]        s_app_wdf_mask_data);


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    reg  [63:0] data_in_tmp;

    reg         s_rx_ready;
    wire        s_rx_valid;
    wire [15:0] s_rx_data;

    wire        s_tx_ready;
    reg         s_tx_valid;
    reg         s_tx_valid_tmp;
    reg         s_tx_valid_tmp2;
    reg  [15:0] s_tx_data;
    reg  [15:0] s_tx_data_tmp;
    reg  [15:0] s_tx_data_tmp2;


    opalkelly_pipe #(
        .TX_ADDR_WIDTH  (TX_ADDR_WIDTH),
        .RX_ADDR_WIDTH  (RX_ADDR_WIDTH))
    pipe_ (// Opal Kelly Side
        .ti_clk             (ti_clk),
        .ti_rst             (ti_rst),

        .ti_in_available    (ti_in_available),
        .ti_in_data_en      (ti_in_data_en),
        .ti_in_data         (ti_in_data),

        .ti_out_available   (ti_out_available),
        .ti_out_data_en     (ti_out_data_en),
        .ti_out_data        (ti_out_data),

        // System Side
        .s_clk              (s_clk),
        .s_rst              (s_rst),

        .sys_rx_ready       (s_rx_ready),
        .sys_rx_valid       (s_rx_valid),
        .sys_rx             (s_rx_data),

        .sys_tx_ready       (s_tx_ready),
        .sys_tx_valid       (s_tx_valid),
        .sys_tx             (s_tx_data) );


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    localparam S_IDLE   = 0,
               S_WRITE1 = 1,
               S_WRITE2 = 2,
               S_READ   = 3,
               S_WAIT0  = 4,
               S_WAIT1  = 5,
               S_WAIT2  = 6,
               S_WAIT3  = 7;
    integer state;


    localparam WR_BURST_0 = 0,
               WR_BURST_1 = 1,
               WR_BURST_2 = 2,
               WR_BURST_3 = 3;
    integer wr_state;


    localparam RD_BURST_0   = 0,
               RD_BURST_1   = 1,
               RD_BURST_2   = 2,
               RD_BURST_3   = 3;
    integer rd_state;


    reg  [31:0] s_app_wdf_data_tmp;
    reg  [63:0] data_in;
    reg  [30:0] s_app_af_addr_wr;
    reg  [30:0] s_app_af_addr_rd;
    reg         rnw_mode;
    integer     counter;
    reg         write_data;

    assign s_app_wdf_mask_data    = 4'b0000;

    always @(posedge s_clk) begin
        if (s_rst) begin
            counter     <= 0;
            rnw_mode    <= 1'b0;
        end
        else begin
            counter <= counter + s_app_af_wren;
            if (counter >= 25) begin
                counter     <= 0;
                rnw_mode    <= ~rnw_mode;
            end
        end
    end


    always @(posedge s_clk) begin
        if (s_rst) begin
            s_rx_ready    <= 1'b0;
            write_data      <= 1'b0;
            wr_state        <= WR_BURST_0;
        end
        else begin
            s_rx_ready    <= ~rnw_mode;
            write_data      <= 1'b0;
            wr_state        <= WR_BURST_0;

            case (wr_state)

                WR_BURST_0 : begin
                    wr_state <= WR_BURST_0;

                    if (s_rx_valid) begin
                        data_in[15:0]   <= s_rx_data;
                        wr_state        <= WR_BURST_1;
                    end
                end

                WR_BURST_1 : begin
                    wr_state <= WR_BURST_1;

                    if (s_rx_valid) begin
                        data_in[31:16]  <= s_rx_data;
                        wr_state        <= WR_BURST_2;
                    end
                end

                WR_BURST_2 : begin
                    wr_state <= WR_BURST_2;

                    if (s_rx_valid) begin
                        data_in[47:32]  <= s_rx_data;
                        wr_state        <= WR_BURST_3;
                    end
                end

                WR_BURST_3 : begin
                    wr_state <= WR_BURST_3;

                    if (s_rx_valid) begin
                        write_data      <= 1'b1;
                        data_in[63:48]  <= s_rx_data;
                        wr_state        <= WR_BURST_0;
                    end
                end
            endcase
        end
    end


    always @(posedge s_clk) begin
        if (s_rst) begin
            state           <= S_IDLE;

            s_app_af_cmd      <= 'b0;
            s_app_af_addr     <= 'b0;
            s_app_af_wren     <= 1'b0;

            s_app_af_addr_wr  <= 'b0;
            s_app_af_addr_rd  <= 'b0;

            s_app_wdf_wren    <= 1'b0;
        end
        else begin
            s_app_af_wren  <= 1'b0;
            s_app_wdf_wren <= 1'b0;
            state        <= S_IDLE;

            case (state)
                S_IDLE: begin
                    state <= S_IDLE;

                    // only start writing when initialization done
                    if (phy_init_done & ~rnw_mode & write_data) begin
                        data_in_tmp <= data_in;
                        state <= S_WRITE1;
                    end else if (phy_init_done & rnw_mode & s_tx_ready) begin
                        state <= S_READ;
                    end
                end

                S_WRITE1: begin
                    state               <= S_WRITE2;
                    s_app_wdf_wren        <= 1'b1;
                    s_app_wdf_data        <= data_in_tmp[31:0];
                    s_app_wdf_data_tmp    <= data_in_tmp[63:32];

                    s_app_af_wren         <= 1'b1;
                    s_app_af_addr         <= s_app_af_addr_wr;
                    s_app_af_addr_wr      <= s_app_af_addr_wr + 4;

                    s_app_af_cmd          <= 3'b000;

                end

                S_WRITE2: begin
                    s_app_wdf_wren    <= 1'b1;
                    s_app_wdf_data    <= s_app_wdf_data_tmp;

                    state           <= S_IDLE;
                end

                S_READ: begin
                    state           <= S_WAIT0;

                    s_app_af_wren     <= 1'b1;
                    s_app_af_addr     <= s_app_af_addr_rd;
                    s_app_af_addr_rd  <= s_app_af_addr_rd + 4;
                    s_app_af_cmd      <= 3'b001;
                end

                S_WAIT0: begin
                    state <= S_WAIT1;
                end
                S_WAIT1: begin
                    state <= S_WAIT2;
                end
                S_WAIT2: begin
                    state <= S_WAIT3;
                end
                S_WAIT3: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end


    always @(posedge s_clk) begin
        if (s_rst) begin
            rd_state        <= RD_BURST_0;
            s_tx_valid    <= 1'b0;
        end
        else begin
            rd_state        <= RD_BURST_0;
            s_tx_valid    <= 1'b0;

            case (rd_state)
                RD_BURST_0: begin
                    rd_state <= RD_BURST_0;

                    if (s_app_rd_data_valid) begin
                        rd_state            <= RD_BURST_1;
                        s_tx_valid        <= 1'b1;
                        s_tx_valid_tmp    <= 1'b1;
                        s_tx_data         <= s_app_rd_data[15:0];
                        s_tx_data_tmp     <= s_app_rd_data[31:16];
                    end
                end

                RD_BURST_1: begin
                    rd_state            <= RD_BURST_1;
                    s_tx_valid        <= s_tx_valid_tmp;
                    s_tx_data         <= s_tx_data_tmp;
                    s_tx_valid_tmp    <= 1'b0;
                    s_tx_data_tmp     <= 'b0;

                    if (s_app_rd_data_valid) begin
                        rd_state            <= RD_BURST_2;
                        s_tx_valid_tmp    <= 1'b1;
                        s_tx_valid_tmp2   <= 1'b1;
                        s_tx_data_tmp     <= s_app_rd_data[15:0];
                        s_tx_data_tmp2    <= s_app_rd_data[31:16];
                    end
                end

                RD_BURST_2: begin
                    rd_state        <= RD_BURST_3;
                    s_tx_valid    <= s_tx_valid_tmp;
                    s_tx_data     <= s_tx_data_tmp;
                end

                RD_BURST_3: begin
                    rd_state        <= RD_BURST_0;
                    s_tx_valid    <= s_tx_valid_tmp2;
                    s_tx_data     <= s_tx_data_tmp2;
                end
            endcase
        end
    end


endmodule

`endif //  `ifndef _xem5010_loopback_
