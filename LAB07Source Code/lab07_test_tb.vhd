library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity lab07_test_tb is
end lab07_test_tb;

architecture Behavioral of lab07_test_tb is

constant period: time:=200ns;


component lab07_test is
	port(
		clk: in    std_logic;
		nss: out   std_logic;-- PIC pin 11 SPI
		trig: in   std_logic;
		msg_in: in std_logic_vector(7 downto 0)
	);
end component;
    
    signal clk: std_logic:='0';
    signal trig: std_logic:='0';
    signal nss: std_logic;
    signal msg_in: std_logic_vector(7 downto 0);
    
begin

dut: lab07_test PORT MAP(clk=>clk,nss=>nss,trig=>trig, msg_in=>msg_in);

    process
    begin
        clk<='0';
        wait for period/2;
        clk<='1';
        wait for period/2;
    end process;
    
    process
    begin
        wait for 100 ns;
        msg_in <= b"01010101";
        trig <= '1';
        wait for 200 ns;
        trig <= '0';
        wait for 200000 ns;
        msg_in <= b"11111111";
        trig <= '1';
        wait for 200 ns;
        trig <= '0';
        wait for 200000 ns;
        msg_in <= b"00001111";
        trig <= '1';
        wait for 200 ns;
        trig <= '0';
        wait for 200000 ns;
        msg_in <= b"11110000";
        trig <= '1';
        wait for 200 ns;
        trig <= '0';
        wait for 200000 ns;
        msg_in <= b"11000011";
        trig <= '1';
        wait for 200 ns;
        trig <= '0';
        wait for 200000 ns;
    end process;

end Behavioral;
