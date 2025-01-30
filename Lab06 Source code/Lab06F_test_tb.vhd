library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Lab06F_Test_tb is
end Lab06F_Test_tb;

architecture Behavioral of lab06F_Test_tb is

    constant period: time:=200ns;

    component Lab06F_test is
        port(
		  clk: in    std_logic;
		  srx: out   std_logic_vector(7 downto 0);-- PIC pin 9 RS-232
		  trig: in   std_logic;
		  msg_in: in  std_logic_vector(7 downto 0)
	   );
    end component;

    signal clk: std_logic:='0';
    signal trig: std_logic:='0';
    signal srx: std_logic_vector(7 downto 0);
    signal msg_in: std_logic_vector(7 downto 0);
begin

dut: lab06F_test PORT MAP(clk=>clk,srx=>srx,trig=>trig,msg_in => msg_in);

    process
    begin
        clk<='0';
        wait for period/2;
        clk<='1';
        wait for period/2;
    end process;

    process
    begin
        msg_in <= b"00111100";
        wait for 180 ns;
        trig <= '1';
        wait for 120 ns;
        trig <= '0';
        wait for 250000 ns;
        msg_in <= b"01010101";
        wait for 180 ns;
        trig <= '1';
        wait for 120 ns;
        trig <= '0';
        wait for 250000 ns;
        msg_in <= b"00001111";
        wait for 180 ns;
        trig <= '1';
        wait for 120 ns;
        trig <= '0';
        wait for 250000 ns;
        msg_in <= b"11110000";
        wait for 180 ns;
        trig <= '1';
        wait for 120 ns;
        trig <= '0';
        wait;
    end process;

end Behavioral;
