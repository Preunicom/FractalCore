----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/25/2026 08:16:00 AM
-- Design Name: 
-- Module Name: Value_Combination - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Combines the start values depending on the settings.
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
entity Value_Combination is
	port (
		i_resetn : in  std_logic;
		i_clk : in  std_logic;
        -- Settings
        i_pixel_distance: in  std_logic_vector(7 downto 0);
        i_frames_per_step : in std_logic_vector(15 downto 0);
        i_mode : in std_logic_vector(1 downto 0);
        i_enable_mini_map : in  std_logic;
        i_step_width : in std_logic_vector(16 downto 0);
        i_lfsr_seed_re : in std_logic_vector(17 downto 0);
        i_lfsr_seed_im : in std_logic_vector(17 downto 0);
        i_lfsr_xor_mask_re : in std_logic_vector(16 downto 0);
        i_lfsr_xor_mask_im : in std_logic_vector(16 downto 0);
        i_diamond_heigh : in std_logic_vector(16 downto 0);
        i_diamond_width : in std_logic_vector(16 downto 0);
        -- Control
        i_load_seed : in std_logic;
        -- AXI Stream like interface
        i_ready : std_logic;
        o_valid : std_logic;
        o_video_pix_col : std_logic_vector(9 downto 0);
        o_video_pix_row : std_logic_vector(8 downto 0);
        o_video_frame_idx : std_logic_vector(1 downto 0);
        o_z0_real : std_logic_vector(17 downto 0);
        o_z0_img : std_logic_vector(17 downto 0);
        o_c_real : std_logic_vector(17 downto 0);
        o_c_img : std_logic_vector(17 downto 0);
        -- Highlight data
        o_highlight : t_highlight_info
	);
end entity;

architecture Behavioral of Value_Combination is
    component Julia_C_Generation is
        port (
            i_resetn    : in  std_logic;
            i_clk       : in  std_logic;
            i_en        : in  std_logic;
            i_frames_per_step : in std_logic_vector(15 downto 0);
            i_step_width : in std_logic_vector(16 downto 0);
            i_mode : in std_logic; -- 0: Diamond, 1: LFSR
            i_load_seed : in std_logic;
            i_lfsr_seed_re : in std_logic_vector(17 downto 0);
            i_lfsr_seed_im : in std_logic_vector(17 downto 0);
            i_lfsr_xor_mask_re : in std_logic_vector(16 downto 0);
            i_lfsr_xor_mask_im : in std_logic_vector(16 downto 0);
            i_diamond_heigh : in std_logic_vector(16 downto 0);
            i_diamond_width : in std_logic_vector(16 downto 0);
            o_target_re : out std_logic_vector(17 downto 0);
            o_target_im : out std_logic_vector(17 downto 0);        
            o_current_coord_re : out std_logic_vector(17 downto 0);
            o_current_coord_im : out std_logic_vector(17 downto 0)
        );
    end component;
    -- TODO
begin

-- TODO

end architecture;

-- TODO: Minimap target and current pos highlighting --> Give to Thomas (+ redraw interface picture)
-- TODO: Move Pixel and Coord gen. logic in seperat component and route the trafic through the components
-- TODO: Output the overlay pixel to thomas with pixel x/y values.

-- TODO: Update TBs

-- TODO: Calc. highlight: 
-- entfernung zu aktuellem Pixel < dist*2 für col und row und in minimap --> Highlight