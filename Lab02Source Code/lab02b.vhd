library IEEE;
use IEEE.std_logic_1164.all;

entity lab02b is
	port(
		clk: in  std_logic;
		led: out std_logic_vector(4 downto 0)
	);
end lab02b;

architecture arch of lab02b is
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
	signal bits: std_logic_vector(28 downto 0);
begin
	counter: bcounter generic map(NBITS=>bits'high-bits'low+1)
		port map(clk=>clk,rst=>'0',cin=>'1',cout=>open,bits=>bits);

	led<=bits(bits'high downto bits'high-4);
end arch;