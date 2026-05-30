----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/28/2026 10:16:00 AM
-- Design Name: 
-- Module Name: TB_Core - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the core for calculating the mandelbrot set.
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
use work.Pkg_TB_Utils.all;

entity TB_Core is
end TB_Core;

architecture Testbench of TB_Core is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_clk : std_logic := '0';
    signal s_resetn : std_logic;
    signal s_pixel_data : t_pixel_data := c_PIXEL_DATA_RESET;
    signal s_valid : std_logic;
    signal s_ready : std_logic;

    -- CHECK
    signal c_ready : std_logic;
    signal c_valid : std_logic;
    signal c_pixel_result : t_pixel_result;

    -- TEST MANAGEMENT
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    
    UUT: entity work.Core
    port map (
        i_resetn        => s_resetn,
        i_clk           => s_clk,
        i_pixel_data    => s_pixel_data,
        i_valid         => s_valid,
        o_ready         => c_ready,
        i_ready         => s_ready,
        o_valid         => c_valid,
        o_pixel_result  => c_pixel_result
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- TEST 0 - 0 iterations
        s_pixel_data.video_frame_idx <= "00";
        s_pixel_data.video_pix_col <= "0000000000";
        s_pixel_data.video_pix_row <= "000000000";
        s_pixel_data.z_real <= std_logic_vector(to_signed(2, 18) sll 15);
        s_pixel_data.z_img <= std_logic_vector(to_signed(2, 18) sll 15);
        s_pixel_data.c_real <= std_logic_vector(to_signed(2, 18) sll 15);
        s_pixel_data.c_img <= std_logic_vector(to_signed(2, 18) sll 15);
        s_valid <= '1';
        s_ready <= '0';
        wait until rising_edge(s_clk);
        -- TEST 1 - 2 iteration
        s_pixel_data.video_frame_idx <= "01";
        s_pixel_data.video_pix_col <= "0000000001";
        s_pixel_data.video_pix_row <= "000000001";
        s_pixel_data.z_real <= (others => '0');
        s_pixel_data.z_img <= (others => '0');
        s_pixel_data.c_real <= std_logic_vector(to_signed(5, 18) sll 13); -- 1.01 -> 1.25
        s_pixel_data.c_img <= std_logic_vector(to_signed(1, 18) sll 13); -- 0.01 -> 0.25
        s_valid <= '1';
        s_ready <= '0';
        wait until rising_edge(s_clk);
        -- TEST 2 - >0 & <100 iterations
        s_pixel_data.video_frame_idx <= "10";
        s_pixel_data.video_pix_col <= "0000000010";
        s_pixel_data.video_pix_row <= "000000010";
        s_pixel_data.z_real <= (others => '0');
        s_pixel_data.z_img  <= (others => '0');
        s_pixel_data.c_real <= std_logic_vector(to_signed(-24366, 18)); -- -0.7436
        s_pixel_data.c_img  <= std_logic_vector(to_signed(4316, 18));   --  0.1318
        s_valid <= '1';
        s_ready <= '0';
        wait until rising_edge(s_clk);
        -- TEST 3 - >100 iterations (convergent)
        s_pixel_data.video_frame_idx <= "11";
        s_pixel_data.video_pix_col <= "0000000011";
        s_pixel_data.video_pix_row <= "000000011";
        s_pixel_data.z_real <= std_logic_vector(to_signed(1, 18) sll 12); -- 0.125 = 0.001 -> Shift -3
        s_pixel_data.z_img  <= std_logic_vector(to_signed(1, 18) sll 14); -- 0.5 = 0.1 -> Shift -1
        s_pixel_data.c_real <= std_logic_vector(to_signed(-1, 18) sll 12); -- -0.125 = -0.001 -> Shift -3
        s_pixel_data.c_img  <= std_logic_vector(to_signed(1, 18) sll 13);   --  0.25 = 0.01 -> Shift -2
        s_valid <= '1';
        s_ready <= '0';
        for i in 1 to 152 loop -- Transmit test 1 first
            wait until rising_edge(s_clk);
        end loop;
        s_ready <= '1';
        wait_for_handshake(s_clk, s_valid, c_ready);
        s_valid <= '0';
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        -- TEST 0
        wait_for_handshake(s_clk, c_valid, s_ready);
        assert c_pixel_result.video_frame_idx = "00"
            report "Frame Idx. is wrong!"
                & " Exp.: 00"
                & " Got. " & to_string(c_pixel_result.video_frame_idx)
            severity failure;
        assert c_pixel_result.video_pix_col = "0000000000"
            report "Pixel Column is wrong!" & LF
                & " Exp.: 0000000000" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_col)
            severity failure;
        assert c_pixel_result.video_pix_row = "000000000"
            report "Pixel Row is wrong!" & LF
                & " Exp.: 000000000" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_row)
            severity failure;
        assert c_pixel_result.is_convergent = '0'
            report "Convergent flag is wrong!"
                & " Exp.: 0"
                & " Got. " & std_logic'image(c_pixel_result.is_convergent)
            severity failure;
        assert c_pixel_result.cycles_until_divergent = std_logic_vector(to_unsigned(0, 8))
            report "Iteration amount is wrong!" & LF
                & " Exp.: " & to_string(to_unsigned(0, 8)) & LF
                & " Got.  " & to_string(c_pixel_result.cycles_until_divergent)
            severity failure;
        -- TEST 1
        wait_for_handshake(s_clk, c_valid, s_ready);
        assert c_pixel_result.video_frame_idx = "01"
            report "Frame Idx. is wrong!"
                & " Exp.: 01"
                & " Got. " & to_string(c_pixel_result.video_frame_idx)
            severity failure;
        assert c_pixel_result.video_pix_col = "0000000001"
            report "Pixel Column is wrong!" & LF
                & " Exp.: 0000000001" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_col)
            severity failure;
        assert c_pixel_result.video_pix_row = "000000001"
            report "Pixel Row is wrong!" & LF
                & " Exp.: 000000001" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_row)
            severity failure;
        assert c_pixel_result.is_convergent = '0'
            report "Convergent flag is wrong!"
                & " Exp.: 0"
                & " Got. " & std_logic'image(c_pixel_result.is_convergent)
            severity failure;
        assert c_pixel_result.cycles_until_divergent = std_logic_vector(to_unsigned(2, 8))
            report "Iteration amount is wrong!" & LF
                & " Exp.: " & to_string(to_unsigned(2, 8)) & LF
                & " Got.  " & to_string(c_pixel_result.cycles_until_divergent)
            severity failure;
        -- TEST 2
        wait_for_handshake(s_clk, c_valid, s_ready);
        assert c_pixel_result.video_frame_idx = "10"
            report "Frame Idx. is wrong!"
                & " Exp.: 10"
                & " Got. " & to_string(c_pixel_result.video_frame_idx)
            severity failure;
        assert c_pixel_result.video_pix_col = "0000000010"
            report "Pixel Column is wrong!" & LF
                & " Exp.: 0000000010" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_col)
            severity failure;
        assert c_pixel_result.video_pix_row = "000000010"
            report "Pixel Row is wrong!" & LF
                & " Exp.: 000000010" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_row)
            severity failure;
        assert c_pixel_result.is_convergent = '0'
            report "Convergent flag is wrong!"
                & " Exp.: 0"
                & " Got. " & std_logic'image(c_pixel_result.is_convergent)
            severity failure;
        -- Check no exact iteration value the calculation is sligthtly off due to rounding at the end of one iteration
        -- But the value should be around 60-100 (MatLab solution: 94, Test: 66)
        assert to_integer(unsigned(c_pixel_result.cycles_until_divergent)) > 60
            report "Iteration amount is wrong!" & LF
                & " Exp.: >" & to_string(to_unsigned(60, 8)) & LF
                & " Got.  " & to_string(c_pixel_result.cycles_until_divergent)
            severity failure;
        -- TEST 3
        wait_for_handshake(s_clk, c_valid, s_ready);
        assert c_pixel_result.video_frame_idx = "11"
            report "Frame Idx. is wrong!"
                & " Exp.: 11"
                & " Got. " & to_string(c_pixel_result.video_frame_idx)
            severity failure;
        assert c_pixel_result.video_pix_col = "0000000011"
            report "Pixel Column is wrong!" & LF
                & " Exp.: 0000000011" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_col)
            severity failure;
        assert c_pixel_result.video_pix_row = "000000011"
            report "Pixel Row is wrong!" & LF
                & " Exp.: 000000011" & LF
                & " Got. " & to_string(c_pixel_result.video_pix_row)
            severity failure;
        assert c_pixel_result.is_convergent = '1'
            report "Convergent flag is wrong!"
                & " Exp.: 1"
                & " Got. " & std_logic'image(c_pixel_result.is_convergent)
            severity failure;
        assert c_pixel_result.cycles_until_divergent = std_logic_vector(to_unsigned(101, 8))
            report "Iteration amount is wrong!" & LF
                & " Exp.: " & to_string(to_unsigned(101, 8)) & LF
                & " Got.  " & to_string(c_pixel_result.cycles_until_divergent)
            severity failure;
        wait until rising_edge(s_clk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 1000*tbase;
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
