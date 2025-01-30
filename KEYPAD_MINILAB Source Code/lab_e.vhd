library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_e is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		key: inout std_logic_vector(7 downto 1)
	);
end lab_e;

architecture arch of lab_e is

	constant cnt_max: integer:=120;
	constant cnt_len: integer:=7;

	component lab_e_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic;
			data_i: in  std_logic_vector(11 downto 0)
		);
	end component;
	signal data:    std_logic_vector(11 downto 0);
	
	
	-- FSM typedef
	type FSM_type1 is (Precharge, Drive, Read);
	signal FSM: FSM_type1 := Precharge;
	
	signal key1: std_logic_vector(7 downto 1);
	signal key2: std_logic_vector(7 downto 1);
	signal key_stable: std_logic_vector(7 downto 1);
	
	signal cnt: unsigned(cnt_len-1 downto 0):=to_unsigned(0,cnt_len);	
begin
	gui: lab_e_gui port map(clk=>clk,rx=>rx,tx=>tx,data_i=>data);
	
	
	-- METASTABILITY SYNCHRONIZER
	process(clk)
	begin
	if rising_edge(clk) then
	   key1 <= key;
	   key2 <= key1;
	   key_stable <= key2;
	end if;
	end process;
	

    
    -- STATE MACHINE: PRECHARGE -> DRIVE -> READ  (LOOP)
    process(clk)
        variable index_int: integer:=4;
    begin
    if(rising_edge(clk)) then
       
       case FSM is
       
       --In precharge we:
       -- 1. Set key(3 downto 1) to '1'.
       -- 2. Set horizontal wires key(7 downto 4) as Z
       -- 3. Wait for some time (10 us)
       -- 4. Go to Drive
        when precharge =>
            -- set key(3-1) to '1'
            key(3 downto 1) <= b"111";          
            
            -- set key(7-4) to 'Z'
            for i in 7 downto 4 loop                
                key(i) <= 'Z';
            end loop; 
            
            -- wait for some time (10us) - then go to Drive
            if(cnt = cnt_max) then
                FSM <= Drive;
                cnt <= to_unsigned(0,cnt_len);
            else
                FSM <= precharge;
                cnt <= cnt+1;
            end if;
        
        --In Drive we:
        -- 1. Set key(3 downto 1) as undriven (Z)
        -- 2. Drive key(horiz_index) to 0
        -- 3. Wait for some time (10 us)
        -- 4. Go to Read
        when Drive =>            
            -- set keys to 'Z'
            for i in 7 downto 1 loop                
                key(i) <= 'Z';
            end loop;   
            -- Set key(horiz_index) to '0';
            key(index_int) <= '0';    
            
            --wait for some time (10us), then go to Read
            if(cnt = cnt_max) then
                FSM <= Read;
                cnt <= to_unsigned(0,cnt_len);
            else
                FSM <= Drive;
                cnt <= cnt+1;
            end if;
        
        --In Read we:
        -- 1. Check if any key(3 downto 0) are low (0).
        -- 2. If key low then set the according output high. Else set according output low. (data)
        -- 3. Increment/roll over horiz_index
        -- 4. Go back to precharge. 
        when Read =>        
          
            --wait for the input to be present after metastability synchronizer
            --(Need to be in Read for 3 clock cycles)
            if(cnt = 2) then
            
                FSM <= precharge;
                cnt <= to_unsigned(0,cnt_len);

                -- Set data according to index_int and value read at key_stable(3-1). 
                if(index_int = 4) then
                    for i in 2 downto 0 loop
                        if(key_stable(i+1) = '0') then
                            data(i) <= '1';
                        else
                            data(i) <= '0';     
                        end if;
                    end loop;
                elsif(index_int = 5) then
                    for i in 2 downto 0 loop
                        if(key_stable(i+1) = '0') then
                            data(i+3) <= '1';
                        else
                            data(i+3) <= '0';     
                        end if;
                    end loop;
                
                elsif(index_int = 6) then
                    for i in 2 downto 0 loop
                        if(key_stable(i+1) = '0') then
                            data(i+6) <= '1';
                        else
                            data(i+6) <= '0'; 
                        end if;
                    end loop;
                
                else -- (index_int = 7)
                    
                    for i in 2 downto 0 loop
                        if(key_stable(i+1) = '0') then
                            data(i+9) <= '1';
                        else
                            data(i+9) <= '0'; 
                        end if;
                    end loop;
                    
                end if;
                
                
                if( index_int = 7 ) then
                    index_int := 4;
                else
                    index_int := index_int + 1;
                end if;
            else
                FSM <= Read;
                cnt <= cnt+1;
            end if;
        
         when others =>
            null;
            
         end case;       
    end if;
    
    end process;

end arch;