----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/18/2026 11:26:00 PM
-- Design Name: 
-- Module Name: Pkg_VGA - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Constants for the VGA visualization
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Pkg_VGA is

    -- Source for timing:
    -- https://digilent.com/reference/learn/programmable-logic/tutorials/vga-display-congroller/start

    -- COLS
    constant c_COLS             : integer := 640; 
    constant c_COLS_BACKPORCH   : integer := 48; 
    constant c_COLS_SYNCTIME    : integer := 96;
    constant c_COLS_FRONTPORCH  : integer := 16;
    constant c_COLS_SUM         : integer := c_COLS + c_COLS_BACKPORCH + c_COLS_SYNCTIME + c_COLS_FRONTPORCH; -- 800

    constant c_COLS_BUS_WIDTH   : integer := 10; -- = ceil(ln2(c_COLS_SUM)) = 10

    -- ROWS
    constant c_ROWS             : integer := 480; 
    constant c_ROWS_BACKPORCH   : integer := 33; 
    constant c_ROWS_SYNCTIME    : integer := 2;
    constant c_ROWS_FRONTPORCH  : integer := 10;
    constant c_ROWS_SUM         : integer := c_ROWS + c_ROWS_BACKPORCH + c_ROWS_SYNCTIME + c_ROWS_FRONTPORCH; -- 525

    constant c_ROWS_BUS_WIDTH   : integer := 10; -- = ceil(ln2(c_ROWS_SUM)) = 10
 
end Pkg_VGA;


package body Pkg_VGA is

end Pkg_VGA;
