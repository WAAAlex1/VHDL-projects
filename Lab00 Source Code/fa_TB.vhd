library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fa_TB is
end fa_TB;

architecture arch of fa_TB is
    component fa is 
        port(
            x: in std_logic;
            y: in std_logic;
            z: in std_logic;
            c: out std_logic;
            s: out std_logic);
    end component;
    
    signal x: std_logic;
    signal y: std_logic;
    signal z: std_logic;
    signal c: std_logic;
    signal s: std_logic;

begin
    test: fa port map(x=>x,y=>y,z=>z,c=>c,s=>s);
    process begin
        x<='0';y<='0';z<='0';
        wait for 1 ns;
        x<='0';y<='0';z<='1';
        wait for 1 ns;
        x<='0';y<='1';z<='0';
        wait for 1 ns;
        x<='0';y<='1';z<='1';
        wait for 1 ns;
        x<='1';y<='0';z<='0';
        wait for 1 ns; 
        x<='1';y<='0';z<='1';
        wait for 1 ns;
        x<='1';y<='1';z<='0';
        wait for 1 ns;
        x<='1';y<='1';z<='1';
        wait for 1 ns;
        x<='0';y<='0';z<='0';
        wait;
    end process;
end arch;
