----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/25/2026 08:16:00 AM
-- Design Name: 
-- Module Name: Pixel_Data_Generation_Pipeline - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Generates pixel data depending on the set settings.
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
	use IEEE.numeric_std.all;
library work;
    use work.Pkg_Utils.all;

-- Maps pixel to coordinates and provides both information
entity Pixel_Data_Generation_Pipeline is
	port (
		i_resetn : in  std_logic;
		i_clk : in  std_logic;
        -- Settings
        i_pixel_distance: in  std_logic_vector(7 downto 0);
        i_frames_per_step : in std_logic_vector(15 downto 0);
        i_mode : in std_logic_vector(1 downto 0);
        i_enable_minimap : in std_logic;
        i_step_width : in std_logic_vector(16 downto 0);
        i_lfsr_seed_re : in std_logic_vector(16 downto 0);
        i_lfsr_seed_im : in std_logic_vector(16 downto 0);
        i_lfsr_xor_mask_re : in std_logic_vector(15 downto 0);
        i_lfsr_xor_mask_im : in std_logic_vector(15 downto 0);
        i_diamond_height : in std_logic_vector(15 downto 0);
        i_diamond_width : in std_logic_vector(15 downto 0);
        -- Control
        i_load_seed : in std_logic;
        -- AXI Stream like interface
        i_ready : in std_logic;
        o_valid : out std_logic;
        o_video_pix_col : out std_logic_vector(9 downto 0);
        o_video_pix_row : out std_logic_vector(8 downto 0);
        o_video_frame_idx : out std_logic_vector(1 downto 0);
        o_z0_real : out std_logic_vector(17 downto 0);
        o_z0_img : out std_logic_vector(17 downto 0);
        o_c_real : out std_logic_vector(17 downto 0);
        o_c_img : out std_logic_vector(17 downto 0);
        -- Highlight data
        o_highlight : out t_highlight_info
	);
end entity;

architecture Behavioral of Pixel_Data_Generation_Pipeline is
    component Pixel_Generation is
        port (
            i_resetn                : in  std_logic;
            i_clk                   : in  std_logic;
            i_fetch_next            : in  std_logic;
            o_frame_idx             : out std_logic_vector(1 downto 0);
            o_pixel_col             : out std_logic_vector(9 downto 0);
            o_pixel_row             : out std_logic_vector(8 downto 0);
            o_is_in_minimap_area    : out std_logic
        );
    end component;
    component Coordinate_Mapping is
        port (
            i_resetn                : in  std_logic;
            i_clk                   : in  std_logic;
            i_fetch_next            : in std_logic;
            i_frame_idx             : in std_logic_vector(1 downto 0);
            i_pixel_col             : in std_logic_vector(9 downto 0);
            i_pixel_row             : in std_logic_vector(8 downto 0);
            i_is_in_minimap_area    : in std_logic;
            i_minimap_en            : in std_logic;
            i_pixel_distance        : in std_logic_vector(7 downto 0);
            o_valid                 : out std_logic;
            o_frame_idx             : out std_logic_vector(1 downto 0);
            o_pixel_col             : out std_logic_vector(9 downto 0);
            o_pixel_row             : out std_logic_vector(8 downto 0);
            o_pixel_coord_re        : out std_logic_vector(17 downto 0);
            o_pixel_coord_im        : out std_logic_vector(17 downto 0);
            o_is_in_minimap         : out std_logic
        );
    end component;
    component Start_Value_Mapping is
        port (
            i_resetn            : in  std_logic;
            i_clk               : in  std_logic;
            i_fetch_next        : in std_logic;
            i_valid             : in std_logic;
            i_frame_idx         : in std_logic_vector(1 downto 0);
            i_pixel_col         : in std_logic_vector(9 downto 0);
            i_pixel_row         : in std_logic_vector(8 downto 0);
            i_pixel_coord_re    : in std_logic_vector(17 downto 0);
            i_pixel_coord_im    : in std_logic_vector(17 downto 0);
            i_is_in_minimap     : in std_logic;
            -- Config
            i_frames_per_step   : in std_logic_vector(15 downto 0);
            i_step_width        : in std_logic_vector(16 downto 0);
            i_mode              : in std_logic_vector(1 downto 0); -- 00: Diamond, 01: LFSR, 1X: Mandelbrot
            i_load_seed         : in std_logic;
            i_lfsr_seed_re      : in std_logic_vector(16 downto 0);
            i_lfsr_seed_im      : in std_logic_vector(16 downto 0);
            i_lfsr_xor_mask_re  : in std_logic_vector(15 downto 0);
            i_lfsr_xor_mask_im  : in std_logic_vector(15 downto 0);
            i_diamond_height    : in std_logic_vector(15 downto 0);
            i_diamond_width     : in std_logic_vector(15 downto 0);
            -- Outputs
            o_valid             : out std_logic;
            o_frame_idx         : out std_logic_vector(1 downto 0);
            o_pixel_col         : out std_logic_vector(9 downto 0);
            o_pixel_row         : out std_logic_vector(8 downto 0);
            o_pixel_coord_z0_re : out std_logic_vector(17 downto 0);
            o_pixel_coord_z0_im : out std_logic_vector(17 downto 0);
            o_pixel_coord_c_re  : out std_logic_vector(17 downto 0);
            o_pixel_coord_c_im  : out std_logic_vector(17 downto 0);
            -- Julia mode values
            o_c_coord_re        : out std_logic_vector(17 downto 0);
            o_c_coord_im        : out std_logic_vector(17 downto 0);
            o_c_target_re       : out std_logic_vector(17 downto 0);
            o_c_target_im       : out std_logic_vector(17 downto 0);
            o_is_in_minimap     : out std_logic
        );
    end component;
    component Highlight_Calculation is
        port (
            i_resetn                : in  std_logic;
            i_clk                   : in  std_logic;
            i_valid                 : in std_logic;
            i_frame_idx             : in std_logic_vector(1 downto 0);
            i_pixel_col             : in std_logic_vector(9 downto 0);
            i_pixel_row             : in std_logic_vector(8 downto 0);
            i_pixel_coord_re        : in std_logic_vector(17 downto 0);
            i_pixel_coord_im        : in std_logic_vector(17 downto 0);
            i_c_coord_re            : in std_logic_vector(17 downto 0);
            i_c_coord_im            : in std_logic_vector(17 downto 0);
            i_c_target_coord_re     : in std_logic_vector(17 downto 0);
            i_c_target_coord_im     : in std_logic_vector(17 downto 0);
            i_is_in_minimap         : in std_logic;
            o_highlight_info        : out t_highlight_info
        );
    end component;

    -- Control
    signal w_minimap_en : std_logic;

    -- Pixel gen out - Coord map in
    signal w_pixel_frame_idx : std_logic_vector(1 downto 0);
    signal w_pixel_pix_col : std_logic_vector(9 downto 0);
    signal w_pixel_pix_row : std_logic_vector(8 downto 0);
    signal w_pixel_in_minimap_area : std_logic;

    -- Coord map out - Start value map in
    signal w_coord_valid : std_logic;
    signal w_coord_frame_idx : std_logic_vector(1 downto 0);
    signal w_coord_pix_col : std_logic_vector(9 downto 0);
    signal w_coord_pix_row : std_logic_vector(8 downto 0);
    signal w_coord_coord_re : std_logic_vector(17 downto 0);
    signal w_coord_coord_im : std_logic_vector(17 downto 0);
    signal w_coord_in_minimap : std_logic;

    -- Start value map out - highlight in / port out
    signal w_sval_valid : std_logic;
    signal w_sval_frame_idx : std_logic_vector(1 downto 0);
    signal w_sval_pix_col : std_logic_vector(9 downto 0);
    signal w_sval_pix_row : std_logic_vector(8 downto 0);
    signal w_sval_c_coord_re : std_logic_vector(17 downto 0);
    signal w_sval_c_coord_im : std_logic_vector(17 downto 0);
    signal w_sval_current_frame_c_coord_re : std_logic_vector(17 downto 0);
    signal w_sval_current_frame_c_coord_im : std_logic_vector(17 downto 0);
    signal w_sval_c_target_coord_re : std_logic_vector(17 downto 0);
    signal w_sval_c_target_coord_im : std_logic_vector(17 downto 0);
    signal w_sval_in_minimap : std_logic;

begin

    PIXEL_GEN: Pixel_Generation
    port map (
        i_resetn             => i_resetn,
        i_clk                => i_clk,
        i_fetch_next         => i_ready,
        o_frame_idx          => w_pixel_frame_idx,
        o_pixel_col          => w_pixel_pix_col,
        o_pixel_row          => w_pixel_pix_row,
        o_is_in_minimap_area => w_pixel_in_minimap_area
    );

    -- Julia mode and minimap enabled
    w_minimap_en <= not i_mode(1) and i_enable_minimap;

    COORD_MAP: Coordinate_Mapping
    port map (
        i_resetn             => i_resetn,
        i_clk                => i_clk,
        i_fetch_next         => i_ready,
        i_frame_idx          => w_pixel_frame_idx,
        i_pixel_col          => w_pixel_pix_col,
        i_pixel_row          => w_pixel_pix_row,
        i_is_in_minimap_area => w_pixel_in_minimap_area,
        i_minimap_en         => w_minimap_en,
        i_pixel_distance     => i_pixel_distance,
        o_valid              => w_coord_valid,
        o_frame_idx          => w_coord_frame_idx,
        o_pixel_col          => w_coord_pix_col,
        o_pixel_row          => w_coord_pix_row,
        o_pixel_coord_re     => w_coord_coord_re,
        o_pixel_coord_im     => w_coord_coord_im,
        o_is_in_minimap      => w_coord_in_minimap
    );

    START_VAL_MAP: Start_Value_Mapping
    port map (
        i_resetn            => i_resetn,
        i_clk               => i_clk,
        i_fetch_next        => i_ready,
        i_valid             => w_coord_valid,
        i_frame_idx         => w_coord_frame_idx,
        i_pixel_col         => w_coord_pix_col,
        i_pixel_row         => w_coord_pix_row,
        i_pixel_coord_re    => w_coord_coord_re,
        i_pixel_coord_im    => w_coord_coord_im,
        i_is_in_minimap     => w_coord_in_minimap,
        i_frames_per_step   => i_frames_per_step,
        i_step_width        => i_step_width,
        i_mode              => i_mode,
        i_load_seed         => i_load_seed,
        i_lfsr_seed_re      => i_lfsr_seed_re,
        i_lfsr_seed_im      => i_lfsr_seed_im,
        i_lfsr_xor_mask_re  => i_lfsr_xor_mask_re,
        i_lfsr_xor_mask_im  => i_lfsr_xor_mask_im,
        i_diamond_height    => i_diamond_height,
        i_diamond_width     => i_diamond_width,
        o_valid             => w_sval_valid,
        o_frame_idx         => w_sval_frame_idx,
        o_pixel_col         => w_sval_pix_col,
        o_pixel_row         => w_sval_pix_row,
        o_pixel_coord_z0_re => o_z0_real,
        o_pixel_coord_z0_im => o_z0_img,
        o_pixel_coord_c_re  => w_sval_c_coord_re,
        o_pixel_coord_c_im  => w_sval_c_coord_im,
        o_c_coord_re        => w_sval_current_frame_c_coord_re,
        o_c_coord_im        => w_sval_current_frame_c_coord_im,
        o_c_target_re       => w_sval_c_target_coord_re,
        o_c_target_im       => w_sval_c_target_coord_im,
        o_is_in_minimap     => w_sval_in_minimap
    );

    HIGHLIGHT_CALC: Highlight_Calculation
    port map (
        i_resetn            => i_resetn,
        i_clk               => i_clk,
        i_valid             => w_sval_valid,
        i_frame_idx         => w_sval_frame_idx,
        i_pixel_col         => w_sval_pix_col,
        i_pixel_row         => w_sval_pix_row,
        i_pixel_coord_re    => w_sval_c_coord_re, -- Use c coordinate as minimap is Mandelbrot set
        i_pixel_coord_im    => w_sval_c_coord_im, -- Use c coordinate as minimap is Mandelbrot set
        i_c_coord_re        => w_sval_current_frame_c_coord_re,
        i_c_coord_im        => w_sval_current_frame_c_coord_im,
        i_c_target_coord_re => w_sval_c_target_coord_re,
        i_c_target_coord_im => w_sval_c_target_coord_im,
        i_is_in_minimap     => w_sval_in_minimap,
        o_highlight_info    => o_highlight
    );

    o_valid <= w_sval_valid;
    o_video_frame_idx <= w_sval_frame_idx;
    o_video_pix_col <= w_sval_pix_col;
    o_video_pix_row <= w_sval_pix_row;
    o_c_real <= w_sval_c_coord_re;
    o_c_img <= w_sval_c_coord_im;

end architecture;