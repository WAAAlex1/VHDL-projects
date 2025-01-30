library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05c is
	port(
		clk:      in  std_logic;
		rx:       in  std_logic;
		tx:       out std_logic;
		vaux12_n: in  std_logic;
		vaux12_p: in  std_logic;
		btn:      in  std_logic;
		square:   out std_logic
	);
end lab05c;

architecture arch of lab05c is
	component lab05c_gui is
		generic(
			SAMPLES: natural
		);
		port(
			clk_i:   in  std_logic;
			rx_i:    in  std_logic;
			tx_o:    out std_logic;
			thrsh_o: out std_logic_vector(11 downto 0);
			addr_o:  out std_logic_vector(9 downto 0);
			data_i:  in  std_logic_vector(11 downto 0)
		);
	end component;
	component lab05_adc is
		port(
			clk_i:     in  std_logic;
			vaux12n_i: in  std_logic;
			vaux12p_i: in  std_logic;
			rdy_o:     out std_logic;
			data_o:    out std_logic_vector(11 downto 0)
		);
	end component;
	component lab05_ram is
		port(
			clka_i:  in  std_logic;
			wea_i:   in  std_logic;
			addra_i: in  std_logic_vector(9 downto 0);
			dataa_i: in  std_logic_vector(35 downto 0);
			dataa_o: out std_logic_vector(35 downto 0);
			clkb_i:  in  std_logic;
			web_i:   in  std_logic;
			addrb_i: in  std_logic_vector(9 downto 0);
			datab_i: in  std_logic_vector(35 downto 0);
			datab_o: out std_logic_vector(35 downto 0)
		);
	end component;
	component lab05_cmt is
		port(
			clk_i: in  std_logic;
			clk_o: out std_logic
		);
	end component;
	constant samples: natural:=400; -- want to display 200 samples before trigger and 200 after
	signal fclk:  std_logic;
	signal rdy:   std_logic;
	signal thrsh: std_logic_vector(11 downto 0);
	signal addra: std_logic_vector(9 downto 0);
	signal dataa: std_logic_vector(35 downto 0);
	signal addrb: std_logic_vector(9 downto 0);
	signal datab: std_logic_vector(35 downto 0);
	
	-- For toggling the square wave signal 
	signal sqr_help: std_logic:='0';
	signal sqr_cnt:  unsigned(10 downto 0):= (others => '0');
	
	-- FOR DRIVING SHIFT REGISTER & RAM
	signal trig: unsigned(11 downto 0);
	signal ram_data: std_logic_vector(35 downto 0);
	signal sh_reg: unsigned(2399 downto 0):=(others=>'0');
	signal sh_reg_next: unsigned(2399 downto 0):=(others=>'0');
	signal sh_data: unsigned(11 downto 0):=(others=>'0');
	signal sh_data_next: unsigned(11 downto 0):=(others=>'0');
	signal count: unsigned(9 downto 0):= to_unsigned(400,10);
	signal count_next: unsigned(9 downto 0):= to_unsigned(400,10);
	-- control signals
	signal start: std_logic:='0';
	signal output: std_logic:='0';
	signal output_next: std_logic:='0';
	signal sh_help: unsigned(2399 downto 0):=(others=>'0');
begin
  
    --------------------------- COMPONENT INSTANTIATIONS --------------------
	gui: lab05c_gui generic map (SAMPLES=>samples) port map(clk_i=>clk,
		rx_i=>rx,tx_o=>tx,thrsh_o=>thrsh,addr_o=>addra,
		data_i=>dataa(11 downto 0));
		
	cmt: lab05_cmt port map(clk_i=>clk,clk_o=>fclk);
	
	adc: lab05_adc port map(clk_i=>fclk,vaux12n_i=>vaux12_n,
		vaux12p_i=>vaux12_p,rdy_o=>rdy,data_o=>datab(11 downto 0));
		
	-- when output true, top 12 MSB of sh_reg are stored in RAM
	-- at address = count. 
	ram: lab05_ram port map(clka_i=>clk,wea_i=>'0',addra_i=>addra,
		dataa_i=>(others=>'0'),dataa_o=>dataa,clkb_i=>fclk,
		web_i=>output,addrb_i=>addrb,datab_i=>ram_data,datab_o=>open);
		
	--------------------------- COMBINATIONAL LOGIC --------------------	
	trig <= unsigned(thrsh);
	ram_data(35 downto 12) <= (others => '0');	
	ram_data(11 downto 0) <= std_logic_vector(sh_reg(2399 downto 2388));
	addrb <= std_logic_vector(count);
	start <= btn;
	square <= sqr_help;
	sh_help <= shift_left(sh_reg,12);
	--------------------------- COMBINATIONAL PROCESS --------------------
	-- THIS SHOULD: 
	-- When new value available from XADC (rdy) we:
	-- Always shift this value into the shift register bottom 12 bits. 
	-- Go to a new state, dependent on the current state and control values (trigger, start, value)
	
	-- When in idle state:
	   -- if start high, next value >= trigger and former value <= trigger
	       -- Go from idle state (400) to start state (0)           
	-- When in states 0-398 the following is true
	   -- Output is high
	       -- top 12 bits from shift_register put into ram at address = state
	-- When in state 399 (end state)
	   -- Output is high
	       -- Top 12 bits from shift register put into ram at address = state
	   -- Next state = 0 if start = high
	   -- Else Next state = idle state if start = low
	   
    -- This way, after having gone through all states, we will have:
        -- Stored the 200 samples prior to a trigger in RAM addresses 0-199
        -- Stored the 200 samples after a trigger (including the trigger) in RAM addresses 200-399.
	process(rdy)
	begin
	   if rising_edge(rdy) then
	       -- always update shift register
	       sh_data_next <= unsigned(datab(11 downto 0));                         -- update sh_data_next
	       sh_reg_next(2399 downto 12) <= sh_help(2399 downto 12);               -- update shift register 
	       sh_reg_next(11 downto 0) <= sh_data;                                  -- using sh_data at 12 lsb
	       
	       case count is
	           when b"0110010000" => -- idle state (400)
	               if start = '1' then -- button pressed
	                   if (sh_reg(12 downto 0) <= trig) and (sh_data >= trig) then -- trigger
	                       count_next <= (others=>'0'); -- go to start state
	                       output_next <= '1'; -- set output next to true
	                   end if;
	               end if;
	           when b"0110001111" => -- end state (399)
	               if start = '1' then
	                   if (sh_reg(12 downto 0) <= trig) and (sh_data >= trig) then -- if trigger
	                       count_next <= (others=>'0'); -- go to start state
	                       output_next <= '1'; -- set output next to true
	                   else
	                       count_next <= count+1;
	                       output_next <= '0'; -- turn off output
	                   end if;
	               else
	                   count_next <= count+1; -- go to idle state (400)
	                   output_next <= '0'; -- turn off output
	               end if;
	           when others => -- middle states (0-398)
	               count_next <= count+1; -- increment count
	               output_next <= '1'; -- Keep output turned on. 
	       end case;
	   end if;	
	end process;
	--------------------------- SEQUENTIAL PROCESS --------------------	
	process(fclk) 
	begin
	   if rising_edge(fclk) then
	       count <= count_next;   -- update counter 
	       output <= output_next; -- update output
	       sh_reg <= sh_reg_next; -- update sh_reg
	       sh_data <= sh_data_next; -- update sh_data
	   end if;	
	end process;
	--------------------------- SQUARE WAVE SIGNAL --------------------
	-- Counter of 1040 cycles, toggling square
	-- hence square has period of 2080 cycles.
	process(fclk)
	begin
	   if rising_edge(fclk) then
	       if sqr_cnt = 1039 then
	           sqr_cnt <= to_unsigned(0,11); --reset sqr_cnt to 0 
	           sqr_help <= not(sqr_help); -- toggle sqr_help
	       else
	          sqr_cnt <= sqr_cnt+1; -- increment sqr_cnt
	       end if;
	   end if;
	end process;
	
end arch;