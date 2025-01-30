library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab03a is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic;
		btn: in  std_logic_vector(1 downto 0)
	);
end lab03a;

architecture arch of lab03a is
	component lab03_gui
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			data_o: out std_logic_vector(27 downto 0);
			data_i: in  std_logic_vector(27 downto 0)
		);
	end component;
	component counter
		generic(
			NBITS: natural;-- Counter size
			INITC: natural -- Power-on reset
		);
		port(
			clock_i: in  std_logic; -- Input clock
			reset_i: in  std_logic; -- Asynchronous reset
			load_i:  in  std_logic; -- Synchronous load
			beg_i:   in  std_logic_vector(NBITS-1 downto 0); -- Start count
			inc_i:   in  std_logic_vector(NBITS-1 downto 0); -- Increment
			end_i:   in  std_logic_vector(NBITS-1 downto 0); -- End count
			count_i: in  std_logic_vector(NBITS-1 downto 0); -- Count in
			carry_i: in  std_logic; -- Carry-in for cascading
			count_o: out std_logic_vector(NBITS-1 downto 0); -- Count out
			carry_o: out std_logic  -- Carry-out for cascading
		);
	end component;
	component mSync
	   Port(
	       I, C, R: in std_logic;
           O: out std_logic
	   );
	end component;
	signal data_o: std_logic_vector(27 downto 0); --Internal signal for handling data
	signal data_i: std_logic_vector(27 downto 0); --Internal signal for handling data 
	
	signal c_vector: std_logic_vector(8 downto 1); --Internal vector for handling carry signals. 
	signal divider_carry_in: std_logic; -- internal signal for specifically handling the carry_in of counter 2. 
	signal turbo : std_logic; -- internal signal for handling turbo button (after mSync)
	signal load_i: std_logic; -- internal signal for handling load button (after mSync)
	signal beg_h0: std_logic_vector(3 downto 0); -- internal signals for hours0 instantiation
	signal end_h0: std_logic_vector(3 downto 0);
begin
    
    --Metastability synchronizers for button inputs (will be delayed 3 cycles).
    mSync1: mSync port map(I=>btn(0), C=>clk, R=>'0', O=>load_i);
    mSync2: mSync port map(I=>btn(1), C=>clk, R=>'0', O=>turbo);
    
    --Instantiation of MATLAB GUI MODULE. Consider a Black box.
	gui: lab03_gui port map(clk_i=>clk,rx_i=>rx,tx_o=>tx,data_o=>data_o,data_i=>data_i);
	
	-- Instantiation of 9 cascaded accumulators (Here used simply as counters). 
	-- First counter should not take any carry_in, Last counter should not give any carry_out
	-- Second counter (divider) carry_in controlled by carry_o from counter1 ORed with turbo button
	prescaler:  counter   generic map(NBITS=>14, INITC=>0)
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0') , inc_i => (others=>'0'),
	                       end_i => b"10011100001111", count_i => (others=>'0'), carry_i => '1', count_o => open , carry_o => c_vector(1));
	
	divider_carry_in <= c_vector(1) or turbo;                  
    divider:    counter   generic map(NBITS=>10, INITC=>0)
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i => (others=>'0'), 
	                       end_i => b"1111100111", count_i => (others=>'0') , carry_i => divider_carry_in , count_o => open, carry_o => c_vector(2));
    
    tenths:     counter   generic map(NBITS=>4, INITC=>7)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i =>(others=>'0') , 
	                       end_i => b"1001", count_i => data_o(3 downto 0) , carry_i => c_vector(2), count_o => data_i(3 downto 0), carry_o => c_vector(3)); 	                                
    
    seconds0:   counter   generic map(NBITS=>4, INITC=>6)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i =>(others=>'0') , 
	                       end_i => b"1001", count_i => data_o(7 downto 4) , carry_i => c_vector(3), count_o => data_i(7 downto 4), carry_o => c_vector(4)); 	                                
    seconds1:   counter   generic map(NBITS=>4, INITC=>5)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i =>(others=>'0') , 
	                       end_i => b"0101", count_i => data_o(11 downto 8) , carry_i => c_vector(4), count_o => data_i(11 downto 8), carry_o => c_vector(5));
	                       
    minutes0:   counter   generic map(NBITS=>4, INITC=>4)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i =>(others=>'0') , 
	                       end_i => b"1001", count_i => data_o(15 downto 12) , carry_i => c_vector(5), count_o => data_i(15 downto 12), carry_o => c_vector(6));
    minutes1:   counter   generic map(NBITS=>4, INITC=>3)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i =>(others=>'0') , 
	                       end_i => b"0101", count_i => data_o(19 downto 16) , carry_i => c_vector(6), count_o => data_i(19 downto 16), carry_o => c_vector(7));
	
	-- Combinatorial statements for defining beg_h0 and end_h0 as these depend on the value of hours1. 
	beg_h0 <= std_logic_vector(to_unsigned(0,4)) when data_i(27 downto 24)=std_logic_vector(to_unsigned(0,4))
                                                 else std_logic_vector(to_unsigned(1,4));
    end_h0 <= std_logic_vector(to_unsigned(9,4)) when data_i(27 downto 24)=std_logic_vector(to_unsigned(0,4))
                                                 else std_logic_vector(to_unsigned(2,4));
    
    hours0:     counter   generic map(NBITS=>4, INITC=>2)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>beg_h0, inc_i =>(others=>'0') , 
	                       end_i => end_h0, count_i => data_o(23 downto 20) , carry_i => c_vector(7), count_o => data_i(23 downto 20), carry_o => c_vector(8));
    hours1:     counter   generic map(NBITS=>4, INITC=>1)                    
	                       port map(clock_i => clk, reset_i=>'0', load_i=>load_i, beg_i=>(others=>'0'), inc_i =>(others=>'0') , 
	                       end_i => b"0001", count_i => data_o(27 downto 24) , carry_i => c_vector(8), count_o => data_i(27 downto 24), carry_o => open);
end arch;



