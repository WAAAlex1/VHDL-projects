library IEEE;
use IEEE.std_logic_1164.all;

entity SRLATCH2_TB is
end SRLATCH2_TB;

architecture arch of SRLATCH2_TB is
	component SRLATCH2
		port(
			nS: in  std_logic;
			nR: in  std_logic;
			Q:  out std_logic
		);
	end component;
	signal nS: std_logic:='1';
	signal nR: std_logic:='1';
	signal Q:  std_logic;
begin
	test: SRLATCH2 port map (nS=>nS,nR=>nR,Q=>Q);

	process
	begin
		-- You must expand the test cases here
		-- so that all 12 transistions are tested.
		nS<='1';nR<='1'; --0
		wait for 1 us;
		nS<='0';nR<='1'; --1
		wait for 1 us;
		nS<='1';nR<='1'; --2
	    wait for 1 us;
		nS<='1';nR<='0'; --3
		wait for 1 us;
		nS<='1';nR<='1'; --4
		wait for 1 us;
		nS<='0';nR<='0'; --5
		wait for 1 us;
		nS<='1';nR<='1'; --6
		wait for 1 us;
		nS<='0';nR<='1'; --7
		wait for 1 us;
		nS<='0';nR<='0'; --8
		wait for 1 us;
		nS<='1';nR<='0'; --9
		wait for 1 us;
		nS<='0';nR<='0'; --10
		wait for 1 us;
		nS<='0';nR<='1'; --11
		wait for 1 us;
		nS<='1';nR<='0'; --12
		wait for 1 us;
		nS<='0';nR<='1'; --13
		wait;
	end process;
end arch;