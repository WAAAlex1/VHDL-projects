
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Lab06R_test is
    port(
		clk: in    std_logic;
		srx: out   std_logic_vector(7 downto 0);-- PIC pin 9 RS-232
		stx: in    std_logic -- PIC pin 10 RS-232
	);
end Lab06R_test;

architecture Behavioral of Lab06R_test is

-- FSM typedef and signal for receive
	type FSM_type2 is (start, sample, stop);
	signal RFSM: FSM_type2 := start;
	signal RFSM_n: FSM_type2 := start;
	
-- Signals for ReceiveFSM
	signal input: std_logic:='0';
    signal receive: std_logic_vector(7 downto 0):= (others => '0');
	signal receive_n: std_logic_vector(7 downto 0):= (others => '0');
	signal receive_temp: std_logic_vector(7 downto 0):= (others => '0');
	signal R_count: unsigned(7 downto 0):= to_unsigned(0,8);
	signal R_count_n: unsigned(7 downto 0):= to_unsigned(0,8);
	signal bitnumR: unsigned(3 downto 0) := to_unsigned(0,4);
	signal bitnumR_n: unsigned(3 downto 0) := to_unsigned(0,4);

-- constants for bit_period and num_bits
	constant bit_period: natural:=104; 
	constant num_bits: natural:=8;   -- Number of bits needed in our counters.

begin

    input <= stx;
    srx <= receive;

---------------------- Receive FSM --------------------------
	-- Two segment process -> here combinatorial part
	process(RFSM, input, receive_temp, bitnumR, R_count)
	begin
	   case RFSM is
	   
	       when start =>
	           receive_temp <= (others => '0');                                -- reset receive_temp
	           bitnumR_n <= to_unsigned(0,4);
	           if input = '0' then                                             -- start bit found
	               RFSM_n <= sample;                                               -- Go to sample
	               R_count_n <= to_unsigned(bit_period + (bit_period/2), num_bits);  -- Set to 1.5 bit periods
	           else                                                            -- start bit not found
	               RFSM_n <= start;                                                -- stay in start
	           end if;    	
	           
	       when sample =>
	           if R_count = to_unsigned(0, num_bits) then       -- If time to sample
	               receive_temp(to_integer(bitnumR)) <= input;     -- sample input
	               if bitnumR < 7 then                           -- not all bits received
	                   RFSM_n <= sample;                               -- stay in sample	
	                   R_count_n <= to_unsigned(bit_period, num_bits); -- set to 1 bit period
	                   bitnumR_n <= bitnumR+1;
	               else                                            -- if all bits received
	                   RFSM_n <= stop;                                 -- go to stop
	                   R_count_n <= to_unsigned(bit_period, num_bits); -- reset count
	               end if;
	           else                                            -- if not time to sample
	               R_count_n <= R_count-1;                         -- decrement count
	               RFSM_n <= sample;                               -- stay in sample
	           end if;
	           
	        when stop =>
	           if R_count = to_unsigned(0,num_bits) then -- Count reached 0
	               if input = '1' then                             -- Stop bit found.
	                   RFSM_n <= start;                                -- go to start
	                   receive_n <= receive_temp;                      -- Propagate data
	               else                                           -- Stop bit not found.
	                   receive_temp <= (others => '0');                -- discard data
	                   RFSM_n <= stop;                                 -- stay in stop 
	                   R_count_n <= to_unsigned(1, num_bits);          -- set count to 1 (keep looking)
	               end if;                                             -- Needed to sunchronize after error
	           else                                               -- Keep decrementing count
	               RFSM_n <= stop;                                 -- stay in stop
	               R_count_n <= R_count-1;                         -- decrement count
	           end if;    	
	           
	           when others =>
	               null;
	           
	       end case;

	end process;
	
    -- Two segment approach -> here sequential part. 
	process(clk)
	begin
	   if rising_edge(clk) then
	       RFSM <= RFSM_n;
	       R_count <= R_count_n;
	       bitnumR <= bitnumR_n;
	       receive <= receive_n;
	   end if;
	end process;


end Behavioral;
