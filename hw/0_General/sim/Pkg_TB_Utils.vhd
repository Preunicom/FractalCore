----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Pkg_Core - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Provides an record of the PixelData
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

package Pkg_TB_Utils is

    procedure wait_for_handshake(
        signal i_clk : in std_logic;
        signal i_valid : in std_logic;
        signal i_ready : in std_logic
    );

    procedure wait_for_enabled_clock(
        signal i_clk : in std_logic;
        signal i_en : in std_logic
    );

    procedure wait_for_clock_cycles(
        signal i_clk : in std_logic;
        constant amount : in integer
    );

end package;

package body Pkg_TB_Utils is

    procedure wait_for_handshake(
        signal i_clk : in std_logic;
        signal i_valid : in std_logic;
        signal i_ready : in std_logic
    ) is
    begin
        loop
            wait until rising_edge(i_clk);
            if i_valid = '1' and i_ready = '1' then
                exit;
            end if;
        end loop;
    end procedure;

    procedure wait_for_enabled_clock(
        signal i_clk : in std_logic;
        signal i_en : in std_logic
    ) is
    begin
        loop
            wait until rising_edge(i_clk);
            if i_en = '1' then
                exit;
            end if;
        end loop;
    end procedure;

    procedure wait_for_clock_cycles(
        signal i_clk : in std_logic;
        constant amount : in integer
    ) is 
    begin
        for i in 0 to amount - 1 loop
            wait until rising_edge(i_clk);
        end loop;
    end procedure;

end Pkg_TB_Utils;