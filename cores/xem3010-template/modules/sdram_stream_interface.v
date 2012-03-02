/***************************************************************************************************
 * Module: sdram_stream_interface
 *
 * Description: The sdram_stream_interface will write streams of data to the sdram on the Opal Kelly
 *              3010 board in a first in first out bases.  The wr ready flag indicates that the wr
 *              buffer can still accept data.  While an active rd ready flag will start reading
 *              data from the SDRAM so long as there is not a write to the SDRAM which will take
 *              precedence.
 *
 * Test bench: tester_sdram_stream_interface.v
 *
 * Created: Sat  3 Jul 2010 21:36:49 EDT
 *
 * Author: Berin Martini // berin.martini@gamil.com
 **************************************************************************************************/
`ifndef _sdram_stream_interface_ `define _sdram_stream_interface_

`include "fifo_async.v"


module sdram_stream_interface
  #(parameter SDRAM_ADDR_WIDTH = 15) // Can be no greater then 15 bits wide
   (// System Side
    input  wire         sys_clk,
    input  wire         sys_rst,

    output wire         sys_wr_ready,
    input  wire         sys_wr_valid,
    input  wire [15:0]  sys_wr_data,

    input  wire         sys_rd_ready,
    output reg          sys_rd_valid,
    output wire [15:0]  sys_rd_data,

    // SDRAM Side
    input  wire         sdram_clk,
    input  wire         sdram_rst,

    output reg          sdram_full,
    output reg          sdram_empty,

    input  wire         sdram_cmd_ack,
    input  wire         sdram_cmd_done,
    output reg          sdram_cmd_wr,
    output reg          sdram_cmd_rd,
    output reg  [14:0]  sdram_addr,

    output wire [15:0]  sdram_wr_data,
    input  wire         sdram_wr_data_en,
    input  wire [15:0]  sdram_rd_data,
    input  wire         sdram_rd_data_en
   );

`include "common_functions.v"


    /**************************************************************************************
     * Private parameters for 'sdram_stream_interface'
     **************************************************************************************/

    localparam WR_BUFF_WIDTH    = 11; // Must be 10 bits or greater wide
    localparam RD_BUFF_WIDTH    = 10; // Must be 10 bits or greater wide (2 pages deep)

    // FSM states
    localparam S_IDLE      = 0,
               S_WACKWAIT  = 1,
               S_RACKWAIT  = 2,
               S_WBUSY     = 3,
               S_RBUSY     = 4;
    reg  [4:0] state, state_nx;


`ifdef VERBOSE
    initial $display("\nusing 'sdram_stream_interface' ");
`endif


    /**************************************************************************************
     * Internal signals
     **************************************************************************************/

    wire                        sys_wr_full;
    wire                        sys_rd_empty;

    wire                        sdram_full_nx;
    wire                        sdram_empty_nx;

    reg  [SDRAM_ADDR_WIDTH:0]   sdram_wr_ptr;
    wire [SDRAM_ADDR_WIDTH:0]   sdram_wr_ptr_nx;
    wire [SDRAM_ADDR_WIDTH-1:0] sdram_wr_addr;
    wire [SDRAM_ADDR_WIDTH-1:0] sdram_wr_addr_nx;

    reg  [SDRAM_ADDR_WIDTH:0]   sdram_rd_ptr;
    wire [SDRAM_ADDR_WIDTH:0]   sdram_rd_ptr_nx;
    wire [SDRAM_ADDR_WIDTH-1:0] sdram_rd_addr;
    wire [SDRAM_ADDR_WIDTH-1:0] sdram_rd_addr_nx;

    wire                        sdram_write;
    wire                        sdram_wr_done;
    wire                        sdram_wr_page;
    wire [WR_BUFF_WIDTH:0]      sdram_wr_count;

    wire                        sdram_read;
    wire                        sdram_rd_done;
    wire                        sdram_rd_page;
    wire [RD_BUFF_WIDTH:0]      sdram_rd_count;


    // Buffer for data to SDRAM
    fifo_async #(
        .DATA_WIDTH         (16),
        .ADDR_WIDTH         (WR_BUFF_WIDTH),
        .FALL               (0),
        .LEAD_ALMOST_FULL   (0),
        .LEAD_ALMOST_EMPTY  (0))
    wr_to_sdram (
        .pop_clk        ( ~sdram_clk),
        .pop_rst        (sdram_rst),
        .pop            (sdram_wr_data_en),
        .pop_data       (sdram_wr_data),
        .pop_empty      (),
        .pop_empty_a    (),
        .pop_count      (sdram_wr_count),

        .push_clk       (sys_clk),
        .push_rst       (sys_rst),
        .push           (sys_wr_valid),
        .push_data      (sys_wr_data),
        .push_full      (sys_wr_full),
        .push_full_a    (),
        .push_count     () );


    // Buffer for data from SDRAM
    fifo_async #(
        .DATA_WIDTH         (16),
        .ADDR_WIDTH         (RD_BUFF_WIDTH),
        .FALL               (0),
        .LEAD_ALMOST_FULL   (0),
        .LEAD_ALMOST_EMPTY  (0))
    rd_from_sdram (
        .pop_clk        (sys_clk),
        .pop_rst        (sys_rst),
        .pop            (sys_rd_ready),
        .pop_data       (sys_rd_data),
        .pop_empty      (sys_rd_empty),
        .pop_empty_a    (),
        .pop_count      (),

        .push_clk       ( ~sdram_clk),
        .push_rst       (sdram_rst),
        .push           (sdram_rd_data_en),
        .push_data      (sdram_rd_data),
        .push_full      (),
        .push_full_a    (),
        .push_count     (sdram_rd_count) );


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    // System FLOW ready flag
    assign sys_wr_ready     = ~sys_wr_full;

    // FSM flags
    assign sdram_write      = state[S_WACKWAIT];

    assign sdram_read       = state[S_RACKWAIT];

    assign sdram_wr_done    = state[S_WBUSY] & sdram_cmd_done;

    assign sdram_rd_done    = state[S_RBUSY] & sdram_cmd_done;

    assign sdram_wr_page    = (sdram_wr_count >= 512);

    assign sdram_rd_page    = (sdram_rd_count >= 512);

    // Address Generation
    assign sdram_wr_addr    = sdram_wr_ptr[SDRAM_ADDR_WIDTH-1:0];

    assign sdram_wr_addr_nx = sdram_wr_ptr_nx[SDRAM_ADDR_WIDTH-1:0];

    assign sdram_rd_addr    = sdram_rd_ptr[SDRAM_ADDR_WIDTH-1:0];

    assign sdram_rd_addr_nx = sdram_rd_ptr_nx[SDRAM_ADDR_WIDTH-1:0];

    assign sdram_wr_ptr_nx  = sdram_wr_ptr + sdram_wr_done;

    assign sdram_rd_ptr_nx  = sdram_rd_ptr + sdram_rd_done;


    // SDRAM full next
    assign sdram_full_nx  = (sdram_wr_addr_nx == sdram_rd_addr)
                            ? (sdram_wr_ptr_nx[SDRAM_ADDR_WIDTH] != sdram_rd_ptr[SDRAM_ADDR_WIDTH])
                            : 1'b0;

    // SDRAM empty next
    assign sdram_empty_nx = (sdram_wr_addr == sdram_rd_addr_nx)
                            ? (sdram_wr_ptr[SDRAM_ADDR_WIDTH] == sdram_rd_ptr_nx[SDRAM_ADDR_WIDTH])
                            : 1'b0;


    always @(negedge sdram_clk)
        sdram_full <= sdram_full_nx;


    always @(negedge sdram_clk)
        sdram_empty <= sdram_empty_nx;


    always @(negedge sdram_clk)
        if  (sdram_rst) sdram_wr_ptr    <= 'b0;
        else            sdram_wr_ptr    <= sdram_wr_ptr_nx;


    always @(negedge sdram_clk)
        if  (sdram_rst) sdram_rd_ptr    <= 'b0;
        else            sdram_rd_ptr    <= sdram_rd_ptr_nx;


    // System FLOW valid flag
    always @(posedge sys_clk)
        sys_rd_valid <= (sys_rd_ready & ~sys_rd_empty);


    // SDRAM Address assignment
    always @(negedge sdram_clk) begin
        sdram_cmd_wr    <= 1'b0;
        sdram_cmd_rd    <= 1'b0;
        sdram_addr      <= 'b0;

        if (sdram_write) begin
            sdram_cmd_wr    <= 1'b1;
            sdram_addr      <= sdram_wr_addr;
        end
        else if (sdram_read) begin
            sdram_cmd_rd    <= 1'b1;
            sdram_addr      <= sdram_rd_addr;
        end
    end


    /************************************************************************************
     * SDRAM FSM
     *
     * This FSM handles the multiplexing of the SDRAM bus between write and read
     * requests.  The write FIFO needs to be holding at least a full page of data before
     * a write will occur.  A second page read will not start so long as there is a full
     * page in the read FIFO.
     ************************************************************************************/

    always @(negedge sdram_clk)
        if (sdram_rst) begin
            state           <= 'b0;
            state[S_IDLE]   <= 1'b1;
        end
        else state <= state_nx;


    always @* begin
        state_nx = 'b0;

        case (1'b1)

            state[S_IDLE] : begin
                if      (~sdram_full  &  sdram_wr_page) state_nx[S_WACKWAIT]    = 1'b1;
                else if (~sdram_empty & ~sdram_rd_page) state_nx[S_RACKWAIT]    = 1'b1;
                else                                    state_nx[S_IDLE]        = 1'b1;
            end

            state[S_WACKWAIT] : begin
                if      (sdram_cmd_ack)                 state_nx[S_WBUSY]       = 1'b1;
                else                                    state_nx[S_WACKWAIT]    = 1'b1;
            end

            state[S_RACKWAIT] : begin
                if      (sdram_cmd_ack)                 state_nx[S_RBUSY]       = 1'b1;
                else                                    state_nx[S_RACKWAIT]    = 1'b1;
            end

            state[S_WBUSY] : begin
                if      (sdram_cmd_done)                state_nx[S_IDLE]        = 1'b1;
                else                                    state_nx[S_WBUSY]       = 1'b1;
            end

            state[S_RBUSY] : begin
                if      (sdram_cmd_done)                state_nx[S_IDLE]        = 1'b1;
                else                                    state_nx[S_RBUSY]       = 1'b1;
            end
        endcase
    end



endmodule

`endif //  `ifndef _sdram_stream_interface_
