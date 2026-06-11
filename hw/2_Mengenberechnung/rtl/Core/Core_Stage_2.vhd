
----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Core_Stage_2 - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Calculation of part 2 of the Mandelbrot set equation.
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

entity Core_Stage_2 is
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        i_stage_data : in t_stage_data;
        i_zr_add_zi : in signed(18 downto 0);
        i_zr_sub_zi : in signed(18 downto 0);
        i_2zr_mul_zi : in signed(36 downto 0);
        i_zr_mul_zr : in signed(35 downto 0);
        i_zi_mul_zi : in signed(35 downto 0);
        o_stage_data : out t_stage_data;
        o_real_mul : out signed(37 downto 0);
        o_img_res_long : out signed(37 downto 0);
        o_magnitude_res : out signed(36 downto 0)
    );
end Core_Stage_2;

architecture Behavioral of Core_Stage_2 is
    signal w_ci_sign_ext : signed(36 downto 0); -- 7.30
begin

    STAGE_DATA: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_stage_data <= c_STAGE_DATA_RESET;
            else
                o_stage_data <= i_stage_data;
            end if;
        end if;
    end process;

    RE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_real_mul <= (others => '0');
            else
                -- 4.15 * 4.15 = 8.30
                o_real_mul <= i_zr_add_zi * i_zr_sub_zi;
            end if;
        end if;
    end process;

    IM: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_img_res_long <= (others => '0');
            else
                -- 7.30 + 7.30 = 8.30
                o_img_res_long <= resize(i_2zr_mul_zi, 38) + resize(w_ci_sign_ext, 38);
            end if;
        end if;
    end process;
    
    -- 3.15 --> 7.30
    w_ci_sign_ext <= resize(i_stage_data.c_img, 37) sll 15;

    MAGNITUDE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_magnitude_res <= (others => '0');
            else
                -- 6.30 + 6.30 = 7.30
                o_magnitude_res <= resize(i_zr_mul_zr, 37) + resize(i_zi_mul_zi, 37);
            end if;
        end if;
    end process;

end architecture;