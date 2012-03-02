/***************************************************************************************************
 * TEST BENCH SKELETON
 *
 * Those tasks are always the same, whatever the testbench
 * It should be included within the module testbench.
 * Then the user needs to declare these functions:
 *  > display_header()
 *  >
 *  > init()
 *  > test1() to test10()
 *
 * Time-stamp: <2009-06-10 17:51:36 clementfarabet>
 *
 * Author: Clement Farabet // clement.farabet@gmail.com
 **************************************************************************************************/

// These macros wait for a certain nb of clock cycles.
// _n waits for negative edges
`define wait_1_cycle_n(sig) @(negedge sig)
`define wait_1_cycle(sig) @(posedge sig)
`define wait_N_cycles(sig, n) repeat(n) @(posedge sig)
`define wait_N_cycles_n(sig, n) repeat(n) @(negedge sig)


/**************************************************************************************
 * VERBOSE makes the modules tell how they build (their params).
 * It's good to comment it when there's a lot being instanciated...
 *
 * TB_VERBOSE makes testbenches display signals. Comment to make
 * testbenches faster, uncomment to have direct feedback.
 **************************************************************************************/
//`define VERBOSE
//`define TB_VERBOSE


   /******************************************************************
    * Console output
    ******************************************************************/
 initial
     begin
        $dumpfile("result.vcd");
        $dumpvars;
     end

   // End of simul
   event end_trigger;
   always @(end_trigger) $finish;

`ifdef TB_VERBOSE
   initial #1 display_header();

   // And strobe signals at each clock
   always @(posedge clock)
     display_signals();

   // disp header a the end too
   always @(end_trigger)
     display_header();
`endif

   /******************************************************************
    * Clock and reset
    ******************************************************************/
   always #(2.5) clock = !clock;

   task test_reset;
      begin
         $display("RESET");
         `wait_1_cycle_n(clock);
         reset <= 1;
         `wait_N_cycles_n(clock,20);
         reset <= 0;
      end
   endtask // test_reset

   /******************************************************************
    * Main Stimuli
    ******************************************************************/
   initial
     begin
        // Reset everything2

        init();          `wait_N_cycles_n(clock, 2);
        test_reset();    `wait_N_cycles_n(clock, 2);

        // then perform tests
        test_1();        `wait_N_cycles_n(clock, 2);
        test_2();        `wait_N_cycles_n(clock, 2);
        test_3();        `wait_N_cycles_n(clock, 2);
        test_4();        `wait_N_cycles_n(clock, 2);
        test_5();        `wait_N_cycles_n(clock, 2);
        test_6();        `wait_N_cycles_n(clock, 2);
        test_7();        `wait_N_cycles_n(clock, 2);
        test_8();        `wait_N_cycles_n(clock, 2);
        test_9();        `wait_N_cycles_n(clock, 2);
        test_10();       `wait_N_cycles_n(clock, 2);

        // and terminate...
        -> end_trigger;
     end



