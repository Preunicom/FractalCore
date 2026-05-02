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

-- Generates frames pixel by pixel
entity Pixel_Generation is
	port (
		i_resetn                : in  std_logic;
		i_clk                   : in  std_logic;
		i_fetch_next            : in  std_logic;
        o_frame_idx             : out std_logic_vector(1 downto 0);
        o_pixel_col             : out std_logic_vector(9 downto 0);
        o_pixel_row             : out std_logic_vector(8 downto 0);
        o_is_in_minimap_area    : out std_logic
	);
end entity;

architecture Behavioral of Pixel_Generation is
    constant c_FRAME_WIDTH : unsigned(9 downto 0) := to_unsigned(640, 10);
    constant c_FRAME_HEIGHT : unsigned(8 downto 0) := to_unsigned(480, 9);
    constant c_MINI_MAP_AREA_END_RE : unsigned := c_FRAME_WIDTH / 4;
    constant c_MINI_MAP_AREA_START_IM : unsigned := 3 * (c_FRAME_HEIGHT / 4);
    signal r_col_idx : unsigned(9 downto 0) := (others => '0');
    signal r_row_idx : unsigned(8 downto 0) := (others => '0');
    signal r_frame_idx : unsigned(1 downto 0) := (others => '0');  
begin

    -- Calculate the pixel idx for re and im as well as the frame idx
    COUNT: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_col_idx <= (others => '0');
                r_row_idx <= (others => '0');
                r_frame_idx <= (others => '0');
            else
                if i_fetch_next = '1' then
                    -- Fetch next pixel
                    r_col_idx <= r_col_idx + 1;
                    if r_col_idx = c_FRAME_WIDTH - 1 then
                        -- End of row reached
                        r_col_idx <= (others => '0');
                        r_row_idx <= r_row_idx + 1;
                        if r_row_idx = c_FRAME_HEIGHT - 1 then
                            -- End of frame reached
                            r_row_idx <= (others => '0');
                            r_frame_idx <= r_frame_idx + 1; -- Overflow is intended
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    o_pixel_col <= std_logic_vector(r_col_idx);
    o_pixel_row <= std_logic_vector(r_row_idx);
    o_frame_idx <= std_logic_vector(r_frame_idx);
    o_is_in_minimap_area <= '1' when r_col_idx <= c_MINI_MAP_AREA_END_RE and 
                                r_row_idx >= c_MINI_MAP_AREA_START_IM
                                else '0';

end architecture;