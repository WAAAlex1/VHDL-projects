


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity mSync is
     Port ( 
        I, C, R: in std_logic;
        O: out std_logic
     );
end mSync;

architecture Behavioral of mSync is
    component DFFAR
        Port (
          D: in  std_logic; -- Data input
		  C: in  std_logic; -- Clock input
		  R: in  std_logic; -- Asynchronouse reset
		  Q: out std_logic := '0' -- Data output
        );
    end component;
    signal internal: std_logic_vector(1 downto 0);
    signal O_int: std_logic;
begin
    O<=O_int;
    DFFAR1: DFFAR port map(D=>I, C=>C, R=>R, Q=>internal(0));
    DFFAR2: DFFAR port map(D=>internal(0), C=>C, R=>R, Q=>internal(1));
    DFFAR3: DFFAR port map(D=>internal(1), C=>C, R=>R, Q=>O_int);
end Behavioral;
