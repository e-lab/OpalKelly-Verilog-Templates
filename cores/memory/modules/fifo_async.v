/***************************************************************************************************
 * Module: fifo_async
 *
 * Description: A very generic FIFO, with asynchronous clocks on read and write
 *              ports, with empty/full flags
 *
 * Behavior:
 *              WRITE:
 *              (with push combinatorially driven by ~push_full)
 *                           __    __    __    __    __
 *              push_clk  __|  |__|  |__|  |__|  |__|  |__
 *                        __________             _________
 *              push_full           |___________|
 *                                     ___________
 *              push      ____________|           |_______
 *                        ____________ _____ _____________
 *              push_data ____________X_____X_____________
 *
 *              > data is reg'd:        ^     ^
 *
 *
 *              READ:
 *              (with pop combinatorially driven by ~empty) :
 *                           __    __    __    __    __
 *              pop_clk   __|  |__|  |__|  |__|  |__|  |__
 *                         _________             _________
 *              pop_empty           |___________|
 *                                     ___________
 *              pop        ___________|           |_______
 *                         _________ _____ _______________
 *              pop_data   _________X_____X_______________
 *
 *              > data is valid:        ^     ^
 *
 *
 * Development Stage: DONE...
 *  > simult push/pop  Looks OK
 *  > full/empty       Assertion of  “full” or “empty” happens exactly when the FIFO goes full or
 *                     empty.  Removal of “full” and “empty” status is pessimistic and will happen
 *                     only after a few clock cycles.
 *
 * Test bench: tester_fifo_async.v
 *
 * Time-stamp: Tue 27 Oct 2009 11:19:59 EDT
 *
 * Author:
 * http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
 * http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO2.pdf
 * http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_Resets.pdf
 **************************************************************************************************/

`ifndef _fifo_async_ `define _fifo_async_


module fifo_async
  #(parameter
    DATA_WIDTH          = 8,
    ADDR_WIDTH          = 4,
    FALL                = 1,
    LEAD_ALMOST_FULL    = 0,
    LEAD_ALMOST_EMPTY   = 0)
   (input                       pop_clk,
    input                       pop_rst,
    input                       pop,
    output reg [DATA_WIDTH-1:0] pop_data,
    output reg                  pop_empty,
    output                      pop_empty_a,
    output [ADDR_WIDTH:0]       pop_count,

    input                       push_clk,
    input                       push_rst,
    input                       push,
    input  [DATA_WIDTH-1:0]     push_data,
    output reg                  push_full,
    output                      push_full_a,
    output [ADDR_WIDTH:0]       push_count
   );

    /************************************************************************************
     * Message
     ************************************************************************************/

`ifdef VERBOSE
    initial $display("fifo async with depth: %d", DEPTH);
`endif


    /************************************************************************************
     * Internal signals
     ************************************************************************************/

    localparam DEPTH = 1<<ADDR_WIDTH; // DEPTH = 2**ADDR_WIDTH

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    wire                    dirset_n;
    wire                    dirclr_n;
    reg                     direction;

    // rptr_empty
    reg    [ADDR_WIDTH-1:0] rptr;
    reg    [ADDR_WIDTH-1:0] rbin;

    reg                     rempty;
    wire   [ADDR_WIDTH-1:0] rgnext;
    wire   [ADDR_WIDTH-1:0] rbnext;

    // wptr_full
    reg    [ADDR_WIDTH-1:0] wptr;
    reg    [ADDR_WIDTH-1:0] wbin;

    reg                     wfull;
    wire   [ADDR_WIDTH-1:0] wgnext;
    wire   [ADDR_WIDTH-1:0] wbnext;

    wire                    aempty_n;
    wire                    afull_n;


    /************************************************************************************
     * Implementation
     ************************************************************************************/

    generate
        if (FALL) begin : FALL_THROUGHT_

            always @* pop_data = mem[rptr];
            //always @(mem[rptr], rptr) pop_data = mem[rptr];
            //always @(posedge pop_clk) pop_data <= mem[rgnext];

        end
        else begin : NOT_FALL_THROUGHT_

            always @(posedge pop_clk)
                if (pop && !pop_empty) pop_data <= mem[rptr];

        end
    endgenerate

    always @(posedge push_clk)
        if (push & ~push_full) mem[wptr] <= push_data;


    //---------------------------------------------------------------
    // Async pointer compare to determine direction of change
    //---------------------------------------------------------------
    assign aempty_n = ~((wptr == rptr) && !direction);

    assign afull_n  = ~((wptr == rptr) &&  direction);

    assign dirset_n = ~( (wptr[ADDR_WIDTH-1]^rptr[ADDR_WIDTH-2])
                      & ~(wptr[ADDR_WIDTH-2]^rptr[ADDR_WIDTH-1]));

    assign dirclr_n = ~((~(wptr[ADDR_WIDTH-1]^rptr[ADDR_WIDTH-2])
                      &   (wptr[ADDR_WIDTH-2]^rptr[ADDR_WIDTH-1]))
                      |   push_rst);


    // should inferring an RS-flip-flop, if not use code above
    always @(negedge dirset_n or negedge dirclr_n)
        if      (!dirclr_n) direction <= 1'b0;
        else                direction <= 1'b1;


    //---------------------------------------------------------------
    // GRAYSTYLE2 Read pointer
    //---------------------------------------------------------------
    always @(posedge pop_clk or posedge pop_rst)
        if (pop_rst)    rbin <= 'b0;
        else            rbin <= rbnext;


    always @(posedge pop_clk or posedge pop_rst)
        if (pop_rst)    rptr <= 'b0;
        else            rptr <= rgnext;


    //---------------------------------------------------------------
    // increment the binary count if not empty
    //---------------------------------------------------------------
    assign rbnext = !pop_empty ? rbin + pop : rbin;

    assign rgnext = (rbnext>>1) ^ rbnext; // binary-to-gray conversion

    always @(posedge pop_clk or negedge aempty_n)
        if (!aempty_n) {pop_empty, rempty} <= 2'b11;
        else           {pop_empty, rempty} <= {rempty, ~aempty_n};


    //---------------------------------------------------------------
    // GRAYSTYLE2 Write pointer
    //---------------------------------------------------------------
    always @(posedge push_clk or posedge push_rst)
        if (push_rst)   wbin <= 'b0;
        else            wbin <= wbnext;


    always @(posedge push_clk or posedge push_rst)
        if (push_rst)   wptr <= 'b0;
        else            wptr <= wgnext;


    //---------------------------------------------------------------
    // increment the binary count if not full
    //---------------------------------------------------------------
    assign wbnext = !push_full ? wbin + push : wbin;

    assign wgnext = (wbnext>>1) ^ wbnext; // binary-to-gray conversion

    always @(posedge push_clk or posedge push_rst or negedge afull_n)
        if      (push_rst) {push_full, wfull} <= 2'b00;
        else if (!afull_n) {push_full, wfull} <= 2'b11;
        else               {push_full, wfull} <= {wfull, ~afull_n};


    //---------------------------------------------------------------
    // Pass counter to other clk domain and convert gray to binary.
    // These binary counters are used to calculate two counters that
    // contain the number of elements in the fifo as seen from each
    // clk domain.
    //---------------------------------------------------------------
    wire [ADDR_WIDTH-1:0]   push_rbin;
    reg  [ADDR_WIDTH-1:0]   push_1rptr;
    reg  [ADDR_WIDTH-1:0]   push_2rptr;

    wire [ADDR_WIDTH-1:0]   pop_wbin;
    reg  [ADDR_WIDTH-1:0]   pop_1wptr;
    reg  [ADDR_WIDTH-1:0]   pop_2wptr;


    assign push_rbin    = (push_rbin>>1) ^ push_2rptr; // gray-to-binary conversion

    assign pop_wbin     = (pop_wbin>>1) ^ pop_2wptr; // gray-to-binary conversion

    assign push_count   = ((push_rbin > wbin) || push_full)
                            ? (DEPTH - push_rbin + wbin)
                            : (wbin - push_rbin);

    assign pop_count    = ((pop_wbin > rbin) || pop_empty)
                            ? (pop_wbin - rbin)
                            : (DEPTH - rbin + pop_wbin);


    always @(posedge push_clk)
        if (push_rst)   {push_2rptr, push_1rptr} <= 'b0;
        else            {push_2rptr, push_1rptr} <= {push_1rptr, rptr};


    always @(posedge pop_clk)
        if (pop_rst)    {pop_2wptr, pop_1wptr} <= 'b0;
        else            {pop_2wptr, pop_1wptr} <= {pop_1wptr, wptr};



//    // Almost empty used in count
//    reg                     pop_empty_almost;
//    reg                     pop_empty_rff;
//    wire                    aempty_a_n;
//    wire [ADDR_WIDTH-1:0]   rbin_a_nx;
//    wire [ADDR_WIDTH-1:0]   rptr_a_nx;
//    reg  [ADDR_WIDTH-1:0]   rptr_a;
//
//    assign rbin_a_nx    = (rbnext + 1);
//
//    assign rptr_a_nx    = (rbin_a_nx>>1) ^ rbin_a_nx;
//
//    assign aempty_a_n   = ~(wptr == rptr_a);
//
//
//    always @(posedge pop_clk) rptr_a <= rptr_a_nx;
//
//
//    always @(posedge pop_clk or posedge pop_rst or negedge aempty_a_n)
//        if      (pop_rst)       {pop_empty_almost, pop_empty_rff} <= 2'b00;
//        else if (!aempty_a_n)   {pop_empty_almost, pop_empty_rff} <= 2'b11;
//        else                    {pop_empty_almost, pop_empty_rff} <= {pop_empty_rff, ~aempty_a_n};
//
//
//    always @(posedge pop_clk)
//        if ((pop_wbin > rbnext) || pop_empty_almost || pop_empty) begin
//            pop_count <= (pop_wbin - rbnext);
//        end
//        else begin
//            pop_count <= (DEPTH - rbnext + pop_wbin);
//        end
//
//
//    // Almost full used in count
//    reg                     push_full_almost;
//    reg                     push_full_rff;
//    wire                    afull_a_n;
//    wire [ADDR_WIDTH-1:0]   wbin_a_nx;
//    wire [ADDR_WIDTH-1:0]   wptr_a_nx;
//    reg  [ADDR_WIDTH-1:0]   wptr_a;
//
//
//    assign wbin_a_nx    = (wbnext + 1);
//
//    assign wptr_a_nx    = (wbin_a_nx>>1) ^ wbin_a_nx;
//
//    assign afull_a_n    = ~(wptr_a == rptr);
//
//
//    always @(posedge push_clk) wptr_a <= wptr_a_nx;
//
//
//    always @(posedge push_clk or posedge push_rst or negedge afull_a_n)
//        if      (push_rst)      {push_full_almost, push_full_rff} <= 2'b00;
//        else if (!afull_a_n)    {push_full_almost, push_full_rff} <= 2'b11;
//        else                    {push_full_almost, push_full_rff} <= {push_full_rff, ~afull_a_n};
//
//
//    always @(posedge push_clk)
//        if ((push_rbin > wbnext) || push_full_almost || push_full) begin
//            push_count <= (DEPTH - push_rbin + wbnext);
//        end
//        else begin
//            push_count <= (wbnext - push_rbin);
//        end


    //---------------------------------------------------------------
    // increment the "almost" binary count if the binary counter does
    //---------------------------------------------------------------



    genvar ea;
    generate
        if (0 < LEAD_ALMOST_EMPTY) begin : ALMOST_EMPTY_

            wire [ADDR_WIDTH-1:0] rbnext_almost [0:LEAD_ALMOST_EMPTY-1];
            wire [ADDR_WIDTH-1:0] rgnext_almost [0:LEAD_ALMOST_EMPTY-1];
            reg  [ADDR_WIDTH-1:0] rptr_almost   [0:LEAD_ALMOST_EMPTY-1];

            wire                            aempty_almost_n;
            wire [0:LEAD_ALMOST_EMPTY-1]    aempty1_almost_n;
            wire [0:LEAD_ALMOST_EMPTY-1]    aempty2_almost_n;
            reg                             pop_empty1_a;
            reg                             pop_empty2_a;

            assign pop_empty_a          = pop_empty1_a | pop_empty;

            assign aempty_almost_n      = &(aempty1_almost_n);

            assign rbnext_almost[0]     = (rbnext + 1);

            assign rgnext_almost[0]     = (rbnext_almost[0]>>1) ^ rbnext_almost[0];

            assign aempty1_almost_n[0]  = ~(wptr == (rptr_almost[0]));


            always @(posedge pop_clk) rptr_almost[0] <= rgnext_almost[0];


            for (ea = 1; ea < LEAD_ALMOST_EMPTY; ea = ea + 1) begin : EA_
                assign rbnext_almost[ea]    = (rbnext + ea + 1);

                assign rgnext_almost[ea]    = (rbnext_almost[ea]>>1) ^ rbnext_almost[ea];

                assign aempty1_almost_n[ea] = ~(wptr == (rptr_almost[ea]));

                always @(posedge pop_clk) rptr_almost[ea] <= rgnext_almost[ea];
            end


            // almost empty
            always @(posedge pop_clk or posedge pop_rst or negedge aempty_almost_n)
                if      (pop_rst)           {pop_empty1_a, pop_empty2_a} <= 2'b00;
                else if (!aempty_almost_n)  {pop_empty1_a, pop_empty2_a} <= 2'b11;
                else begin
                    {pop_empty1_a, pop_empty2_a} <= {pop_empty2_a, ~aempty_almost_n};
                end

        end
        else begin : EMPTY_
            assign pop_empty_a = pop_empty;
        end
    endgenerate


    //---------------------------------------------------------------
    // increment the "almost" binary count if the binary counter does
    //---------------------------------------------------------------


    genvar fa;
    generate
        if (0 < LEAD_ALMOST_FULL) begin : ALMOST_FULL_

            wire [ADDR_WIDTH-1:0] wbnext_almost [0:LEAD_ALMOST_FULL-1];
            wire [ADDR_WIDTH-1:0] wgnext_almost [0:LEAD_ALMOST_FULL-1];
            reg  [ADDR_WIDTH-1:0] wptr_almost   [0:LEAD_ALMOST_FULL-1];

            wire                        afull_almost_n;
            wire [0:LEAD_ALMOST_FULL-1] afull1_almost_n;
            wire [0:LEAD_ALMOST_FULL-1] afull2_almost_n;
            reg                         wfull1_a;
            reg                         wfull2_a;

            assign push_full_a          = wfull1_a | push_full;

            assign afull_almost_n       = &(afull1_almost_n);

            assign wbnext_almost[0]     = (wbnext + 1);

            assign wgnext_almost[0]     = (wbnext_almost[0]>>1) ^ wbnext_almost[0];

            assign afull1_almost_n[0]   = ~(wptr_almost[0] == rptr);


            always @(posedge push_clk) wptr_almost[0] <= wgnext_almost[0];


            for (fa = 1; fa < LEAD_ALMOST_FULL; fa = fa + 1) begin : FA_
                assign wbnext_almost[fa]    = (wbnext + fa + 1);

                assign wgnext_almost[fa]    = (wbnext_almost[fa]>>1) ^ wbnext_almost[fa];

                assign afull1_almost_n[fa]  = ~((wptr_almost[fa] == rptr));

                always @(posedge push_clk) wptr_almost[fa] <= wgnext_almost[fa];
            end

            // almost full
            always @(posedge push_clk or posedge push_rst or negedge afull_almost_n)
                if      (push_rst)          {wfull1_a, wfull2_a} <= 2'b00;
                else if (!afull_almost_n)   {wfull1_a, wfull2_a} <= 2'b11;
                else                        {wfull1_a, wfull2_a} <= {wfull2_a, ~afull_almost_n};


        end
        else begin : FULL_
            assign push_full_a = push_full;
        end
    endgenerate



endmodule

`endif //  `ifndef _fifo_async_
