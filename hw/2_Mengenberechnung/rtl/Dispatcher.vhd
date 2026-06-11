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
    component Skid_Buffer is
        generic(
            g_DATA_WIDTH : natural 
        );
        port(
            i_resetn : in std_logic;
            i_clk : in std_logic;
            -- Input
            i_valid : in std_logic;
            i_data : in std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            o_ready : out std_logic;
            -- Output 1
            i_ready : in std_logic;
            o_valid : out std_logic;
            o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- Skid buffer
    signal w_skid_buf_inp_pixel_data: std_logic_vector(92 downto 0);
    signal w_skid_buf_out_pixel_data : std_logic_vector(92 downto 0);
    
    -- Dispatch
    signal w_buf_out_ready : std_logic;
    signal w_buf_out_valid : std_logic;
    signal r_s1_selected : std_logic;

    -- Helper signals
    signal w_handshake_s1 : std_logic;
    signal w_handshake_s2 : std_logic;
begin

    w_skid_buf_inp_pixel_data <= to_std_logic_vector(i_pixel_data);

    INP_SKID_BUF: Skid_Buffer
    generic map (
        g_DATA_WIDTH => 93
    )
    port map (
        i_resetn => i_resetn,
        i_clk    => i_clk,
        i_valid  => i_valid,
        i_data   => w_skid_buf_inp_pixel_data,
        o_ready  => o_ready,
        i_ready  => w_buf_out_ready,
        o_valid  => w_buf_out_valid,
        o_data   => w_skid_buf_out_pixel_data
    );

    w_handshake_s1 <= w_buf_out_valid and i_s1_ready;
    w_handshake_s2 <= w_buf_out_valid and i_s2_ready;

    SWITCH_REG: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_s1_selected <= '1';
            else
                if w_buf_out_valid = '1' then
                    if r_s1_selected = '1' and i_s1_ready = '1' then
                        -- Was successfully transmitted to s1
                        r_s1_selected <= '0';
                    elsif r_s1_selected = '0' and i_s2_ready = '1' then
                        -- Was successfully transmitted to s2
                        r_s1_selected <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    SWITCH_LOGIC: process(w_handshake_s1, w_handshake_s2, r_s1_selected, w_buf_out_valid, i_s1_ready, i_s2_ready)
	begin
        o_s1_valid <= '0';
        o_s2_valid <= '0';
        w_buf_out_ready <= '0';
        if w_handshake_s1 = '1' and w_handshake_s2 = '1' then
            -- Both ready, take planned signal
            if r_s1_selected = '1' then
                -- Take s1
                o_s1_valid <= w_buf_out_valid;
                w_buf_out_ready <= i_s1_ready;
            else
                -- Take s2
                o_s2_valid <= w_buf_out_valid;
                w_buf_out_ready <= i_s2_ready;
            end if;
        elsif w_handshake_s2 = '1' then
            -- Only s2 ready, take s2
            o_s2_valid <= w_buf_out_valid;
            w_buf_out_ready <= i_s2_ready;
        else
            -- Nobody or s1 ready, take s1
            o_s1_valid <= w_buf_out_valid;
            w_buf_out_ready <= i_s1_ready;
        end if;
    end process;

    o_s1_pixel_data <= to_pixel_data(w_skid_buf_out_pixel_data);
    o_s2_pixel_data <= to_pixel_data(w_skid_buf_out_pixel_data);
   
end Behavioral;