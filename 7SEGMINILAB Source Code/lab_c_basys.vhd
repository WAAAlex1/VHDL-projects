library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_c_basys is
	port(
		clk:   in  std_logic;
		data:  in  std_logic_vector(3 downto 0);
		ano:   out std_logic_vector(4 downto 1);
		seg_out: out std_logic_vector(7 downto 1);
	);
end lab_c_basys;

architecture arch of lab_c_basys is
	
	signal data_u: unsigned(3 downto 0);

    -- USER DEFINED SIGNALS ----------------------
    -- USED FOR PROCESS 1
	signal pattern: std_logic_vector(7 downto 1):=b"0110_000";
	
	-- USED FOR PROCESS 2
	signal cnt: unsigned(18 downto 0) := to_unsigned(0,19); --Need 19 bits to count to 300.000 (3ms uptime for each anode)
	signal ano_1: std_logic_vector(ano'high downto ano'low):=b"1000";
	constant cnt_target: natural:=300000;
	constant num_bits: natural:=19;
	
	--FOR TESTING  
	signal data_test: unsigned(4 downto 1);
		
begin
    
    --INPUTS
    data_u <= unsigned(data);

    --OUTPUTS
	seg_out <= not pattern;
	ano <= ano_1;
	
	-- PROCESS 1 -> TRANSLATE DATA INTO PATTERN
	with to_integer(data_u) select
	   pattern <= b"0110_000" when 1,
	              b"1101_101" when 2,
	              b"1111_001" when 3, 
	              b"0110_011" when 4, 
	              b"1011_011" when 5,
	              b"1011_111" when 6,
	              b"1110_010" when 7,
	              b"1111_111" when 8,
	              b"1111_011" when 9,
	              b"1110_111" when 10, --A
	              b"0011_111" when 11, --b
	              b"0111_101" when 12, --C
	              b"0111_101" when 13, --d
	              b"1001_111" when 14, --E
	              b"1000_111" when 15, 
	              b"1111_110" when others;
	              
	
	-- PROCESS 2 -> DRIVE DATA ONTO 7-SEG
	-- 2 segment approach. 
	-- use simple counter. When count reached circular shift anode right once. 
	-- Count reached when count = 36000. Count needed to get 12ms refresh speed 
	-- as each digit should then be turned on for 3ms -> 3/1000hZ -> needs 300.000 cycles from 100MHz clock. 
	
	process(clk) 
	begin
	if rising_edge(clk) then
	   if cnt = cnt_target then
           ano_1 <= ano_1(ano_1'low)&ano_1(ano_1'high downto ano_1'low+1); -- Right circular shifting
           cnt <= to_unsigned(0,num_bits);
       else
           cnt <= cnt+1;
       end if;
	 end if;
	end process;

end arch;