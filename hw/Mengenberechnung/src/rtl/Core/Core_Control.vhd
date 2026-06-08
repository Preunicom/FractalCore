----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Core_Control - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Conctrols the pipelined calculation of the Mandelbrot set equation.
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

entity Core_Control is
    generic(
        g_MAX_ITERATIONS : integer := 100
    );
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        i_magnitude : in signed(36 downto 0);
        i_load_data_valid : in std_logic;
        i_transmit_partner_ready : in std_logic;
        o_transmit_data_valid : out std_logic;
        o_transmit_is_convergent : out std_logic;
        o_transmit_iteration_data : out std_logic_vector(7 downto 0);
        o_load_data_ready : out std_logic;
        o_select_loaded_data : out std_logic
    );
end Core_Control;

architecture Behavioral of Core_Control is
    signal r_s1_control : t_stage_control;
    signal r_s2_control : t_stage_control;
    signal r_s3_control : t_stage_control;
    signal r_select_loaded_data : std_logic;
begin

    assert g_MAX_ITERATIONS < 255
        report "The MAX_ITERATIONS amount has to be less than 255!"
        severity failure;

    REG_S3_to_1: process(i_clk) 
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_s1_control <= c_STAGE_CONTROL_RESET;
            else
                r_s1_control <= r_s3_control;
                -- Only check/add iteration if the data is valid and not in the loading process
                if r_s3_control.valid = '1' and r_select_loaded_data = '0' then
                    -- 7.30 --> 4 = 1 at pos. 32
                    if i_magnitude(36 downto 32) /= "00000" -- End calc. because of Magnitude
                    or r_s3_control.ready = '1' then -- Remain ended calc.
                        r_s1_control.ready <= '1';
                        r_s1_control.iteration_counter <= r_s3_control.iteration_counter;
                    elsif r_s3_control.iteration_counter >= g_MAX_ITERATIONS then -- End calc. because of max. iterations reached
                        r_s1_control.ready <= '1';
                        -- Set convergent
                        r_s1_control.iteration_counter <= g_MAX_ITERATIONS + 1;
                    else
                        r_s1_control.iteration_counter <= r_s3_control.iteration_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    o_transmit_data_valid <= r_s1_control.ready and r_s1_control.valid;
    o_transmit_iteration_data <= std_logic_vector(to_signed(r_s1_control.iteration_counter, 8));
    o_transmit_is_convergent <= '1' when r_s1_control.iteration_counter > g_MAX_ITERATIONS else '0';

    REG_S1_to_2: process(i_clk) 
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_s2_control <= c_STAGE_CONTROL_RESET;
            else
                r_s2_control <= r_s1_control;
                if r_s1_control.ready = '1' and r_s1_control.valid = '1' and i_transmit_partner_ready = '1' then
                    -- Data was transmitted to partner
                    r_s2_control.valid <= '0';
                    r_s2_control.ready <= '0';
                    r_s2_control.iteration_counter <= 0;
                end if;
            end if;
        end if;
    end process;

    o_load_data_ready <= not r_s2_control.valid;

    REG_S2_to_3: process(i_clk) 
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_s3_control <= c_STAGE_CONTROL_RESET;
                r_select_loaded_data <= '0';
            else
                r_s3_control <= r_s2_control;
                if r_s2_control.valid ='0' and i_load_data_valid = '1' then 
                    -- Data was loaded
                    r_s3_control.valid <= '1';
                    r_s3_control.ready <= '0';
                    r_s3_control.iteration_counter <= 0;
                    r_select_loaded_data <= '1';
                else
                    r_select_loaded_data <= '0';
                end if;
            end if;
        end if;
    end process;

    o_select_loaded_data <= r_select_loaded_data;

end architecture;