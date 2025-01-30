--------------------------------------------------------------------------
-- Company: //
-- Engineer: Alexander Wang Aakersø
--
-- Create Date: 09/24/2024
-- Design Name: Generic Accumulator
-- Module Name: gen_accu
-- Project Name: lab03
-- Target Devices: Basys Board 3
-- FPGA: XC7A35T-1CPG236C. 100MHz clock. 
-- Tool versions: Vivado 2024.1.1
-- Description:
-- Module serves as a generic accumulator/counter.
-- Features include specifying beginning and end count,
-- setting power-on reset value, setting increment value,
-- and parallel loading of new count.
--
-- Dependencies:
-- IEEE library, IEEE.std_logic_1164.all, IEEE.numeric_std.all
-- No user specified components/modules used.
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Module not able to function properly if any of the 
-- following conditions are met:
-- If beg_i set to be greater than end_i.
-- If INITC not in range (beg_i, end_i)
-- If count_i not in range (beg_i, end_i)
-- If inc_i greater than double the range/base of accu
-- If inc_i is not a positive integer value.
-- (inc_i is std_logic_vec -> we convert to unsigned so...
-- .. user should not expect counter to do as expected if..
-- .. incr input value meant as negative).
-- It is therefore up to the instantiator to ensure
-- that these conditions are avoided. 
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gen_accu is
	generic(
		NBITS: natural:=4;-- Counter size
		INITC: natural:=0 -- Power-on reset
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
		count_o: out std_logic_vector(NBITS-1 downto 0) -- Count out
		          := std_logic_vector(to_unsigned(INITC, NBITS)); 
		carry_o: out std_logic := '0'  -- Carry-out for cascading
	);
end gen_accu;

architecture arch of gen_accu is
-- Internal signals - count initialized to INITC
-- Other signals initialized to zeros
signal beg_U, end_U, inc_U : unsigned(NBITS-1 downto 0);
signal carry_iU : unsigned(NBITS-1 downto 0) := (others=>'0');
signal count_next : unsigned(NBITS-1 downto 0) := (others=>'0');
signal count : unsigned(NBITS-1 downto 0):= to_unsigned(INITC, NBITS);
signal carry_o_sig : std_logic := '0';

begin
    --Signals for simplifying comparisons later using unsigned
    beg_U <= unsigned(beg_i); 
    end_U <= unsigned(end_i);
    inc_U <= unsigned(inc_i);
    --insert carry_i as LSB of extended carry_IU
    carry_iU(carry_iU'low) <= carry_i; 
    
    -- Two segment process used
    -- First process handles combinatorial logic
    process(count, inc_U, end_U, beg_U, carry_iU, load_i)
    begin
        if (load_i = '1') then
            count_next <= unsigned(count_i);
            carry_o_sig <= '0';
        else
            if(("0"&count)+("0"&inc_U)+("0"&carry_iU)>("0"&end_U)) then
                -- Overflow occured -> carry_o high, roll over count
                count_next <= (count+inc_U+carry_iU)-(end_U-beg_U+1);
                carry_o_sig <= '1';
            else -- no overflow -> compute next count. Set carry_o low.
                count_next <= count + inc_U + carry_iU;
                carry_o_sig <= '0';
            end if;
        end if;
    end process;
    -- Second process handles clock and asynchronous reset
    process(clock_i, reset_i)
    begin
        if reset_i = '1' then 
            --asynchronous reset. Set count to INITC
            count <= to_unsigned(INITC, NBITS);
        elsif rising_edge(clock_i) then
            -- set count to equal count_next
            count <= count_next;    
        end if;
    end process;
    -- Output assignments:
    -- cast unsigned to std_logic_vector
    count_o <= std_logic_vector(count);
    -- carry_o should only be 1 when carry_o_sig and not reset
    carry_o <= carry_o_sig and not reset_i;
end arch;