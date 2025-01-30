library IEEE;
use IEEE.std_logic_1164.all;

entity DFFAR is
	port(
		D: in  std_logic; -- Data input
		C: in  std_logic; -- Clock input
		R: in  std_logic; -- Asynchronouse reset
		Q: out std_logic := '0' -- Data output
	);
end DFFAR;

architecture arch of DFFAR is
begin
	process(C,R)
	begin
	   if R='1' then 
	       Q <= '0';
	   elsif rising_edge(C)then
	       Q <= D ; --after 10 ns;
	   end if;
	end process;
end arch;