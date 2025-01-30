library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07_test is
	port(
		clk: in    std_logic;
		nss: out   std_logic;-- PIC pin 11 SPI
		trig: in   std_logic;
		msg_in: in std_logic_vector(7 downto 0)
	);
end lab07_test;

architecture arch of lab07_test is

	-- FSM typedef and signal for transmit
	type FSM_type1 is (start, S1);
	signal TFSM: FSM_type1 := start;
	signal TFSM_n: FSM_type1 := start;
	
	-- FSM typedef and signal for receive
	type FSM_type2 is (start, s1, sample);
	signal RFSM: FSM_type2 := start;
	signal RFSM_n: FSM_type2 := start;
	
	-- FSM typedef and signal for CLOCK
	type FSM_type3 is (start, LOW, HIGH);
	signal CFSM: FSM_type3 := start;
	signal CFSM_n: FSM_type3 := start;
	
	-- Signals for TransmitFSM
	signal out_SDI: std_logic:='0';
	signal out_SS: std_logic:='0';
	signal msg: std_logic_vector(7 downto 0):= (others => '0');
	
	-- Signals for ReceiveFSM
	signal input: std_logic:='0';
    signal receive: std_logic_vector(7 downto 0):= (others => '0');
	signal receive_n: std_logic_vector(7 downto 0):= (others => '0');
	signal receive_temp: std_logic_vector(7 downto 0):= (others => '0');
    signal bitnum: unsigned(3 downto 0):=to_unsigned(0,4);
    signal bitnum_n: unsigned(3 downto 0):=to_unsigned(0,4);
	
	-- Signals for ClockFSM
	signal clk100: std_logic:='0';
	signal re_clk100: std_logic:='0';
	signal re_clk100_n: std_logic:='0';
	signal cycle_cnt: unsigned(3 downto 0):=(others => '0'); -- Used for keeping track of how many cycles we emit'
	signal cycle_cnt_n: unsigned(3 downto 0):=(others => '0'); -- Used for keeping track of how many cycles we emit
	signal count: unsigned(6 downto 0):=(others => '0');     -- Need 7 bits for counting 120. 
	signal count_n: unsigned(6 downto 0):=(others => '0');
	
	constant cnt_len: natural:=7;
	constant cnt_target: natural:=59;
		
begin
    
    ---------------------- CONNECTIONS FOR TRANSMITTING --------- 
	nss<=out_SS;
	---------------------- CONNECTIONS FOR RECEIVING ------------
	input  <= out_sdi;
	msg <= msg_in;
	---------------------- Transmit FSM --------------------------
	-- Two segment process -> here combinatorial part
	process(TFSM, cycle_cnt, trig, msg)
	begin
	   case TFSM is
	   
	       when start =>
	           
	           out_sdi <= '0';
	           out_SS <= '1';
	           
	           if(trig = '1') then
	               TFSM_n <= S1;
	           else
	               TFSM_n <= start;
	           end if;    
	           
	       when S1 =>
	           out_SS <= '0';
	           if(cycle_cnt <= 7) then
	               TFSM_n <= S1;
	               out_sdi <= msg(TO_INTEGER(7-cycle_cnt));
	           else
	               TFSM_n <= start;
                   out_sdi <= msg(0);
                   out_SS <= '1';
	           end if;
	          	           
	       when others =>
	           null;
	   end case;
	   
	end process;
	
	-- Two segment approach -> here sequential part. 
	process(clk)
	begin
	   if rising_edge(clk) then
	       TFSM <= TFSM_n; 
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

	---------------------- Receive FSM --------------------------
	-- Two segment process -> here combinatorial part
	process(RFSM, input, receive_temp, re_clk100, out_ss, bitnum)
	begin
	   case RFSM is
	           when start =>
	               receive_temp <= (others=>'0');
	               bitnum_n <= to_unsigned(0,4);
	               if(out_ss = '0') then
	                   RFSM_n <= S1;
	               else
	                   RFSM_n <= start;
	               end if;
	         
	           when S1 =>
	               if(out_ss = '0') then
	                   RFSM_n <= S1;
	                   if(re_clk100 = '1') then
	                       RFSM_n <= sample;	                       
	                   end if;  
	                   receive_n <= receive_n;
	                   if(bitnum = 8) then
	                       receive_n <= receive_temp;
                       end if;
	               else
	                   RFSM_n <= start;
	               end if;
	           
	           when sample =>
	               receive_temp(TO_INTEGER(7-bitnum)) <= input;
	               bitnum_n <= bitnum + 1;
	               RFSM_n <= S1;           
	           when others =>
	               null;
	           
	       end case;

	end process;
	
    -- Two segment approach -> here sequential part. 
	process(clk)
	begin
	   if rising_edge(clk) then
	       RFSM <= RFSM_n;
	       receive <= receive_n;
	       bitnum <= bitnum_n;
	   end if;
	end process;
	
	
end arch;


---------------------- Transmit FSM --------------------------
	-- Two segment process -> here combinatorial part
	process(TFSM, cycle_cnt, trig, msg, data_o)
	begin
	   case TFSM is
	   
	       when start =>
	           
	           out_sdi <= '0';
	           out_SS <= '1';
	           
	           if(trig = '1') then
	               TFSM_n <= S1;
	               msg <= data_o;
	           else
	               TFSM_n <= start;
	           end if;    
	           
	       when S1 =>
	           out_SS <= '0';
	           if(cycle_cnt <= 7) then
	               TFSM_n <= S1;
	               out_sdi <= msg(TO_INTEGER(7-cycle_cnt));
	           else
	               TFSM_n <= start;
                   out_sdi <= msg(0);
                   out_SS <= '1';
	           end if;
	          	           
	       when others =>
	           null;
	   end case;
	   
	end process;
	
	-- Two segment approach -> here sequential part. 
	process(clk)
	begin
	   if rising_edge(clk) then
	       TFSM <= TFSM_n; 
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

---------------------- Receive FSM --------------------------
	-- Two segment process -> here combinatorial part
	process(RFSM, input, receive_temp, re_clk100, out_ss, bitnum)
	begin
	   case RFSM is
	           when start =>
	               receive_temp <= (others=>'0');
	               bitnum_n <= to_unsigned(0,4);
	               if(out_ss = '0') then
	                   RFSM_n <= S1;
	               else
	                   RFSM_n <= start;
	               end if;
	         
	           when S1 =>
	               if(out_ss = '0') then
	                   RFSM_n <= S1;
	                   if(re_clk100 = '1') then
	                       RFSM_n <= sample;	                       
	                   end if;  
	                   if(bitnum = 8) then
	                       receive_n <= receive_temp;
                       end if;
	               else
	                   RFSM_n <= start;
	               end if;
	           
	           when sample =>
	               receive_temp(TO_INTEGER(7-bitnum)) <= input;
	               bitnum_n <= bitnum + 1;
	               RFSM_n <= S1;           
	           when others =>
	               null;
	           
	       end case;

	end process;
	
    -- Two segment approach -> here sequential part. 
	process(clk)
	begin
	   if rising_edge(clk) then
	       RFSM <= RFSM_n;
	       receive <= receive_n;
	       bitnum <= bitnum_n;
	   end if;
	end process;

