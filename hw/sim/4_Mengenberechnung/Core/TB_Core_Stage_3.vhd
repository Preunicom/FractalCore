----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/28/2026 09:03:00 AM
-- Design Name: 
-- Module Name: TB_Core_Stage_3 - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing stage 3 of the core.
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
use std.env.finish;
use std.textio.all;

library work;
use work.Pkg_Core.all;

entity TB_Core_Stage_3 is
end TB_Core_Stage_3;

architecture Testbench of TB_Core_Stage_3 is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_clk : std_logic := '0';
    signal s_resetn : std_logic;
    signal s_stage_data : t_stage_data := c_STAGE_DATA_RESET;
    signal s_real_mul : signed(37 downto 0);
    signal s_img_res_long : signed(37 downto 0);

    -- CHECK
    signal c_stage_data : t_stage_data;

    -- TEST MANAGEMENT
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    
    UUT: entity work.Core_Stage_3
    port map (
        i_resetn       => s_resetn,
        i_clk          => s_clk,
        i_stage_data   => s_stage_data,
        i_real_mul     => s_real_mul,
        i_img_res_long => s_img_res_long,
        o_stage_data   => c_stage_data
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- TEST 1 - Test no fractal bits and positive numbers
        s_real_mul <= to_signed(1, 38) sll 30;
        s_stage_data.c_real <= to_signed(2, 18) sll 15;
        s_img_res_long <= to_signed(2, 38) sll 30;
        wait until rising_edge(s_clk);
        -- TEST 2 -  Test fractal bits and negative numbers
        s_real_mul <= to_signed(-3, 38) sll 29; -- (-1.5) -1.1 -> Shift -1
        s_stage_data.c_real <= to_signed(9, 18) sll 12; -- (1.125) 1.001 -> Shift -3
        s_img_res_long <= to_signed(-21, 38) sll 27; -- (-2.625) -10.101 -> Shift -3
        wait until rising_edge(s_clk);
        -- TEST 3 -  Test Overflow / Underflow
        s_real_mul <= to_signed(9, 38) sll 29; -- (4.5) 100.1 -> Shift -1
        s_stage_data.c_real <= to_signed(-1, 18) sll 14; -- (-0.5) -0.1 -> Shift -1
        s_img_res_long <= to_signed(-5, 38) sll 30; -- (-5) -101 -> Shift -0
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        -- TEST 1
        assert c_stage_data.z_real = to_signed(3, 18) sll 15
            report "Real failed!" & LF
                & " Exp.: " & to_string(to_signed(3, 18) sll 15) & LF
                & " Got:  " & to_string(c_stage_data.z_real)
            severity failure;
        assert c_stage_data.z_img = to_signed(2, 18) sll 15
            report "Imag failed!" & LF
                & " Exp.: " & to_string(to_signed(2, 18) sll 15) & LF
                & " Got:  " & to_string(c_stage_data.z_img)
            severity failure;
        assert c_stage_data.c_real = to_signed(2, 18) sll 15
            report "Stage data failed!" & LF
                & " Exp.: " & to_string(to_signed(2, 18) sll 15) & LF
                & " Got:  " & to_string(c_stage_data.c_real)
            severity failure;
        wait until rising_edge(s_clk);
        -- TEST 2
        assert c_stage_data.z_real = to_signed(-3, 18) sll 12 -- (-0.375) -0.011 -> Shift -3
            report "Real failed!" & LF
                & " Exp.: " & to_string(to_signed(-3, 18) sll 12) & LF
                & " Got:  " & to_string(c_stage_data.z_real)
            severity failure;
        assert c_stage_data.z_img = to_signed(-21, 18) sll 12
            report "Imag failed!" & LF
                & " Exp.: " & to_string(to_signed(2, 18) sll 15) & LF
                & " Got:  " & to_string(c_stage_data.z_img)
            severity failure;
        assert c_stage_data.c_real = to_signed(9, 18) sll 12
            report "Stage data failed!" & LF
                & " Exp.: " & to_string(to_signed(9, 18) sll 12) & LF
                & " Got:  " & to_string(c_stage_data.c_real)
            severity failure;
        wait until rising_edge(s_clk);
        -- TEST 3
        assert c_stage_data.z_real = to_signed((2**17)-1, 18) -- (4) -> Overflow
            report "Real failed!" & LF
                & " Exp.: " & to_string(to_signed((2**17)-1, 18)) & LF
                & " Got:  " & to_string(c_stage_data.z_real)
            severity failure;
        assert c_stage_data.z_img = to_signed(-2**17, 18) -- (-5) -> Underflow
            report "Imag failed!" & LF
                & " Exp.: " & to_string(to_signed(-2**17, 18)) & LF
                & " Got:  " & to_string(c_stage_data.z_img)
            severity failure;
        assert c_stage_data.c_real = to_signed(-1, 18) sll 14
            report "Stage data failed!" & LF
                & " Exp.: " & to_string(to_signed(-1, 18) sll 14) & LF
                & " Got:  " & to_string(c_stage_data.c_real)
            severity failure;
        wait until rising_edge(s_clk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 100*tbase;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;
