/***************************************************************************************************
 * Common functions
 *
 * Description: a bunch of useful functions. This file should be included within
 *              the declaration of a module.
 *
 *
 * Created: June 16, 2009, 4:09PM
 *
 * Author: Clement Farabet // clement.farabet@gmail.com
 **************************************************************************************************/
function integer user_clog2;
   input [31:0] value;
   integer      res;
   begin
      res = value - 1;
      for(user_clog2 = 0; res > 0; user_clog2 = user_clog2 + 1)
        res = res >> 1;
   end
endfunction // clog2

/**************************************************************************************
 * CLOG is ceiling of log2(x).
 * Xilinx tools don't support the built in $clog2, but support
 * user defined constant functions.
 * Iccarus is exactly the opposite...
 **************************************************************************************/
`ifdef __SYNTH_ONLY__
`define CLOG2 user_clog2
`else
`define CLOG2 $clog2
`endif


function [31:0] big_to_little_endian;
    input [0:31] big;
    integer iii;
    begin
        for (iii=0;iii<32;iii=iii+1) big_to_little_endian[iii] = big[31-iii];
    end
endfunction // big_to_little_endian

function [0:31] little_to_big_endian;
    input [31:0] big;
    integer iii;
    begin
        for (iii=0;iii<32;iii=iii+1) little_to_big_endian[iii] = big[31-iii];
    end
endfunction // little_to_big_endian
