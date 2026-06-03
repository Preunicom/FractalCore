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

    constant DATA_WIDTH : integer := 9;
    constant AXI_DATA_WIDTH : integer := 32;
    constant AXI_ADDR_WIDTH : integer := 4;
    constant tbase : time := 10 ns;

    signal i_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal o_red   : std_logic_vector(3 downto 0);
    signal o_green : std_logic_vector(3 downto 0);
    signal o_blue  : std_logic_vector(3 downto 0);

    signal AXI_A_CLK    : std_logic := '0';
    signal AXI_A_RESETN : std_logic := '0';

    signal AXI_AW_ADDR  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal AXI_AW_VALID : std_logic := '0';
    signal AXI_AW_READY : std_logic;

    signal AXI_DW_DATA  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal AXI_DW_STRB  : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
    signal AXI_DW_VALID : std_logic := '0';
    signal AXI_DW_READY : std_logic;

    signal AXI_RW_RESP  : std_logic_vector(1 downto 0);
    signal AXI_RW_VALID : std_logic;
    signal AXI_RW_READY : std_logic := '0';

    signal AXI_AR_ADDR  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal AXI_AR_VALID : std_logic := '0';
    signal AXI_AR_READY : std_logic;

    signal AXI_DR_DATA  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal AXI_DR_RESP  : std_logic_vector(1 downto 0);
    signal AXI_DR_VALID : std_logic;
    signal AXI_DR_READY : std_logic := '0';

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

    procedure axi_write_color_scheme(
        constant scheme : in std_logic_vector(1 downto 0)
    ) is
    begin
        AXI_AW_ADDR  <= x"0";
        AXI_DW_DATA  <= (others => '0');
        AXI_DW_DATA(1 downto 0) <= scheme;
        AXI_DW_STRB  <= "0001";

        AXI_AW_VALID <= '1';
        AXI_DW_VALID <= '1';
        AXI_RW_READY <= '1';

        wait until rising_edge(AXI_A_CLK) and AXI_AW_READY = '1' and AXI_DW_READY = '1';

        AXI_AW_VALID <= '0';
        AXI_DW_VALID <= '0';

        wait until rising_edge(AXI_A_CLK) and AXI_RW_VALID = '1';

        assert AXI_RW_RESP = "00"
            report "AXI WRITE RESP Fehler"
            severity failure;

        AXI_RW_READY <= '0';

        wait until rising_edge(AXI_A_CLK);
    end procedure;

begin

    uut: entity work.Farbcodierung
        generic map (
            DATA_WIDTH     => DATA_WIDTH,
            AXI_DATA_WIDTH => AXI_DATA_WIDTH,
            AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
        )
        port map (
            i_data  => i_data,
            o_red   => o_red,
            o_green => o_green,
            o_blue  => o_blue,

            AXI_A_CLK    => AXI_A_CLK,
            AXI_A_RESETN => AXI_A_RESETN,

            AXI_AW_ADDR  => AXI_AW_ADDR,
            AXI_AW_VALID => AXI_AW_VALID,
            AXI_AW_READY => AXI_AW_READY,

            AXI_DW_DATA  => AXI_DW_DATA,
            AXI_DW_STRB  => AXI_DW_STRB,
            AXI_DW_VALID => AXI_DW_VALID,
            AXI_DW_READY => AXI_DW_READY,

            AXI_RW_RESP  => AXI_RW_RESP,
            AXI_RW_VALID => AXI_RW_VALID,
            AXI_RW_READY => AXI_RW_READY,

            AXI_AR_ADDR  => AXI_AR_ADDR,
            AXI_AR_VALID => AXI_AR_VALID,
            AXI_AR_READY => AXI_AR_READY,

            AXI_DR_DATA  => AXI_DR_DATA,
            AXI_DR_RESP  => AXI_DR_RESP,
            AXI_DR_VALID => AXI_DR_VALID,
            AXI_DR_READY => AXI_DR_READY
        );

    AXI_A_CLK <= not AXI_A_CLK after tbase / 2;

    STIMULI : process
    begin
        AXI_A_RESETN <= '0';
        wait for 5*tbase;
        AXI_A_RESETN <= '1';
        wait for 2*tbase;

        -- Schema 00: Graustufen
        axi_write_color_scheme("00");

        i_data <= '0' & x"00";
        wait for tbase;

        assert o_red = "0000" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Graustufen Wert 0 falsch"
            severity failure;

        i_data <= '0' & x"F0";
        wait for tbase;

        assert o_red = "1111" and o_green = "1111" and o_blue = "1111"
            report "Fehler: Graustufen Wert F0 falsch"
            severity failure;

        -- Schema 01: Blau/Gruen/Gelb/Rot
        axi_write_color_scheme("01");

        i_data <= '0' & x"10";
        wait for tbase;

        assert o_red = "0000" and o_green = "1000" and o_blue = "1111"
            report "Fehler: Farbschema 01 Wert 16 falsch"
            severity failure;

        i_data <= '0' & x"40";
        wait for tbase;

        assert o_red = "0000" and o_green = "1111" and o_blue = "0000"
            report "Fehler: Farbschema 01 Wert 64 falsch"
            severity failure;

        -- Schema 10: Schwarz/Weiss
        axi_write_color_scheme("10");

        i_data <= '0' & x"00";
        wait for tbase;

        assert o_red = "0000" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Schwarz/Weiss Wert 0 falsch"
            severity failure;

        i_data <= '0' & x"01";
        wait for tbase;

        assert o_red = "1111" and o_green = "1111" and o_blue = "1111"
            report "Fehler: Schwarz/Weiss Wert 1 falsch"
            severity failure;

        -- Schema 11: Fire-Style
        axi_write_color_scheme("11");

        i_data <= '0' & x"40";
        wait for tbase;

        assert o_red = "1111" and o_green = "0000" and o_blue = "0000"
            report "Fehler: Fire Wert 64 falsch"
            severity failure;

        i_data <= '0' & x"80";
        wait for tbase;

        assert o_red = "1111" and o_green = "1111" and o_blue = "0000"
            report "Fehler: Fire Wert 128 falsch"
            severity failure;

        -- Highlight / Konvergenzfarben
        axi_write_color_scheme("01");

        i_data <= '1' & x"55";
        wait for tbase;

        assert o_red = "1111" and o_green = "0000" and o_blue = "1111"
            report "Fehler: Highlight Magenta falsch"
            severity failure;

        tb_test_ended <= true;
        wait;
    end process;

    CHECK : process
    begin
        wait until tb_test_ended = true;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for tbase;
        finish;
    end process;

    END_TEST_CHECK : process
    begin
        wait for 500*tbase;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;