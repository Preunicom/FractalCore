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

    signal o_ready : std_logic;
    signal i_valid : std_logic := '0';
    signal i_pix_col : std_logic_vector(9 downto 0) := (others => '0');
    signal i_pix_row : std_logic_vector(8 downto 0) := (others => '0');
    signal i_frame_idx : std_logic_vector(1 downto 0) := (others => '0');
    signal i_red : std_logic_vector(3 downto 0) := (others => '0');
    signal i_green : std_logic_vector(3 downto 0) := (others => '0');
    signal i_blue : std_logic_vector(3 downto 0) := (others => '0');

    signal i_CLK_VGA : std_logic := '0';
    signal i_CLK_Arbiter : std_logic := '0';

    signal i_resetn_vga : std_logic := '0';
    signal i_resetn_arbiter : std_logic := '0';

    signal o_blue : std_logic_vector(3 downto 0);
    signal o_green : std_logic_vector(3 downto 0);
    signal o_red : std_logic_vector(3 downto 0);
    signal o_VSync : std_logic;
    signal o_HSync : std_logic;

    signal tb_test_done : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    uut: entity work.VGA
        port map (
            o_ready => o_ready,
            i_valid => i_valid,
            i_pix_col => i_pix_col,
            i_pix_row => i_pix_row,
            i_frame_idx => i_frame_idx,
            i_red => i_red,
            i_green => i_green,
            i_blue => i_blue,
            i_CLK_VGA => i_CLK_VGA,
            i_CLK_Arbiter => i_CLK_Arbiter,
            i_resetn_vga => i_resetn_vga,
            i_resetn_arbiter => i_resetn_arbiter,
            o_blue => o_blue,
            o_green => o_green,
            o_red => o_red,
            o_VSync => o_VSync,
            o_HSync => o_HSync
        );

    i_CLK_VGA <= not i_CLK_VGA after 20 ns;      -- 25 MHz
    i_CLK_Arbiter <= not i_CLK_Arbiter after 10 ns; -- 50 MHz

    i_resetn_vga <= '0', '1' after 200 ns;
    i_resetn_arbiter <= '0', '1' after 200 ns;

    STIMULI : process
    begin
        wait until i_resetn_vga = '1' and i_resetn_arbiter = '1';

        wait for 100 ns;
        assert o_ready = '1'
            report "Fehler: o_ready ist nicht aktiv!"
            severity failure;

        -- Farbe 1 (rot)
        i_valid <= '1';
        i_red   <= "1111";
        i_green <= "0000";
        i_blue  <= "0000";

        wait for 40 us;

        -- Farbe 2 (grün)
        i_red   <= "0000";
        i_green <= "1111";
        i_blue  <= "0000";

        wait for 40 us;

        i_valid <= '0';

        wait for 20 us;

        tb_test_done <= true;
        wait;
    end process;

    CHECK_PROC : process
    begin
        wait until tb_test_done = true;

        assert o_HSync /= 'U' and o_VSync /= 'U'
            report "Sync Signale sind undefiniert!"
            severity failure;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for tbase;
        finish;
    end process;

    TIMEOUT_PROC : process
    begin
        wait for 100*640*480*tbase;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;