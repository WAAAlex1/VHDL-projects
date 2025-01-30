
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Lab06R_test_tb is
end Lab06R_test_tb;

architecture Behavioral of Lab06R_test_tb is

    component Lab06R_test is
        port(
		  clk: in    std_logic;
		  srx: out   std_logic_vector(7 downto 0);
		  stx: in    std_logic
	   );
    end component;

    signal clk: std_logic:='0';
    signal stx: std_logic:='1';
    signal srx: std_logic_vector(7 downto 0);
begin

dut: Lab06R_test PORT MAP(clk=>clk,srx=>srx,stx=>stx);

    process
    begin
        clk<='0';
        wait for 100 ns;
        clk<='1';
        wait for 100 ns;
    end process;

    process
    begin
        wait for 2600 ns;
        stx <= '0';
        wait for 20800 ns;
        stx <= '1';
        wait for 20800 ns;
        stx <= '0';
        wait for 20800 ns;
        stx <= '1';
        wait for 20800 ns;
        stx <= '1';
        wait for 20800 ns;
        stx <= '0';
        wait for 20800 ns;
        stx <= '1';
        wait for 20800 ns;
        stx <= '1';
        wait for 20800 ns;
        stx <= '0';
        wait for 20800 ns;
        stx <= '1';
        wait;
    end process;

end Behavioral;

