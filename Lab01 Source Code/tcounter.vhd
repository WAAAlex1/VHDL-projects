library IEEE;
use IEEE.std_logic_1164.all;

entity tcounter is
	port(
		C:  in  std_logic; -- Clock input
		R:  in  std_logic; -- Asynchronouse reset
		B4: out std_logic; -- Output bits
		B3: out std_logic;
		B2: out std_logic;
		B1: out std_logic;
		B0: out std_logic
	);
end tcounter;

architecture arch of tcounter is
	component DFFAR
		port(
			D: in  std_logic; -- Data input
			C: in  std_logic; -- Clock input
			R: in  std_logic; -- Asynchronouse reset
			Q: out std_logic  -- Data output
		);
	end component;
	signal q4: std_logic;
	signal q3: std_logic;
	signal q2: std_logic;
	signal q1: std_logic;
	signal q0: std_logic;
	signal d4: std_logic;
	signal d3: std_logic;
	signal d2: std_logic;
	signal d1: std_logic;
	signal d0: std_logic;
begin
	B4 <= q4;
	B3 <= q3;
	B2 <= q2;
	B1 <= q1;
	B0 <= q0;

	d4 <= not q4;
	d3 <= not q3;
	d2 <= not q2;
	d1 <= not q1;
	d0 <= not q0;
	
	dffar0: DFFAR port map (D=>d0,C=>C ,R=>R,Q=>q0);
	dffar1: DFFAR port map (D=>d1,C=>d0,R=>R,Q=>q1);
	dffar2: DFFAR port map (D=>d2,C=>d1,R=>R,Q=>q2);
	dffar3: DFFAR port map (D=>d3,C=>d2,R=>R,Q=>q3);
	dffar4: DFFAR port map (D=>d4,C=>d3,R=>R,Q=>q4);
	
end arch;