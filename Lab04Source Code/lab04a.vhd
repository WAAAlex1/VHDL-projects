library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab04a is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic;
		btn: in  std_logic;
		led: out std_logic_vector(1 downto 0)
	);
end lab04a;

architecture arch of lab04a is
	component lab04_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(41 downto 0);
			data_i: in  std_logic_vector(41 downto 0)
		);
	end component;
	signal data_o:    std_logic_vector(41 downto 0);
	signal data_i:    std_logic_vector(41 downto 0);
	signal start:     std_logic:='0';
	
	signal remainder: unsigned(62 downto 0);
	signal divisor:   unsigned(62 downto 0);
	signal factor:    unsigned(21 downto 0):=b"100000_00000000_00000000";
	signal count:     unsigned(5 downto 0):=b"101010"; -- idle state of count = 42
	
	signal start_rem: unsigned(41 downto 0);
	signal found_fac: std_logic:='0';
	signal output:    unsigned(41 downto 0);
begin
	gui: lab04_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i);

    data_i <= std_logic_vector(output);
    -- factor is divisor
    -- remainder is given from matlab (should be saved on start)
    
	process(clk)
	begin
		if rising_edge(clk) then
			case count is
				when b"101010" => -- when b is in start state (42)
					if (factor=b"100000_00000000_00000000") then -- if factor is 2^21
						if (start='1') then -- when we're starting:
							-- Start of new factorization
							led<=b"11"; -- turn on LED to indicate factorization in progress
							factor<=b"000000_00000000_00000010";
							divisor<=b"000000_00000000_00000010" & to_unsigned(0, 41); -- eq to 2 when starting extend to 62 bit
							start_rem <= unsigned(data_i); --save start remainder
							remainder <= to_unsigned(0,21) & unsigned(data_i);
							output <= (0 => '1', others => '0'); -- set Matlab to show 1
							count<=b"000000"; -- set count to start at 0
						else -- when we've finished:
							led<=b"00"; -- turn off led to indicate factorization finished
							if found_fac = '0' then -- if no prime factor found
							     output <= start_rem; -- then set matlab val = start val (start val is prime). 
							end if;
						end if;
					else -- if there still are factors to check
						-- Increment factor and reinitialize others
						factor <= factor+1;
						divisor <= factor+1 &  to_unsigned(0, 41); -- use new divisor
						remainder <= to_unsigned(0,21) & start_rem; -- use same remainder (given at start of program).
						count<=b"000000"; -- restart count
					end if;
				when b"101001" => -- Counter has completed full loop (shifted 41 times)
					-- Check for zero remainder
					if (remainder=0) then -- remainder = 0 means factor divisible
					   -- check for if prime factor already found
					   if(found_fac = '0') then -- only show smallest prime factor
					       output <= to_unsigned(0,20) & factor;
					       found_fac <= '1';
					   end if;	
					end if;
					count<=count+1;
				when others =>
					-- Shift and subtract
					if (remainder>=divisor) then
						remainder<=remainder-divisor;
					end if;
					divisor<= shift_right(divisor, 1);-- shift right
					count<=count+1;
			end case;
		end if;
	end process;
end arch;