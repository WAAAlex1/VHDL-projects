library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_b is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic;
		row: out std_logic_vector(6 downto 2);
		col: out std_logic_vector(4 downto 2)
	);
end lab_b;

architecture arch of lab_b is
	component lab_b_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic:='1';
			data_o: out std_logic_vector(14 downto 0)
		);
	end component;
	signal data: std_logic_vector(14 downto 0);
	
	signal col2: std_logic_vector(4 downto 0);
	signal col3: std_logic_vector(4 downto 0);
	signal col4: std_logic_vector(4 downto 0);
	
	signal row2: std_logic_vector(2 downto 0);
	signal row3: std_logic_vector(2 downto 0);
	signal row4: std_logic_vector(2 downto 0);
	signal row5: std_logic_vector(2 downto 0);
	signal row6: std_logic_vector(2 downto 0);
	
	signal col_internal: std_logic_vector(4 downto 2);
	signal col_internal2: std_logic_vector(4 downto 2);
	
	signal col_sr: std_logic_vector(4 downto 2):=b"110";
	signal cnt:    unsigned(16 downto 0):=to_unsigned(0, 17);
	
	constant cnt_max: integer:=125000;
	constant cnt_len: integer:=17;
	
begin
	gui: lab_b_gui port map(clk=>clk,rx=>rx,tx=>tx,data_o=>data);
	
	col2 <= data(4 downto 0);
	col3 <= data(9 downto 5);
	col4 <= data(14 downto 10);
	
	row2 <= col4(0)&col3(0)&col2(0);
	row3 <= col4(1)&col3(1)&col2(1);
	row4 <= col4(2)&col3(2)&col2(2);
	row5 <= col4(3)&col3(3)&col2(3);
	row6 <= col4(4)&col3(4)&col2(4);
	
	-- We need two processes. One that decides which LEDS should be turned on and one which flickers. 
	-- FIRST PROCESS. Should be combinatorial. 
	
	-- Find the internal values for col -> what it ideally should be-
	-- Remember that col_internal(i) = 0 means leds are ON. 
	gen1: for i in 2 to 4 generate
	   col_internal(i) <= not( row2(i-2) or row3(i-2) or row4(i-2) or row5(i-2) or row6(i-2) );
	   end generate;
	    
    -- Second Process.     
    --  32Hz flicker chosen -> period of 375000. Each row should be on for count = 125000 cycles)
    --  Turn rows on and off by right circular shifting (110). This way only one row (0) is on at a time. 
	process(clk)
	begin
	   if(rising_edge(clk)) then
	   	   if(cnt = cnt_max) then
	           cnt <= to_unsigned(0,cnt_len);
	           col_sr <= col_sr(col_sr'low)&col_sr(col_sr'high downto col_sr'low+1);
	       else
	           cnt <= cnt+1;
	       end if;
	   end if;
	end process;   
          
    
    -- Col outputs given from data and col_sr.
    -- Remember that col(i) = 0 means LEDS are on. 
	gen3: for i in 2 to 4 generate
        col_internal2(i) <= col_internal(i) or col_sr(i);
        end generate;
        
    col <= col_internal2;
        
        -- OUTPUTS
    -- Row outputs given directly from data. 
    gen2: for i in 2 to 6 generate
        row(i) <= (col4(i-2) and not col_internal2(4))  or (col3(i-2)and not col_internal2(3)) or (col2(i-2)and not col_internal2(2));
        end generate;      

end arch;