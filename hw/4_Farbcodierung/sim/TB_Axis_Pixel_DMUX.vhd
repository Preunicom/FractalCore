----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2026 02:25:54 PM
-- Design Name: 
-- Module Name: TB_Axis_Pixel_DMUX - Behavioral
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

entity TB_Axis_Pixel_DMUX is
end TB_Axis_Pixel_DMUX;

architecture Testbench of TB_Axis_Pixel_DMUX is

    constant CLK_PERIOD : time := 10 ns;

    signal i_clk    : std_logic := '0';
    signal i_resetn : std_logic := '0';

    signal s_axis_tdata  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tready : std_logic;

    signal m0_axis_tdata  : std_logic_vector(31 downto 0);
    signal m0_axis_tvalid : std_logic;
    signal m0_axis_tready : std_logic := '1';

    signal m1_axis_tdata  : std_logic_vector(31 downto 0);
    signal m1_axis_tvalid : std_logic;
    signal m1_axis_tready : std_logic := '1';

    signal tb_test_done   : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    i_clk <= not i_clk after CLK_PERIOD / 2;

    uut: entity work.Axis_Pixel_DMUX
        port map (
            i_clk    => i_clk,
            i_resetn => i_resetn,

            s_axis_tdata  => s_axis_tdata,
            s_axis_tvalid => s_axis_tvalid,
            s_axis_tready => s_axis_tready,

            m0_axis_tdata  => m0_axis_tdata,
            m0_axis_tvalid => m0_axis_tvalid,
            m0_axis_tready => m0_axis_tready,

            m1_axis_tdata  => m1_axis_tdata,
            m1_axis_tvalid => m1_axis_tvalid,
            m1_axis_tready => m1_axis_tready
        );

    STIMULI : process
    begin
        i_resetn <= '0';
        wait for 30 ns;
        i_resetn <= '1';
        wait for CLK_PERIOD;

        -- Frame 0: frame_idx = "00", also FIFO0
        s_axis_tdata  <= "00" & std_logic_vector(to_unsigned(5, 10)) &
                         std_logic_vector(to_unsigned(3, 9)) &
                         x"2A" & "000";
        s_axis_tvalid <= '1';

        wait for CLK_PERIOD;

        assert m0_axis_tvalid = '1'
            report "Fehler: Frame 0 wurde nicht zu FIFO0 geleitet"
            severity failure;

        assert m1_axis_tvalid = '0'
            report "Fehler: Frame 0 wurde falsch zu FIFO1 geleitet"
            severity failure;

        assert m0_axis_tdata = s_axis_tdata
            report "Fehler: FIFO0 TDATA falsch"
            severity failure;


        -- Frame 1: frame_idx = "01", also FIFO1
        s_axis_tdata <= "01" & std_logic_vector(to_unsigned(10, 10)) &
                        std_logic_vector(to_unsigned(7, 9)) &
                        x"55" & "000";

        wait for CLK_PERIOD;

        assert m0_axis_tvalid = '0'
            report "Fehler: Frame 1 wurde falsch zu FIFO0 geleitet"
            severity failure;

        assert m1_axis_tvalid = '1'
            report "Fehler: Frame 1 wurde nicht zu FIFO1 geleitet"
            severity failure;

        assert m1_axis_tdata = s_axis_tdata
            report "Fehler: FIFO1 TDATA falsch"
            severity failure;


        -- FIFO1 nicht bereit
        m1_axis_tready <= '0';
        wait for CLK_PERIOD;

        assert s_axis_tready = '0'
            report "Fehler: s_axis_tready sollte 0 sein, wenn FIFO1 nicht bereit ist"
            severity failure;

        m1_axis_tready <= '1';
        s_axis_tvalid <= '0';

        wait for CLK_PERIOD;

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
        wait for 2 us;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;
