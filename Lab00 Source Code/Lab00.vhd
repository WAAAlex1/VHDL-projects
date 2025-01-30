library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Lab00 is
    Port ( btn : in STD_LOGIC;
           led : out STD_LOGIC);
end Lab00;

architecture arch of Lab00 is
begin
    led<=btn;
    
end arch;
