----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/29/2026 09:00:00 AM
-- Design Name: 
-- Module Name: TB_Arbiter - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Arbiter.
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
use work.Pkg_Core.all;

entity TB_Arbiter is
end TB_Arbiter;

architecture Testbench of TB_Arbiter is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_m1_valid : std_logic;
    signal s_m2_valid : std_logic;
    signal s_m1_pixel_result : t_pixel_result;
    signal s_m2_pixel_result : t_pixel_result;
    signal s_ready : std_logic;
    
    -- CHECK
    signal c_m1_ready : std_logic;
    signal c_m2_ready : std_logic;
    signal c_pixel_result : t_pixel_result;
    signal c_valid : std_logic;

    signal tb_test_ended : boolean := false;

    signal tb_test_passed : boolean := false;

    procedure check_slave(
        signal valid : in std_logic;
        signal ready : in std_logic;
        signal frame : in std_logic_vector;
        signal row : in std_logic_vector;
        signal col : in std_logic_vector;
        signal iteration_amount : in std_logic_vector;
        signal convergent_flag : in std_logic;
        constant exp_frame : in std_logic_vector;
        constant exp_row : in std_logic_vector;
        constant exp_col : in std_logic_vector;
        constant exp_iteration_amount : in std_logic_vector;
        constant exp_convergent_flag : in std_logic

    ) is
    begin
        loop
            wait until rising_edge(s_clk);
            if valid = '1' and ready = '1' then
                assert frame = exp_frame
                    report "Wrong frame received!" 
                        & " Exp.: " & to_string(exp_frame)
                        & " Got: " & to_string(frame)
                    severity failure;
                assert row = exp_row
                    report "Wrong row received!" 
                        & " Exp.: " & to_string(exp_row)
                        & " Got: " & to_string(row)
                    severity failure;
                assert col = exp_col
                    report "Wrong col received!" 
                        & " Exp.: " & to_string(exp_col)
                        & " Got: " & to_string(col)
                    severity failure;
                assert iteration_amount = exp_iteration_amount
                    report "Wrong itertion amount received!" 
                        & " Exp.: " & to_string(exp_iteration_amount)
                        & " Got: " & to_string(iteration_amount)
                    severity failure;
                assert convergent_flag = exp_convergent_flag
                    report "Wrong convergent flag received!" 
                        & " Exp.: " & to_string(exp_convergent_flag)
                        & " Got: " & to_string(convergent_flag)
                    severity failure;
                assert c_m1_ready nand c_m2_ready
                    report "Ready flag sent to both masters! Exp.: Only one of both masters get ready."
                    severity failure;
                exit;
            end if;
        end loop;
    end procedure;

begin
    UUT: entity work.Arbiter
    port map (
        i_resetn          => s_resetn,
        i_clk             => s_clk,
        i_m1_valid        => s_m1_valid,
        o_m1_ready        => c_m1_ready,
        i_m1_pixel_result => s_m1_pixel_result,
        i_m2_valid        => s_m2_valid,
        o_m2_ready        => c_m2_ready,
        i_m2_pixel_result => s_m2_pixel_result,
        i_ready           => s_ready,
        o_valid           => c_valid,
        o_pixel_result    => c_pixel_result
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- Only m1
        s_ready <= '0';
        s_m1_valid <= '1';
        s_m1_pixel_result.video_frame_idx <= "10";
        s_m1_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(5, 10));
        s_m1_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(5, 9));
        s_m1_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(1, 8));
        s_m1_pixel_result.is_convergent <= '0';
        s_m2_valid <= '0';
        s_m2_pixel_result.video_frame_idx <= "01";
        s_m2_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(3, 10));
        s_m2_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(3, 9));
        s_m2_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(2, 8));
        s_m2_pixel_result.is_convergent <= '1';
        -- Test delay 
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        -- Only m2
        s_ready <= '1';
        s_m1_valid <= '0';
        s_m1_pixel_result.video_frame_idx <= "10";
        s_m1_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(1, 10));
        s_m1_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(1, 9));
        s_m1_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(3, 8));
        s_m1_pixel_result.is_convergent <= '1';
        s_m2_valid <= '1';
        s_m2_pixel_result.video_frame_idx <= "11";
        s_m2_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(3, 10));
        s_m2_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(3, 9));
        s_m2_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(4, 8));
        s_m2_pixel_result.is_convergent <= '0';
        wait until rising_edge(s_clk);
        -- Both (m1 prio because last was m2)
        s_ready <= '1';
        s_m1_valid <= '1';
        s_m1_pixel_result.video_frame_idx <= "00";
        s_m1_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(5, 10));
        s_m1_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(5, 9));
        s_m1_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(5, 8));
        s_m1_pixel_result.is_convergent <= '0';
        s_m2_valid <= '1';
        s_m2_pixel_result.video_frame_idx <= "01";
        s_m2_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(3, 10));
        s_m2_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(3, 9));
        s_m2_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(6, 8));
        s_m2_pixel_result.is_convergent <= '1';
        wait until rising_edge(s_clk);
        -- Only m1
        s_ready <= '1';
        s_m1_valid <= '1';
        s_m1_pixel_result.video_frame_idx <= "10";
        s_m1_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(5, 10));
        s_m1_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(5, 9));
        s_m1_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(1, 8));
        s_m1_pixel_result.is_convergent <= '0';
        s_m2_valid <= '0';
        s_m2_pixel_result.video_frame_idx <= "01";
        s_m2_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(3, 10));
        s_m2_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(3, 9));
        s_m2_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(2, 8));
        s_m2_pixel_result.is_convergent <= '1';
        wait until rising_edge(s_clk);
        -- Both (m2 prio because m1 was last)
        s_ready <= '1';
        s_m1_valid <= '1';
        s_m1_pixel_result.video_frame_idx <= "10";
        s_m1_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(1, 10));
        s_m1_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(1, 9));
        s_m1_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(7, 8));
        s_m1_pixel_result.is_convergent <= '1';
        s_m2_valid <= '1';
        s_m2_pixel_result.video_frame_idx <= "01";
        s_m2_pixel_result.video_pix_col <= std_logic_vector(to_unsigned(3, 10));
        s_m2_pixel_result.video_pix_row <= std_logic_vector(to_unsigned(3, 9));
        s_m2_pixel_result.cycles_until_divergent <= std_logic_vector(to_unsigned(8, 8));
        s_m2_pixel_result.is_convergent <= '0';
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        check_slave(c_valid, s_ready, c_pixel_result.video_frame_idx, c_pixel_result.video_pix_row, c_pixel_result.video_pix_col, c_pixel_result.cycles_until_divergent, c_pixel_result.is_convergent,
            "10", std_logic_vector(to_unsigned(5, 9)), std_logic_vector(to_unsigned(5, 10)), std_logic_vector(to_unsigned(1, 8)), '0');
        check_slave(c_valid, s_ready, c_pixel_result.video_frame_idx, c_pixel_result.video_pix_row, c_pixel_result.video_pix_col, c_pixel_result.cycles_until_divergent, c_pixel_result.is_convergent,
            "11", std_logic_vector(to_unsigned(3, 9)), std_logic_vector(to_unsigned(3, 10)), std_logic_vector(to_unsigned(4, 8)), '0');
        check_slave(c_valid, s_ready, c_pixel_result.video_frame_idx, c_pixel_result.video_pix_row, c_pixel_result.video_pix_col, c_pixel_result.cycles_until_divergent, c_pixel_result.is_convergent,
            "00", std_logic_vector(to_unsigned(5, 9)), std_logic_vector(to_unsigned(5, 10)), std_logic_vector(to_unsigned(5, 8)), '0');
        check_slave(c_valid, s_ready, c_pixel_result.video_frame_idx, c_pixel_result.video_pix_row, c_pixel_result.video_pix_col, c_pixel_result.cycles_until_divergent, c_pixel_result.is_convergent,
            "10", std_logic_vector(to_unsigned(5, 9)), std_logic_vector(to_unsigned(5, 10)), std_logic_vector(to_unsigned(1, 8)), '0');
        check_slave(c_valid, s_ready, c_pixel_result.video_frame_idx, c_pixel_result.video_pix_row, c_pixel_result.video_pix_col, c_pixel_result.cycles_until_divergent, c_pixel_result.is_convergent,
            "01", std_logic_vector(to_unsigned(3, 9)), std_logic_vector(to_unsigned(3, 10)), std_logic_vector(to_unsigned(8, 8)), '0');
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