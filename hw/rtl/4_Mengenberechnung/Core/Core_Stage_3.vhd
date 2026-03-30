
----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Core_Stage_3 - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Calculation of part 3 of the Mandelbrot set equation.
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

entity Core_Stage_3 is
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        i_stage_data : in t_stage_data;
        i_real_mul : in signed(37 downto 0);
        i_img_res_long : in signed(37 downto 0);
        o_stage_data : out t_stage_data
    );
end Core_Stage_3;

architecture Behavioral of Core_Stage_3 is
    signal w_cr_sign_ext : signed(37 downto 0); -- 8.30
    signal w_real_res_long : signed(38 downto 0); -- 9.30
    signal w_res_real : signed(17 downto 0); -- 3.15
    signal w_res_imag : signed(17 downto 0); -- 3.15
begin

    -- Combine data in result data for next iteration
    STAGE_DATA: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_stage_data <= c_STAGE_DATA_RESET;
            else
                o_stage_data <= i_stage_data;
                o_stage_data.z_real <= w_res_real;
                o_stage_data.z_img <= w_res_imag;
            end if;
        end if;
    end process;

    -- Truncate from 9.30 to 3.15
    RE: process(w_real_res_long)
	begin
        if w_real_res_long(38) = '0' and w_real_res_long(38 downto 32) /= 0 then
            -- Overflow --> Take max value
            w_res_real <= (others => '1');
            w_res_real(17) <= '0';
        elsif w_real_res_long(38) = '1' and w_real_res_long(38 downto 32) /= "1111111" then
            -- Underflow --> Take min value
            w_res_real <= (others => '0');
            w_res_real(17) <= '1';
        else
            -- 9.30 --> 3.15
            w_res_real <= w_real_res_long(32 downto 15);
        end if;
    end process;

    -- 8.30 + 8.30 = 9.30
    w_real_res_long <= resize(i_real_mul, 39) + resize(w_cr_sign_ext, 39);
    -- 3.15 --> 8.30
    w_cr_sign_ext <= resize(i_stage_data.c_real, 38) sll 15;
    -- 9.30 --> 3.15

    -- Truncate from 8.30 to 3.15
    IM: process(i_img_res_long)
	begin
        if i_img_res_long(37) = '0' and i_img_res_long(37 downto 32) /= 0 then
            -- Overflow --> Take max value
            w_res_imag <= (others => '1');
            w_res_imag(17) <= '0';
        elsif i_img_res_long(37) = '1' and i_img_res_long(37 downto 32) /= "111111" then
            -- Underflow --> Take min value
            w_res_imag <= (others => '0');
            w_res_imag(17) <= '1';
        else
            -- 9.30 --> 3.15
            w_res_imag <= i_img_res_long(32 downto 15);
        end if;
    end process;

    -- No Magnitude in this stage as its result is already ready

end architecture;