----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Core_Stage_1 - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Calculation of part 1 of the Mandelbrot set equation.
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

entity Core_Stage_1 is
    port(
        i_clk : in std_logic;
        i_stage_data : in t_stage_data;
        o_stage_data : out t_stage_data;
        o_zr_add_zi : out signed(18 downto 0);
        o_zr_sub_zi : out signed(18 downto 0);
        o_2zr_mul_zi : out signed(36 downto 0);
        o_zr_mul_zr : out signed(35 downto 0);
        o_zi_mul_zi : out signed(35 downto 0)
    );
end Core_Stage_1;

architecture Behavioral of Core_Stage_1 is
    signal w_2zr : signed(18 downto 0); -- 4.15
begin

    STAGE_DATA: process(i_clk)
	begin
        if rising_edge(i_clk) then
            -- No reset necessary, as the stage will be reset to invalid in the Stage Control Unit
            o_stage_data <= i_stage_data;
        end if;
    end process;

    RE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            -- No reset necessary, as the stage will be reset to invalid in the Stage Control Unit
            -- 3.15 + 3.15 = 4.15
            o_zr_add_zi <= resize(i_stage_data.z_real, 19) + resize(i_stage_data.z_img, 19);
            -- 3.15 - 3.15 = 4.15
            o_zr_sub_zi <= resize(i_stage_data.z_real, 19) - resize(i_stage_data.z_img, 19);
        end if;
    end process;

    IM: process(i_clk)
	begin
        if rising_edge(i_clk) then
            -- No reset necessary, as the stage will be reset to invalid in the Stage Control Unit
            -- 4.15 * 3.15 = 7.30
            -- 4.15 has more than 18 Bits, but as 3.15 has 18 bits and the DSPs on the Arty A7 supports 25x18 Bit multiplications, this is ok.
            o_2zr_mul_zi <= w_2zr * i_stage_data.z_img;
        end if;
    end process;
    
    -- z_real * 2
    -- 3.15 * 1.0 = 4.15
    w_2zr <= i_stage_data.z_real & '0';

    MAGNITUDE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            -- No reset necessary, as the stage will be reset to invalid in the Stage Control Unit
            -- 3.15 * 3.15 = 6.30
            o_zr_mul_zr <= i_stage_data.z_real * i_stage_data.z_real;
            -- 3.15 * 3.15 = 6.30
            o_zi_mul_zi <= i_stage_data.z_img * i_stage_data.z_img;
        end if;
    end process;

end architecture;