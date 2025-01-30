library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_a is
	port(
		clk:   in  std_logic;
		rx:    in  std_logic;
		tx:    out std_logic;
		btn_r: in  std_logic;
		btn_b: in  std_logic;
		btn_y: in  std_logic;
		btn_g: in  std_logic
	);
end lab_a;

architecture arch of lab_a is
	component lab_a_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic;
			cntr_i: in  unsigned(6 downto 0);
			cntb_i: in  unsigned(6 downto 0);
			cnty_i: in  unsigned(6 downto 0);
			cntg_i: in  unsigned(6 downto 0)
		);
	end component;
	
	signal cntr: unsigned(6 downto 0);
	signal cntb: unsigned(6 downto 0);
	signal cnty: unsigned(6 downto 0);
	signal cntg: unsigned(6 downto 0);
	
	signal btn_r1: std_logic;
	signal btn_r2: std_logic;
	signal btn_r3: std_logic;
	signal out_btn_r: std_logic;
	signal cnt_btn_r: unsigned(18 downto 0);
	
	signal btn_g1: std_logic;
	signal btn_g2: std_logic;
	signal btn_g3: std_logic;
	signal out_btn_g: std_logic;
    signal cnt_btn_g: unsigned(18 downto 0);

	signal btn_b1: std_logic;
	signal btn_b2: std_logic;
	signal btn_b3: std_logic;
	signal out_btn_b: std_logic;
	
	signal btn_y1: std_logic;
	signal btn_y2: std_logic;
	signal btn_y3: std_logic;
	signal out_btn_y: std_logic;
	
	constant cnt_max: integer:=300000;
	constant cnt_min: integer:=0;
	
	
	
begin
	gui: lab_a_gui port map(clk=>clk,rx=>rx,tx=>tx,
		cntr_i=>cntr,cntb_i=>cntb,cnty_i=>cnty,cntg_i=>cntg);
		
		
		
		-- METHOD: BTN R and BTN G will be debounced. Others will not. 
		-- Create process for each btn. Button press => increment btn cntr
		
		-- MATH: Debounced buttons should be able to register presses less than 20 presses/second (20Hz). 
		--       Find size of Saturation counter: 
		--       20Hz from 12MHz -> Factor of 600.000
		--       Assuming 50% duty cycle of every press we need a counter which counts to 300.000
		
		-- Issue with this type of debouncer:
		--    Say the duty cycle of presses are not 50% then
		--    The saturation counter will never reach 0 and higher frequency presses will NOT be filtered.
		--    Solution:
		--        ?
		--        ?
		
		-- FOR BTN_R
		process(clk)
		begin
		  if rising_edge(clk) then
		      -- Metastability shift register
		      btn_r1 <= btn_r;
		      btn_r2 <= btn_r1;
		      btn_r3 <= btn_r2;  
		      
		      -- Saturation counter 
		      if(btn_r3 = '1') then   -- BUTTON NOT PRESSED
		          if(cnt_btn_r /= cnt_min) then
		              cnt_btn_r <= cnt_btn_r - 1;
		          else
		              out_btn_r <= '0';    
		          end if;
		      else                    -- BUTTON PRESSED
		          if(cnt_btn_r /= cnt_max) then
		              cnt_btn_r <= cnt_btn_r + 1;
		          else
		              out_btn_r <= '1';    
		          end if;
		       end if;
		  end if;     
		end process;
		
		-- use rising edge of out_btn_r to increment cntr
		-- when out_btn_r has a rising edge we have a definitive press. 
		process(out_btn_r)
		begin
		  if rising_edge(out_btn_r) then -- DEFINITIVE BUTTON PRESS
		      cntr <= cntr+1;
		  end if;
		end process;  
		
		-- FOR BTN_G
		process(clk)
		begin
		  if rising_edge(clk) then
		      -- Metastability shift register
		      btn_g1 <= btn_g;
		      btn_g2 <= btn_g1;
		      btn_g3 <= btn_g2;  
		      
		      -- Saturation counter 
		      if(btn_g3 = '1') then   -- BUTTON NOT PRESSED
		          if(cnt_btn_g /= cnt_min) then
		              cnt_btn_g <= cnt_btn_g - 1;
		          else
		              out_btn_g <= '0';    
		          end if;
		      else                    -- BUTTON PRESSED
		          if(cnt_btn_g /= cnt_max) then
		              cnt_btn_g <= cnt_btn_g + 1;
		          else
		              out_btn_g <= '1';    
		          end if;
		       end if;
		  end if;     
		end process;
		
		-- use rising edge of out_btn_r to increment cntr
		-- when out_btn_r has a rising edge we have a definitive press. 
		process(out_btn_g)
		begin
		  if rising_edge(out_btn_g) then -- DEFINITIVE BUTTON PRESS
		      cntg <= cntg+1;
		  end if;
		end process; 
		
		-- FOR BTN_B
		process(clk)
		begin
		  if rising_edge(clk) then
		      -- Metastability shift register
		      btn_b1 <= btn_b;
		      btn_b2 <= btn_b1;
		      btn_b3 <= btn_b2;  
		      
		      out_btn_b <= btn_b3;
		  end if;     
		end process;
		 
		process(out_btn_b)
		begin
		  if rising_edge(out_btn_b) then 
		      cntb <= cntb+1;
		  end if;
		end process; 
		
		-- FOR BTN_Y
		process(clk)
		begin
		  if rising_edge(clk) then
		      -- Metastability shift register
		      btn_y1 <= btn_y;
		      btn_y2 <= btn_y1;
		      btn_y3 <= btn_y2;  
		      
		      out_btn_y <= btn_y3;
		  end if;     
		end process;
		
		process(out_btn_y)
		begin
		  if rising_edge(out_btn_y) then
		      cnty <= cnty+1;
		  end if;
		end process; 
		

end arch;