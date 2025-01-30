library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Cin is
     Port ( 
        I, C, R: in std_logic;
        C_in: out std_logic
     );
end Cin;

architecture Behavioral of Cin is
    component DFFAR
        Port (
          D: in  std_logic; -- Data input
		  C: in  std_logic; -- Clock input
		  R: in  std_logic; -- Asynchronouse reset
		  Q: out std_logic := '0' -- Data output
        );
    end component;
    signal internal: std_logic_vector(3 downto 0);
    signal C_in_int: std_logic;
begin
    C_in <= C_in_int;
    
    DFFAR1: DFFAR port map(D=>I, C=>C, R=>R, Q=>internal(0));
    DFFAR2: DFFAR port map(D=>internal(3), C=>C, R=>R, Q=>C_in_int);
 
    internal(2) <= I and not(internal(0));
    process(internal(2), C_in_int)
        begin
            case(internal(2)) is
                when '1' => internal(3) <= not C_in_int;
                when others => internal(3) <= C_in_int;
            end case;
    end process;
end Behavioral;
