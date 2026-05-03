----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/02/2026 06:29:00 AM
-- Design Name: 
-- Module Name: TB_Start_Value_Mapping - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the start value mapping.
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
use std.env.finish;

library work;
use work.Pkg_TB_Utils.all;

entity TB_Start_Value_Mapping is
end TB_Start_Value_Mapping;

architecture Testbench of TB_Start_Value_Mapping is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn              : std_logic;
    signal s_clk                 : std_logic := '0';
    signal s_fetch_next          : std_logic;
    signal s_valid               : std_logic;
    signal s_frame_idx           : std_logic_vector(1 downto 0);
    signal s_pixel_col           : std_logic_vector(9 downto 0);
    signal s_pixel_row           : std_logic_vector(8 downto 0);
    signal s_pixel_coord_re      : std_logic_vector(17 downto 0);
    signal s_pixel_coord_im      : std_logic_vector(17 downto 0);
    signal s_is_in_minimap       : std_logic;
    signal s_pixel_distance      : std_logic_vector(7 downto 0);
    signal s_frames_per_step     : std_logic_vector(15 downto 0);
    signal s_step_width          : std_logic_vector(16 downto 0);
    signal s_mode                : std_logic_vector(1 downto 0);
    signal s_load_seed           : std_logic;
    signal s_lfsr_seed_re        : std_logic_vector(17 downto 0);
    signal s_lfsr_seed_im        : std_logic_vector(17 downto 0);
    signal s_lfsr_xor_mask_re    : std_logic_vector(16 downto 0);
    signal s_lfsr_xor_mask_im    : std_logic_vector(16 downto 0);
    signal s_diamond_heigh       : std_logic_vector(16 downto 0);
    signal s_diamond_width       : std_logic_vector(16 downto 0);

    -- CHECK
    signal c_valid : std_logic;
    signal c_frame_idx : std_logic_vector(1 downto 0);
    signal c_pixel_col : std_logic_vector(9 downto 0);
    signal c_pixel_row : std_logic_vector(8 downto 0);
    signal c_pixel_coord_z0_re : std_logic_vector(17 downto 0);
    signal c_pixel_coord_z0_im : std_logic_vector(17 downto 0);
    signal c_pixel_coord_c_re : std_logic_vector(17 downto 0);
    signal c_pixel_coord_c_im : std_logic_vector(17 downto 0);
    signal c_c_coord_re : std_logic_vector(17 downto 0);
    signal c_c_coord_im : std_logic_vector(17 downto 0);
    signal c_c_target_re : std_logic_vector(17 downto 0);
    signal c_c_target_im : std_logic_vector(17 downto 0);
    signal c_is_in_minimap : std_logic;
    signal c_pixel_distance : std_logic_vector(7 downto 0);

    signal tb_current_test_step : integer;
    signal tb_test_clock_en : std_logic;

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

    procedure check_data(
        constant i_exp_frame_idx        : in std_logic_vector(1 downto 0);
        constant i_exp_pixel_col        : in integer;
        constant i_exp_pixel_row        : in integer;
        constant i_exp_pixel_coord_z0_re: in integer;
        constant i_exp_pixel_coord_z0_im: in integer;
        constant i_exp_pixel_coord_c_re : in integer;
        constant i_exp_pixel_coord_c_im : in integer;
        constant i_exp_c_coord_re       : in integer;
        constant i_exp_c_coord_im       : in integer;
        constant i_exp_c_target_re      : in integer;
        constant i_exp_c_target_im      : in integer;
        constant i_exp_is_in_minimap    : in std_logic;
        constant i_exp_pixel_distance   : in integer;
        constant debug_info             : in string
    ) is 
    begin
        assert c_frame_idx = i_exp_frame_idx
            report "Wrong frame idx!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_frame_idx) & LF &
                "Got:  " & to_string(c_frame_idx)
            severity failure;
        assert to_integer(unsigned(c_pixel_col)) = i_exp_pixel_col
            report "Wrong pixel column!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_col) & LF &
                "Got:  " & to_string(to_integer(unsigned(c_pixel_col)))
            severity failure;
        assert to_integer(unsigned(c_pixel_row)) = i_exp_pixel_row
            report "Wrong pixel row!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_row) & LF &
                "Got:  " & to_string(to_integer(unsigned(c_pixel_row)))
            severity failure;
        assert to_integer(signed(c_pixel_coord_z0_re)) = i_exp_pixel_coord_z0_re
            report "Wrong pixel z_0 RE coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_coord_z0_re) & LF &
                "Got:  " & to_string(to_integer(signed(c_pixel_coord_z0_re)))
            severity failure;
        assert to_integer(signed(c_pixel_coord_z0_im)) = i_exp_pixel_coord_z0_im
            report "Wrong pixel z_0 IM coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_coord_z0_im) & LF &
                "Got:  " & to_string(to_integer(signed(c_pixel_coord_z0_im)))
            severity failure;
        assert to_integer(signed(c_pixel_coord_c_re)) = i_exp_pixel_coord_c_re
            report "Wrong pixel c RE coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_coord_c_re) & LF &
                "Got:  " & to_string(to_integer(signed(c_pixel_coord_c_re)))
            severity failure;
        assert to_integer(signed(c_pixel_coord_c_im)) = i_exp_pixel_coord_c_im
            report "Wrong pixel c IM coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_coord_c_im) & LF &
                "Got:  " & to_string(to_integer(signed(c_pixel_coord_c_im)))
            severity failure;
        assert to_integer(signed(c_c_coord_re)) = i_exp_c_coord_re
            report "Wrong frame c RE coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_c_coord_re) & LF &
                "Got:  " & to_string(to_integer(signed(c_c_coord_re)))
            severity failure;
        assert to_integer(signed(c_c_coord_im)) = i_exp_c_coord_im
            report "Wrong frame c IM coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_c_coord_im) & LF &
                "Got:  " & to_string(to_integer(signed(c_c_coord_im)))
            severity failure;
        assert to_integer(signed(c_c_target_re)) = i_exp_c_target_re
            report "Wrong frame c RE target coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_c_target_re) & LF &
                "Got:  " & to_string(to_integer(signed(c_c_target_re)))
            severity failure;
        assert to_integer(signed(c_c_target_im)) = i_exp_c_target_im
            report "Wrong frame c IM target coordinate!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_c_target_im) & LF &
                "Got:  " & to_string(to_integer(signed(c_c_target_im)))
            severity failure;
        assert c_is_in_minimap = i_exp_is_in_minimap
            report "Wrong is in minimap flag!" & "(" & debug_info & ")" & LF &
                "Exp.: " & std_logic'image(i_exp_is_in_minimap) & LF &
                "Got:  " & std_logic'image(c_is_in_minimap)
            severity failure;
        assert to_integer(unsigned(c_pixel_distance)) = i_exp_pixel_distance
            report "Wrong pixel distance!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(i_exp_pixel_distance) & LF &
                "Got:  " & to_string(to_integer(unsigned(c_pixel_distance)))
            severity failure;
    end procedure; 
begin
    UUT: entity work.Start_Value_Mapping
    port map (
        i_resetn            => s_resetn,
        i_clk               => s_clk,
        i_fetch_next        => s_fetch_next,
        i_valid             => s_valid,
        i_frame_idx         => s_frame_idx,
        i_pixel_col         => s_pixel_col,
        i_pixel_row         => s_pixel_row,
        i_pixel_coord_re    => s_pixel_coord_re,
        i_pixel_coord_im    => s_pixel_coord_im,
        i_is_in_minimap     => s_is_in_minimap,
        i_pixel_distance    => s_pixel_distance,
        i_frames_per_step   => s_frames_per_step,
        i_step_width        => s_step_width,
        i_mode              => s_mode,
        i_load_seed         => s_load_seed,
        i_lfsr_seed_re      => s_lfsr_seed_re,
        i_lfsr_seed_im      => s_lfsr_seed_im,
        i_lfsr_xor_mask_re  => s_lfsr_xor_mask_re,
        i_lfsr_xor_mask_im  => s_lfsr_xor_mask_im,
        i_diamond_heigh     => s_diamond_heigh,
        i_diamond_width     => s_diamond_width,
        o_valid             => c_valid,
        o_frame_idx         => c_frame_idx,
        o_pixel_col         => c_pixel_col,
        o_pixel_row         => c_pixel_row,
        o_pixel_coord_z0_re => c_pixel_coord_z0_re,
        o_pixel_coord_z0_im => c_pixel_coord_z0_im,
        o_pixel_coord_c_re  => c_pixel_coord_c_re,
        o_pixel_coord_c_im  => c_pixel_coord_c_im,
        o_c_coord_re        => c_c_coord_re,
        o_c_coord_im        => c_c_coord_im,
        o_c_target_re       => c_c_target_re,
        o_c_target_im       => c_c_target_im,
        o_is_in_minimap     => c_is_in_minimap,
        o_pixel_distance    => c_pixel_distance
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        tb_current_test_step  <= 0;
        s_fetch_next          <= '1';
        s_valid               <= '0';
        s_frame_idx           <= "00";
        s_pixel_col           <= std_logic_vector(to_unsigned(1000, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(1000, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(1000, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(1000, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(100, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(100, 16));
        s_step_width          <= std_logic_vector(to_unsigned(100, 17)); 
        s_mode                <= "10"; -- Mandelbrot
        s_load_seed           <= '1';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(1000, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(1000, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1000, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1000, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 1;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "00";
        s_pixel_col           <= std_logic_vector(to_unsigned(1, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(11, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(1, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(11, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "10"; -- Mandelbrot
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(0, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(0, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(0, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(0, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 2;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "00";
        s_pixel_col           <= std_logic_vector(to_unsigned(2, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(12, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(2, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(12, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "01"; -- LFSR (but not used yet, because no new frame)
        s_load_seed           <= '1';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 3;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "01";
        s_pixel_col           <= std_logic_vector(to_unsigned(3, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(13, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(3, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(13, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "01"; -- LFSR
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 4;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "10";
        s_pixel_col           <= std_logic_vector(to_unsigned(3, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(13, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(4, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(14, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "01"; -- LFSR
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 5;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "10";
        s_pixel_col           <= std_logic_vector(to_unsigned(4, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(14, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(4, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(14, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "00"; -- Diamond
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 6;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "11";
        s_pixel_col           <= std_logic_vector(to_unsigned(5, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(15, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(5, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(15, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "00"; -- Diamond
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 7;
        s_fetch_next          <= '0';
        s_valid               <= '0';
        s_frame_idx           <= "10";
        s_pixel_col           <= std_logic_vector(to_unsigned(6, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(16, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(6, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(16, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "00"; -- Diamond
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 8;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "11"; -- Same frame as last valid frame
        s_pixel_col           <= std_logic_vector(to_unsigned(7, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(17, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(7, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(17, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "00"; -- Diamond
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 9;
        s_fetch_next          <= '0';
        s_valid               <= '0';
        s_frame_idx           <= "00";
        s_pixel_col           <= std_logic_vector(to_unsigned(8, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(18, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(8, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(18, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "10"; -- Mandelbot 
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 10;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "00";
        s_pixel_col           <= std_logic_vector(to_unsigned(8, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(18, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(9, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(19, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "10"; -- Mandelbot 
        s_load_seed           <= '0';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(10, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(10, 17));
        s_diamond_width       <= std_logic_vector(to_signed(10, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 11;
        s_fetch_next          <= '1';
        s_valid               <= '1';
        s_frame_idx           <= "01";
        s_pixel_col           <= std_logic_vector(to_unsigned(9, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(19, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(9, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(19, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "00"; -- Diamond 
        s_load_seed           <= '1';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(1, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(1, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(1, 17));
        s_diamond_width       <= std_logic_vector(to_signed(1, 17));
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 12;
        s_fetch_next          <= '0';
        s_valid               <= '0';
        s_frame_idx           <= "10";
        s_pixel_col           <= std_logic_vector(to_unsigned(9, 10));
        s_pixel_row           <= std_logic_vector(to_unsigned(19, 9));
        s_pixel_coord_re      <= std_logic_vector(to_signed(9, 18));
        s_pixel_coord_im      <= std_logic_vector(to_signed(19, 18));
        s_is_in_minimap       <= '0';
        s_pixel_distance      <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step     <= std_logic_vector(to_unsigned(1, 16));
        s_step_width          <= std_logic_vector(to_unsigned(1, 17)); 
        s_mode                <= "00"; -- Diamond
        s_load_seed           <= '1';
        s_lfsr_seed_re        <= std_logic_vector(to_signed(1, 18));
        s_lfsr_seed_im        <= std_logic_vector(to_signed(1, 18));
        s_lfsr_xor_mask_re    <= std_logic_vector(to_signed(1, 17));
        s_lfsr_xor_mask_im    <= std_logic_vector(to_signed(1, 17));
        s_diamond_heigh       <= std_logic_vector(to_signed(1, 17));
        s_diamond_width       <= std_logic_vector(to_signed(1, 17));
        wait until rising_edge(s_clk);  
        tb_current_test_step  <= 13;
        s_fetch_next          <= '1';
        s_valid               <= '0';
        s_load_seed           <= '0';
        wait until rising_edge(s_clk);  
        tb_current_test_step  <= 14;
        s_is_in_minimap       <= '1';
        s_valid               <= '1';
        wait until rising_edge(s_clk);
        tb_current_test_step  <= 15;
        s_is_in_minimap       <= '0';
        s_frame_idx           <= "11";
        wait until rising_edge(s_clk);  
        tb_current_test_step  <= 16;
        s_fetch_next          <= '1';
        s_frame_idx           <= "00";
        wait;
    end process;

    tb_test_clock_en <= c_valid and s_fetch_next;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("00", 1, 11, 0, 0, 1, 11, 0, 0, 10, 0, '0', 1, "Step 1"); -- Mandelbrot
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("00", 2, 12, 0, 0, 2, 12, 0, 0, 10, 0, '0', 1, "Step 2"); -- Mandelbrot
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("01", 3, 13, 3, 13, 0, 0, 0, 0, 10, 10, '0', 1, "Step 3"); -- LFSR
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("10", 3, 13, 4, 14, 1, 1, 1, 1, 10, 10, '0', 1, "Step 4"); -- LFSR
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("10", 4, 14, 4, 14, 1, 1, 1, 1, 10, 10, '0', 1, "Step 5"); -- Diamond but no new frame
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("11", 5, 15, 5, 15, 3, 1, 3, 1, 10, 0, '0', 1, "Step 6"); -- Diamond
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("11", 7, 17, 7, 17, 3, 1, 3, 1, 10, 0, '0', 1, "Step 8"); -- Diamond
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("00", 8, 18, 0, 0, 9, 19, 3, 1, 1, 0, '0', 1, "Step 10"); -- Mandelbrot (Diamond width changes async 2 steps later to 1)
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("01", 9, 19, 9, 19, 2, 0, 2, 0, 1, 0, '0', 1, "Step 11"); -- Diamond 
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("10", 9, 19, 0, 0, 9, 19, 2, 0, 1, 0, '1', 1, "Step 14"); -- Diamond (Minimap)
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("11", 9, 19, 9, 19, 1, -1, 1, -1, 1, 0, '0', 1, "Step 15"); -- Diamond
        wait_for_enabled_clock(s_clk, tb_test_clock_en);
        check_data("00", 9, 19, 9, 19, 0, 0, 0, 0, 0, 1, '0', 1, "Step 16"); -- Diamond
        wait until rising_edge(s_clk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 1000*tbase;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            wait for tbase;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;