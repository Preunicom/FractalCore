----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/27/2026 14:05:00 AM
-- Design Name: 
-- Module Name: Highlight_Calculation - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Resolves the pixels which should be highlighted in the minimap.
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

entity Highlight_Calculation is
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
        i_pixel_distance        : in  std_logic_vector(7 downto 0);
        o_highlight_info        : out t_highlight_info
	);
end entity;

architecture Behavioral of Highlight_Calculation is
    signal w_frame_idx : integer;
    signal w_dist_c_re : signed(18 downto 0);
    signal w_dist_c_im : signed(18 downto 0);
    signal w_dist_target_re : signed(18 downto 0);
    signal w_dist_target_im : signed(18 downto 0);
    signal w_max_distance : signed(18 downto 0);
    signal r_last_frame_idx : std_logic_vector(1 downto 0);
begin

    w_frame_idx <= to_integer(unsigned(i_frame_idx));

    w_dist_c_re <= abs(resize(signed(i_pixel_coord_re), 19) - resize(signed(i_c_coord_re), 19));
    w_dist_c_im <= abs(resize(signed(i_pixel_coord_im), 19) - resize(signed(i_c_coord_im), 19));
    w_dist_target_re <= abs(resize(signed(i_pixel_coord_re), 19) - resize(signed(i_c_target_coord_re), 19));
    w_dist_target_im <= abs(resize(signed(i_pixel_coord_im), 19) - resize(signed(i_c_target_coord_im), 19));
    w_max_distance(8 downto 0) <= signed(i_pixel_distance(7 downto 0) & '0'); -- pixel distance * 2 (Because pixel_dist*4/2 as it is in minimap and should be maximum 1/2 pixel distance away)
    w_max_distance(18 downto 9) <= (others => '0');

    CALC: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                for i in 0 to 3 loop
                    o_highlight_info(i) <= c_HIGHLIGHT_PIXEL_RESET;
                end loop;
                r_last_frame_idx <= (others => '1'); -- Max frame idx, as frame starts at 0 after reset --> Change is recognized
            else
                if i_valid = '1' then
                    r_last_frame_idx <= i_frame_idx;
                    if r_last_frame_idx /= i_frame_idx then
                        -- New frame --> Reset values
                        o_highlight_info(w_frame_idx) <= c_HIGHLIGHT_PIXEL_RESET;
                    end if;
                    if  i_is_in_minimap = '1' then
                        -- Data is valid and pixel is in enabled minimap
                        if w_dist_c_re <= w_max_distance and w_dist_c_im <= w_max_distance then
                            o_highlight_info(w_frame_idx).valid <= '1';
                            o_highlight_info(w_frame_idx).current_pixel_col <= i_pixel_col;
                            o_highlight_info(w_frame_idx).current_pixel_row <= i_pixel_row;
                        end if;
                        if w_dist_target_re <= w_max_distance and w_dist_target_im <= w_max_distance then
                            o_highlight_info(w_frame_idx).valid <= '1';
                            o_highlight_info(w_frame_idx).target_pixel_col <= i_pixel_col;
                            o_highlight_info(w_frame_idx).target_pixel_row <= i_pixel_row;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;