--------------------------------------------------------------------------
-- FrontPanel Library Module Declarations (VHDL)
--
-- Copyright (c) 2004-2010 Opal Kelly Incorporated
-- $Rev: 824 $ $Date: 2011-02-23 13:48:17 -0800 (Wed, 23 Feb 2011) $
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;
entity okHost is
	port (
		hi_in		: in std_logic_vector(7 downto 0);
		hi_out	: out std_logic_vector(1 downto 0);
		hi_inout	: inout std_logic_vector(15 downto 0);
		ti_clk	: out std_logic;
		ok1		: out std_logic_vector(30 downto 0);
		ok2		: in std_logic_vector(16 downto 0)
	);
end okHost;

architecture archHost of okHost is
	attribute box_type: string;
  
	component okCore port (
		hi_in : in std_logic_vector(7 downto 0);
		hi_out : out std_logic_vector(2 downto 0);
		hi_datain : in std_logic_vector(15 downto 0);
		hi_dataout : out std_logic_vector(15 downto 0);
		ok1 : out std_logic_vector(30 downto 0);
		ok2 : in std_logic_vector(16 downto 0));
	end component;
	attribute box_type of okCore : component is "black_box";
	
	signal hi_datain : std_logic_vector(15 downto 0);
	signal hi_dataout : std_logic_vector(15 downto 0);
	signal hi_out_core : std_logic_vector(2 downto 0);
	signal hi_in_bus : std_logic_vector(7 downto 0);
	signal hi_drive_b : std_logic;
	signal ti_clk_int : std_logic;
begin
	ti_clk <= ti_clk_int;
	hi_drive_b <= not hi_out_core(2);
	hi_in_bus <= hi_in(7 downto 1) & ti_clk_int;
	
	-- Clock buffer for the Host Interface clock.
	clkbuf : BUFGDLL port map (I => hi_in(0), O => ti_clk_int);
	
	-- Instantiate bidirectional IOBUFs for the hi_data lines.
	iobuf0  : IOBUF port map (T => hi_drive_b, O => hi_datain(0),  I => hi_dataout(0),  IO => hi_inout(0) );
	iobuf1  : IOBUF port map (T => hi_drive_b, O => hi_datain(1),  I => hi_dataout(1),  IO => hi_inout(1) );
	iobuf2  : IOBUF port map (T => hi_drive_b, O => hi_datain(2),  I => hi_dataout(2),  IO => hi_inout(2) );
	iobuf3  : IOBUF port map (T => hi_drive_b, O => hi_datain(3),  I => hi_dataout(3),  IO => hi_inout(3) );
	iobuf4  : IOBUF port map (T => hi_drive_b, O => hi_datain(4),  I => hi_dataout(4),  IO => hi_inout(4) );
	iobuf5  : IOBUF port map (T => hi_drive_b, O => hi_datain(5),  I => hi_dataout(5),  IO => hi_inout(5) );
	iobuf6  : IOBUF port map (T => hi_drive_b, O => hi_datain(6),  I => hi_dataout(6),  IO => hi_inout(6) );
	iobuf7  : IOBUF port map (T => hi_drive_b, O => hi_datain(7),  I => hi_dataout(7),  IO => hi_inout(7) );
	iobuf8  : IOBUF port map (T => hi_drive_b, O => hi_datain(8),  I => hi_dataout(8),  IO => hi_inout(8) );
	iobuf9  : IOBUF port map (T => hi_drive_b, O => hi_datain(9),  I => hi_dataout(9),  IO => hi_inout(9) );
	iobuf10 : IOBUF port map (T => hi_drive_b, O => hi_datain(10), I => hi_dataout(10), IO => hi_inout(10) );
	iobuf11 : IOBUF port map (T => hi_drive_b, O => hi_datain(11), I => hi_dataout(11), IO => hi_inout(11) );
	iobuf12 : IOBUF port map (T => hi_drive_b, O => hi_datain(12), I => hi_dataout(12), IO => hi_inout(12) );
	iobuf13 : IOBUF port map (T => hi_drive_b, O => hi_datain(13), I => hi_dataout(13), IO => hi_inout(13) );
	iobuf14 : IOBUF port map (T => hi_drive_b, O => hi_datain(14), I => hi_dataout(14), IO => hi_inout(14) );
	iobuf15 : IOBUF port map (T => hi_drive_b, O => hi_datain(15), I => hi_dataout(15), IO => hi_inout(15) );
	
	obuf0 : OBUF port map (I => hi_out_core(0), O => hi_out(0));
	obuf1 : OBUF port map (I => hi_out_core(1), O => hi_out(1));
	
	-- Instantiate the core Host Interface.
	hicore : okCore port map(
		hi_in => hi_in_bus,
		hi_out => hi_out_core,
		hi_datain => hi_datain,
		hi_dataout => hi_dataout,
		ok1 => ok1,
		ok2 => ok2);
end archHost;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.vcomponents.all;
entity okHost_XEM5010 is
	port (
		hi_in		: in std_logic_vector(7 downto 0);
		hi_out	: out std_logic_vector(1 downto 0);
		hi_inout	: inout std_logic_vector(15 downto 0);
		ti_clk	: out std_logic;
		ok1		: out std_logic_vector(30 downto 0);
		ok2		: in std_logic_vector(16 downto 0)
	);
end okHost_XEM5010;

architecture archHost_XEM5010 of okHost_XEM5010 is
	attribute box_type: string;
  
	component okCore port (
		hi_in : in std_logic_vector(7 downto 0);
		hi_out : out std_logic_vector(2 downto 0);
		hi_datain : in std_logic_vector(15 downto 0);
		hi_dataout : out std_logic_vector(15 downto 0);
		ok1 : out std_logic_vector(30 downto 0);
		ok2 : in std_logic_vector(16 downto 0));
	end component;
	attribute box_type of okCore : component is "black_box";
	
	signal hi_datain : std_logic_vector(15 downto 0);
	signal hi_dataout : std_logic_vector(15 downto 0);
	signal hi_out_core : std_logic_vector(2 downto 0);
	signal hi_in_bus : std_logic_vector(7 downto 0);
	signal hi_drive_b : std_logic;
	signal ti_clk_int : std_logic;
	signal dcm_clk0 : std_logic;
	signal rst1 : std_logic;
	signal rst2 : std_logic;
	signal rst3 : std_logic;
	signal rst4 : std_logic;
	signal rstin : std_logic;
begin
	ti_clk <= ti_clk_int;
	hi_drive_b <= not hi_out_core(2);
	hi_in_bus <= hi_in(7 downto 1) & ti_clk_int;
	

	-- Clock buffer for the Host Interface clock.
	hi_dcm : DCM_ADV port map (CLKIN => hi_in(0),
	              CLKFB => ti_clk_int,
	              CLK0 => dcm_clk0,
	              RST => rstin);
  hi_clkbuf : BUFG port map (I => dcm_clk0, O => ti_clk_int);
  flop1 : FDS port map (D => '0',    C => hi_in(0), Q => rst1, S => '0');
  flop2 : FD  port map (D => rst1, C => hi_in(0), Q => rst2);
  flop3 : FD  port map (D => rst2, C => hi_in(0), Q => rst3);
  flop4 : FD  port map (D => rst3, C => hi_in(0), Q => rst4);
  rstin <= (rst2 or rst3 or rst4);


	-- Instantiate bidirectional IOBUFs for the hi_data lines.
	iobuf0  : IOBUF port map (T => hi_drive_b, O => hi_datain(0),  I => hi_dataout(0),  IO => hi_inout(0) );
	iobuf1  : IOBUF port map (T => hi_drive_b, O => hi_datain(1),  I => hi_dataout(1),  IO => hi_inout(1) );
	iobuf2  : IOBUF port map (T => hi_drive_b, O => hi_datain(2),  I => hi_dataout(2),  IO => hi_inout(2) );
	iobuf3  : IOBUF port map (T => hi_drive_b, O => hi_datain(3),  I => hi_dataout(3),  IO => hi_inout(3) );
	iobuf4  : IOBUF port map (T => hi_drive_b, O => hi_datain(4),  I => hi_dataout(4),  IO => hi_inout(4) );
	iobuf5  : IOBUF port map (T => hi_drive_b, O => hi_datain(5),  I => hi_dataout(5),  IO => hi_inout(5) );
	iobuf6  : IOBUF port map (T => hi_drive_b, O => hi_datain(6),  I => hi_dataout(6),  IO => hi_inout(6) );
	iobuf7  : IOBUF port map (T => hi_drive_b, O => hi_datain(7),  I => hi_dataout(7),  IO => hi_inout(7) );
	iobuf8  : IOBUF port map (T => hi_drive_b, O => hi_datain(8),  I => hi_dataout(8),  IO => hi_inout(8) );
	iobuf9  : IOBUF port map (T => hi_drive_b, O => hi_datain(9),  I => hi_dataout(9),  IO => hi_inout(9) );
	iobuf10 : IOBUF port map (T => hi_drive_b, O => hi_datain(10), I => hi_dataout(10), IO => hi_inout(10) );
	iobuf11 : IOBUF port map (T => hi_drive_b, O => hi_datain(11), I => hi_dataout(11), IO => hi_inout(11) );
	iobuf12 : IOBUF port map (T => hi_drive_b, O => hi_datain(12), I => hi_dataout(12), IO => hi_inout(12) );
	iobuf13 : IOBUF port map (T => hi_drive_b, O => hi_datain(13), I => hi_dataout(13), IO => hi_inout(13) );
	iobuf14 : IOBUF port map (T => hi_drive_b, O => hi_datain(14), I => hi_dataout(14), IO => hi_inout(14) );
	iobuf15 : IOBUF port map (T => hi_drive_b, O => hi_datain(15), I => hi_dataout(15), IO => hi_inout(15) );
	
	obuf0 : OBUF port map (I => hi_out_core(0), O => hi_out(0));
	obuf1 : OBUF port map (I => hi_out_core(1), O => hi_out(1));
	
	-- Instantiate the core Host Interface.
	hicore : okCore port map(
		hi_in => hi_in_bus,
		hi_out => hi_out_core,
		hi_datain => hi_datain,
		hi_dataout => hi_dataout,
		ok1 => ok1,
		ok2 => ok2);
end archHost_XEM5010;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.vcomponents.all;
entity okHost_XEM6001 is
	port (
		hi_in		: in std_logic_vector(7 downto 0);
		hi_out	: out std_logic_vector(1 downto 0);
		hi_inout	: inout std_logic_vector(15 downto 0);
		ti_clk	: out std_logic;
		ok1		: out std_logic_vector(30 downto 0);
		ok2		: in std_logic_vector(16 downto 0)
	);
end okHost_XEM6001;

architecture archHost_XEM6001 of okHost_XEM6001 is
	attribute box_type: string;
  
	component okCore port (
		hi_in : in std_logic_vector(7 downto 0);
		hi_out : out std_logic_vector(2 downto 0);
		hi_datain : in std_logic_vector(15 downto 0);
		hi_dataout : out std_logic_vector(15 downto 0);
		ok1 : out std_logic_vector(30 downto 0);
		ok2 : in std_logic_vector(16 downto 0));
	end component;
	attribute box_type of okCore : component is "black_box";
	
	signal hi_datain : std_logic_vector(15 downto 0);
	signal hi_dataout : std_logic_vector(15 downto 0);
	signal hi_out_core : std_logic_vector(2 downto 0);
	signal hi_in_bus : std_logic_vector(7 downto 0);
	signal hi_drive_b : std_logic;
	signal ti_clk_int : std_logic;
	signal dcm_clk0 : std_logic;
	signal rst1 : std_logic;
	signal rst2 : std_logic;
	signal rst3 : std_logic;
	signal rst4 : std_logic;
	signal rstin : std_logic;
begin
	ti_clk <= ti_clk_int;
	hi_drive_b <= not hi_out_core(2);
	hi_in_bus <= hi_in(7 downto 1) & ti_clk_int;
	
	-- Clock buffer for the Host Interface clock.
	hi_dcm : DCM_SP  port map (CLKIN     => hi_in(0),
	                  CLKFB     => ti_clk_int,
	                  CLK0      => dcm_clk0,
	                  PSCLK     => '0',
	                  PSEN      => '0',
	                  PSINCDEC  => '0',
	                  RST       => rstin,
	                  DSSEN     => '0');
  hi_clkbuf : BUFG port map (I => dcm_clk0, O => ti_clk_int);
  flop1 : FDS port map (D => '0',    C => hi_in(0), Q => rst1, S => '0');
  flop2 : FD  port map (D => rst1, C => hi_in(0), Q => rst2);
  flop3 : FD  port map (D => rst2, C => hi_in(0), Q => rst3);
  flop4 : FD  port map (D => rst3, C => hi_in(0), Q => rst4);
  rstin <= (rst2 or rst3 or rst4);

	-- Instantiate bidirectional IOBUFs for the hi_data lines.
	iobuf0  : IOBUF port map (T => hi_drive_b, O => hi_datain(0),  I => hi_dataout(0),  IO => hi_inout(0) );
	iobuf1  : IOBUF port map (T => hi_drive_b, O => hi_datain(1),  I => hi_dataout(1),  IO => hi_inout(1) );
	iobuf2  : IOBUF port map (T => hi_drive_b, O => hi_datain(2),  I => hi_dataout(2),  IO => hi_inout(2) );
	iobuf3  : IOBUF port map (T => hi_drive_b, O => hi_datain(3),  I => hi_dataout(3),  IO => hi_inout(3) );
	iobuf4  : IOBUF port map (T => hi_drive_b, O => hi_datain(4),  I => hi_dataout(4),  IO => hi_inout(4) );
	iobuf5  : IOBUF port map (T => hi_drive_b, O => hi_datain(5),  I => hi_dataout(5),  IO => hi_inout(5) );
	iobuf6  : IOBUF port map (T => hi_drive_b, O => hi_datain(6),  I => hi_dataout(6),  IO => hi_inout(6) );
	iobuf7  : IOBUF port map (T => hi_drive_b, O => hi_datain(7),  I => hi_dataout(7),  IO => hi_inout(7) );
	iobuf8  : IOBUF port map (T => hi_drive_b, O => hi_datain(8),  I => hi_dataout(8),  IO => hi_inout(8) );
	iobuf9  : IOBUF port map (T => hi_drive_b, O => hi_datain(9),  I => hi_dataout(9),  IO => hi_inout(9) );
	iobuf10 : IOBUF port map (T => hi_drive_b, O => hi_datain(10), I => hi_dataout(10), IO => hi_inout(10) );
	iobuf11 : IOBUF port map (T => hi_drive_b, O => hi_datain(11), I => hi_dataout(11), IO => hi_inout(11) );
	iobuf12 : IOBUF port map (T => hi_drive_b, O => hi_datain(12), I => hi_dataout(12), IO => hi_inout(12) );
	iobuf13 : IOBUF port map (T => hi_drive_b, O => hi_datain(13), I => hi_dataout(13), IO => hi_inout(13) );
	iobuf14 : IOBUF port map (T => hi_drive_b, O => hi_datain(14), I => hi_dataout(14), IO => hi_inout(14) );
	iobuf15 : IOBUF port map (T => hi_drive_b, O => hi_datain(15), I => hi_dataout(15), IO => hi_inout(15) );
	
	obuf0 : OBUF port map (I => hi_out_core(0), O => hi_out(0));
	obuf1 : OBUF port map (I => hi_out_core(1), O => hi_out(1));
	
	-- Instantiate the core Host Interface.
	hicore : okCore port map(
		hi_in => hi_in_bus,
		hi_out => hi_out_core,
		hi_datain => hi_datain,
		hi_dataout => hi_dataout,
		ok1 => ok1,
		ok2 => ok2);
		
end archHost_XEM6001;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okCore is
	port (
		hi_in			: in std_logic_vector(7 downto 0);
		hi_out		: out std_logic_vector(2 downto 0);
		hi_datain	: in std_logic_vector(15 downto 0);
		hi_dataout	: out std_logic_vector(15 downto 0);
		ok1			: out std_logic_vector(30 downto 0);
		ok2			: in std_logic_vector(16 downto 0)
	);
end okCore;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okWireIn is
	port (
		ok1			: in std_logic_vector(30 downto 0);
		ep_addr		: in std_logic_vector(7 downto 0);
		ep_dataout	: out std_logic_vector(15 downto 0)
	);
end okWireIn;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okWireOut is
	port (
		ok1			: in std_logic_vector(30 downto 0);
		ok2			: out std_logic_vector(16 downto 0);
		ep_addr		: in std_logic_vector(7 downto 0);
		ep_datain	: in std_logic_vector(15 downto 0)
	);
end okWireOut;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okTriggerIn is
	port (
		ok1			: in std_logic_vector(30 downto 0);
		ep_addr		: in std_logic_vector(7 downto 0);
		ep_clk		: in std_logic;
		ep_trigger	: out std_logic_vector(15 downto 0)
	);
end okTriggerIn;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okTriggerOut is
	port (
		ok1			: in std_logic_vector(30 downto 0);
		ok2			: out std_logic_vector(16 downto 0);
		ep_addr		: in std_logic_vector(7 downto 0);
		ep_clk		: in std_logic;
		ep_trigger	: in std_logic_vector(15 downto 0)
	);
end okTriggerOut;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okPipeIn is
	port (
		ok1			: in std_logic_vector(30 downto 0);
		ok2			: out std_logic_vector(16 downto 0);
		ep_addr		: in std_logic_vector(7 downto 0);
		ep_write		: out std_logic;
		ep_dataout	: out std_logic_vector(15 downto 0)
	);
end okPipeIn;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okPipeOut is
	port (
		ok1			: in std_logic_vector(30 downto 0);
		ok2			: out std_logic_vector(16 downto 0);
		ep_addr		: in std_logic_vector(7 downto 0);
		ep_read		: out std_logic;
		ep_datain	: in std_logic_vector(15 downto 0)
	);
end okPipeOut;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okBTPipeIn is
	port (
		ok1				: in std_logic_vector(30 downto 0);
		ok2				: out std_logic_vector(16 downto 0);
		ep_addr			: in std_logic_vector(7 downto 0);
		ep_write			: out std_logic;
		ep_blockstrobe	: out std_logic;
		ep_dataout		: out std_logic_vector(15 downto 0);
		ep_ready			: in std_logic
	);
end okBTPipeIn;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okBTPipeOut is
	port (
		ok1				: in std_logic_vector(30 downto 0);
		ok2				: out std_logic_vector(16 downto 0);
		ep_addr			: in std_logic_vector(7 downto 0);
		ep_read			: out std_logic;
		ep_blockstrobe	: out std_logic;
		ep_datain		: in std_logic_vector(15 downto 0);
		ep_ready			: in std_logic
	);
end okBTPipeOut;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity okWireOR is
	generic (
		N     : integer := 1
	);
	port (
		ok2   : out std_logic_vector(16 downto 0);
		ok2s  : in  std_logic_vector(N*17-1 downto 0)
	);
end okWireOR;
architecture archWireOR of okWireOR is
begin
	process (ok2s)
		variable ok2_int : STD_LOGIC_VECTOR(16 downto 0);
	begin
		ok2_int := b"0_0000_0000_0000_0000";
		for i in N-1 downto 0 loop
			ok2_int := ok2_int or ok2s( (i*17+16) downto (i*17) );
		end loop;
		ok2 <= ok2_int;
	end process;
end archWireOR;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package FRONTPANEL is
	component okHost port (
		hi_in    : in std_logic_vector(7 downto 0);
		hi_out   : out std_logic_vector(1 downto 0);
		hi_inout : inout std_logic_vector(15 downto 0);
		ti_clk   : out std_logic;
		ok1      : out std_logic_vector(30 downto 0);
		ok2      : in std_logic_vector(16 downto 0));
	end component;

	component okHost_XEM5010 port (
		hi_in     : in std_logic_vector(7 downto 0);
		hi_out    : out	std_logic_vector(1 downto 0);
		hi_inout  : inout	std_logic_vector(15 downto 0);
		ti_clk    : out std_logic;
		ok1       : out std_logic_vector(30 downto 0);
		ok2       : in std_logic_vector(16 downto 0));
	end component;
	
	component okHost_XEM6001 port (
		hi_in     : in std_logic_vector(7 downto 0);
		hi_out    : out	std_logic_vector(1 downto 0);
		hi_inout  : inout	std_logic_vector(15 downto 0);
		ti_clk    : out std_logic;
		ok1       : out std_logic_vector(30 downto 0);
		ok2       : in std_logic_vector(16 downto 0));
	end component;

	component okWireIn port (
		ok1        : in std_logic_vector(30 downto 0);
		ep_addr    : in std_logic_vector(7 downto 0);
		ep_dataout : out std_logic_vector(15 downto 0));
	end component;

	component okWireOut port (
		ok1       : in std_logic_vector(30 downto 0);
		ok2       : out std_logic_vector(16 downto 0);
		ep_addr   : in std_logic_vector(7 downto 0);
		ep_datain : in std_logic_vector(15 downto 0));
	end component;

	component okTriggerIn port (
		ok1        : in std_logic_vector(30 downto 0);
		ep_addr    : in std_logic_vector(7 downto 0);
		ep_clk     : in std_logic;
		ep_trigger : out std_logic_vector(15 downto 0));
	end component;

	component okTriggerOut port (
		ok1        : in std_logic_vector(30 downto 0);
		ok2        : out std_logic_vector(16 downto 0);
		ep_addr    : in std_logic_vector(7 downto 0);
		ep_clk     : in std_logic;
		ep_trigger : in std_logic_vector(15 downto 0));
	end component;

	component okPipeIn port (
		ok1        : in std_logic_vector(30 downto 0);
		ok2        : out std_logic_vector(16 downto 0);
		ep_addr    : in std_logic_vector(7 downto 0);
		ep_write   : out std_logic;
		ep_dataout : out std_logic_vector(15 downto 0));
	end component;

	component okPipeOut port (
		ok1        : in std_logic_vector(30 downto 0);
		ok2        : out std_logic_vector(16 downto 0);
		ep_addr    : in std_logic_vector(7 downto 0);
		ep_read    : out std_logic;
		ep_datain  : in std_logic_vector(15 downto 0));
	end component;
	
	component okBTPipeIn port (
		ok1            : in std_logic_vector(30 downto 0);
		ok2            : out std_logic_vector(16 downto 0);
		ep_addr        : in std_logic_vector(7 downto 0);
		ep_write       : out std_logic;
		ep_blockstrobe : out std_logic;
		ep_dataout     : out std_logic_vector(15 downto 0);
		ep_ready       : in std_logic);
	end component;

	component okBTPipeOut port (
		ok1            : in std_logic_vector(30 downto 0);
		ok2            : out std_logic_vector(16 downto 0);
		ep_addr        : in std_logic_vector(7 downto 0);
		ep_read        : out std_logic;
		ep_blockstrobe : out std_logic;
		ep_datain      : in std_logic_vector(15 downto 0);
		ep_ready       : in std_logic);
	end component;

	component okWireOR
	generic (N : integer := 1);
	port (
		ok2   : out std_logic_vector(16 downto 0);
		ok2s  : in  std_logic_vector(N*17-1 downto 0));
	end component;

end FRONTPANEL;
