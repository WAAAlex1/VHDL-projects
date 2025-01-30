library IEEE;
use IEEE.std_logic_1164.all;

entity tcounter_TB is
end tcounter_TB;

architecture arch of tcounter_TB is
	component tcounter
		port(
			C:  in  std_logic; -- Clock input
			R:  in  std_logic; -- Asynchronouse reset
			B4: out std_logic; -- Output bits
			B3: out std_logic;
			B2: out std_logic;
			B1: out std_logic;
			B0: out std_logic
		);
	end component;
	signal C:  std_logic:='0';
	signal R:  std_logic:='1';
	signal B4: std_logic;
	signal B3: std_logic;
	signal B2: std_logic;
	signal B1: std_logic;
	signal B0: std_logic;
begin

	test: tcounter port map(C=>C,R=>R,
		B4=>B4,B3=>B3,B2=>B2,B1=>B1,B0=>B0);

	process
	begin
		C<='0';
		wait for 1 us;
		C<='1';
		wait for 1 us;
	end process;

	process
	begin
		R<='1';
		wait for 2.5 us;
		R<='0';
		wait;
	end process;
end arch;