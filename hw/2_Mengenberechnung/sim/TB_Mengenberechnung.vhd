----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/29/2026 10:11:00 AM
-- Design Name: 
-- Module Name: TB_Calculation - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the calculation unit for the mandelbrot set.
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

entity TB_Mengenberechnung is
end TB_Mengenberechnung;

architecture Testbench of TB_Mengenberechnung is
    constant tbase_init: time := 20 ns;
    constant tbase_calc : time := 10 ns;
    constant tbase_arbit: time := 15 ns;
    -- STIMULI
    constant c_AMOUNT_CORES : natural := 50;
    constant c_AMOUNT_STIMULI_PER_CASE : integer := 63;
    signal s_clk_init : std_logic := '0';
    signal s_clk_calc : std_logic := '0';
    signal s_clk_color : std_logic := '0';
    signal s_resetn_init : std_logic;
    signal s_resetn_calc : std_logic;
    signal s_resetn_color : std_logic;
    signal s_valid : std_logic;
    signal s_video_pix_col : std_logic_vector(9 downto 0);
    signal s_video_pix_row : std_logic_vector(8 downto 0);
    signal s_video_frame_idx : std_logic_vector(1 downto 0);
    signal s_z0_real : std_logic_vector(17 downto 0);
    signal s_z0_img : std_logic_vector(17 downto 0);
    signal s_c_real : std_logic_vector(17 downto 0);
    signal s_c_img : std_logic_vector(17 downto 0);
    signal s_ready : std_logic;

    -- CHECK
    signal c_ready : std_logic;
    signal c_valid : std_logic;
    signal c_video_pix_col : std_logic_vector(9 downto 0);
    signal c_video_pix_row : std_logic_vector(8 downto 0);
    signal c_video_frame_idx : std_logic_vector(1 downto 0);
    signal c_is_convergent : std_logic;
    signal c_cycles_until_divergent : std_logic_vector(7 downto 0);

    -- TEST MANAGEMENT
    -- Timeout: ca. 1 Core needed for one stimuli iteration with 100 calc iterations with 3 clock cycles each
    --> 300 clock cycles per iteration but as many iterations parallel as we use cores
    --> 300 * (ITER / CORES)
    -- But with less than 3 Cores we need at least 900 + buffer clock cycles (in WC no parallelization)
    constant c_TB_TIMEOUT : natural := 1000 + ((300*c_AMOUNT_STIMULI_PER_CASE)/c_AMOUNT_CORES);
    signal tb_checked_row_1_packets : integer := 0;
    signal tb_checked_row_2_packets : integer := 0;
    signal tb_checked_row_3_packets : integer := 0;
    signal tb_checked_row_4_packets : integer := 0;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    assert c_AMOUNT_STIMULI_PER_CASE < 2**6
        report "This TB supports a maximum of 63 iterations per case! Adjust c_AMOUNT_STIMULI_PER_CASE corresponding!"
        severity failure;
    
    UUT: entity work.Mengenberechnung
    generic map (
        g_AMOUNT_CORES => c_AMOUNT_CORES
    )
    port map (
        i_resetn_calc            => s_resetn_calc,
        i_clk_calc               => s_clk_calc,
        i_clk_init               => s_clk_init,
        i_resetn_init            => s_resetn_init,
        i_valid                  => s_valid,
        i_video_pix_col          => s_video_pix_col,
        i_video_pix_row          => s_video_pix_row,
        i_video_frame_idx        => s_video_frame_idx,
        i_z0_real                => s_z0_real,
        i_z0_img                 => s_z0_img,
        i_c_real                 => s_c_real,
        i_c_img                  => s_c_img,
        o_ready                  => c_ready,
        i_clk_color              => s_clk_color,
        i_resetn_color           => s_resetn_color,
        i_ready                  => s_ready,
        o_valid                  => c_valid,
        o_video_pix_col          => c_video_pix_col,
        o_video_pix_row          => c_video_pix_row,
        o_video_frame_idx        => c_video_frame_idx,
        o_is_convergent          => c_is_convergent,
        o_cycles_until_divergent => c_cycles_until_divergent
    );

    -- The Async FIFO needs to sync the reset, so the usual 1 clock cycle reset is not long enough here
    s_resetn_init <= '0', '1' after 3*tbase_init;
    s_clk_init <= not s_clk_init after 0.5*tbase_init;

    s_resetn_calc <= '0', '1' after 3*tbase_calc;
    s_clk_calc <= not s_clk_calc after 0.5*tbase_calc;

    s_resetn_color <= '0', '1' after 3*tbase_arbit;
    s_clk_color <= not s_clk_color after 0.5*tbase_arbit;

    STIMULI: process
	begin
        wait until s_resetn_init = '1';
        for i in 1 to c_AMOUNT_STIMULI_PER_CASE loop
            -- 2 iterations
            s_video_frame_idx <= "01";
            s_video_pix_col <= std_logic_vector(to_unsigned(i + 2**7, 10));
            s_video_pix_row <= std_logic_vector(to_unsigned(2, 9));
            s_z0_real <= (others => '0');
            s_z0_img <= (others => '0');
            s_c_real <= std_logic_vector(to_signed(5, 18) sll 13); -- 1.01 -> 1.25
            s_c_img <= std_logic_vector(to_signed(1, 18) sll 13); -- 0.01 -> 0.25
            s_valid <= '1';
            s_ready <= '0';
            wait_for_handshake(s_clk_init, s_valid, c_ready);
        end loop;
        s_valid <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(s_clk_init);
        end loop;
        for i in 1 to c_AMOUNT_STIMULI_PER_CASE loop
            -- >0 & <100 iterations
            s_video_frame_idx <= "10";
            s_video_pix_col <= std_logic_vector(to_unsigned(i + 2**8, 10));
            s_video_pix_row <= std_logic_vector(to_unsigned(3, 9));
            s_z0_real <= (others => '0');
            s_z0_img  <= (others => '0');
            s_c_real <= std_logic_vector(to_signed(-24366, 18)); -- -0.7436
            s_c_img  <= std_logic_vector(to_signed(4316, 18));   --  0.1318
            s_valid <= '1';
            s_ready <= '0';
            wait_for_handshake(s_clk_init, s_valid, c_ready);
        end loop;
        for i in 1 to c_AMOUNT_STIMULI_PER_CASE loop
            -- 0 iterations
            s_video_frame_idx <= "00";
            s_video_pix_col <= std_logic_vector(to_unsigned(i + 2**6, 10));
            s_video_pix_row <= std_logic_vector(to_unsigned(1, 9));
            s_z0_real <= std_logic_vector(to_signed(2, 18) sll 15);
            s_z0_img <= std_logic_vector(to_signed(2, 18) sll 15);
            s_c_real <= std_logic_vector(to_signed(2, 18) sll 15);
            s_c_img <= std_logic_vector(to_signed(2, 18) sll 15);
            s_valid <= '1';
            s_ready <= '0';
            wait_for_handshake(s_clk_init, s_valid, c_ready);
        end loop;
        for i in 1 to c_AMOUNT_STIMULI_PER_CASE loop
            -- Convergent --> 100 iterations
            s_video_frame_idx <= "11";
            s_video_pix_col <= std_logic_vector(to_unsigned(i + 2**9, 10));
            s_video_pix_row <= std_logic_vector(to_unsigned(4, 9));
            s_z0_real <= std_logic_vector(to_signed(1, 18) sll 12); -- 0.125 = 0.001 -> Shift -3
            s_z0_img <= std_logic_vector(to_signed(1, 18) sll 14); -- 0.5 = 0.1 -> Shift -1
            s_c_real <= std_logic_vector(to_signed(-1, 18) sll 12); -- -0.125 = -0.001 -> Shift -3
            s_c_img <= std_logic_vector(to_signed(1, 18) sll 13);   --  0.25 = 0.01 -> Shift -2
            s_valid <= '1';
            s_ready <= '0';
            wait_for_handshake(s_clk_init, s_valid, c_ready);
        end loop;
        s_valid <= '0';
        s_ready <= '0';
        loop
            wait until rising_edge(s_clk_init);
            if c_valid = '1' then
                exit;
            end if;
        end loop;
        for i in 1 to 10 loop
            wait until rising_edge(s_clk_init);
        end loop;
        s_ready <= '1';
        wait;
    end process;

    CHECK: process  
        variable row_1 : integer := 0;
        variable row_2 : integer := 0;
        variable row_3 : integer := 0;
        variable row_4 : integer := 0;
	begin
        wait until s_resetn_color = '1';
        loop
            wait_for_handshake(s_clk_color, c_valid, s_ready);
            if c_video_pix_row = std_logic_vector(to_unsigned(1, 9)) then
            ----- 0 Iterations
                row_1 := row_1 + 1;
                assert c_video_frame_idx = "00"
                    report "Wrong frame idx!" & LF
                        & " Exp.: 00" & LF
                        & " Got:  " & to_string(c_video_frame_idx)
                    severity failure;
                assert c_video_pix_col(9 downto 6) = "0001"
                    report "Wrong pixel column!" & LF
                        & " Exp.: 0001******" & LF
                        & " Got:  " & to_string(c_video_pix_col)
                    severity failure;
                assert c_is_convergent = '0'
                    report "Convergent flag is wrong!"
                        & " Exp.: 0"
                        & " Got.  " & std_logic'image(c_is_convergent)
                    severity failure;
                assert c_cycles_until_divergent = std_logic_vector(to_unsigned(0, 8))
                    report "Iteration amount is wrong!" & LF
                        & " Exp.: " & to_string(to_unsigned(0, 8)) & LF
                        & " Got.  " & to_string(c_cycles_until_divergent)
                    severity failure;
            elsif c_video_pix_row = std_logic_vector(to_unsigned(2, 9)) then
            ----- 2 Iterations
                row_2 := row_2 + 1;
                assert c_video_frame_idx = "01"
                    report "Wrong frame idx!" & LF
                        & " Exp.: 01" & LF
                        & " Got:  " & to_string(c_video_frame_idx)
                    severity failure;
                assert c_video_pix_col(9 downto 6) = "0010"
                    report "Wrong pixel column!" & LF
                        & " Exp.: 0010******" & LF
                        & " Got:  " & to_string(c_video_pix_col)
                    severity failure;
                assert c_is_convergent = '0'
                    report "Convergent flag is wrong!"
                        & " Exp.: 0"
                        & " Got. " & std_logic'image(c_is_convergent)
                    severity failure;
                assert c_cycles_until_divergent = std_logic_vector(to_unsigned(2, 8))
                    report "Iteration amount is wrong!" & LF
                        & " Exp.: " & to_string(to_unsigned(2, 8)) & LF
                        & " Got.  " & to_string(c_cycles_until_divergent)
                    severity failure;
            elsif c_video_pix_row = std_logic_vector(to_unsigned(3, 9)) then
            ----- >0 & <100 iterations
                row_3 := row_3 + 1;
                assert c_video_frame_idx = "10"
                    report "Wrong frame idx!" & LF
                        & " Exp.: 10" & LF
                        & " Got:  " & to_string(c_video_frame_idx)
                    severity failure;
                assert c_video_pix_col(9 downto 6) = "0100"
                    report "Wrong pixel column!" & LF
                        & " Exp.: 0100******" & LF
                        & " Got:  " & to_string(c_video_pix_col)
                    severity failure;
                assert c_is_convergent = '0'
                    report "Convergent flag is wrong!"
                        & " Exp.: 0"
                        & " Got. " & std_logic'image(c_is_convergent)
                    severity failure;
                -- Check no exact iteration value the calculation is slightly off due to rounding at the end of one iteration
                -- But the value should be around 60-100 (MatLab solution: 94, Test: 66)
                assert to_integer(unsigned(c_cycles_until_divergent)) > 60
                    report "Iteration amount is wrong!" & LF
                        & " Exp.: >" & to_string(to_unsigned(60, 8)) & LF
                        & " Got.  " & to_string(c_cycles_until_divergent)
                    severity failure;
            elsif c_video_pix_row = std_logic_vector(to_unsigned(4, 9)) then
            ----- Convergent --> 101 Iterations
                row_4 := row_4 + 1; 
                assert c_video_frame_idx = "11"
                    report "Wrong frame idx!" & LF
                        & " Exp.: 11" & LF
                        & " Got:  " & to_string(c_video_frame_idx)
                    severity failure;
                assert c_video_pix_col(9 downto 6) = "1000"
                    report "Wrong pixel column!" & LF
                        & " Exp.: 1000******" & LF
                        & " Got:  " & to_string(c_video_pix_col)
                    severity failure;
                assert c_is_convergent = '1'
                    report "Convergent flag is wrong!"
                        & " Exp.: 1"
                        & " Got. " & std_logic'image(c_is_convergent)
                    severity failure;
                assert c_cycles_until_divergent = std_logic_vector(to_unsigned(101, 8))
                    report "Iteration amount is wrong!" & LF
                        & " Exp.: " & to_string(to_unsigned(101, 8)) & LF
                        & " Got.  " & to_string(c_cycles_until_divergent)
                    severity failure;
            end if;
            tb_checked_row_1_packets <= row_1;
            tb_checked_row_2_packets <= row_2;
            tb_checked_row_3_packets <= row_3;
            tb_checked_row_4_packets <= row_4;
            -- CHECK TEST END
            if row_1 = c_AMOUNT_STIMULI_PER_CASE 
            and row_2 = c_AMOUNT_STIMULI_PER_CASE 
            and row_3 = c_AMOUNT_STIMULI_PER_CASE 
            and row_4 = c_AMOUNT_STIMULI_PER_CASE then
                tb_test_ended <= true;
                wait;
            end if;
        end loop;
    end process;

    END_TEST_CHECK: process
    begin
       
        wait until tb_test_ended = true for c_TB_TIMEOUT*tbase_calc;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            wait for tbase_init;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;