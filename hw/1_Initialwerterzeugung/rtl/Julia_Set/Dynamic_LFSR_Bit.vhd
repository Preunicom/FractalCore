----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/15/2026 18:20:00 AM
-- Design Name: 
-- Module Name: Dynamic_LFSR_Bit - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: One Bit in an LFSR - Configured with xor or direct input. Can also be loaded with a seed.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Dynamic_LFSR_Bit is
    port(
        i_clk : in std_logic;
        i_en : in std_logic;
        i_load_en : in std_logic;
        i_load_data : in std_logic;
        i_prev_data : in std_logic;
        i_use_xor : in std_logic;
        i_xor_data : in std_logic;
        o_data : out std_logic
    );
end Dynamic_LFSR_Bit;

architecture Behavioral of Dynamic_LFSR_Bit is
    signal w_input_data : std_logic := '1';
    signal w_xor : std_logic;
begin

    FLIPFLOP: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_en = '1' then
                o_data <= w_input_data;
            end if;
            if i_load_en = '1' then
                o_data <= i_load_data;
            end if;
        end if;
    end process;

    w_xor <= i_prev_data xor i_xor_data;
    w_input_data <= w_xor when i_use_xor = '1' else i_prev_data;

end Behavioral;