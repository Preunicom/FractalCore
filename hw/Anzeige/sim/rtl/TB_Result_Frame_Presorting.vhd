----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/18/2026 9:18:00 PM
-- Design Name: 
-- Module Name: TB_Result_Frame_Presorting - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Testing the presorting algorithm.
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
use work.Pkg_TB_Utils.all;

entity TB_Result_Frame_Presorting is
end TB_Result_Frame_Presorting;

architecture Testbench of TB_Result_Frame_Presorting is
    constant tbase : time := 10 ns;
        
    -- STIMULI
    signal s_resetn                      : std_logic;
    signal s_clk                         : std_logic := '0';
    signal s_valid                       : std_logic := '0';
    signal s_video_pix_col               : std_logic_vector(9 downto 0) := (others => '0');
    signal s_video_pix_row               : std_logic_vector(8 downto 0) := (others => '0');
    signal s_video_frame_idx             : std_logic_vector(1 downto 0) := (others => '0');
    signal s_is_convergent               : std_logic := '0';
    signal s_cycles_until_divergent      : std_logic_vector(7 downto 0) := (others => '0');
    signal s_f_X0_ready                  : std_logic := '0';
    signal s_f_X1_ready                  : std_logic := '0';

    -- CHECK
    signal c_ready                       : std_logic;
    signal c_f_X0_valid                  : std_logic;
    signal c_f_X0_video_pix_col          : std_logic_vector(9 downto 0) := (others => '0');
    signal c_f_X0_video_pix_row          : std_logic_vector(8 downto 0) := (others => '0');
    signal c_f_X0_video_frame_idx        : std_logic_vector(1 downto 0) := (others => '0');
    signal c_f_X0_is_convergent          : std_logic;
    signal c_f_X0_cycles_until_divergent : std_logic_vector(7 downto 0) := (others => '0');
    signal c_f_X1_valid                  : std_logic;
    signal c_f_X1_video_pix_col          : std_logic_vector(9 downto 0) := (others => '0');
    signal c_f_X1_video_pix_row          : std_logic_vector(8 downto 0) := (others => '0');
    signal c_f_X1_video_frame_idx        : std_logic_vector(1 downto 0) := (others => '0');
    signal c_f_X1_is_convergent          : std_logic;
    signal c_f_X1_cycles_until_divergent : std_logic_vector(7 downto 0) := (others => '0');
   
    -- TB MANAGE SIGNALS
    signal tb_even_test_ended : boolean := false;
    signal tb_odd_test_ended : boolean := false;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    UUT: entity work.Result_Frame_Presorting
    port map (
        i_resetn                      => s_resetn,
        i_clk                         => s_clk,
        i_valid                       => s_valid,
        i_video_pix_col               => s_video_pix_col,
        i_video_pix_row               => s_video_pix_row,
        i_video_frame_idx             => s_video_frame_idx,
        i_is_convergent               => s_is_convergent,
        i_cycles_until_divergent      => s_cycles_until_divergent,
        o_ready                       => c_ready,
        i_f_X0_ready                  => s_f_X0_ready,
        o_f_X0_valid                  => c_f_X0_valid,
        o_f_X0_video_pix_col          => c_f_X0_video_pix_col,
        o_f_X0_video_pix_row          => c_f_X0_video_pix_row,
        o_f_X0_video_frame_idx        => c_f_X0_video_frame_idx,
        o_f_X0_is_convergent          => c_f_X0_is_convergent,
        o_f_X0_cycles_until_divergent => c_f_X0_cycles_until_divergent,
        i_f_X1_ready                  => s_f_X1_ready,
        o_f_X1_valid                  => c_f_X1_valid,
        o_f_X1_video_pix_col          => c_f_X1_video_pix_col,
        o_f_X1_video_pix_row          => c_f_X1_video_pix_row,
        o_f_X1_video_frame_idx        => c_f_X1_video_frame_idx,
        o_f_X1_is_convergent          => c_f_X1_is_convergent,
        o_f_X1_cycles_until_divergent => c_f_X1_cycles_until_divergent
    );

    s_resetn <= '0', '1' after 10*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI_WRITE: process
	begin
        wait until s_resetn = '1';
        for i in 1 to 20000 loop
            s_video_frame_idx <= std_logic_vector(to_unsigned(i mod 4, 2));
            s_video_pix_col <= std_logic_vector(to_unsigned(i mod 640, 10));
            s_video_pix_row <= std_logic_vector(to_unsigned(i mod 480, 9));
            s_cycles_until_divergent <= std_logic_vector(to_unsigned(i mod 256, 8));
            s_is_convergent <= '0';
            s_valid <= '1';
            wait_for_handshake(s_clk, s_valid, c_ready);
        end loop;
        s_valid <= '0';
        wait;
    end process;

    STIMULI_READ_EVEN: process
	begin
        wait until s_resetn = '1';
        while true loop
            s_f_X0_ready <= '1';
            wait_for_handshake(s_clk, c_f_X0_valid, s_f_X0_ready);
            s_f_X0_ready <= '0';
            wait for 3*tbase;
        end loop;
    end process;

    STIMULI_READ_ODD: process
	begin
        wait until s_resetn = '1';
        while true loop
            s_f_X1_ready <= '1';
            wait_for_handshake(s_clk, c_f_X1_valid, s_f_X1_ready);
            s_f_X1_ready <= '0';
            wait for 3*tbase;
        end loop;
    end process;

    CHECK_EVEN: process
	begin
        wait until s_resetn = '1';
        for i in 1 to 10000 loop
            wait_for_handshake(s_clk, c_f_X0_valid, s_f_X0_ready);
            assert to_integer(unsigned(c_f_X0_video_frame_idx)) = (i*2) mod 4
                report "Wrong even column value!" & LF
                        & " Exp.: " & to_string((i*2) mod 640) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X0_video_pix_col)))
                severity failure;
            assert to_integer(unsigned(c_f_X0_video_pix_col)) = (i*2) mod 640
                report "Wrong even column value!" & LF
                        & " Exp.: " & to_string((i*2) mod 640) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X0_video_pix_col)))
                severity failure;
            assert to_integer(unsigned(c_f_X0_video_pix_row)) = (i*2) mod 480
                report "Wrong even row value!" & LF
                        & " Exp.: " & to_string((i*2) mod 480) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X0_video_pix_row)))
                severity failure;
            assert to_integer(unsigned(c_f_X0_cycles_until_divergent)) = (i*2) mod 256
                report "Wrong even cycles until divergent amount value!" & LF
                        & " Exp.: " & to_string((i*2) mod 256) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X0_cycles_until_divergent)))
                severity failure;
            assert c_f_X0_is_convergent = '0'
                report "Wrong even convergent flag!" & LF
                        & " Exp.: 0" & LF
                        & " Got:  " & std_logic'image(c_f_X0_is_convergent)
                severity failure;
        end loop;
        wait until rising_edge(s_clk);
        assert c_f_X0_valid = '0'
            report "Even FIFO is not empty at the end but should be!"
            severity failure;
        wait until rising_edge(s_clk);
        tb_even_test_ended <= true;
        wait;
    end process;

    CHECK_ODD: process
	begin
        wait until s_resetn = '1';
        for i in 0 to 9999 loop
            wait_for_handshake(s_clk, c_f_X1_valid, s_f_X1_ready);
            assert to_integer(unsigned(c_f_X1_video_frame_idx)) = (i*2 + 1) mod 4
                report "Wrong odd column value!" & LF
                        & " Exp.: " & to_string((i*2 + 1) mod 640) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X1_video_pix_col)))
                severity failure;
            assert to_integer(unsigned(c_f_X1_video_pix_col)) = (i*2 + 1) mod 640
                report "Wrong odd column value!" & LF
                        & " Exp.: " & to_string((i*2 + 1) mod 640) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X1_video_pix_col)))
                severity failure;
            assert to_integer(unsigned(c_f_X1_video_pix_row)) = (i*2 + 1) mod 480
                report "Wrong odd row value!" & LF
                        & " Exp.: " & to_string((i*2 + 1) mod 480) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X1_video_pix_row)))
                severity failure;
            assert to_integer(unsigned(c_f_X1_cycles_until_divergent)) = (i*2 + 1) mod 256
                report "Wrong odd cycles until divergent amount value!" & LF
                        & " Exp.: " & to_string((i*2 + 1) mod 256) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_f_X1_cycles_until_divergent)))
                severity failure;
            assert c_f_X1_is_convergent = '0'
                report "Wrong odd convergent flag!" & LF
                        & " Exp.: 0" & LF
                        & " Got:  " & std_logic'image(c_f_X1_is_convergent)
                severity failure;
        end loop;
        wait until rising_edge(s_clk);
        assert c_f_X1_valid = '0'
            report "Odd FIFO is not empty at the end but should be!"
            severity failure;
        wait until rising_edge(s_clk);
        tb_odd_test_ended <= true;
        wait;
    end process;

    tb_test_ended <= true when tb_even_test_ended = true and tb_odd_test_ended = true else false;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 50000*tbase;
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
