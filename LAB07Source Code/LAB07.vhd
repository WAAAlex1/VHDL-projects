library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07 is
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
end lab07;

architecture arch of lab07 is
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

	-- FSM typedef and signal for transmit
	type FSM_type1 is (start, B7, B6, B5, B4, B3, B2, B1, B0 );
	signal TFSM: FSM_type1 := start;
	
	-- FSM typedef and signal for receive
	type FSM_type2 is (start, s1, sample);
	signal RFSM: FSM_type2 := start;
	
	-- FSM typedef and signal for CLOCK
	type FSM_type3 is (start, LOW, HIGH, finish);
	signal CFSM: FSM_type3 := start;
	
	-- Signals for TransmitFSM
	signal out_SDI: std_logic:='0';
	signal out_SS: std_logic:='1';
	signal msg: std_logic_vector(7 downto 0):= (others => '0');
	
	-- Signals for ReceiveFSM
	signal input: std_logic:='0';
    signal receive: std_logic_vector(7 downto 0):= (others => '0');
	signal receive_temp: std_logic_vector(7 downto 0):= (others => '0');
    --signal bitnum: unsigned(3 downto 0):=to_unsigned(0,4);
    
	-- Signals for ClockFSM
	signal clk100: std_logic:='0';
	signal re_clk100: std_logic:='0';
	signal fe_clk100: std_logic:='0';
	signal count: unsigned(6 downto 0):=(others => '0');    
	
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
	sdi<=out_sdi;
	nss<=out_SS;
	sck<=clk100;
	msg <= data_o;
	---------------------- CONNECTIONS FOR RECEIVING ------------
	data_i <= receive; 
	input  <= sdo;
	---------------------- Transmit FSM -------------------------
	process(clk)
	   variable index: integer:=0;
	begin
	   if rising_edge(clk) then
	       case TFSM is
	   
	       when start =>
	           
	           out_sdi <= '0';
	           out_SS <= '1';
	           
	           if(trig = '1') then
	               TFSM <= B7;
	               out_sdi <= msg(7);
	           else
	               TFSM <= start;
	           end if;    
	           
	        when B7 =>
	           out_SS <= '0';
	           TFSM <= B7;
	           out_sdi <= msg(7);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B6;
	               out_sdi <= msg(6);
	           end if;
	           
            when B6 =>
	           out_SS <= '0';
	           TFSM <= B6;
	           out_sdi <= msg(6);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B5;
	               out_sdi <= msg(5);
	           end if; 
	           
            when B5 =>
	           out_SS <= '0';
	           TFSM <= B5;
	           out_sdi <= msg(5);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B4;
	               out_sdi <= msg(4);
	           end if;
	           
	       when B4 =>
	           out_SS <= '0';
	           TFSM <= B4;
	           out_sdi <= msg(4);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B3;
	               out_sdi <= msg(3);
	           end if;
	           
	       when B3 =>
	           out_SS <= '0';
	           TFSM <= B3;
	           out_sdi <= msg(3);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B2;
	               out_sdi <= msg(2);
	           end if;
	           
	       when B2 =>
	           out_SS <= '0';
	           TFSM <= B2;
	           out_sdi <= msg(2);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B1;
	               out_sdi <= msg(1);
	           end if;
	           
	       when B1 =>
	           out_SS <= '0';
	           TFSM <= B1;
	           out_sdi <= msg(1);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= B0;
	               out_sdi <= msg(0);
	           end if;
	           
	       when B0 =>
	           out_SS <= '0';
	           TFSM <= B0;
	           out_sdi <= msg(0);
	           
	           if(fe_clk100 = '1') then
	               TFSM <= start;
	               out_sdi <= '0';
	               out_SS <= '1';
	           end if;  
	                             
	       when others =>
	           null;
	   end case;
	   end if;
	end process;

    ---------------------- CLOCK FSM --------------------------
    
	process(clk)
	   variable num_bits: integer:=0;
	begin
	   if rising_edge(clk) then
	       case CFSM is
	       
	       when start =>
	           clk100 <= '0';
	           fe_clk100 <= '0';
	           
	           num_bits := 0;
	           count <= to_unsigned(0,cnt_len);
	           
	           if(out_SS = '0') then
	               CFSM <= LOW;
	           else
	               CFSM <= start;    
	           end if;  

	       when LOW =>
	           clk100 <= '0';
	           fe_clk100 <= '0';
	           
	           if(out_SS = '1') then
	               CFSM <= start;
	           elsif (count = cnt_target) then
	               CFSM <= HIGH;
	               clk100 <= '1';
	               re_clk100 <= '1';
	           else
                   count <= count+1;
                   CFSM <= LOW;
	           end if;    
	           
	       when HIGH =>
	           clk100 <= '1';
	           re_clk100 <= '0';
	           
	           if(count = 0) then
	               fe_clk100 <= '1';
	               num_bits := num_bits + 1;
	               if (num_bits <= 7) then   
	                   CFSM <= LOW;
	                   clk100 <= '0';
	               else
	                   clk100 <= '0';
	                   CFSM <= start;
	               end if;    
	           else
	               count <= count-1;
	               CFSM <= HIGH;
	           end if;      
	              	           
	       when others =>
	           null;
	   end case;
	   end if;
	end process;
	
	---------------------- Receive FSM --------------------------
	process(clk)
	   variable bitnum: integer:=0;
	begin
	   if rising_edge(clk) then
	   case RFSM is
           when start =>
               receive_temp <= (others=>'0');
               bitnum := 0;
               if(out_ss = '0') then
                   RFSM <= S1;
               else
                   RFSM <= start;
               end if;
         
           when S1 =>
               RFSM <= start;
               
               if(out_ss = '0') then
                   RFSM <= S1;
                   if(re_clk100 = '1') then
                       receive_temp(7-bitnum) <= input;
                       bitnum := bitnum + 1;	                        
                   elsif(fe_clk100 = '1' and bitnum = 8) then
                      RFSM <= start;
                      receive <= receive_temp;
                      bitnum := 0;
                   end if; 
               end if;    
           
           when others =>
               null;
	       end case;
	   end if;
	end process;

end arch;