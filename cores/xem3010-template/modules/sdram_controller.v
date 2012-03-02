/***************************************************************************************************
 * Module: sdram_controller
 *
 * Description: The sdram_controller will write streams of data to the sdram in the Opal Kelly
 *              3010 board in a first in first out bases.  The wr ready flag is an active ready
 *              (acts like a pop), while the rd ready flag must be passive to take into
 *              consideration the latency of the SDRAM memory.  The best way to interface with this
 *              is with two buffer fifos between the this module and the system.
 *
 * Test bench: tester_sdram_controller.v
 *
 * Created: Sat  3 Jul 2010 21:36:49 EDT
 *
 * Author: Berin Martini // berin.martini@gamil.com
 **************************************************************************************************/
`ifndef _sdram_controller_ `define _sdram_controller_

//`include "flow_bus_logical_mux.v"
//`include "fifo_sync.v"

module sdram_controller
  #(parameter
    SDRAM_DATA_WIDTH    = 16,
    SDRAM_BURST_MODE    = 8,
    SDRAM_BANK_WIDTH    = 2,
    SDRAM_ROW_WIDTH     = 13,
    SDRAM_COL_WIDTH     = 9)
   (sdr_clk,
    sdr_rst,

    sdr_wr_ready,
    sdr_wr_valid,
    sdr_wr_data,
    sdr_wr_mask,
    sdr_wr_addr,

    sdr_rd_ready,
    sdr_rd_valid,
    sdr_rd_mask,
    sdr_rd_addr,

    sdr_rd_data_ready,
    sdr_rd_data_valid,
    sdr_rd_data,

    sdr_cke,
    sdr_cs_n,
    sdr_we_n,
    sdr_cas_n,
    sdr_ras_n,
    sdr_ldqm,
    sdr_udqm,
    sdr_ba,
    sdr_a,
    sdr_d
   );

`include "common_functions.v"


    /**************************************************************************************
     * Private parameters for 'sdram_controller'
     **************************************************************************************/

    // Parameters to concat/unconcat data packets.                                  // Example:
    localparam SDRAM_ADDR_WIDTH = SDRAM_BANK_WIDTH + SDRAM_ROW_WIDTH + SDRAM_COL_WIDTH;
    localparam SDRAM_MASK_WIDTH = `CLOG2(SDRAM_DATA_WIDTH*SDRAM_BURST_MODE);

    input                           sdr_clk;
    input                           sdr_rst;

    output                          sdr_wr_ready;
    input                           sdr_wr_valid;
    input  [SDRAM_DATA_WIDTH-1:0]   sdr_wr_data;
    input  [SDRAM_MASK_WIDTH-1:0]   sdr_wr_mask;
    input  [SDRAM_ADDR_WIDTH-1:0]   sdr_wr_addr;

    output                          sdr_rd_ready;
    input                           sdr_rd_valid;
    input  [SDRAM_ADDR_WIDTH-1:0]   sdr_rd_addr;
    input  [SDRAM_MASK_WIDTH-1:0]   sdr_rd_mask;

    input                           sdr_rd_data_ready;
    output reg                          sdr_rd_data_valid;
    output reg [SDRAM_DATA_WIDTH-1:0]   sdr_rd_data;

    output                          sdr_cke;
    output                          sdr_cs_n;
    output                          sdr_we_n;
    output                          sdr_cas_n;
    output                          sdr_ras_n;
    output                          sdr_ldqm;
    output                          sdr_udqm;
    output [1:0]                    sdr_ba;
    output [12:0]                   sdr_a;
    inout  [15:0]                   sdr_d;


`ifdef VERBOSE
    initial $display("\nusing 'sdram_controller' ");
`endif


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    // Delay timings.  Most of these are specified in ns on the Micron
    // datasheet.  They are converted to clock cycles here for a
    // 100 MHz clock frequency.
    parameter CNT_tRP   = 4'd1;
    parameter CNT_tRFC  = 4'd9;
    parameter CNT_tMRD  = 4'd1;
    parameter CNT_tWR   = 4'd4;
    parameter CNT_tCAS  = 4'd2;
    parameter CNT_tINIT = 16'd17500;


    reg  [3:0]  sdram_cmd;      // {cs_n, ras_n, cas_n, we_n}
    reg  [1:0]  sdram_ba;
    reg  [12:0] sdram_a;

    assign {sdr_cs_n, sdr_ras_n, sdr_cas_n, sdr_we_n} = sdram_cmd;
    assign sdr_ba       = sdram_ba;
    assign sdr_a        = sdram_a;
    assign sdr_cke      = 1'b1;
    assign sdr_ldqm     = 1'b0;
    assign sdr_udqm     = 1'b0;

    parameter CMD_INHIBIT         = 4'b1000,
              CMD_NOP             = 4'b0111,
              CMD_ACTIVE          = 4'b0011,
              CMD_READ            = 4'b0101,
              CMD_WRITE           = 4'b0100,
              CMD_BURSTTERMINATE  = 4'b0110,
              CMD_PRECHARGE       = 4'b0010,
              CMD_AUTOREFRESH     = 4'b0001,
              CMD_LOADMODE        = 4'b0000;

    parameter DIR_READ  = 1'b1,
              DIR_WRITE = 1'b0;


    // Default mode:
    // Burst length = Full page
    // Burst type = Sequential
    // CAS latency = 2 (for Micron -7E devices)
    // Operating mode = Standard
    // Write burst mode = Programmed burst length
    //parameter MODE_DEFAULT = 13'b0000000100111;
    //parameter MODE_DEFAULT = 13'b0000000110111; //CAS=3
    parameter MODE_DEFAULT = 13'b0000000110011; //CAS=3, Burst=8


    parameter [5:0]
              s_idle         = 6'd0,
              s_reset        = 6'd1,
              s_reset2       = 6'd2,
              s_reset3       = 6'd3,
              s_reset4       = 6'd4,
              s_reset5       = 6'd5,
              s_reset6       = 6'd6,

              s_loadmode     = 6'd7,
              s_loadmode2    = 6'd8,

              s_blockwrite   = 6'd9,
              s_blockwrite1  = 6'd10,
              s_blockwrite2  = 6'd11,
              s_blockwrite3  = 6'd12,
              s_blockwrite4  = 6'd13,
              s_blockwrite5  = 6'd14,
              s_blockwrite6  = 6'd15,
              s_blockwrite7  = 6'd16,
              s_blockwrite8  = 6'd17,

              s_blockread    = 6'd18,
              s_blockread1   = 6'd19,
              s_blockread2   = 6'd20,
              s_blockread3   = 6'd21,
              s_blockread4   = 6'd22,
              s_blockread5   = 6'd23,
              s_blockread6   = 6'd24,
              s_blockread7   = 6'd25,
              s_blockread8   = 6'd26,

              s_autorefresh  = 6'd27,
              s_autorefresh1 = 6'd28,
              s_autorefresh2 = 6'd29,
              s_autorefresh3 = 6'd30,

              s_init         = 6'd31,
              s_init2        = 6'd32;
    reg [5:0] state;

    reg [15:0] sdram_dout;
    reg        sdram_dir;
    assign sdr_d = (DIR_WRITE == sdram_dir) ? sdram_dout : 'bz;

    always @(posedge sdr_clk) begin
        sdr_rd_data <= sdr_d;
    end


    // Initialization counter
    reg [15:0] cINIT;

    // Counter for various delay timings.
    reg [3:0] cWAIT;

    // Transaction counter.
    reg [8:0] cTX;

    // Refresh timer.
    reg [9:0] cREFRESH_TIMER;
    reg [4:0] cREFRESH_COUNT;


    always @(posedge sdr_clk) begin
        if (sdr_rst) begin
            state       <= s_init;
            //cREFRESH_TIMER <= REFRESH_CYCLE;
            cWAIT       <= 0;
            //rowaddr     <= 0;

            sdram_cmd   <= CMD_INHIBIT;
            sdram_ba    <= 0;
            sdram_a     <= 0;
            sdram_dir   <= DIR_WRITE;
        end else begin
            sdr_rd_data_valid <= 1'b0;
            sdram_dout  <= sdr_d;
            sdram_dir   <= DIR_WRITE;

            case (state)

                s_init: begin
                    sdram_cmd   <= CMD_INHIBIT;
                    sdram_a     <= 13'b0010000000000;
                    sdram_ba    <= 2'b00;
                    cINIT       <= CNT_tINIT;
                    //cINIT       <= 16'd10;
                    state       <= s_init2;
                end

                // Wait to satisfy tINIT (>100us).
                s_init2: begin
                    cINIT <= cINIT - 1;
                    if (cINIT == 0)
                        state <= s_reset;
                    else
                        state <= s_init2;
                end

                // --- RESET ----------------------------------------------------
                // Send PRECHARGE to all banks.
                s_reset: begin
                    sdram_cmd   <= CMD_PRECHARGE;
                    sdram_a     <= 13'b0010000000000;
                    sdram_ba    <= 2'b00;
                    cWAIT       <= CNT_tRP;
                    state       <= s_reset2;
                end

                // Wait to satisfy tRP.
                s_reset2: begin
                    sdram_cmd   <= CMD_NOP;
                    cWAIT       <= cWAIT - 1;
                    if (cWAIT == 0)
                        state <= s_reset3;
                    else
                        state <= s_reset2;
                end

                // Send AUTO REFRESH.
                s_reset3: begin
                    sdram_cmd   <= CMD_AUTOREFRESH;
                    cWAIT       <= CNT_tRFC;
                    state       <= s_reset4;
                end

                // Wait to satisfy tRFC.
                s_reset4: begin
                    sdram_cmd   <= CMD_NOP;
                    cWAIT       <= cWAIT - 1;
                    if (cWAIT == 0)
                        state <= s_reset5;
                    else
                        state <= s_reset4;
                end

                // Send AUTO REFRESH.
                s_reset5: begin
                    sdram_cmd   <= CMD_AUTOREFRESH;
                    //cREFRESH_TIMER <= REFRESH_CYCLE;
                    cWAIT       <= CNT_tRFC;
                    state       <= s_reset6;
                end

                // Wait to satisfy tRFC.
                s_reset6: begin
                    sdram_cmd   <= CMD_NOP;
                    cWAIT       <= cWAIT - 1;
                    if (cWAIT == 0)
                        state <= s_loadmode;
                    else
                        state <= s_reset6;
                end

                // Send the LOAD MODE command.
                s_loadmode: begin
                    sdram_cmd   <= CMD_LOADMODE;
                    sdram_a     <= MODE_DEFAULT;
                    cWAIT       <= CNT_tMRD;
                    state       <= s_loadmode2;
                end

                // Wait to satisfy tMRD.
                s_loadmode2: begin
                    sdram_cmd   <= CMD_NOP;
                    cWAIT       <= cWAIT - 1;
                    if (cWAIT == 0)
                        //state <= s_idle;
                        state <= s_blockwrite;
                    else
                        state <= s_loadmode2;
                end

                s_blockwrite: begin
                    //cTX         <= 9'd511;
                    cTX         <= 9'd7;
                    sdram_cmd   <= CMD_ACTIVE;
                    //sdram_ba    <= rowaddr[14:13];
                    //sdram_a     <= rowaddr[12:0];
                    sdram_ba    <= 'b0;
                    sdram_a     <= 'b0;
                    state       <= s_blockwrite2;
                end

                // Send NOP to satisfy tRCD.
                s_blockwrite2: begin
                    sdram_cmd   <= CMD_NOP;
                    state       <= s_blockwrite3;
                end

                // Send a WRITE with AUTO PRECHARGE
                // First FIFO data is available here.
                s_blockwrite3: begin
                    sdram_cmd   <= CMD_WRITE;
                    //sdram_ba    <= rowaddr[14:13];
                    //sdram_a     <= {4'b0010, 9'd0};
                    sdram_ba    <= 'b0;
                    sdram_a     <= 'b0;
                    cTX         <= cTX - 1;
                    state       <= s_blockwrite4;
                end

                // Send NOP until the burst is complete.
                s_blockwrite4: begin
                    sdram_cmd <= CMD_NOP;
                    cTX <= cTX - 1;
                    if (cTX == 2)
                        state <= s_blockwrite5;
                    else begin
                        sdram_dout  <= cTX;
                        state       <= s_blockwrite4;
                    end
                end

                // Second to last WRITE in the burst.
                s_blockwrite5: begin
                    sdram_cmd   <= CMD_NOP;
                    sdram_dout  <= cTX-1;
                    state       <= s_blockwrite6;
                end

                // Last WRITE in the burst.
                s_blockwrite6: begin
                    sdram_cmd   <= CMD_NOP;
                    sdram_dout  <= 0;
                    state       <= s_blockwrite7;
                    //state       <= s_blockread;
                        cWAIT       <= 4'b1111;
                end

                // NOT - Terminate the full-page burst.
                // IS - wait between write and read
                s_blockwrite7: begin
                    //sdram_cmd   <= CMD_BURSTTERMINATE;
                    //state       <= s_blockwrite8;

                    sdram_cmd   <= CMD_NOP;
                    sdram_dout  <= 0;
                        cWAIT       <= cWAIT - 1;
                        if (cWAIT == 0) state <= s_blockread;
                        else            state <= s_blockwrite7;
                end

                // Wait to satisfy tWR.
                // Perform an AUTO REFRESH when we finish.
                s_blockwrite8: begin
                    sdram_cmd       <= CMD_NOP;
                    cREFRESH_COUNT  <= 5'd1;
                    state           <= s_autorefresh;
                end

                // Send the ACTIVE command
                s_blockread: begin
                    //cTX         <= 9'd511;
                    cTX         <= 9'd7;
                    sdram_cmd   <= CMD_ACTIVE;
                    //sdram_ba    <= rowaddr[14:13];
                    //sdram_a     <= rowaddr[12:0];
                    sdram_ba    <= 'b0;
                    sdram_a     <= 'b0;
                    sdram_dir   <= DIR_READ;
                    state       <= s_blockread2;
                end

                // Send NOP to satisfy tRCD.
                s_blockread2: begin
                    sdram_cmd   <= CMD_NOP;
                    sdram_dir   <= DIR_READ;
                    state       <= s_blockread3;
                end

                // Send a READ with AUTO PRECHARGE
                s_blockread3: begin
                    sdram_cmd   <= CMD_READ;
                    //sdram_ba    <= rowaddr[14:13];
                    //sdram_a     <= {4'b0010, 9'd0};
                    sdram_ba    <= 'b0;
                    sdram_a     <= 'b0;
                    sdram_dir   <= DIR_READ;
                    //cTX         <= 9'd511;
                    cTX         <= 9'd7;
                    cWAIT       <= CNT_tCAS;
                    state       <= s_blockread4;
                end

                // CAS wait
                s_blockread4: begin
                    sdram_cmd   <= CMD_NOP;
                    sdram_dir   <= DIR_READ;
                    cWAIT       <= cWAIT - 1;
                    if (cWAIT == 0) begin
                        state   <= s_blockread5;
                    end else begin
                        state   <= s_blockread4;
                    end
                end

                // First read is available here
                s_blockread5: begin
                    sdram_cmd   <= CMD_NOP;
                    sdram_dir   <= DIR_READ;
                    //fifo_write  <= 1'b1;
                    sdr_rd_data_valid <= 1'b1;

                    cTX <= cTX - 1;
                    if (cTX == 9'd3)
                        state <= s_blockread6;
                    else
                        state <= s_blockread5;
                end

                // Send BURST TERMINATE.
                s_blockread6: begin
                    sdram_cmd   <= CMD_BURSTTERMINATE;
                    sdram_dir   <= DIR_READ;
                    //fifo_write  <= 1'b1;
                    sdr_rd_data_valid <= 1'b1;
                    cTX         <= cTX - 1;
                    state       <= s_blockread7;
                end

                // Send NOP.  Second to last read available here.
                s_blockread7: begin
                    sdram_cmd   <= CMD_NOP;
                    sdram_dir   <= DIR_READ;
                    //fifo_write  <= 1'b1;
                    sdr_rd_data_valid <= 1'b1;
                    state       <= s_blockread8;
                end

                // Send NOP.  Last read available here.
                // Run an AUTO REFRESH cycle after the block read.
                s_blockread8: begin
                    sdram_cmd       <= CMD_NOP;
                    sdram_dir       <= DIR_READ;
                    //fifo_write      <= 1'b1;
                    sdr_rd_data_valid <= 1'b1;
                    //cmd_done        <= 1'b1;
                    cREFRESH_COUNT  <= 5'd1;
                    state           <= s_autorefresh;
            end
            endcase
        end
    end



endmodule

`endif //  `ifndef _sdram_controller_
