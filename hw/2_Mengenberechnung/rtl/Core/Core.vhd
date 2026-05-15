----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Core - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Calculation of the Mandelbrot set equation.
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

library work;
use work.Pkg_Core.all;

entity Core is
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        -- In
        i_pixel_data : in t_pixel_data;
        i_valid : in std_logic;
        o_ready : out std_logic;
        -- Out
        i_ready : in std_logic;
        o_valid : out std_logic;
        o_pixel_result : out t_pixel_result
    );
end Core;

architecture Behavioral of Core is
    -- STAGE 1 IN
    signal w_s1_in_stage_data : t_stage_data;
    -- STAGE 1 -> 2
    signal w_s2_in_stage_data : t_stage_data;
    signal w_zr_add_zi : signed(18 downto 0); -- 4.15
    signal w_zr_sub_zi : signed(18 downto 0); -- 4.15
    signal w_2zr_mul_zi : signed(36 downto 0); -- 7.30
    signal w_zr_mul_zr : signed(35 downto 0); -- 6.30
    signal w_zi_mul_zi : signed(35 downto 0); -- 6.30
    -- STAGE 2 -> 3
    signal w_s3_in_stage_data : t_stage_data;
    signal w_real_mul : signed(37 downto 0); -- 8.30
    signal w_img_res_long : signed(37 downto 0); -- 8.30
    signal w_res_magnitude : signed(36 downto 0); -- 7.30
    -- STAGE 3 OUT
    signal w_s3_out_stage_data : t_stage_data;

    -- LOAD
    signal r_loaded_data : t_pixel_data;
    signal r_s3_loaded_data : t_pixel_data;
    signal w_load_data_ready : std_logic;
    signal w_select_loaded_data : std_logic;
    signal r_s3_select_loaded_data : std_logic;

begin

    LOAD: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_loaded_data <= c_PIXEL_DATA_RESET;
                r_s3_loaded_data <= c_PIXEL_DATA_RESET;
                r_s3_select_loaded_data <= '0';
            else
                r_loaded_data <= i_pixel_data;
                -- Allign signal to the stages
                r_s3_loaded_data <= r_loaded_data;
                r_s3_select_loaded_data <= w_select_loaded_data;
            end if;
        end if;
    end process;

    w_s1_in_stage_data <= to_stage_data(r_s3_loaded_data) when r_s3_select_loaded_data = '1' else w_s3_out_stage_data;

    o_ready <= w_load_data_ready;

    CONTROL: entity work.Core_Control
    port map (
        i_resetn                  => i_resetn,
        i_clk                     => i_clk,
        i_magnitude               => w_res_magnitude,
        i_load_data_valid         => i_valid,
        i_transmit_partner_ready  => i_ready,
        o_transmit_data_valid     => o_valid,
        o_transmit_is_convergent  => o_pixel_result.is_convergent,
        o_transmit_iteration_data => o_pixel_result.cycles_until_divergent,
        o_load_data_ready         => w_load_data_ready,
        o_select_loaded_data      => w_select_loaded_data
    );

    STAGE_1: entity work.Core_Stage_1
    port map (
        i_resetn     => i_resetn,
        i_clk        => i_clk,
        i_stage_data => w_s1_in_stage_data,
        o_stage_data => w_s2_in_stage_data,
        o_zr_add_zi  => w_zr_add_zi,
        o_zr_sub_zi  => w_zr_sub_zi,
        o_2zr_mul_zi => w_2zr_mul_zi,
        o_zr_mul_zr  => w_zr_mul_zr,
        o_zi_mul_zi  => w_zi_mul_zi
    );

    STAGE_2: entity work.Core_Stage_2
    port map (
        i_resetn        => i_resetn,
        i_clk           => i_clk,
        i_stage_data    => w_s2_in_stage_data,
        i_zr_add_zi     => w_zr_add_zi,
        i_zr_sub_zi     => w_zr_sub_zi,
        i_2zr_mul_zi    => w_2zr_mul_zi,
        i_zr_mul_zr     => w_zr_mul_zr,
        i_zi_mul_zi     => w_zi_mul_zi,
        o_stage_data    => w_s3_in_stage_data,
        o_real_mul      => w_real_mul,
        o_img_res_long  => w_img_res_long,
        o_magnitude_res => w_res_magnitude
    );

    STAGE_3: entity work.Core_Stage_3
    port map (
        i_resetn       => i_resetn,
        i_clk          => i_clk,
        i_stage_data   => w_s3_in_stage_data,
        i_real_mul     => w_real_mul,
        i_img_res_long => w_img_res_long,
        o_stage_data   => w_s3_out_stage_data
    );

    o_pixel_result.video_frame_idx <= w_s3_out_stage_data.video_frame_idx;
    o_pixel_result.video_pix_col <= w_s3_out_stage_data.video_pix_col;
    o_pixel_result.video_pix_row <= w_s3_out_stage_data.video_pix_row;

end Behavioral;