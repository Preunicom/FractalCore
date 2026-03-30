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
use std.env.finish;

library work;
use work.Pkg_Core.all;

entity TB_Dispatcher is
end TB_Dispatcher;

architecture Testbench of TB_Dispatcher is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_clk : std_logic := '0';
    signal s_valid : std_logic;
    signal s_pixel_data : t_pixel_data;
    signal s_s1_ready : std_logic;
    signal s_s2_ready : std_logic;
    -- CHECK
    signal c_ready : std_logic;
    signal c_s1_valid : std_logic;
    signal c_s2_valid : std_logic;
    signal c_pixel_data : t_pixel_data;

    signal tb_test_ended : boolean := false;

    signal tb_test_passed : boolean := false;

    procedure check_slave(
        signal valid : in std_logic;
        signal ready : in std_logic;
        signal data : in std_logic_vector;
        constant exp_data : in std_logic_vector;
        signal other_valid : in std_logic
    ) is
    begin
        loop
            wait until rising_edge(s_clk);
            if valid = '1' and ready = '1' then
                assert data = exp_data
                    report "Wrong pixel data (video pix row) received!" 
                        & " Exp.: " & to_string(exp_data)
                        & " Got: " & to_string(data)
                    severity failure;
                assert other_valid = '0'
                    report "Wrong slave valid signal sent!"
                        & " Exp.: " & std_logic'image('0')
                        & " Got: " & std_logic'image(other_valid)
                    severity failure;
                exit;
            end if;
        end loop;
    end procedure;

begin
    UUT: entity work.Dispatcher
    port map (
        i_valid      => s_valid,
        i_pixel_data => s_pixel_data,
        o_ready      => c_ready,
        i_s1_ready   => s_s1_ready,
        o_s1_valid   => c_s1_valid,
        i_s2_ready   => s_s2_ready,
        o_s2_valid   => c_s2_valid,
        o_pixel_data => c_pixel_data
    );

    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        s_valid <= '0';
        s_pixel_data.video_frame_idx <= "01";
        s_s1_ready <= '0';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '0';
        s_pixel_data.video_frame_idx <= "01";
        s_s1_ready <= '0';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '0';
        s_pixel_data.video_frame_idx <= "01";
        s_s1_ready <= '1';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_frame_idx <= "11";
        s_s1_ready <= '1';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000001";
        s_pixel_data.video_frame_idx <= "UU";
        s_s1_ready <= '1';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000011";
        s_s1_ready <= '0';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000111";
        s_s1_ready <= '0';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000000"; -- Ignored
        s_s1_ready <= '0';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000000"; -- Ignored
        s_s1_ready <= '0';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000001";
        s_s1_ready <= '0';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "000000010";
        s_s1_ready <= '1';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '0';
        s_pixel_data.video_pix_row <= "000000000";  -- Ignored
        s_s1_ready <= '1';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "100000000";
        s_s1_ready <= '0';
        s_s2_ready <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '0';
        s_pixel_data.video_pix_row <= "000000000";  -- Ignored
        s_s1_ready <= '0';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "010000000"; -- Ignored
        s_s1_ready <= '0';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "110000000";
        s_s1_ready <= '1';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        s_pixel_data.video_pix_row <= "100000001"; -- Ignored
        s_s1_ready <= '0';
        s_s2_ready <= '0';
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        check_slave(c_s1_valid, s_s1_ready, c_pixel_data.video_frame_idx, "11", c_s2_valid);
        check_slave(c_s1_valid, s_s1_ready, c_pixel_data.video_pix_row, "000000001", c_s2_valid);
        check_slave(c_s2_valid, s_s2_ready, c_pixel_data.video_pix_row, "000000011", c_s1_valid);
        check_slave(c_s2_valid, s_s2_ready, c_pixel_data.video_pix_row, "000000111", c_s1_valid);
        check_slave(c_s2_valid, s_s2_ready, c_pixel_data.video_pix_row, "000000001", c_s1_valid);
        check_slave(c_s1_valid, s_s1_ready, c_pixel_data.video_pix_row, "000000010", c_s2_valid);
        check_slave(c_s2_valid, s_s2_ready, c_pixel_data.video_pix_row, "100000000", c_s1_valid);
        check_slave(c_s1_valid, s_s1_ready, c_pixel_data.video_pix_row, "110000000", c_s2_valid);
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
