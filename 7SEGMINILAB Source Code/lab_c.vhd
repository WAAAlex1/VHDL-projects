library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_c is
	port(
		clk:   in  std_logic;
		rx:    in  std_logic;
		tx:    out std_logic;
		com:   out std_logic;
		seg_a: out std_logic;
		seg_b: out std_logic;
		seg_c: out std_logic;
		seg_d: out std_logic;
		seg_e: out std_logic;
		seg_f: out std_logic;
		seg_g: out std_logic
	);
end lab_c;

architecture arch of lab_c is
    constant cnt_target: natural:=50000;
	constant num_bits: natural:=16;
	
	component lab_c_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic;
			data_o: out unsigned(3 downto 0)
		);
	end component;
	signal data: unsigned(3 downto 0);

    -- USER DEFINED SIGNALS ----------------------
    -- USED FOR PROCESS 1
	signal pattern: std_logic_vector(7 downto 1):=b"0110_000";
	
	-- USED FOR PROCESS 2
	signal cnt: unsigned(num_bits - 1 downto 0) := to_unsigned(0, num_bits); --Need 16 bits to count to 50.000
	signal com_sr: std_logic_vector(1 downto 0):=b"10";

begin
	gui: lab_c_gui port map(clk=>clk,rx=>rx,tx=>tx,data_o=>data);
	
	
	seg_a <= pattern(7) xor com_sr(com_sr'high);
	seg_b <= pattern(6) xor com_sr(com_sr'high);
	seg_c <= pattern(5) xor com_sr(com_sr'high);
	seg_d <= pattern(4) xor com_sr(com_sr'high);
	seg_e <= pattern(3) xor com_sr(com_sr'high);
	seg_f <= pattern(2) xor com_sr(com_sr'high);
	seg_g <= pattern(1) xor com_sr(com_sr'high);
	com <= com_sr(com_sr'high);
	
	-- PROCESS 1 -> TRANSLATE DATA INTO PATTERN
	
	with to_integer(data) select
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
	              b"1001_110" when 12, --C
	              b"0111_101" when 13, --d
	              b"1001_111" when 14, --E
	              b"1000_111" when 15, --F
	              b"1111_110" when others; -- 0
	              
	-- PROCESS 2 -> DRIVE DATA ONTO 7-SEG
	-- 2 segment approach. 
	-- use simple counter. When count reached circular shift com right once. 
	-- Count reached when count = 50.000. Count needed to get 120Hz from 12MHz is 100.000
	-- we want to shift every half period -> 50.000 cycles needed. 
	
	process(clk) 
	begin
	if rising_edge(clk) then
	   if cnt = cnt_target then
           com_sr <= com_sr(com_sr'low)&com_sr(com_sr'high downto com_sr'low+1); -- Right circular shifting
           cnt <= to_unsigned(0,num_bits);
       else
           cnt <= cnt+1;
       end if;
	 end if;
	end process;

end arch;