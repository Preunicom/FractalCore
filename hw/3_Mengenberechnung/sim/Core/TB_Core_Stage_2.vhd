----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/28/2026 08:20:00 AM
-- Design Name: 
-- Module Name: TB_Core_Stage_2 - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing stage 2 of the core.
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

entity TB_Core_Stage_2 is
end TB_Core_Stage_2;

architecture Testbench of TB_Core_Stage_2 is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_clk : std_logic := '0';
    signal s_resetn : std_logic;
    signal s_stage_data : t_stage_data := c_STAGE_DATA_RESET;
    signal s_zr_add_zi : signed(18 downto 0);
    signal s_zr_sub_zi : signed(18 downto 0);
    signal s_2zr_mul_zi : signed(36 downto 0);
    signal s_zr_mul_zr : signed(35 downto 0);
    signal s_zi_mul_zi : signed(35 downto 0);
    
    -- CHECK
    signal c_stage_data : t_stage_data;
    signal c_real_mul : signed(37 downto 0);
    signal c_img_res_long : signed(37 downto 0);
    signal c_magnitude_res : signed(36 downto 0);

    -- TEST MANAGEMENT
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    
   UUT: entity work.Core_Stage_2
   port map (
    i_resetn        => s_resetn,
    i_clk           => s_clk,
    i_stage_data    => s_stage_data,
    i_zr_add_zi     => s_zr_add_zi,
    i_zr_sub_zi     => s_zr_sub_zi,
    i_2zr_mul_zi    => s_2zr_mul_zi,
    i_zr_mul_zr     => s_zr_mul_zr,
    i_zi_mul_zi     => s_zi_mul_zi,
    o_stage_data    => c_stage_data,
    o_real_mul      => c_real_mul,
    o_img_res_long  => c_img_res_long,
    o_magnitude_res => c_magnitude_res
   );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- TEST 1 - Test no fractal bits and positive numbers
        s_zr_add_zi <= to_signed(2, 19) sll 15;
        s_zr_sub_zi <= to_signed(3, 19) sll 15;
        s_2zr_mul_zi <= to_signed(4, 37) sll 30;
        s_stage_data.c_img <= to_signed(2, 18) sll 15;
        s_zr_mul_zr  <= to_signed(3, 36) sll 30;
        s_zi_mul_zi   <= to_signed(5, 36) sll 30;
        wait until rising_edge(s_clk);
        -- TEST 2 -  Test fractal bits and negative numbers
        s_zr_add_zi <= to_signed(-5, 19) sll 13; -- -1.25 -> 1.01 -> Shift -2
        s_zr_sub_zi <= to_signed(25, 19) sll 12; -- 3.125 -> 11.001 -> Shift -3
        s_2zr_mul_zi <= to_signed(-7, 37) sll 29; -- -3.5 -> 11.1 -> Shift -1
        s_stage_data.c_img <= to_signed(-13, 18) sll 12; -- -1.625 -> 1.101 -> Shift -3
        s_zr_mul_zr  <= to_signed(-17, 36) sll 26; -- -1.0625 -> 1.0001 -> Shift -4
        s_zi_mul_zi   <= to_signed(11, 36) sll 29; -- 5.5 -> 101.1 -> shift -1
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        -- TEST 1
        assert c_real_mul = to_signed(6, 38) sll 30
            report "real mul failed!" & LF
                & " Exp.: " & to_string(to_signed(6, 38) sll 30) & LF
                & " Got:  " & to_string(c_real_mul)
            severity failure;
        assert c_img_res_long = to_signed(6, 38) sll 30
            report "Imag add failed!" & LF
                & " Exp.: " & to_string(to_signed(6, 38) sll 30) & LF
                & " Got:  " & to_string(c_img_res_long)
            severity failure;
        assert c_magnitude_res = to_signed(8, 37) sll 30
            report "Magnitude failed!" & LF
                & " Exp.: " & to_string(to_signed(8, 37) sll 30) & LF
                & " Got:  " & to_string(c_magnitude_res)
            severity failure;
        assert c_stage_data.c_img = to_signed(2, 18) sll 15
            report "Stage data failed!" & LF
                & " Exp.: " & to_string(to_signed(2, 18) sll 15) & LF
                & " Got:  " & to_string(c_stage_data.c_img)
            severity failure;
        wait until rising_edge(s_clk);
        -- TEST 2
        assert c_real_mul = to_signed(-125, 38) sll 25 -- (-3.90625) -11.11101 -> Shift -5
            report "real mul failed!" & LF
                & " Exp.: " & to_string(to_signed(125, 38) sll 25) & "(-3.90625)" & LF
                & " Got:  " & to_string(c_real_mul)
            severity failure;
        assert c_img_res_long = to_signed(-41, 38) sll 27 -- (-5.125) -101.001 -> Shift -3
            report "Imag add failed!" & LF
                & " Exp.: " & to_string(to_signed(-41, 38) sll 27) & "(-5.125)" & LF
                & " Got:  " & to_string(c_img_res_long)
            severity failure;
        assert c_magnitude_res = to_signed(71, 37) sll 26 -- (4,4375) 100.0111 -> Shift -4
            report "Magnitude failed!" & LF
                & " Exp.: " & to_string(to_signed(8, 37) sll 30) & LF
                & " Got:  " & to_string(c_magnitude_res)
            severity failure;
        assert c_stage_data.c_img = to_signed(-13, 18) sll 12
            report "Stage data failed!" & LF
                & " Exp.: " & to_string(to_signed(-13, 18) sll 12) & LF
                & " Got:  " & to_string(c_stage_data.c_img)
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
            wait for tbase;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;
