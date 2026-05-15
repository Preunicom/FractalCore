----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/27/2026 13:20:00 PM
-- Design Name: 
-- Module Name: Pkg_Utils - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Provides utility functions and types for mutliple parts of FractalCore.
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
use ieee.numeric_std.all;

package Pkg_Utils is

    type t_highlight_pixel is record
        valid : std_logic;
        current_pixel_col : std_logic_vector(9 downto 0);
        current_pixel_row : std_logic_vector(8 downto 0);
        target_pixel_col : std_logic_vector(9 downto 0);
        target_pixel_row : std_logic_vector(8 downto 0);
    end record;

    constant c_HIGHLIGHT_PIXEL_RESET : t_highlight_pixel := (
        -- Set valid to invalid and set pixel to highest pixel, so it won't trigger something too early if both values are set valid when one is still invalid.
        -- This works as both pixels or no pixel have to be found.
        valid => '0',
        current_pixel_col => (others => '1'),
        current_pixel_row => (others => '1'),
        target_pixel_col => (others => '1'),
        target_pixel_row => (others => '1')
    );

    type t_highlight_info is array (0 to 3) of t_highlight_pixel;

end package;

package body Pkg_Utils is

end Pkg_Utils;