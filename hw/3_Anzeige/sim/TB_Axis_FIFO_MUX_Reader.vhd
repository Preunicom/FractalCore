----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2026 02:25:54 PM
-- Design Name: 
-- Module Name: TB_Axis_FIOF_MUX_Reader - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity TB_Axis_FIFO_MUX_Reader is
end TB_Axis_FIFO_MUX_Reader;

architecture Testbench of TB_Axis_FIFO_MUX_Reader is
    constant tbase : time := 10 ns;

    constant CLK_PERIOD : time := 10 ns;

    signal i_clk    : std_logic := '0';
    signal i_resetn : std_logic := '0';

    signal i_read_select : std_logic := '0';

    signal s0_axis_tdata  : std_logic_vector(31 downto 0) := (others => '0');
    signal s0_axis_tvalid : std_logic := '0';
    signal s0_axis_tready : std_logic;

    signal s1_axis_tdata  : std_logic_vector(31 downto 0) := (others => '0');
    signal s1_axis_tvalid : std_logic := '0';
    signal s1_axis_tready : std_logic;

    signal o_fb_we      : std_logic;
    signal o_fb_wr_x    : std_logic_vector(9 downto 0);
    signal o_fb_wr_y    : std_logic_vector(8 downto 0);
    signal o_fb_wr_data : std_logic_vector(8 downto 0);

    signal tb_test_done   : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    i_clk <= not i_clk after CLK_PERIOD / 2;

    uut: entity work.Axis_FIFO_MUX_Reader
        port map (
            i_clk    => i_clk,
            i_resetn => i_resetn,

            i_read_select => i_read_select,

            s0_axis_tdata  => s0_axis_tdata,
            s0_axis_tvalid => s0_axis_tvalid,
            s0_axis_tready => s0_axis_tready,

            s1_axis_tdata  => s1_axis_tdata,
            s1_axis_tvalid => s1_axis_tvalid,
            s1_axis_tready => s1_axis_tready,

            o_fb_we      => o_fb_we,
            o_fb_wr_x    => o_fb_wr_x,
            o_fb_wr_y    => o_fb_wr_y,
            o_fb_wr_data => o_fb_wr_data
        );

    STIMULI : process
    begin
        i_resetn <= '0';
        wait for 30 ns;
        i_resetn <= '1';
        wait for CLK_PERIOD;

        -- FIFO0 lesen
        i_read_select <= '0';

        s0_axis_tdata <= "0" & std_logic_vector(to_unsigned(5, 10)) &
                         std_logic_vector(to_unsigned(3, 9)) & "0" &
                         x"2A" & "000";
        s0_axis_tvalid <= '1';

        s1_axis_tdata <= "1" & std_logic_vector(to_unsigned(20, 10)) &
                         std_logic_vector(to_unsigned(9, 9)) & "0" &
                         x"55" & "000";
        s1_axis_tvalid <= '1';

        wait for CLK_PERIOD;

        assert s0_axis_tready = '1'
            report "Fehler: FIFO0 sollte ready sein"
            severity failure;

        assert s1_axis_tready = '0'
            report "Fehler: FIFO1 sollte nicht ready sein"
            severity failure;

        wait for CLK_PERIOD;

        assert o_fb_we = '1'
            report "Fehler: Framebuffer Write Enable bei FIFO0 nicht gesetzt"
            severity failure;

        assert o_fb_wr_x = std_logic_vector(to_unsigned(5, 10))
            report "Fehler: X-Wert aus FIFO0 falsch"
            severity failure;

        assert o_fb_wr_y = std_logic_vector(to_unsigned(3, 9))
            report "Fehler: Y-Wert aus FIFO0 falsch"
            severity failure;

        assert o_fb_wr_data =  "0" & x"2A"
            report "Fehler: Iterationswert aus FIFO0 falsch"
            severity failure;


        -- FIFO1 lesen
        i_read_select <= '1';

        wait for CLK_PERIOD;

        assert s0_axis_tready = '0'
            report "Fehler: FIFO0 sollte nicht ready sein"
            severity failure;

        assert s1_axis_tready = '1'
            report "Fehler: FIFO1 sollte ready sein"
            severity failure;

        wait for CLK_PERIOD;

        assert o_fb_we = '1'
            report "Fehler: Framebuffer Write Enable bei FIFO1 nicht gesetzt"
            severity failure;

        assert o_fb_wr_x = std_logic_vector(to_unsigned(20, 10))
            report "Fehler: X-Wert aus FIFO1 falsch"
            severity failure;

        assert o_fb_wr_y = std_logic_vector(to_unsigned(9, 9))
            report "Fehler: Y-Wert aus FIFO1 falsch"
            severity failure;

        assert o_fb_wr_data = "0" & x"55"
            report "Fehler: Iterationswert aus FIFO1 falsch"
            severity failure;


        -- Kein FIFO valid
        s0_axis_tvalid <= '0';
        s1_axis_tvalid <= '0';

        wait for CLK_PERIOD;

        assert o_fb_we = '0'
            report "Fehler: o_fb_we sollte 0 sein, wenn kein FIFO valid ist"
            severity failure;

        tb_test_done <= true;
        wait;
    end process;

    CHECK_PROC : process
    begin
        wait until tb_test_done = true;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for CLK_PERIOD;
        finish;
    end process;

    TIMEOUT_PROC : process
    begin
        wait for tbase*1000;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;