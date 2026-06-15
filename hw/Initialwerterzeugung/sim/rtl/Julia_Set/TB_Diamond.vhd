----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/23/2026 04:46:00 AM
-- Design Name: 
-- Module Name: TB_Diamond - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Diamond c generation.
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
use IEEE.numeric_std.all;
use std.env.finish;

library work;
use work.Pkg_TB_Utils.all;

entity TB_Diamond is
end TB_Diamond;

architecture Testbench of TB_Diamond is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_en : std_logic;
    signal s_diamond_height: std_logic_vector(15 downto 0);
    signal s_diamond_width : std_logic_vector(15 downto 0);
    
    -- CHECK
    signal c_target_re : std_logic_vector(16 downto 0);
    signal c_target_im : std_logic_vector(16 downto 0);

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Diamond
    port map (
        i_resetn            => s_resetn,
        i_clk               => s_clk,
        i_en                => s_en,
        i_diamond_height    => s_diamond_height,
        i_diamond_width     => s_diamond_width,
        o_target_re         => c_target_re,
        o_target_im         => c_target_im
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        s_en <= '1';
        s_diamond_width  <= std_logic_vector(to_unsigned(65535, 16));
        s_diamond_height <= std_logic_vector(to_unsigned(65535, 16));
        wait until rising_edge(s_clk);
        s_en <= '0';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        s_en <= '1';
        wait until rising_edge(s_clk);
        s_en <= '0';
        wait until rising_edge(s_clk);
        s_en <= '1';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        s_diamond_width  <= std_logic_vector(to_unsigned(2, 16));
        s_diamond_height <= std_logic_vector(to_unsigned(10, 16));
        s_en <= '0';
        wait until rising_edge(s_clk);
        s_en <= '1';
        wait until rising_edge(s_clk);
        s_en <= '0';
        wait until rising_edge(s_clk);
        s_en <= '1';
        wait until rising_edge(s_clk);
        s_en <= '0';
        wait until rising_edge(s_clk);
        s_en <= '1';
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(65535, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(65535, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(0, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(0, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(65535, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(65535, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(-65535, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(-65535, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(0, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(0, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(-65535, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(-65535, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(2, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(2, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(0, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(0, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(10, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(10, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(-2, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(-2, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(0, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_im)
            severity failure;
        wait_for_enabled_clock(s_clk, s_en);
        assert c_target_re = std_logic_vector(to_signed(0, 17))
            report "Wrong RE value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_re)
            severity failure;
        assert c_target_im = std_logic_vector(to_signed(-10, 17))
            report "Wrong IM value received!" & LF
                & "Exp.: " & to_string(std_logic_vector(to_signed(0, 17))) & LF
                & "Got:  " & to_string(c_target_im)
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