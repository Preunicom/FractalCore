----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:30:00 PM
-- Design Name: 
-- Module Name: Dispatcher - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Dispatches one input to two outputs.
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

library work;
use work.Pkg_Core.all;

entity Dispatcher is
    port(
        -- Input
        i_valid : in std_logic;
        i_pixel_data : in t_pixel_data;
        o_ready : out std_logic;
        -- Output 1
        i_s1_ready : in std_logic;
        o_s1_valid : out std_logic;
        -- Output 2
        i_s2_ready : in std_logic;
        o_s2_valid : out std_logic;
        -- Both Outputs
        o_pixel_data : out t_pixel_data
    );
end Dispatcher;

architecture Behavioral of Dispatcher is
begin

    -- Ready if one of both partners is ready
    o_ready <= i_s1_ready or i_s2_ready;
    o_pixel_data <= i_pixel_data;
    
    VALID: process(i_s1_ready, i_s2_ready, i_valid)
	begin
        o_s1_valid <= '0';
        o_s2_valid <= '0';
        if i_valid = '1' then
            if i_s2_ready = '1' and i_s1_ready = '0' then
                o_s2_valid <= '1';
            else 
                o_s1_valid <= '1';
            end if;
        end if;
    end process;
   
end Behavioral;