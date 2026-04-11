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

    signal w_m1_buf_ready : std_logic;
    signal w_m1_buf_valid : std_logic;
    signal w_m1_buf_data : std_logic_vector(29 downto 0);
    signal w_m1_buf_pixel_result : t_pixel_result;

    signal w_m2_buf_ready : std_logic;
    signal w_m2_buf_valid : std_logic;
    signal w_m2_buf_data : std_logic_vector(29 downto 0);
    signal w_m2_buf_pixel_result : t_pixel_result;

    signal w_m1_prio : std_logic_vector(20 downto 0);
    signal w_m2_prio : std_logic_vector(20 downto 0);
    signal w_selected_m1 : std_logic;
begin

    M1_INP_SKID_BUF: Skid_Buffer
    generic map (
        g_DATA_WIDTH => 30
    )
    port map (
        i_resetn => i_resetn,
        i_clk    => i_clk,
        i_valid  => i_m1_valid,
        i_data   => to_std_logic_vector(i_m1_pixel_result),
        o_ready  => o_m1_ready,
        i_ready  => w_m1_buf_ready,
        o_valid  => w_m1_buf_valid,
        o_data   => w_m1_buf_data
    );
    w_m1_buf_pixel_result <= to_pixel_result(w_m1_buf_data);

    M2_INP_SKID_BUF: Skid_Buffer
    generic map (
        g_DATA_WIDTH => 30
    )
    port map (
        i_resetn => i_resetn,
        i_clk    => i_clk,
        i_valid  => i_m2_valid,
        i_data   => to_std_logic_vector(i_m2_pixel_result),
        o_ready  => o_m2_ready,
        i_ready  => w_m2_buf_ready,
        o_valid  => w_m2_buf_valid,
        o_data   => w_m2_buf_data
    );
    w_m2_buf_pixel_result <= to_pixel_result(w_m2_buf_data);

    -- CONTROL PATH

    w_m1_prio <= w_m1_buf_pixel_result.video_frame_idx & w_m1_buf_pixel_result.video_pix_row & w_m1_buf_pixel_result.video_pix_col;
    w_m2_prio <= w_m2_buf_pixel_result.video_frame_idx & w_m2_buf_pixel_result.video_pix_row & w_m2_buf_pixel_result.video_pix_col;

    ARBIT: process(w_m1_buf_valid, w_m2_buf_valid, w_m1_prio, w_m2_prio, w_m1_buf_pixel_result.video_frame_idx, w_m2_buf_pixel_result.video_frame_idx)
	begin
        w_selected_m1 <= '1';
        if w_m1_buf_valid = '1' and w_m2_buf_valid = '0' then
            w_selected_m1 <= '1';
        elsif w_m1_buf_valid = '0' and w_m2_buf_valid = '1' then
            w_selected_m1 <= '0';
        else
            -- Both valid
            if (w_m1_prio < w_m2_prio or (w_m1_buf_pixel_result.video_frame_idx = "11" and w_m2_buf_pixel_result.video_frame_idx = "00"))
            and not (w_m1_buf_pixel_result.video_frame_idx = "00" and w_m2_buf_pixel_result.video_frame_idx = "11") then -- Overflow in frame
                -- m1 has lower prio index --> m1 is more important
                w_selected_m1 <= '1';
            else
                -- m2 has lower prio index --> m2 is more important
                w_selected_m1 <= '0';
            end if;
        end if;
    end process;

    -- DATAPATH

    w_m1_buf_ready <= i_ready when w_selected_m1 = '1' else '0';
    w_m2_buf_ready <= i_ready when w_selected_m1 = '0' else '0';
    o_valid <= w_m1_buf_valid when w_selected_m1 = '1' else w_m2_buf_valid;
    o_pixel_result <= w_m1_buf_pixel_result when w_selected_m1 = '1' else w_m2_buf_pixel_result;
   
end Behavioral;