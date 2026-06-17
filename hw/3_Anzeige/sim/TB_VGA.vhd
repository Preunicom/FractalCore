----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: TB_VGA - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
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

entity TB_VGA is
end TB_VGA;

architecture Testbench of TB_VGA is

    constant tbase : time := 20 ns;

    signal i_clk    : std_logic := '0';
    signal i_resetn : std_logic := '0';

    signal o_rd_x   : std_logic_vector(9 downto 0);
    signal o_rd_y   : std_logic_vector(8 downto 0);

    signal o_visible : std_logic;
    signal o_HSync   : std_logic;
    signal o_VSync   : std_logic;

    signal tb_test_done   : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    uut: entity work.VGA
        port map (
            i_clk    => i_clk,
            i_resetn => i_resetn,

            o_rd_x => o_rd_x,
            o_rd_y => o_rd_y,

            o_visible => o_visible,
            o_HSync   => o_HSync,
            o_VSync   => o_VSync
        );

    i_clk <= not i_clk after tbase / 2;

    STIMULI : process
    begin
        i_resetn <= '0';
        wait for 5 * tbase;

        assert o_rd_x = std_logic_vector(to_unsigned(0, 10))
            report "Fehler: o_rd_x nach Reset nicht 0"
            severity failure;

        assert o_rd_y = std_logic_vector(to_unsigned(0, 9))
            report "Fehler: o_rd_y nach Reset nicht 0"
            severity failure;

        assert o_visible = '1'
            report "Fehler: o_visible nach Reset nicht 1"
            severity failure;

        i_resetn <= '1';

        wait for tbase;

        assert o_rd_x = std_logic_vector(to_unsigned(1, 10))
            report "Fehler: o_rd_x zaehlt nicht hoch"
            severity failure;

        assert o_rd_y = std_logic_vector(to_unsigned(0, 9))
            report "Fehler: o_rd_y sollte noch 0 sein"
            severity failure;

        assert o_HSync /= 'U' and o_VSync /= 'U'
            report "Sync Signale sind undefiniert"
            severity failure;

        -- Bis kurz vor Ende der ersten sichtbaren Zeile laufen lassen
        wait for 638 * tbase;

        assert o_visible = '1'
            report "Fehler: o_visible sollte im sichtbaren Bereich 1 sein"
            severity failure;

        -- In den horizontalen Blanking-Bereich laufen
        wait for 5 * tbase;

        assert o_visible = '0'
            report "Fehler: o_visible sollte nach sichtbarer Zeile 0 sein"
            severity failure;

        assert o_rd_x = std_logic_vector(to_unsigned(0, 10))
            report "Fehler: o_rd_x sollte ausserhalb sichtbarem Bereich 0 sein"
            severity failure;

        -- Bis zum naechsten Zeilenanfang laufen
        wait for 156 * tbase;

        assert o_rd_y = std_logic_vector(to_unsigned(1, 9))
            report "Fehler: o_rd_y wurde nach einer Zeile nicht erhoeht"
            severity failure;

        assert o_visible = '1'
            report "Fehler: o_visible sollte am Anfang der zweiten Zeile 1 sein"
            severity failure;

        tb_test_done <= true;
        wait;
    end process;

    CHECK_PROC : process
    begin
        wait until tb_test_done = true;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for tbase;
        finish;
    end process;

    TIMEOUT_PROC : process
    begin
        wait for 50 us;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;