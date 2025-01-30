library IEEE;
use IEEE.std_logic_1164.all;

entity bcounter is
	port(
		C :  in std_logic; -- Clock input
		R :  in std_logic; -- Asynchronouse reset
		B4: out std_logic; -- Output bits
		B3: out std_logic;
		B2: out std_logic;
		B1: out std_logic;
		B0: out std_logic
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
	signal d4: std_logic;
	signal d3: std_logic;
	signal d2: std_logic;
	signal d1: std_logic;
	signal d0: std_logic;
	signal q4: std_logic;
	signal q3: std_logic;
	signal q2: std_logic;
	signal q1: std_logic;
	signal q0: std_logic;
	signal c3: std_logic;
	signal c2: std_logic;
	signal c1: std_logic;
	signal c0: std_logic;
begin
	B4<=q4;
	B3<=q3;
	B2<=q2;
	B1<=q1;
	B0<=q0;

	-- Add instantiations for the four
	-- HADD and the four DFFAR modules.
	
	dffar0: DFFAR port map (D=>d0,C=>C,R=>R,Q=>q0);
	dffar1: DFFAR port map (D=>d1,C=>C,R=>R,Q=>q1);
	dffar2: DFFAR port map (D=>d2,C=>C,R=>R,Q=>q2);
	dffar3: DFFAR port map (D=>d3,C=>C,R=>R,Q=>q3);
	dffar4: DFFAR port map (D=>d4,C=>C,R=>R,Q=>q4);
	
	HADD0: HADD port map (X=>q0,Y=>'1',  C=>c0,S=>d0);
	HADD1: HADD port map (X=>q1,Y=>c0 ,  C=>c1, S=>d1);
	HADD2: HADD port map (X=>q2,Y=>c1 ,  C=>c2, S=>d2);
	HADD3: HADD port map (X=>q3,Y=>c2 ,  C=>c3, S=>d3);
	HADD4: HADD port map (X=>q4,Y=>c3 ,  C=>open, S=>d4);
	
	
end arch;