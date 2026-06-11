----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: TB_Framebuffer - Testbench
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

entity TB_Framebuffer is
end TB_Framebuffer;

architecture Testbench of TB_Framebuffer is

    constant WIDTH : integer := 16;
    constant HEIGHT : integer := 16;
    constant DATA_WIDTH : integer := 8;

    constant tbase : time := 10 ns;

    signal clk : std_logic := '0';

    signal i_we : std_logic := '0';
    signal i_wr_x : std_logic_vector(9 downto 0) := (others => '0');
    signal i_wr_y : std_logic_vector(8 downto 0) := (others => '0');
    signal i_wr_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal i_rd_x : std_logic_vector(9 downto 0) := (others => '0');
    signal i_rd_y : std_logic_vector(8 downto 0) := (others => '0');
    signal o_rd_data : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    uut: entity work.Framebuffer
        generic map (
            WIDTH      => WIDTH,
            HEIGHT     => HEIGHT,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            i_clk_wr => clk,
            i_we => i_we,
            i_wr_x => i_wr_x,
            i_wr_y => i_wr_y,
            i_wr_data => i_wr_data,

            i_clk_rd => clk,
            i_rd_x => i_rd_x,
            i_rd_y => i_rd_y,
            o_rd_data => o_rd_data
        );

    clk <= not clk after tbase / 2;

    STIMULI : process
    begin
        wait for 20 ns;

        -- Test 1: Wert 0xA5 an Pixel (5,5) schreiben
        i_wr_x <= std_logic_vector(to_unsigned(5, 10));
        i_wr_y <= std_logic_vector(to_unsigned(5, 9));
        i_wr_data <= x"A5";
        i_we <= '1';

        wait for tbase;
        i_we <= '0';

        i_rd_x <= std_logic_vector(to_unsigned(5, 10));
        i_rd_y <= std_logic_vector(to_unsigned(5, 9));

        wait for 2*tbase;

        assert o_rd_data = x"A5"
            report "Fehler: Datenwert bei Pixel (5,5) falsch"
            severity failure;

        -- Test 2: Wert 0x3C an Pixel (2,3) schreiben
        i_wr_x <= std_logic_vector(to_unsigned(2, 10));
        i_wr_y <= std_logic_vector(to_unsigned(3, 9));
        i_wr_data <= x"3C";
        i_we <= '1';

        wait for tbase;
        i_we <= '0';

        i_rd_x <= std_logic_vector(to_unsigned(2, 10));
        i_rd_y <= std_logic_vector(to_unsigned(3, 9));

        wait for 2*tbase;

        assert o_rd_data = x"3C"
            report "Fehler: Datenwert bei Pixel (2,3) falsch"
            severity failure;

        -- Test 3: Prüfen, ob Pixel (5,5) noch unverändert ist
        i_rd_x <= std_logic_vector(to_unsigned(5, 10));
        i_rd_y <= std_logic_vector(to_unsigned(5, 9));

        wait for 2*tbase;

        assert o_rd_data = x"A5"
            report "Fehler: Datenwert bei Pixel (5,5) wurde überschrieben"
            severity failure;

        -- Test 4: Out-of-bounds Write darf nichts kaputtmachen
        i_wr_x <= std_logic_vector(to_unsigned(20, 10));
        i_wr_y <= std_logic_vector(to_unsigned(20, 9));
        i_wr_data <= x"FF";
        i_we <= '1';

        wait for tbase;
        i_we <= '0';

        i_rd_x <= std_logic_vector(to_unsigned(5, 10));
        i_rd_y <= std_logic_vector(to_unsigned(5, 9));

        wait for 2*tbase;

        assert o_rd_data = x"A5"
            report "Fehler: Out-of-bounds Write hat Speicher verändert"
            severity failure;

        tb_test_ended <= true;
        wait;
    end process;

    CHECK : process
    begin
        wait until tb_test_ended = true;

        assert o_rd_data /= (o_rd_data'range => 'U')
            report "Fehler: o_rd_data ist undefiniert"
            severity failure;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for tbase;
        finish;
    end process;

    END_TEST_CHECK: process
    begin
        wait for 100 us;
        if tb_test_ended = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
        wait;
    end process;

end Testbench;