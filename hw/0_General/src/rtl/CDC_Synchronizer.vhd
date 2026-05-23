----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/11/2026 15:02:00 PM
-- Design Name: 
-- Module Name: CDC_Synchronizer - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Synchronizes the input data from the input clock domain to the output of the output clock domain with two Flip Flops in the output domain.
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

entity CDC_Synchronizer is
    port(
        i_data : in std_logic;
        i_clk_out : in std_logic;
        o_data : out std_logic
    );
end CDC_Synchronizer;

architecture Behavioral of CDC_Synchronizer is
    signal buf : std_logic;
begin

    CDC_CROSS: process(i_clk_out)
	begin
        if rising_edge(i_clk_out) then
            buf <= i_data;
            o_data <= buf;
        end if;
    end process;

end Behavioral;