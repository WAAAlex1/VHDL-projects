----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.09.2024 20:15:00
-- Design Name: 
-- Module Name: DFFAR_TB - arch_tb
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DFFAR_TB is
end DFFAR_TB;

architecture arch_tb of DFFAR_TB is
	component DFFAR
		port(
			C:   in  std_logic;
			R:   in  std_logic;
			D:   in  std_logic;
			Q:   out std_logic
		);
	end component;
	signal C, D, R, Q: std_logic;
	
begin
    test: DFFAR port map (C=>C, R=>R, D=>D, Q=>Q);

    process -- Clock process
    begin
        C<='0';
        wait for 1 us;
        C<='1';
        wait for 1 us;
    end process;
    
    process -- Signals process
    begin
        D<='0'; R<='0';
        wait for 1 us;
        D<='1';R<='0'; 
		wait for 1 us;
        D<='0';R<='0'; 
		wait for 1 us;
		D<='1';R<='1'; 
		wait for 1 us;
        D<='1';R<='0'; 
		wait for 2.5 us;
		R<='1'; 
		wait;
	end process;
end arch_tb;
