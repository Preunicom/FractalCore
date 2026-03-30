----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 07:08:00 PM
-- Design Name: 
-- Module Name: TB_Dispatcher - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Dispatcher.
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

library work;
use work.Pkg_Core.all;
use work.Pkg_TB_Utils.all;

entity TB_Dispatcher is
end TB_Dispatcher;

architecture Testbench of TB_Dispatcher is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_valid : std_logic;
    signal s_pixel_data : t_pixel_data  := c_PIXEL_DATA_RESET;
    signal s_s1_ready : std_logic;
    signal s_s2_ready : std_logic;
    -- CHECK
    signal c_ready : std_logic;
    signal c_s1_valid : std_logic;
    signal c_s1_pixel_data : t_pixel_data;
    signal c_s2_valid : std_logic;
    signal c_s2_pixel_data : t_pixel_data;

    signal tb_s1_check_ended : boolean := false;
    signal tb_s2_check_ended : boolean := false;
    signal tb_test_passed : boolean := false;

    procedure check_slave(
        signal valid : in std_logic;
        signal ready : in std_logic;
        signal data : in std_logic_vector;
        constant exp_data : in std_logic_vector
    ) is
    begin
        wait_for_handshake(s_clk, valid, ready);
        assert data = exp_data
            report "Wrong pixel data (video pix row) received!" & LF
                & "Exp.: " & to_string(exp_data) & LF
                & "Got:  " & to_string(data)
            severity failure;
    end procedure;

begin
    UUT: entity work.Dispatcher
    port map (
        i_resetn        => s_resetn,
        i_clk           => s_clk,
        i_valid         => s_valid,
        i_pixel_data    => s_pixel_data,
        o_ready         => c_ready,
        i_s1_ready      => s_s1_ready,
        o_s1_valid      => c_s1_valid,
        o_s1_pixel_data => c_s1_pixel_data,
        i_s2_ready      => s_s2_ready,
        o_s2_valid      => c_s2_valid,
        o_s2_pixel_data => c_s2_pixel_data
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI_M: process
	begin
        wait until s_resetn = '1';
        for i in 1 to 6 loop
            s_pixel_data.video_pix_row <= std_logic_vector(to_unsigned(i, 9));
            s_valid <= '1';
            wait_for_handshake(s_clk, s_valid, c_ready);
        end loop;
        s_valid <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(s_clk);
        end loop;
        for i in 7 to 10 loop
            s_pixel_data.video_pix_row <= std_logic_vector(to_unsigned(i, 9));
            s_valid <= '1';
            wait_for_handshake(s_clk, s_valid, c_ready);
        end loop;
        wait;
    end process;

    STIMULI_S1: process
	begin
        wait until s_resetn = '1';
        s_s1_ready <= '1';
        wait_for_handshake(s_clk, c_s1_valid, s_s1_ready);
        s_s1_ready <= '0';
        wait_for_handshake(s_clk, c_s2_valid, s_s2_ready);
        s_s1_ready <= '1';
        wait_for_handshake(s_clk, c_s1_valid, s_s1_ready);
        s_s1_ready <= '1';
        wait_for_handshake(s_clk, c_s1_valid, s_s1_ready);
        s_s1_ready <= '1';
        wait_for_handshake(s_clk, c_s1_valid, s_s1_ready);
        s_s1_ready <= '1';
        wait_for_handshake(s_clk, c_s1_valid, s_s1_ready);
        wait;
    end process;

    STIMULI_S2: process
	begin
        wait until s_resetn = '1';
        s_s2_ready <= '1';
        wait_for_handshake(s_clk, c_s2_valid, s_s2_ready);
        s_s2_ready <= '1';
        wait_for_handshake(s_clk, c_s2_valid, s_s2_ready);
        s_s2_ready <= '1';
        wait_for_handshake(s_clk, c_s2_valid, s_s2_ready);
        s_s2_ready <= '0';
        wait;
    end process;

    CHECK_S1: process
	begin
        check_slave(c_s1_valid, s_s1_ready, c_s1_pixel_data.video_pix_row, std_logic_vector(to_unsigned(1, 9)));
        check_slave(c_s1_valid, s_s1_ready, c_s1_pixel_data.video_pix_row, std_logic_vector(to_unsigned(3, 9)));
        check_slave(c_s1_valid, s_s1_ready, c_s1_pixel_data.video_pix_row, std_logic_vector(to_unsigned(5, 9)));
        check_slave(c_s1_valid, s_s1_ready, c_s1_pixel_data.video_pix_row, std_logic_vector(to_unsigned(7, 9)));
        check_slave(c_s1_valid, s_s1_ready, c_s1_pixel_data.video_pix_row, std_logic_vector(to_unsigned(8, 9)));
        tb_s1_check_ended <= true;
        wait;
    end process;

    CHECK_S2: process
	begin
        check_slave(c_s2_valid, s_s2_ready, c_s2_pixel_data.video_pix_row, std_logic_vector(to_unsigned(2, 9)));
        check_slave(c_s2_valid, s_s2_ready, c_s2_pixel_data.video_pix_row, std_logic_vector(to_unsigned(4, 9)));
        check_slave(c_s2_valid, s_s2_ready, c_s2_pixel_data.video_pix_row, std_logic_vector(to_unsigned(6, 9)));
        tb_s2_check_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until (tb_s1_check_ended = true and tb_s2_check_ended = true) for 100*tbase;
        if tb_s1_check_ended = true and tb_s2_check_ended = true then
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
