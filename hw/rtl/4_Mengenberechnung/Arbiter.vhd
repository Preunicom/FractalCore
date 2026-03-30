----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/29/2026 8:09:00 AM
-- Design Name: 
-- Module Name: Arbiter - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Arbites two input to one output based on the lower pixel.
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

library work;
use work.Pkg_Core.all;

entity Arbiter is
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        -- Input 1
        i_m1_valid : in std_logic;
        o_m1_ready : out std_logic;
        i_m1_pixel_result : in t_pixel_result;
        -- Input 2
        i_m2_valid : in std_logic;
        o_m2_ready : out std_logic;
        i_m2_pixel_result : in t_pixel_result;
        -- Output
        i_ready : in std_logic;
        o_valid : out std_logic;
        o_pixel_result : out t_pixel_result
    );
end Arbiter;

architecture Behavioral of Arbiter is
    signal w_m1_ready : std_logic;
    signal w_m2_ready : std_logic;
    signal r_last_handshake_was_m1 : std_logic;
begin

    CONTROL: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_last_handshake_was_m1 <= '0';
            else
                if i_m1_valid = '1' and w_m1_ready = '1' then
                    r_last_handshake_was_m1 <= '1';
                elsif i_m2_valid = '1' and w_m2_ready = '1' then
                    r_last_handshake_was_m1 <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Valid if one of both partners is valid
    o_valid <= i_m1_valid or i_m2_valid;
    
    ARBIT: process(i_m1_valid, i_m2_valid, i_ready, i_m1_pixel_result, i_m2_pixel_result, r_last_handshake_was_m1)
	begin
        w_m1_ready <= '0';
        w_m2_ready <= '0';
        o_pixel_result <= i_m2_pixel_result;
        if i_m1_valid = '1' and i_m2_valid = '0' then
            w_m1_ready <= i_ready;
            o_pixel_result <= i_m1_pixel_result;
        elsif i_m1_valid = '0' and i_m2_valid = '1' then
            w_m2_ready <= i_ready;
            o_pixel_result <= i_m2_pixel_result;
        else
            -- Both valid
            if r_last_handshake_was_m1 = '1' then
                -- Last time was m1 --> This time m2
                w_m2_ready <= i_ready;
                o_pixel_result <= i_m2_pixel_result;
            else
                -- Last time was m2 --> This time m1
                w_m1_ready <= i_ready;
                o_pixel_result <= i_m1_pixel_result;
            end if;
        end if;
    end process;

    o_m1_ready <= w_m1_ready;
    o_m2_ready <= w_m2_ready;
   
end Behavioral;