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

package Pkg_Core is

    type t_pixel_data is record
        video_pix_col :     std_logic_vector(9 downto 0);
        video_pix_row :     std_logic_vector(8 downto 0);
        video_frame_idx :   std_logic_vector(1 downto 0);
        z_real :            std_logic_vector(17 downto 0);
        z_img :             std_logic_vector(17 downto 0);
        c_real :            std_logic_vector(17 downto 0);
        c_img :             std_logic_vector(17 downto 0);
    end record;

    constant c_PIXEL_DATA_RESET : t_pixel_data := (
        video_pix_col => (others => '0'),
        video_pix_row => (others => '0'),
        video_frame_idx => (others => '0'),
        z_real => (others => '0'),
        z_img => (others => '0'),
        c_real => (others => '0'),
        c_img => (others => '0')
    );

    type t_pixel_result is record
        video_pix_col :             std_logic_vector(9 downto 0);
        video_pix_row :             std_logic_vector(8 downto 0);
        video_frame_idx :           std_logic_vector(1 downto 0);
        is_convergent :             std_logic;
        cycles_until_divergent :  std_logic_vector(7 downto 0);
    end record;

    constant c_PIXEL_RESULT_RESET : t_pixel_result := (
        video_pix_col => (others => '0'),
        video_pix_row => (others => '0'),
        video_frame_idx => (others => '0'),
        is_convergent => '0',
        cycles_until_divergent => (others => '0')
    );

    type t_stage_data is record
        video_pix_col :     std_logic_vector(9 downto 0);
        video_pix_row :     std_logic_vector(8 downto 0);
        video_frame_idx :   std_logic_vector(1 downto 0);
        z_real :            signed(17 downto 0);
        z_img :             signed(17 downto 0);
        c_real :            signed(17 downto 0);
        c_img :             signed(17 downto 0);
    end record;

    constant c_STAGE_DATA_RESET : t_stage_data := (
        video_pix_col => (others => '0'),
        video_pix_row => (others => '0'),
        video_frame_idx => (others => '0'),
        z_real => to_signed(0, 18),
        z_img => to_signed(0, 18),
        c_real => to_signed(0, 18),
        c_img => to_signed(0, 18)
    );

    type t_stage_control is record
        valid :             std_logic;
        ready :             std_logic;
        iteration_counter : integer;
    end record;

    constant c_STAGE_CONTROL_RESET : t_stage_control := (
        valid => '0',
        ready => '0',
        iteration_counter => 0
    );

    function to_stage_data(
        i_pixel_data : t_pixel_data
    ) return t_stage_data;

    function to_pixel_data(
        i_stage_data : t_stage_data
    ) return t_pixel_data;

    function to_std_logic_vector(
        i_data : t_pixel_data
    ) return std_logic_vector;

    function to_pixel_data(
        i_data : std_logic_vector(92 downto 0)
    ) return t_pixel_data;

    function to_std_logic_vector(
        i_data : t_pixel_result
    ) return std_logic_vector;

    function to_pixel_result(
        i_data : std_logic_vector(29 downto 0)
    ) return t_pixel_result;

end package;

package body Pkg_Core is

    function to_stage_data(
        i_pixel_data : t_pixel_data
    ) return t_stage_data is
        variable casted_data : t_stage_data;
    begin
        casted_data.video_pix_col   := i_pixel_data.video_pix_col;
        casted_data.video_pix_row   := i_pixel_data.video_pix_row;
        casted_data.video_frame_idx := i_pixel_data.video_frame_idx;
        casted_data.z_real          := signed(i_pixel_data.z_real);
        casted_data.z_img           := signed(i_pixel_data.z_img);
        casted_data.c_real          := signed(i_pixel_data.c_real);
        casted_data.c_img           := signed(i_pixel_data.c_img);
        return casted_data;
    end function;

    function to_pixel_data(
        i_stage_data : t_stage_data
    ) return t_pixel_data is
        variable casted_data : t_pixel_data;
    begin
        casted_data.video_pix_col   := i_stage_data.video_pix_col;
        casted_data.video_pix_row   := i_stage_data.video_pix_row;
        casted_data.video_frame_idx := i_stage_data.video_frame_idx;
        casted_data.z_real          := std_logic_vector(i_stage_data.z_real);
        casted_data.z_img           := std_logic_vector(i_stage_data.z_img);
        casted_data.c_real          := std_logic_vector(i_stage_data.c_real);
        casted_data.c_img           := std_logic_vector(i_stage_data.c_img);
        return casted_data;
    end function;

    function to_std_logic_vector(
        i_data : t_pixel_data
    ) return std_logic_vector is
        variable result : std_logic_vector(92 downto 0);
    begin
        result(92 downto 91) := i_data.video_frame_idx; -- 2 Bit
        result(90 downto 81) := i_data.video_pix_col;   -- 10 Bit
        result(80 downto 72) := i_data.video_pix_row;   -- 9 Bit
        result(71 downto 54) := i_data.z_real;          -- 18 Bit
        result(53 downto 36) := i_data.z_img;           -- 18 Bit
        result(35 downto 18) := i_data.c_real;          -- 18 Bit
        result(17 downto 0)  := i_data.c_img;           -- 18 Bit
        return result;
    end function;

    function to_pixel_data(
        i_data : std_logic_vector(92 downto 0)
    ) return t_pixel_data is
        variable result : t_pixel_data;
    begin
        result.video_frame_idx  := i_data(92 downto 91); -- 2 Bit
        result.video_pix_col    := i_data(90 downto 81); -- 10 Bit
        result.video_pix_row    := i_data(80 downto 72); -- 9 Bit
        result.z_real           := i_data(71 downto 54); -- 18 Bit
        result.z_img            := i_data(53 downto 36); -- 18 Bit
        result.c_real           := i_data(35 downto 18); -- 18 Bit
        result.c_img            := i_data(17 downto 0);  -- 18 Bit
        return result;
    end function;

     function to_std_logic_vector(
        i_data : t_pixel_result
    ) return std_logic_vector is
        variable result : std_logic_vector(29 downto 0);
    begin
        result(29 downto 28) := i_data.video_frame_idx;
        result(27 downto 18) := i_data.video_pix_col;
        result(17 downto 9) := i_data.video_pix_row;
        result(8) := i_data.is_convergent;
        result(7 downto 0) := i_data.cycles_until_divergent;
        return result;
    end function;

    function to_pixel_result(
        i_data : std_logic_vector(29 downto 0)
    ) return t_pixel_result is
        variable result : t_pixel_result;
    begin
        result.video_frame_idx := i_data(29 downto 28);
        result.video_pix_col := i_data(27 downto 18);
        result.video_pix_row := i_data(17 downto 9);
        result.is_convergent := i_data(8);
        result.cycles_until_divergent := i_data(7 downto 0);
        return result;
    end function;

end Pkg_Core;