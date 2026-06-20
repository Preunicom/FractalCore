----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/01/2026 14:36:00 AM
-- Design Name: 
-- Module Name: Start_Value_Mapping - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Adds the c value to a pixel and chose c and z_0 depedning on the mode
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

entity Start_Value_Mapping is
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
end entity;

architecture Behavioral of Start_Value_Mapping is
    component Julia_C_Generation is
        port (
            i_resetn    : in  std_logic;
            i_clk       : in  std_logic;
            i_en        : in  std_logic;
            i_frames_per_step : in std_logic_vector(15 downto 0);
            i_step_width : in std_logic_vector(16 downto 0);
            i_mode : in std_logic; -- 0: Diamond, 1: LFSR
            i_load_seed : in std_logic;
            i_lfsr_seed_re : in std_logic_vector(16 downto 0);
            i_lfsr_seed_im : in std_logic_vector(16 downto 0);
            i_lfsr_xor_mask_re : in std_logic_vector(15 downto 0);
            i_lfsr_xor_mask_im : in std_logic_vector(15 downto 0);
            i_diamond_height : in std_logic_vector(15 downto 0);
            i_diamond_width : in std_logic_vector(15 downto 0);
            o_target_re : out std_logic_vector(17 downto 0);
            o_target_im : out std_logic_vector(17 downto 0);        
            o_current_coord_re : out std_logic_vector(17 downto 0);
            o_current_coord_im : out std_logic_vector(17 downto 0)
        );
    end component;

    signal r_en_c_generation : std_logic;

    signal r_valid              : std_logic;
    signal r_frame_idx          : std_logic_vector(1 downto 0);
    signal r_pixel_col          : std_logic_vector(9 downto 0);
    signal r_pixel_row          : std_logic_vector(8 downto 0);
    signal r_pixel_coord_re     : std_logic_vector(17 downto 0);
    signal r_pixel_coord_im     : std_logic_vector(17 downto 0);
    signal r_is_in_minimap      : std_logic;
    
    signal r_c_mode             : std_logic;
    signal r_set_mode           : std_logic;

    signal w_target_re          : std_logic_vector(17 downto 0);
    signal w_target_im          : std_logic_vector(17 downto 0);
    signal w_current_c_coord_re : std_logic_vector(17 downto 0);
    signal w_current_c_coord_im : std_logic_vector(17 downto 0);

    signal r_frame_c_coord_re   : std_logic_vector(17 downto 0);
    signal r_frame_c_coord_im   : std_logic_vector(17 downto 0);
    signal r_is_new_frame       : std_logic;

begin
    C_GEN: Julia_C_Generation
    port map (
        i_resetn           => i_resetn,
        i_clk              => i_clk,
        i_en               => r_en_c_generation,
        i_frames_per_step  => i_frames_per_step,
        i_step_width       => i_step_width,
        i_mode             => r_c_mode,
        i_load_seed        => i_load_seed,
        i_lfsr_seed_re     => i_lfsr_seed_re,
        i_lfsr_seed_im     => i_lfsr_seed_im,
        i_lfsr_xor_mask_re => i_lfsr_xor_mask_re,
        i_lfsr_xor_mask_im => i_lfsr_xor_mask_im,
        i_diamond_height   => i_diamond_height,
        i_diamond_width    => i_diamond_width,
        o_target_re        => w_target_re,
        o_target_im        => w_target_im,
        o_current_coord_re => w_current_c_coord_re,
        o_current_coord_im => w_current_c_coord_im
    );

    -- Strobe en if Julia set mode and new frame --> next data in c_gen
    r_en_c_generation <= '1' when (r_frame_idx /= i_frame_idx) 
                                    and i_mode(1) = '0' 
                                    and i_valid = '1' 
                                    and i_fetch_next = '1'
                            else '0';

    -- Pipeline the data to detect frame changes and to allow new c data to be loaded
    INP_REG: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_valid <= '0';
                -- Max pixel values, as it starts with min values at reset --> Definitly changes in the beginning
                r_frame_idx <= (others => '1');
                r_pixel_col <= (others => '1');
                r_pixel_row <= (others => '1');
                r_pixel_coord_re <= (others => '0');
                r_pixel_coord_im <= (others => '0');
                r_is_in_minimap <= '0';
                r_c_mode <= '0';
                r_set_mode <= '0';
                r_is_new_frame <= '0';
            else
                if i_fetch_next = '1' then
                    r_valid <= i_valid;
                    r_is_new_frame <= '0'; -- Reset new frame flag at next pipeline shift
                    if i_valid = '1' then
                        -- Data valid --> Process it
                        if r_frame_idx /= i_frame_idx then
                            -- New frame
                            r_c_mode <= i_mode(0); -- Set c mode for full frame
                            r_set_mode <= i_mode(1); -- Set set mode for full frame
                            r_is_new_frame <= '1';
                        end if;
                        r_frame_idx <= i_frame_idx;
                        r_pixel_col <= i_pixel_col;
                        r_pixel_row <= i_pixel_row;
                        r_pixel_coord_re <= i_pixel_coord_re;
                        r_pixel_coord_im <= i_pixel_coord_im;
                        r_is_in_minimap <= i_is_in_minimap;
                    end if; -- Do not process data which is not valid as it could lead to c generation
                end if;
            end if;
        end if;
    end process;

    OUT_REG: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_valid <= '0';
                -- Max pixel values, as it starts with min values at reset --> Definitly changes in the beginning
                o_frame_idx <= (others => '1');
                o_pixel_col <= (others => '1');
                o_pixel_row <= (others => '1');
                o_pixel_coord_z0_re <= (others => '0');
                o_pixel_coord_z0_im <= (others => '0');
                o_pixel_coord_c_re <= (others => '0');
                o_pixel_coord_c_im <= (others => '0');
                o_is_in_minimap <= '0';
            else
                if i_fetch_next = '1' then
                    o_valid <= r_valid;
                    o_frame_idx <= r_frame_idx;
                    o_pixel_col <= r_pixel_col;
                    o_pixel_row <= r_pixel_row;
                    o_is_in_minimap <= r_is_in_minimap;
                    -- Set c and z_0 depending on mode
                    if r_set_mode = '1' or r_is_in_minimap = '1' then
                        -- Mandelbrot mode or minimap with Mandelbrot logic
                        o_pixel_coord_z0_re <= (others => '0');
                        o_pixel_coord_z0_im <= (others => '0');
                        o_pixel_coord_c_re <= r_pixel_coord_re;
                        o_pixel_coord_c_im <= r_pixel_coord_im;
                    else
                        -- Julia set mode
                        o_pixel_coord_z0_re <= r_pixel_coord_re;
                        o_pixel_coord_z0_im <= r_pixel_coord_im;
                        if r_is_new_frame = '1' then
                            o_pixel_coord_c_re <= w_current_c_coord_re;
                            o_pixel_coord_c_im <= w_current_c_coord_im;
                            r_frame_c_coord_re <= w_current_c_coord_re;
                            r_frame_c_coord_im <= w_current_c_coord_im;
                        else
                            o_pixel_coord_c_re <= r_frame_c_coord_re;
                            o_pixel_coord_c_im <= r_frame_c_coord_im;
                        end if;
                    end if;
                    -- Generated c values
                    o_c_target_re <= w_target_re;
                    o_c_target_im <= w_target_im;
                    if r_is_new_frame = '1' then
                        o_c_coord_re <= w_current_c_coord_re; -- Stays c even if minimap pixel
                        o_c_coord_im <= w_current_c_coord_im; -- Stays c even if minimap pixel
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;