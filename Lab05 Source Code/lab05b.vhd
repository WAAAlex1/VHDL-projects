library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab05b is
	port(
		clk:      in  std_logic;
		rx:       in  std_logic;
		tx:       out std_logic;
		vaux12_n: in  std_logic;
		vaux12_p: in  std_logic;
		btn:      in  std_logic;
		square:   out std_logic
	);
end lab05b;

architecture arch of lab05b is
	component lab05b_gui is
		generic(
			SAMPLES: natural
		);
		port(
			clk_i:  in  std_logic;
			rx_i:   in  std_logic;
			tx_o:   out std_logic;
			addr_o: out std_logic_vector(9 downto 0);
			data_i: in  std_logic_vector(11 downto 0)
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
	constant samples: natural:=200;
	signal rdy:   std_logic;
	signal addra: std_logic_vector(9 downto 0);
	signal dataa: std_logic_vector(35 downto 0);
	signal addrb: std_logic_vector(9 downto 0):= (others=>'0'); --instantiated to 0
	signal datab: std_logic_vector(35 downto 0);
	
	-- For toggling the square wave signal 
	signal sqr_help: std_logic:='0';
	signal sqr_cnt:  unsigned(10 downto 0):= (others => '0');
	
	-- For driving addrb
	signal addrb_count: unsigned(9 downto 0):= to_unsigned(200,10); -- initialized to 200 (idle state)
	signal addrb_c_next: unsigned(9 downto 0):= to_unsigned(200,10); -- initialized to 200 (idle state)

	signal sample_en: std_logic:='0';
	signal sample_en_next: std_logic:='0';
	signal start: std_logic:='0';
	
begin
	gui: lab05b_gui generic map (SAMPLES=>samples) port map(clk_i=>clk,
		rx_i=>rx,tx_o=>tx,addr_o=>addra,data_i=>dataa(11 downto 0));
	
	adc: lab05_adc port map(clk_i=>clk,vaux12n_i=>vaux12_n,
		vaux12p_i=>vaux12_p,rdy_o=>rdy,data_o=>datab(11 downto 0));
	
	ram: lab05_ram port map(clka_i=>clk,wea_i=>'0',addra_i=>addra,
		dataa_i=>(others=>'0'),dataa_o=>dataa,clkb_i=>clk,
		web_i=>sample_en,addrb_i=>addrb,datab_i=>datab,datab_o=>open);
	
	datab(35 downto 12)<=(others=>'0');
	
	-- DRIVING ADDRB AND WEB_I
	-- solution on page 61 not possible due to lack of outputs from XADC module. 
	-- OWN SOLUTION -> Use a counter with idle state to control addrb and web_i.
	-- addrb starts at 200 (idle state). If rising edge of rdy and in idle state and btn pressed, addrb -> 0. 
	-- addrb incremented by 1 whenever rising edge of rdy and not in idle state. 
	-- when addrb equal to 199 go to idle state.
	-- sample_en also controlled -> 
	--    when we are in idle state sample_en is always 0.
	--    when we are in any other state sample_en is 1. 
	
	-- two segment approach used for timing purposes. 
	-- sample_en and addrb changed on rising edge of clk to their next state. 
	-- sample_en and addrb as such set at the same time and constant for atleast one entire clock cycle.  
	
	start <= btn;
	process(rdy)
	begin
	   if rising_edge(rdy) then
	       case addrb_count is
	           when b"0011001000" => -- if in idle state
	               if (start = '1') then -- and if button pressed
	                   addrb_c_next <= (others => '0'); -- go to start state
	                   sample_en_next <= '1'; -- set sample_en
	               else
	                   addrb_c_next <= addrb_count; -- else stay in idle state
	                   sample_en_next <= '0'; -- dont set sample_en
	               end if;
	           when b"0011000111" => -- if in end state (last address: 199)
	               if (start = '1') then
	                   addrb_c_next <= to_unsigned(0,10); -- go to start state immediately
	                   sample_en_next <= '1';  -- set sample_en_next 
	               else
	                   addrb_c_next <= to_unsigned(200,10); -- go to idle state
                       sample_en_next <= '0';  -- set sample_en_next to 0 (not sampling in idle state)
                   end if;
               when others => -- if in any other state (addrb = 0..198)
                    addrb_c_next <= addrb_count+1; -- next address calculated
                    sample_en_next <= '1'; -- sample_en set to 1 (should sample when not in idle state)
           end case;
	   end if;	
	end process;
	
	-- progressing to the next state should be done using the clk
	-- to ensure timing restrictions are upheld. 
	process(clk) 
	begin
	   if rising_edge(clk) then
	       addrb_count <= addrb_c_next; -- addrb_count is updated
	       sample_en <= sample_en_next; -- sample_en is updated
	   end if;	
	end process;
	addrb <= std_logic_vector(addrb_count);

	-- GENERATING A SQUARE WAVE SIGNAL
	-- Counter of 1040 cycles, toggling square
	-- hence square has period of 2080 cycles.
	square <= sqr_help;
	process(clk)
	begin
	   if rising_edge(clk) then
	       if sqr_cnt = 1039 then
	           sqr_cnt <= to_unsigned(0,11); --reset sqr_cnt to 0 
	           sqr_help <= not(sqr_help); -- toggle sqr_help
	       else
	          sqr_cnt <= sqr_cnt+1; -- increment sqr_cnt
	       end if;
	   end if;
	end process;
	
end arch;