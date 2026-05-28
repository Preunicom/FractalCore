----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: TB_Farbcodierung - Testbench
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

entity TB_Farbcodierung is
end TB_Farbcodierung;

architecture Testbench of TB_Farbcodierung is

    constant DATA_WIDTH : integer := 8;
    constant tbase : time := 10 ns;

    signal i_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal i_color_scheme : std_logic_vector(1 downto 0) := (others => '0');

    signal o_red : std_logic_vector(3 downto 0);
    signal o_green : std_logic_vector(3 downto 0);
    signal o_blue : std_logic_vector(3 downto 0);

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    uut: entity work.Farbcodierung
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            i_data => i_data,
            i_color_scheme => i_color_scheme,
            o_red => o_red,
            o_green => o_green,
            o_blue => o_blue
        );

    STIMULI : process
    begin

        -- Schema 00: Graustufen
        i_color_scheme <= "00";
        i_data <= x"00";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Graustufen Wert 0 falsch"
            severity failure;

        i_data <= x"F0";
        wait for 10 ns;

        assert o_red = "1111" and o_green = "1111" and o_blue = "1111"
            report "Fehler: Graustufen Wert F0 falsch"
            severity failure;


        -- Schema 01: Blau/Gruen/Gelb/Rot
        i_color_scheme <= "01";
        i_data <= x"00";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Farbschema 01 Wert 0 falsch"
            severity failure;

        i_data <= x"10";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "1000" and o_blue = "1111"
            report "Fehler: Farbschema 01 Wert 16 falsch"
            severity failure;

        i_data <= x"20";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "1111" and o_blue = "1111"
            report "Fehler: Farbschema 01 Wert 32 falsch"
            severity failure;

        i_data <= x"40";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "1111" and o_blue = "0000"
            report "Fehler: Farbschema 01 Wert 64 falsch"
            severity failure;

        i_data <= x"80";
        wait for 10 ns;

        assert o_red = "1111" and o_green = "1111" and o_blue = "0000"
            report "Fehler: Farbschema 01 Wert 128 falsch"
            severity failure;


        -- Schema 10: Schwarz/Weiss
        i_color_scheme <= "10";
        i_data <= x"00";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Schwarz/Weiss Wert 0 falsch"
            severity failure;

        i_data <= x"01";
        wait for 10 ns;

        assert o_red = "1111" and o_green = "1111" and o_blue = "1111"
            report "Fehler: Schwarz/Weiss Wert 1 falsch"
            severity failure;


        -- Schema 11: Fire-Style
        i_color_scheme <= "11";
        i_data <= x"00";
        wait for 10 ns;

        assert o_red = "0000" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Fire Wert 0 falsch"
            severity failure;

        i_data <= x"40";
        wait for 10 ns;

        assert o_red = "1111" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Fire Wert 64 falsch"
            severity failure;

        i_data <= x"80";
        wait for 10 ns;

        assert o_red = "1111" and o_green = "1111" and o_blue = "0000"
            report "Fehler: Fire Wert 128 falsch"
            severity failure;

        i_data <= x"C0";
        wait for 10 ns;

        assert o_red = "1111" and o_green = "1111" and o_blue = "1111"
            report "Fehler: Fire Wert 192 falsch"
            severity failure;


            tb_test_ended <= true;
        wait;
    end process;

    CHECK : process
    begin
        wait until tb_test_ended = true;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for 10 ns;
        finish;
    end process;

    END_TEST_CHECK: process
    begin
        wait for 200*tbase;
        if tb_test_ended = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
        wait;
    end process;

end Testbench;