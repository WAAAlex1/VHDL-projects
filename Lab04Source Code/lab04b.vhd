library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab04b is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic;
		btn: in  std_logic;
		led: out std_logic_vector(1 downto 0)
	);
end lab04b;

architecture arch of lab04b is
	component lab04_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(47 downto 0);
			data_i: in  std_logic_vector(47 downto 0)
		);
	end component;
	signal data_o:    std_logic_vector(47 downto 0);
	signal data_i:    std_logic_vector(47 downto 0);
	signal start:     std_logic:='0';
	
	signal remainder: unsigned(71 downto 0);
	signal divisor:   unsigned(71 downto 0);
	signal factor:    unsigned(24 downto 0):=b"1_00000000_00000000_00000000";
	--Need to perform 47 shifts - hence idle state = 48
	signal count:     unsigned(5 downto 0):=b"110001"; -- idle state of count = 49
	
	signal start_data: unsigned(47 downto 0);
	signal found_fac:  std_logic:='0';
	signal output:     unsigned(47 downto 0):=(others => '0');
	
	signal square:     unsigned(48 downto 0):=(others => '0');
	
	
begin
	gui: lab04_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,
		data_o=>data_o,data_i=>data_i);

    start <= btn;
    data_i <= std_logic_vector(output);
    -- factor is divisor
    -- Data given from matlab on start is remainder

	process(clk)
	begin
		if rising_edge(clk) then
			case count is
				when b"110001" => -- when count is in start state or end state
					if (factor=b"1_00000000_00000000_00000000") then
						if (start='1') then
							-- Start of new factorization
							led<=b"11";-- turn on LED to indicate factorization in progress
							factor <= (1 => '1', others=>'0'); --initialize factor to 2.
							remainder <= to_unsigned(0,24) & unsigned(data_o);
							divisor<= b"0_00000000_00000000_00000010" & to_unsigned(0, 47); -- eq to 2 when starting extend to 72 bit
							start_data <= unsigned(data_o); --save start data 
							output <= (0 => '1', others => '0'); -- set Matlab to show 1
							count<=b"000000";-- Initial value of count = 0
							found_fac <= '0';
							square <= (2 => '1', others=>'0'); --initialize square to 4.
						else -- factor is in start/end state and start is not true -> we are at end
							led<=b"00"; -- Turn leds off (we have finished computations)
							if found_fac = '0' then -- if no prime factor found
							     output <= start_data; -- then start data is prime. output start data.  
							end if;
						end if;
					else -- if there still are factors to check
						-- Increment factor & divisor and reinitialize others
						factor<=factor+1;
						remainder<= to_unsigned(0,24) & start_data;
						divisor <= (factor+1) &  to_unsigned(0, 47);
						count <= b"000000"; -- restart count
						-- update square -> No need to use padding as none of the elements can ever overflow. 
						square <= square + shift_left(factor,1) + 1;
						-- terminate the process early if square greater than input
						if(square > ('0'&start_data)) then
						  factor <= b"1_00000000_00000000_00000000";
					      count <= b"110001";
						end if;
					end if;
				when b"110000" => -- Counter has completed full loop (shifted 47 times)
					-- Check for zero remainder
					-- Special case for start_data = 0
					if (remainder=0) then -- remainder = 0 means factor divisible
						 -- check for if a prime factor already found, only show smallest prime factor
					   if(start_data > 0) then -- found_fac check no longer needed. 
					       output <= to_unsigned(0,23) & factor;
					       found_fac <= '1';
					   end if;
					   -- as soon as remainder = 0 we've found a factorization -> go to end. 
					   factor <= b"1_00000000_00000000_00000000";
					   count <= b"110001";
					end if;
					count<=count+1;
				when others =>
					-- Shift and subtract
					if (remainder>=divisor) then
						remainder<=remainder-divisor;
					end if;
					divisor <= shift_right(divisor, 1);-- shift right
					count<=count+1;
			end case;
		end if;
	end process;
end arch;
