library IEEE;
use IEEE.std_logic_1164.all;

entity lab02d is
	port(
		clk: in  std_logic;
		btn: in  std_logic_vector(1 downto 0);
		led: out std_logic_vector(4 downto 0)
	);
end lab02d;

architecture arch of lab02d is
	component bcounter
		generic(
			NBITS: natural
		);
		port(
			clk:  in  std_logic; -- Clock input
			rst:  in  std_logic; -- Asynchronouse reset
			cin:  in  std_logic; -- Carry-in and run control
			cout: out std_logic; -- Carry-out for cascading
			bits: out std_logic_vector(NBITS-1 downto 0)
		);
	end component;
	component mSync
	   Port(
	       I, C, R: in std_logic;
           O: out std_logic
	   );
	end component;
	component Cin
	   Port (
          I, C, R: in std_logic;
          C_in: out std_logic
        );
    end component;
    
	signal bits: std_logic_vector(28 downto 0);
	signal internal: std_logic_vector(1 downto 0);
begin
    
    mSync1: mSync port map(I=>btn(0), C=>clk, R=>btn(1), O=>internal(0));
    Cin1: Cin port map(I=>internal(0), C=>clk, R=>btn(1), C_in=>internal(1));
	counter: bcounter generic map(NBITS=>bits'high-bits'low+1)
		port map(clk=>clk,rst=>btn(1),cin=>internal(1),cout=>open,bits=>bits);

	led<=bits(bits'high downto bits'high-4);
end arch;