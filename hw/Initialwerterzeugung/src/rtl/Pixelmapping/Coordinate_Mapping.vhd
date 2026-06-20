----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/25/2026 08:16:00 AM
-- Design Name: 
-- Module Name: Coordinate_Mapping - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Calculates the coordinate to a pixel value
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

entity Coordinate_Mapping is
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
end entity;

architecture Behavioral of Coordinate_Mapping is
    constant c_FRAME_WIDTH : unsigned(9 downto 0) := to_unsigned(640, 10);
    constant c_FRAME_HEIGHT : unsigned(8 downto 0) := to_unsigned(480, 9);
    constant c_FIRST_PIXEL_RE_COORD : signed(9 downto 0) := -(signed('0' & c_FRAME_WIDTH(9 downto 1))); -- - (WIDTH / 2)
    constant c_FIRST_PIXEL_IM_COORD : signed(8 downto 0) := signed('0' & c_FRAME_HEIGHT(8 downto 1)); -- HEIGHT / 2
    constant c_MINI_MAP_COORD_RE_SHIFT : unsigned := (c_FRAME_WIDTH / 4) + (c_FRAME_WIDTH / 8);
    constant c_MINI_MAP_COORD_IM_SHIFT : unsigned := (c_FRAME_HEIGHT / 4) + (c_FRAME_HEIGHT / 8);
    signal r_valid : std_logic;
    signal r_pixel_col_idx : std_logic_vector(9 downto 0) := (others => '0');
    signal r_pixel_row_idx : std_logic_vector(8 downto 0) := (others => '0');
    signal r_re_coord : signed(9 downto 0) := (others => '0');
    signal r_im_coord : signed(8 downto 0) := (others => '0');
    signal r_frame_idx : std_logic_vector(1 downto 0) := (others => '0');
    signal r_is_in_mini_map : std_logic;
    signal r_current_pixel_distance : signed(8 downto 0);
    signal r_minimap_en : std_logic;
    signal r_last_frame_idx : std_logic_vector(1 downto 0);
begin

    -- Pipeline the addition for higher clock frequency
    -- Calculates the coordinate values as well as the mini map coordinates if enabled
    CALC_PIPELINE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_valid <= '0';
                r_re_coord <= (others => '0');
                r_im_coord <= (others => '0');
                r_last_frame_idx <= (others => '1');
                r_pixel_col_idx <= (others => '0');
                r_pixel_row_idx <= (others => '0');
                r_frame_idx <= (others => '0');
                r_current_pixel_distance <= (others => '0');
                r_is_in_mini_map <= '0';
            else
                if i_fetch_next = '1' then
                    if r_last_frame_idx /= i_frame_idx then
                        -- Only update pixel distance and minimap_en at new frame
                        r_current_pixel_distance <= signed("0" & i_pixel_distance); -- Cast to positive signed
                        r_minimap_en <= i_minimap_en;
                    end if;
                    r_valid <= '1'; -- Only invalid in the first iteration after reset
                    -- Pipeline values
                    r_last_frame_idx <= i_frame_idx;
                    r_pixel_col_idx <= i_pixel_col;
                    r_pixel_row_idx <= i_pixel_row;
                    r_frame_idx <= i_frame_idx;
                    if i_is_in_minimap_area = '1' and (r_minimap_en = '1' or (r_last_frame_idx /= i_frame_idx and i_minimap_en = '1')) then
                        -- Set the mini map status for the Julia set Mandelbrot overview map (shift mid of mini map re/im part to zero)
                        r_is_in_mini_map <= '1';
                        -- Min value is -320 + 0 + 240 = -80, Max value is -320 + 159 + 240 = +79 --> Needs 8 bits
                        r_re_coord <= resize(resize(c_FIRST_PIXEL_RE_COORD, 11) + signed('0' & i_pixel_col) + resize(signed(c_MINI_MAP_COORD_RE_SHIFT), 11), 10);
                        -- Min value is 240 - 479 + 180 = -59, Max value is 240 - 360 + 180 = +60 --> Needs 7 bits
                        r_im_coord <= resize(resize(c_FIRST_PIXEL_IM_COORD, 10) - signed('0' & i_pixel_row) + resize(signed(c_MINI_MAP_COORD_IM_SHIFT), 10), 9);
                    else
                        -- Normal coordinates
                        r_is_in_mini_map <= '0';
                        -- Min value is -320 + 0 = -320, Max value is -320 + 639 = +319 --> Needs 10 bits (--> Data type has to be 10 bit)
                        r_re_coord <= resize(resize(c_FIRST_PIXEL_RE_COORD, 11) + signed('0' & i_pixel_col), 10);
                        -- Min value is 240 - 479 = -239, Max value is 240 - 0 = +240 --> Needs 9 bits
                        r_im_coord <= resize(resize(c_FIRST_PIXEL_IM_COORD, 10) - signed('0' & i_pixel_row), 9);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Calculates the final value for the coordinates (mini map as well as normal mode)
    OUTPUT: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_valid <= '0';
                o_pixel_coord_re <= (others => '0');
                o_pixel_coord_im <= (others => '0');
                o_pixel_col <= (others => '0');
                o_pixel_row <= (others => '0');
                o_frame_idx <= (others => '0');
            else
                if i_fetch_next = '1' then
                    o_valid <= r_valid;
                    if r_is_in_mini_map = '1' then
                        -- Use maximum pixel distance to allow the minimap to show all possible C values used by LFSR/Diamond
                        -- C values are between 0x10000 (-65536) and 0x0FFFF (65535) in both dimensions
                        --> -59 / 60 are max values for IM --> Scale these to -59 * x <= -65536
                        -- round_up(65536 / 59) = 1111 but the factor should be even to ensure the highlight can be easily calculated
                        -- Check for all values if they are in the 18 bit signed area:
                        -- RE has higher values in the coord so take RE for the maximum value
                        -- -80/+79 is min/max value --> -2^17 = 131072 -> -131071 / -80 = 1638,39 --> 1112 is smaller than max factor
                        o_pixel_coord_re <= std_logic_vector(resize(r_re_coord * to_signed(1112, 12), 18));
                        o_pixel_coord_im <= std_logic_vector(resize(r_im_coord * to_signed(1112, 12), 18));
                    else
                        -- Coords are max 319 and min -320 -> To fit in 18 bit signed the result needs to be in [-131072, 131071]
                        -- The edge case values to calculate with are: 319 * x <= 131071 and -320 * x >= -131072
                        --> The most critical case is -320 (x is always positive) --> x < -131072 / -320 -> x < 409,6
                        --> As it is a user input we can accept up to positive 8 bit unsigned without having problems when calculating.
                        o_pixel_coord_re <= std_logic_vector(resize(r_re_coord * r_current_pixel_distance, 18));
                        o_pixel_coord_im <= std_logic_vector(resize(r_im_coord * r_current_pixel_distance, 18));
                    end if;
                    o_pixel_col <= r_pixel_col_idx;
                    o_pixel_row <= r_pixel_row_idx;
                    o_frame_idx <= r_frame_idx;
                    o_is_in_minimap <= r_is_in_mini_map;
                end if;
            end if;
        end if;
    end process;

end architecture;