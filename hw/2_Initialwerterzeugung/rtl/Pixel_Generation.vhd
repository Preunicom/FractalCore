----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/20/2026 12:08:00 AM
-- Design Name: 
-- Module Name: Pixel_Generation - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Maps pixel to values
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

-- Maps pixel to coordinates and provides both information
entity Pixel_Generation is
	port (
		i_resetn                : in  std_logic;
		i_clk                   : in  std_logic;
		i_fetch_next            : in  std_logic;
        i_pixel_distance        : in  std_logic_vector(7 downto 0);
        i_enable_mini_map       : in  std_logic;
        o_valid                 : out std_logic;
        o_pixel_coord_re        : out std_logic_vector(17 downto 0);
        o_pixel_coord_im        : out std_logic_vector(17 downto 0);
        o_pixel_idx_re          : out std_logic_vector(9 downto 0);
        o_pixel_idx_im          : out std_logic_vector(8 downto 0);
        o_frame_idx             : out std_logic_vector(1 downto 0);
        o_is_in_mini_map        : out std_logic
	);
end entity;

architecture Behavioral of Pixel_Generation is
    constant c_FRAME_WIDTH : unsigned(9 downto 0) := to_unsigned(640, 10);
    constant c_FRAME_HEIGHT : unsigned(8 downto 0) := to_unsigned(480, 9);
    constant c_FIRST_PIXEL_RE_COORD : signed(9 downto 0) := -(signed('0' & c_FRAME_WIDTH(9 downto 1))); -- - (WIDTH / 2)
    constant c_FIRST_PIXEL_IM_COORD : signed(8 downto 0) := signed('0' & c_FRAME_HEIGHT(8 downto 1)); -- HEIGHT / 2
    signal r_count_re_idx : unsigned(9 downto 0) := (others => '0');
    signal r_count_im_idx : unsigned(8 downto 0) := (others => '0');
    signal r_count_frame_idx : unsigned(1 downto 0) := (others => '0');
    signal r_count_pixel_distance : std_logic_vector(7 downto 0);
    signal r_count_mini_map_en : std_logic;

    constant c_MINI_MAP_AREA_END_RE : unsigned := c_FRAME_WIDTH / 4;
    constant c_MINI_MAP_AREA_START_IM : unsigned := 3 * (c_FRAME_HEIGHT / 4);
    constant c_MINI_MAP_COORD_RE_SHIFT : unsigned := (c_FRAME_WIDTH / 4) + (c_FRAME_WIDTH / 8);
    constant c_MINI_MAP_COORD_IM_SHIFT : unsigned := (c_FRAME_HEIGHT / 4) + (c_FRAME_HEIGHT / 8);
    signal r_pipe_valid : std_logic;
    signal r_pipe_re_idx : unsigned(9 downto 0) := (others => '0');
    signal r_pipe_im_idx : unsigned(8 downto 0) := (others => '0');
    signal r_pipe_re_coord : signed(9 downto 0) := (others => '0');
    signal r_pipe_im_coord : signed(8 downto 0) := (others => '0');
    signal r_pipe_frame_idx : unsigned(1 downto 0) := (others => '0');
    signal r_pipe_pixel_distance : std_logic_vector(7 downto 0);
    signal r_pipe_is_in_enabled_mini_map_area : std_logic;
begin

    -- Calculate the pixel idx for re and im as well as the frame idx
    COUNT: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_count_re_idx <= (others => '0');
                r_count_im_idx <= (others => '0');
                r_count_frame_idx <= (others => '0');
                r_count_pixel_distance <= std_logic_vector(to_signed(1, 8));
                r_count_mini_map_en <= '0';
            else
                if i_fetch_next = '1' then
                    -- Fetch next pixel
                    r_count_re_idx <= r_count_re_idx + 1;
                    if r_count_re_idx = c_FRAME_WIDTH - 1 then
                        -- End or row reached
                        r_count_re_idx <= (others => '0');
                        r_count_im_idx <= r_count_im_idx + 1;
                        if r_count_im_idx = c_FRAME_HEIGHT - 1 then
                            -- End of frame reached
                            r_count_im_idx <= (others => '0');
                            r_count_frame_idx <= r_count_frame_idx + 1; -- Overflow is intended
                            -- Load new pixel distance for new frame
                            r_count_pixel_distance <= i_pixel_distance;
                            r_count_mini_map_en <= i_enable_mini_map;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Pipeline the addition for higher clock frequency
    -- Calculates the coordinate values as well as the mini map coordinates if enabled
    CALC_PIPELINE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_pipe_valid <= '0';
                r_pipe_re_coord <= (others => '0');
                r_pipe_im_coord <= (others => '0');
                r_pipe_re_idx <= (others => '0');
                r_pipe_im_idx <= (others => '0');
                r_pipe_frame_idx <= (others => '0');
                r_pipe_pixel_distance <= (others => '0');
                r_pipe_is_in_enabled_mini_map_area <= '0';
            else
                if i_fetch_next = '1' then
                    r_pipe_valid <= '1';
                    r_pipe_re_idx <= r_count_re_idx;
                    r_pipe_im_idx <= r_count_im_idx;
                    r_pipe_frame_idx <= r_count_frame_idx;
                    r_pipe_pixel_distance <= r_count_pixel_distance;
                    if r_count_re_idx <= c_MINI_MAP_AREA_END_RE and r_count_im_idx >= c_MINI_MAP_AREA_START_IM and r_count_mini_map_en = '1' then
                        -- Set the mini map status for the Julia set Mandelbrot overview map (shift mid of mini map re/im part to zero)
                        r_pipe_is_in_enabled_mini_map_area <= '1';
                        -- Min value is -320 + 0 + 240 = -80, Max value is -320 + 160 + 240 = +80 --> Needs 8 bits
                        r_pipe_re_coord <= resize(resize(c_FIRST_PIXEL_RE_COORD, 11) + signed('0' & r_count_re_idx) + resize(signed(c_MINI_MAP_COORD_RE_SHIFT), 11), 10);
                        -- Min value is 240 - 479 + 180 = -59, Max value is 240 - 360 + 180 = +60 --> Needs 7 bits
                        r_pipe_im_coord <= resize(resize(c_FIRST_PIXEL_IM_COORD, 10) - signed('0' & r_count_im_idx) + resize(signed(c_MINI_MAP_COORD_IM_SHIFT), 10), 9);
                    else
                        -- Normal coordinates
                        r_pipe_is_in_enabled_mini_map_area <= '0';
                        -- Min value is -320 + 0 = -320, Max value is -320 + 640 = +320 --> Needs 10 bits (--> Data type has to be 10 bit)
                        r_pipe_re_coord <= resize(resize(c_FIRST_PIXEL_RE_COORD, 11) + signed('0' & r_count_re_idx), 10);
                        -- Min value is 240 - 479 = -239, Max value is 240 - 0 = +240 --> Needs 9 bits
                        r_pipe_im_coord <= resize(resize(c_FIRST_PIXEL_IM_COORD, 10) - signed('0' & r_count_im_idx), 9);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Calculates the final value for the coordinates (mini map as well es normal mode)
    OUTPUT: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_valid <= '0';
                o_pixel_coord_re <= (others => '0');
                o_pixel_coord_im <= (others => '0');
                o_pixel_idx_re <= (others => '0');
                o_pixel_idx_im <= (others => '0');
                o_frame_idx <= (others => '0');
                o_is_in_mini_map <= '0';
            else
                if i_fetch_next = '1' then
                    o_valid <= r_pipe_valid;
                    if r_pipe_is_in_enabled_mini_map_area = '1' then
                        -- Mul with *4 distance (as minimap is one fourth of the screen width)
                        -- Result has maximum 8 bit in mini map case --> 8 + (8+2) = 18 bit
                        o_pixel_coord_re <= std_logic_vector(resize(r_pipe_re_coord * (signed(r_pipe_pixel_distance & "00")), 18));
                        o_pixel_coord_im <= std_logic_vector(resize(r_pipe_im_coord * (signed(r_pipe_pixel_distance & "00")), 18));
                    else
                        -- Result has maximum 10 bit --> 10 + 8 = 18 bit
                        o_pixel_coord_re <= std_logic_vector(resize(r_pipe_re_coord * signed(r_pipe_pixel_distance), 18));
                        o_pixel_coord_im <= std_logic_vector(resize(r_pipe_im_coord * signed(r_pipe_pixel_distance), 18));
                    end if;
                    o_pixel_idx_re <= std_logic_vector(r_pipe_re_idx);
                    o_pixel_idx_im <= std_logic_vector(r_pipe_im_idx);
                    o_frame_idx <= std_logic_vector(r_pipe_frame_idx);
                    o_is_in_mini_map <= r_pipe_is_in_enabled_mini_map_area;
                end if;
            end if;
        end if;
    end process;

end architecture;