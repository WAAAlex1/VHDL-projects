library IEEE;
use IEEE.std_logic_1164.all;

entity lab02a is
	port(
		clk:  in  std_logic;
		bits: out std_logic_vector(7 downto 0)
	);
end lab02a;

architecture arch of lab02a is
	component bcounter
		generic(
			NBITS: natural
		);
		port(
			clk:  in  std_logic; -- Clock input
			rst:  in  std_logic; -- Asynchronouse reset
			cin:  in  std_logic; -- Carry-in and run control
			cout: out std_logic; -- Carry-out for cascading
			bits: out std_logic_vector(NBITS-1 downto 0)
		);
	end component;
begin
	counter: bcounter generic map(NBITS=>bits'high-bits'low+1)
		port map(clk=>clk,rst=>'0',cin=>'1',cout=>open,bits=>bits);
end arch;