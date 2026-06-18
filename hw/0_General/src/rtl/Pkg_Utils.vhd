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
-- Description: Provides utility functions and types for multiple parts of FractalCore.
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

    function to_std_logic_vector(
        i_data : t_highlight_pixel
    ) return std_logic_vector;

    function to_highlight_pixel(
        i_data : std_logic_vector(38 downto 0)
    ) return t_highlight_pixel;

end package;

package body Pkg_Utils is

    function to_std_logic_vector(
        i_data : t_highlight_pixel
    ) return std_logic_vector is
        variable result : std_logic_vector(38 downto 0);
    begin
        result(38 downto 30) := i_data.target_pixel_row;    -- 9 Bit
        result(29 downto 20) := i_data.target_pixel_col;    -- 10 Bit
        result(19 downto 11) := i_data.current_pixel_row;   -- 9 Bit
        result(10 downto 1) := i_data.current_pixel_col;    -- 10 Bit
        result(0)  := i_data.valid;                         -- 1 Bit
        return result;
    end function;
    
    function to_highlight_pixel(
        i_data : std_logic_vector(38 downto 0)
    ) return t_highlight_pixel is
        variable result : t_highlight_pixel;
    begin
        result.target_pixel_row     := i_data(38 downto 30);    -- 9 Bit
        result.target_pixel_col     := i_data(29 downto 20);    -- 10 Bit
        result.current_pixel_row    := i_data(19 downto 11);    -- 9 Bit
        result.current_pixel_col    := i_data(10 downto 1);     -- 10 Bit
        result.valid                := i_data(0);               -- 1 Bit
        return result;
    end function;

end Pkg_Utils;