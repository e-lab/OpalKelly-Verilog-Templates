/***************************************************************************************************
 * Module: fifo_sync
 *
 * Description: A very generic FIFO, with synchronous clock for read and write
 *              ports, with empty/full flags
 *
 * Behavior:
 *              WRITE:
 *              (with push combinatorially driven by ~full)
 *                           __    __    __    __    __
 *              clk       __|  |__|  |__|  |__|  |__|  |__
 *                        __________             _________
 *              full                |___________|
 *                                     ___________
 *              push      ____________|           |_______
 *                        ____________ _____ _____________
 *              data_push ____________X_____X_____________
 *
 *              > data is reg'd:        ^     ^
 *
 *
 *              READ - Two modes are available:
 *              FALL = 1 (with pop combinatorially driven by ~empty) :
 *                           __    __    __    __    __
 *              clk       __|  |__|  |__|  |__|  |__|  |__
 *                         _________             _________
 *              empty               |___________|
 *                                     ___________
 *              pop        ___________|           |_______
 *                         _________ _____ _______________
 *              data_pop   _________X_____X_______________
 *
 *              > data is valid:        ^     ^
 *
 *
 *              FALL = 0 (with pop combinatorially driven by ~empty) :
 *                           __    __    __    __    __
 *              clk       __|  |__|  |__|  |__|  |__|  |__
 *                         _________             _________
 *              empty               |___________|
 *                                     ___________
 *              pop        ___________|           |_______
 *                         _______________ _____ _________
 *              data_pop   _______________X_____X_________
 *
 *              > data is valid:              ^     ^
 *
 *
 * Development Stage: DONE...
 *  > simult push/pop  Looks OK
 *  > full/empty       Assertion of  “full” or “empty” happens exactly when the FIFO goes full or
 *                     empty.
 *
 *
 * Test bench: tester_fifo_sync.v
 *
 * Time-stamp: Mon  5 Oct 2009 20:55:46 EDT
 *
 * Author:
 * Berin Martini (berin.martini@gmail.com)
 **************************************************************************************************/
`ifndef _fifo_sync_ `define _fifo_sync_



module fifo_sync
  #(parameter
    DATA_WIDTH          = 16,
    ADDR_WIDTH          = 16,
    FALL                = 1,
    LEAD_ALMOST_FULL    = 0,
    LEAD_ALMOST_EMPTY   = 0)
   (output reg  [DATA_WIDTH-1:0]    data_pop,
    output reg  [ADDR_WIDTH:0]      count,
    output reg                      full,
    output reg                      empty,
    output reg                      full_almost,
    output reg                      empty_almost,
    input  [DATA_WIDTH-1:0]         data_push,
    input                           clk,
    input                           rst,
    input                           push,
    input                           pop);

    /************************************************************************************
     * Message
     ************************************************************************************/
`ifdef VERBOSE
    initial $display("fifo sync with depth: %d", DEPTH);
`endif


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    localparam REG_OUTPUT   = FALL ? 0 : 1;
    localparam DEPTH        = 1<<ADDR_WIDTH;

    reg  [DATA_WIDTH-1:0]       mem [0:DEPTH-1];

    reg  [ADDR_WIDTH:0]         wptr;
    wire [ADDR_WIDTH:0]         wptr_nx;
    reg  [ADDR_WIDTH:0]         rptr;
    wire [ADDR_WIDTH:0]         rptr_nx;

    wire [ADDR_WIDTH-1:0]       waddr;
    wire [ADDR_WIDTH-1:0]       waddr_nx;
    wire [ADDR_WIDTH-1:0]       raddr;
    wire [ADDR_WIDTH-1:0]       raddr_nx;

    wire                        full_nx;
    wire                        empty_nx;


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    assign waddr    = wptr      [ADDR_WIDTH-1:0];
    assign waddr_nx = wptr_nx   [ADDR_WIDTH-1:0];

    assign raddr    = rptr      [ADDR_WIDTH-1:0];
    assign raddr_nx = rptr_nx   [ADDR_WIDTH-1:0];

    // Full next
    assign full_nx  = (waddr_nx == raddr) ? (wptr_nx[ADDR_WIDTH] != rptr[ADDR_WIDTH]) : 1'b0;

    // Empty next
    assign empty_nx = (waddr == raddr_nx) ? (wptr[ADDR_WIDTH] == rptr_nx[ADDR_WIDTH]) : 1'b0;

    // Read next
    assign rptr_nx  = rptr + (pop & ~empty);

    // Write next
    assign wptr_nx  = wptr + (push & ~full);


    // Registered population count.
    always @(posedge clk)
        if (rst)    count   <= 'b0;
        else        count   <=
            (wptr[ADDR_WIDTH] == rptr_nx[ADDR_WIDTH]) ? (waddr - raddr_nx):DEPTH - raddr_nx + waddr;


    // Registered full flag.
    always @(posedge clk)
        if (rst)    full    <= 1'b0;
        else        full    <= full_nx;


    // Registered empty flag.
    always @(posedge clk)
        if (rst)    empty   <= 1'b1;
        else        empty   <= empty_nx;


    // Memory read-address pointer.
    always @(posedge clk)
        if (rst)    rptr    <= 0;
        else        rptr    <= rptr_nx;


    // Read from memory
    generate
        if (FALL) begin : FALL_THROUGHT_

            always @* data_pop = mem[raddr];
//            always @(posedge clk) data_pop <= mem[raddr_nx];

        end
        else begin : NOT_FALL_THROUGHT_

            always @(posedge clk)
                if (pop && !empty) data_pop <= mem[raddr];

        end
    endgenerate



    // Memory write-address pointer
    always @(posedge clk)
        if (rst)    wptr    <= 0;
        else        wptr    <= wptr_nx;


    // Write to memory
    always @(posedge clk)
        if (push && !full) mem[waddr] <= data_push;



    /******************************************************************
     * Almost full flag
     ******************************************************************/

    genvar fa;
    generate
        if (0 < LEAD_ALMOST_FULL) begin : FULL_

            wire [0:LEAD_ALMOST_FULL-1] full_nxa;
            wire [ADDR_WIDTH-1:0]       waddr_nxa   [0:LEAD_ALMOST_FULL-1];
            wire [ADDR_WIDTH:0]         wptr_nxa    [0:LEAD_ALMOST_FULL-1];


            // Registered full flag.
            always @(posedge clk)
                if (rst)    full_almost <= 1'b0;
                else        full_almost <= |(full_nxa) | full_nx;


            for (fa = 0; fa < LEAD_ALMOST_FULL; fa = fa + 1) begin : FA_

                assign waddr_nxa[fa]    = (waddr_nx + fa + 1);

                assign wptr_nxa[fa]     = (wptr_nx  + fa + 1);

                assign full_nxa[fa]     =
                    (waddr_nxa[fa] == raddr) ? (wptr_nxa[fa][ADDR_WIDTH] != rptr[ADDR_WIDTH]):1'b0;

            end
        end
        else begin

            // Registered full flag.
            always @(posedge clk)
                if (rst)    full_almost <= 1'b0;
                else        full_almost <= full_nx;

        end
    endgenerate



    /******************************************************************
     * Almost empty flag
     ******************************************************************/

    genvar ea;
    generate
        if (0 < LEAD_ALMOST_EMPTY) begin : EMPTY_

            wire [0:LEAD_ALMOST_EMPTY-1]    empty_nxa;
            wire [ADDR_WIDTH-1:0]           raddr_nxa   [0:LEAD_ALMOST_EMPTY-1];
            wire [ADDR_WIDTH:0]             rptr_nxa    [0:LEAD_ALMOST_EMPTY-1];


            always @(posedge clk)
                if (rst)    empty_almost    <= 1'b1;
                else        empty_almost    <= |(empty_nxa) | empty_nx;


            for (ea = 0; ea < LEAD_ALMOST_EMPTY; ea = ea + 1) begin : EA_

                assign raddr_nxa[ea]    = (raddr_nx + ea + 1);

                assign rptr_nxa[ea]     = (rptr_nx  + ea + 1);

                // Empty next almost
                assign empty_nxa[ea]    =
                    (waddr == raddr_nxa[ea]) ? (wptr[ADDR_WIDTH] == rptr_nxa[ea][ADDR_WIDTH]):1'b0;

            end
        end
        else begin

            always @(posedge clk)
                if (rst)    empty_almost    <= 1'b1;
                else        empty_almost    <= empty_nx;
        end
    endgenerate


endmodule

`endif //  `ifndef _fifo_sync_
