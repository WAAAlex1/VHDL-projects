library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07_clock is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab07_clock;

architecture arch of lab07_clock is
	component lab07_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(7 downto 0);
			data_i: in  std_logic_vector(7 downto 0);
			trig_o: out std_logic
		);
	end component;
	signal data_o:    std_logic_vector(7 downto 0);
	signal data_i:    std_logic_vector(7 downto 0);
	signal trig:      std_logic;
	
	-- FSM typedef and signal for CLOCK
	type FSM_type3 is (start, LOW, HIGH);
	signal CFSM: FSM_type3 := start;
	signal CFSM_n: FSM_type3 := start;
	
	signal out_ss: std_logic:='1';
	
	-- Signals for ClockFSM
	signal clk100: std_logic:='0';
	signal re_clk100: std_logic:='0';
	signal re_clk100_n: std_logic:='0';
	signal cycle_cnt: unsigned(3 downto 0):=(others => '0'); 
	signal cycle_cnt_n: unsigned(3 downto 0):=(others => '0'); 
	signal count: unsigned(6 downto 0):=(others => '0');    
	signal count_n: unsigned(6 downto 0):=(others => '0');
	
	constant cnt_len: natural:=7;
	constant cnt_target: natural:=59;
		
begin
	gui: lab07_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);
    ---------------------- DEFAULT VALUES OF UNUSED PORTS ---------  
	srx <= '1';
	scl<='Z';
	sda<='Z';
    ---------------------- CONNECTIONS FOR TRANSMITTING --------- 
	sdi<=re_clk100;
	nss<='0';
	sck<=clk100;
	---------------------- CONNECTIONS FOR RECEIVING ------------
	data_i <= b"0000_0000"; 
	
	process(trig)
	begin
	   if rising_edge(trig) then
	       out_ss <= not out_ss;
	   end if;    
	end process;
	
    ---------------------- CLOCK FSM --------------------------
	-- Two segment process -> here combinatorial part
	process(CFSM, count, cycle_cnt, out_SS)
	begin
	   case CFSM is
	       when start =>
	           
	           clk100 <= '0';
	           cycle_cnt_n <= to_unsigned(0,4);
	           count_n <= to_unsigned(0,cnt_len);
	           
	           if(out_SS = '0') then
	               CFSM_n <= LOW;
	           else
	               CFSM_n <= start;    
	           end if;    
	           
	       when LOW =>
	           clk100 <= '0';
	           if(count = cnt_target) then
	               re_clk100_n <= '1';
	               CFSM_n <= HIGH;
	           else
	               count_n <= count+1;
	               CFSM_n <= LOW;
	           end if;
	       
	       when HIGH =>
	           clk100 <= '1';
	           if(count = 0) then
	               cycle_cnt_n <= cycle_cnt + 1;
	               if (cycle_cnt < 7) then
	                   CFSM_n <= LOW;
	               else
	                   CFSM_n <= start;
	               end if;    
	           else
	               re_clk100_n <= '0';
	               count_n <= count-1;
	               CFSM_n <= HIGH;
	           end if;    
	          	           
	       when others =>
	           null;
	   end case;
	   
	end process;
	
	-- Two segment approach -> here sequential part. 
	process(clk)
	begin
	   if rising_edge(clk) then
	       CFSM <= CFSM_n;
	       count <= count_n;
	       cycle_cnt <= cycle_cnt_n;
	       re_clk100 <= re_clk100_n;
	   end if;
	end process;

	
	
end arch;