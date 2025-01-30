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
	constant samples: natural:=200;
	signal fclk:  std_logic;
	signal rdy:   std_logic;
	signal thrsh: std_logic_vector(11 downto 0);
	signal addra: std_logic_vector(9 downto 0);
	signal dataa: std_logic_vector(35 downto 0);
	signal addrb: std_logic_vector(9 downto 0);
	signal datab: std_logic_vector(35 downto 0);
begin
	gui: lab05c_gui generic map (SAMPLES=>samples) port map(clk_i=>clk,
		rx_i=>rx,tx_o=>tx,thrsh_o=>thrsh,addr_o=>addra,
		data_i=>dataa(11 downto 0));
	cmt: lab05_cmt port map(clk_i=>clk,clk_o=>fclk);
	adc: lab05_adc port map(clk_i=>fclk,vaux12n_i=>vaux12_n,
		vaux12p_i=>vaux12_p,rdy_o=>rdy,data_o=>datab(11 downto 0));
	ram: lab05_ram port map(clka_i=>clk,wea_i=>'0',addra_i=>addra,
		dataa_i=>(others=>'0'),dataa_o=>dataa,clkb_i=>fclk,
		web_i=>...,addrb_i=>addrb,datab_i=>datab,datab_o=>open);

	datab(35 downto 12)<=(others=>'0');
end arch;