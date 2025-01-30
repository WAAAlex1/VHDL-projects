library IEEE;
use IEEE.std_logic_1164.all;

entity bcounter is
	generic(
		NBITS: natural:=4
	);
	port(
		clk:  in  std_logic; -- Clock input
		rst:  in  std_logic; -- Asynchronouse reset
		cin:  in  std_logic; -- Carry-in and run control
		cout: out std_logic; -- Carry-out for cascading
		bits: out std_logic_vector(NBITS-1 downto 0)
	);
end bcounter;

architecture arch of bcounter is
	component DFFAR
		port(
			D: in  std_logic; -- Data input
			C: in  std_logic; -- Clock input
			R: in  std_logic; -- Asynchronouse reset
			Q: out std_logic  -- Data output
		);
	end component;
	component HADD
		port(
			X: in  std_logic;
			Y: in  std_logic;
			C: out std_logic;
			S: out std_logic
		);
	end component;
	signal c: std_logic_vector(NBITS downto 0);
	signal d: std_logic_vector(NBITS-1 downto 0);
	signal q: std_logic_vector(NBITS-1 downto 0);
begin
	c(0)<=cin;
	cout<=c(NBITS);
	bits<=q;

	chain: for index in NBITS-1 downto 0 generate
		ha: HADD port map (X=>q(index), Y => c(index), C=>c(index+1), S=>d(index));
		ff: DFFAR port map (D=>d(index), C=>clk, R=>rst, Q => q(index));
	end generate;
end arch;