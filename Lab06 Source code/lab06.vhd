library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab06 is
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
end lab06;

architecture arch of lab06 is
	component lab06_gui
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
	type FSM_type1 is (start, S_engage, S_transmit, S_stop);
	signal TFSM: FSM_type1 := start;
	
	-- FSM typedef and signal for receive
	type FSM_type2 is (start, sample, stop);
	signal RFSM: FSM_type2 := start;
	signal RFSM_n: FSM_type2 := start;
	
	-- Signals for TransmitFSM
	signal msg: std_logic_vector(7 downto 0):= (others => '0');
	signal T_count: unsigned(7 downto 0):=to_unsigned(0,8);
	signal output: std_logic:='0';
		
	-- Signals for ReceiveFSM
	signal input: std_logic:='0';
    signal receive: std_logic_vector(7 downto 0):= (others => '0');
	signal receive_temp: std_logic_vector(7 downto 0):= (others => '0');
	signal R_count: unsigned(7 downto 0):= to_unsigned(0,8);
	
	-- constants for bit_period and num_bits
	constant bit_period: natural:=104; 
	constant num_bits: natural:=8;   -- Number of bits needed in our counters.
begin
	gui: lab06_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i,trig_o=>trig);
		
    ---------------------- DEFAULT VALUES OF UNUSED PORTS ---------  
	nss<='1';
	sck<='0';
	sdi<='0';
	scl<='Z';
	sda<='Z';
    ---------------------- CONNECTIONS FOR TRANSMITTING --------- 
	srx <= output;
	msg <= data_o;-- DIFFERENCE  
	---------------------- CONNECTIONS FOR RECEIVING ------------
	data_i <= receive;
	input  <= stx;
	---------------------- Transmit FSM --------------------------

	process(clk)
	   variable bitnumT: integer:=0;
	begin
	   if rising_edge(clk) then
	       case TFSM is
	       
	       when start =>
	           output <= '1';
	           bitnumT := 0; 
	           if trig = '1' then              -- IF TRIGGER
	               TFSM <= S_engage;                   -- go to next state
	               T_count <= to_unsigned(bit_period, num_bits);
	               output <= '0';
	           else                            -- IF NO TRIGGER
	               TFSM <= start;                -- stay in start
	           end if;
	       
	       when S_engage =>
	           output <= '0';
	           if T_count = 0 then -- If waited 1 bit period 
	               TFSM <= S_transmit;                                       -- Go to S_transmit
	               T_count <= to_unsigned(bit_period,num_bits);      -- reset count
	               output <= msg(bitnumT);
	           else                                                -- If not waited 1 bit period
	               T_count <= T_count-1;                             -- decrement count
	               TFSM <= S_engage;                                       -- stay in S_engage
	           end if;
	       
	       when S_transmit =>
	           output <= msg(bitnumT);
	           if T_count = 0 then -- If waited 1 bit period
	               T_count <= to_unsigned(bit_period,num_bits);
	               if bitnumT < 7 then                              -- If not all bits transmitted         
                       TFSM <= S_transmit;                                    -- stay in S_transmit
                       bitnumT := bitnumT+1;                            -- increment bitnum
                   else                                            -- If all bits transmitted
                       TFSM <= S_stop;                                  -- Go to S_stop
                   end if;
	           else                                      -- If not waited 1 bit period
	               T_count <= T_count-1;                         -- decrement count
	               TFSM <= S_transmit;                                   -- stay in S_transmit
	           end if;
	           
	       when S_stop => 
	           output <= '1';
	           if T_count = 0 then -- If waited 1 bit period
	               TFSM <= start;                                    -- Go to start
	           else                                                -- If not waited 1 bit period 
	               T_count <= T_count-1;                             -- Increment count
	               TFSM <= S_stop;                                     -- stay in S1
	           end if;
	       when others =>
	           null;
	   end case;
	   end if;
	end process;

	---------------------- Receive FSM --------------------------
	process(clk)
	   variable bitnumR: integer:=0;
	begin
	   if rising_edge(clk) then
	       case RFSM is
	       when start =>
	           receive_temp <= (others => '0');                                -- reset receive_temp
	           bitnumR := 0;
	           if input = '0' then                                             -- start bit found
	               RFSM <= sample;                                               -- Go to sample
	               R_count <= to_unsigned(bit_period + (bit_period/2), num_bits);  -- Set to 1.5 bit periods
	           else                                                            -- start bit not found
	               RFSM <= start;                                                -- stay in start
	           end if;    	
	           
	       when sample =>
	           if R_count = 0 then                     -- If time to sample
	               receive_temp(bitnumR) <= input;         -- sample input
	               if bitnumR < 7 then                           -- not all bits received
	                   RFSM <= sample;                               -- stay in sample	
	                   R_count <= to_unsigned(bit_period, num_bits); -- set to 1 bit period
	                   bitnumR := bitnumR+1;
	               else                                            -- if all bits received
	                   RFSM <= stop;                                 -- go to stop
	                   R_count <= to_unsigned(bit_period, num_bits); -- reset count
	               end if;
	           else                                            -- if not time to sample
	               R_count <= R_count-1;                         -- decrement count
	               RFSM <= sample;                               -- stay in sample
	           end if;
	           
	        when stop =>
	           if R_count = 0 then -- Count reached 0
	               if input = '1' then                             -- Stop bit found.
	                   RFSM <= start;                                -- go to start
	                   receive <= receive_temp;                      -- Propagate data
	               else                                           -- Stop bit not found.
	                   receive_temp <= (others => '0');                -- discard data
	                   RFSM <= stop;                                 -- stay in stop 
	                   R_count <= to_unsigned(1, num_bits);          -- set count to 1 (keep looking)
	               end if;                                             -- Needed to sunchronize after error
	           else                                               -- Keep decrementing count
	               RFSM <= stop;                                 -- stay in stop
	               R_count <= R_count-1;                         -- decrement count
	           end if;    
	           	
	       when others =>
	           null;
	           
	       end case;
	   end if;
	end process;

end arch;