library IEEE;
use IEEE.std_logic_1164.all;

entity SRLATCH2 is
	port(
		nS: in  std_logic;
		nR: in  std_logic;
		Q:  out std_logic
	);
end SRLATCH2;

architecture arch of SRLATCH2 is
begin
	process(nS,nR)
	begin
		if (nS='1') and (nR='0')
		then
			Q<='0';
		elsif (nS='0') and (nR='1')
		then
			Q<='1';
		end if;
	end process;
end arch;