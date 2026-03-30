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
        i_resetn : in std_logic;
        i_clk : in std_logic;
        -- Input
        i_valid : in std_logic;
        i_pixel_data : in t_pixel_data;
        o_ready : out std_logic;
        -- Output 1
        i_s1_ready : in std_logic;
        o_s1_valid : out std_logic;
        o_s1_pixel_data : out t_pixel_data;
        -- Output 2
        i_s2_ready : in std_logic;
        o_s2_valid : out std_logic;
        o_s2_pixel_data : out t_pixel_data
    );
end Dispatcher;

architecture Behavioral of Dispatcher is
    signal r_s1_saved_ready : std_logic;
    signal r_s2_saved_ready : std_logic;

    signal w_ready : std_logic;
    signal w_s1_ready : std_logic;
    signal w_s2_ready : std_logic;

    signal r_buf_s1_full : std_logic;
    signal r_buf_s1 : t_pixel_data;
    signal r_buf_s2_full : std_logic;
    signal r_buf_s2 : t_pixel_data;

    signal w_selected_s1 : std_logic;
begin

    REG: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_buf_s1_full <= '0';
                r_buf_s1 <= c_PIXEL_DATA_RESET;
                r_buf_s2_full <= '0';
                r_buf_s2 <= c_PIXEL_DATA_RESET;
            else
                -- Save ready until data was transmitted (because one Core slot givs an ready impuls only every 3 clock cylces)
                if i_s1_ready = '1' then
                    r_s1_saved_ready <= '1';
                end if;
                if i_s2_ready = '1' then
                    r_s2_saved_ready <= '1';
                end if;

                -- Reset buffer full flag
                if r_buf_s1_full = '1' and i_s1_ready = '1' then
                    -- buffer 1 was read
                    r_buf_s1_full <= '0';
                    r_s1_saved_ready <= '0';
                end if;
                if r_buf_s2_full = '1' and i_s2_ready = '1' then
                    -- buffer 2 was read
                    r_buf_s2_full <= '0';
                    r_s2_saved_ready <= '0';
                end if;
                
                -- Receive data in buffer
                -- Each Buffer can only be filled every 2 clock cycles, as we do not know if the slave wants one or more data packets
                -- If the slave wants one and we buffer one the data has to wait until the core is free (and this for every dispatcher we meet)
                -- This slows down the dispatch algorithm but garantees that lower pixel idx packages will be computed first
                if i_valid = '1' and w_ready = '1' then
                    if w_selected_s1 = '1' then
                        -- Load buffer 1
                        r_buf_s1_full <= '1';
                        r_buf_s1 <= i_pixel_data;
                    elsif w_selected_s1 = '0' then
                        -- Load buffer 2
                        r_buf_s2_full <= '1';
                        r_buf_s2 <= i_pixel_data;
                    end if;
                end if;

            end if;
        end if;
    end process;

    w_s1_ready  <= (r_s1_saved_ready or i_s1_ready) and not r_buf_s1_full;
    w_s2_ready  <= (r_s2_saved_ready or i_s2_ready) and not r_buf_s2_full;
    w_ready <= w_s1_ready or w_s2_ready;
    o_ready <= w_ready;

    w_selected_s1 <= '1' when w_s1_ready = '1' else '0'; 

    o_s1_valid <= r_buf_s1_full;
    o_s1_pixel_data <= r_buf_s1;
    o_s2_valid <= r_buf_s2_full;
    o_s2_pixel_data <= r_buf_s2;
   
end Behavioral;