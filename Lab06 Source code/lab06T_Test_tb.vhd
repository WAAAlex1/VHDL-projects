
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity lab06T_Test_tb is
end lab06T_Test_tb;

architecture Behavioral of lab06T_Test_tb is

    constant period: time:=200ns;

    component lab06T_Test is
        port(
		  clk: in    std_logic;
		  srx: out   std_logic;
		  trig: in   std_logic
	   );
    end component;

    signal clk: std_logic:='0';
    signal trig: std_logic:='0';
    signal srx: std_logic;
begin

dut: lab06T_Test PORT MAP(clk=>clk,trig=>trig,srx=>srx);

    process
    begin
        clk<='0';
        wait for period/2;
        clk<='1';
        wait for period/2;
    end process;

    process
    begin
        wait for 180 ns;
        trig <= '1';
        wait for 120 ns;
        trig <= '0';
        wait;
    end process;

end Behavioral;
