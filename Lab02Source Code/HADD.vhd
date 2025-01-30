library IEEE;
use IEEE.std_logic_1164.all;

entity HADD is
	port(
		X: in  std_logic; -- Data in
		Y: in  std_logic; -- Data in
		C: out std_logic; -- Carry out
		S: out std_logic  -- Sum out
	);
end HADD;

architecture arch of HADD is
begin
	C<=X and Y ; --after 10 ns;
	S<=X xor Y ; --after 10 ns;
end arch;