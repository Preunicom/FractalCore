----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/20/2026 14:09:00 AM
-- Design Name: 
-- Module Name: TB_Pixel_Generation - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Pixel Generation.
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

entity TB_Pixel_Generation is
end TB_Pixel_Generation;

architecture Testbench of TB_Pixel_Generation is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn              : std_logic;
    signal s_clk                 : std_logic := '0';
    signal s_fetch_next          : std_logic;

    -- CHECK
    signal c_pixel_col : std_logic_vector(9 downto 0);
    signal c_pixel_row : std_logic_vector(8 downto 0);
    signal c_frame_idx : std_logic_vector(1 downto 0);
    signal c_is_in_minimap : std_logic;

    signal tb_pixel_col : integer;
    signal tb_pixel_row : integer;
    signal tb_frame_idx : integer;
    signal tb_last_col : integer;
    signal tb_last_row : integer;
    signal tb_last_frame_idx : integer;
    signal tb_last_fetch_next : std_logic;

    signal tb_test_ended_frame_idx : boolean := false;
    signal tb_test_ended_col : boolean := false;
    signal tb_test_ended_row : boolean := false;
    signal tb_test_ended_mini_map : boolean := false;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Pixel_Generation
    port map (
        i_resetn         => s_resetn,
        i_clk            => s_clk,
        i_fetch_next     => s_fetch_next,
        o_frame_idx      => c_frame_idx,
        o_pixel_col      => c_pixel_col,
        o_pixel_row      => c_pixel_row,
        o_is_in_minimap  => c_is_in_minimap
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    tb_pixel_col <= to_integer(unsigned(c_pixel_col));
    tb_pixel_row <= to_integer(unsigned(c_pixel_row));
    tb_frame_idx <= to_integer(unsigned(c_frame_idx));

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- Test 6 frames
        for i in 0 to 5 loop
            s_fetch_next <= '1';
            wait for 100*tbase;
            s_fetch_next <= '0';
            wait for 200*tbase;
            s_fetch_next <= '1';
            wait for 2*tbase;
            s_fetch_next <= '0';
            wait for 1*tbase;
            s_fetch_next <= '1';
            wait for ((640 * 480) - 202) * tbase;
            s_fetch_next <= '0';
            wait for 500*tbase;
            s_fetch_next <= '1';
            wait for 100*tbase;
        end loop;
        wait;
    end process;

    SET_LAST: process(s_clk)
	begin
        if rising_edge(s_clk) then
            if s_resetn = '0' then
                tb_last_col <= 639;
                tb_last_row <= 479;
                tb_last_frame_idx <= 3;
            else
                if s_fetch_next = '1' then
                    tb_last_col <= tb_pixel_col;
                    tb_last_row <= tb_pixel_row;
                    tb_last_frame_idx <= tb_frame_idx;
                    tb_last_fetch_next <= s_fetch_next;
                end if;
            end if;
        end if;
    end process;

    CHECK_COL: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' then 
                -- Read data and request next
                assert tb_pixel_col = (tb_last_col + 1) mod 640
                    report "Wrong pixel column received!" & LF
                        & "Exp.:" & to_string((tb_last_col + 1) mod 640) & LF
                        & "Got.:" & to_string(tb_pixel_col)
                    severity failure;
                tb_test_ended_col <= true;
            else
                assert tb_pixel_col = tb_last_col or
                    (tb_pixel_col = tb_last_col + 1 and tb_last_fetch_next = '1')
                    report "Pixel column changed without fetch next!" & LF
                        & "Exp.:" & to_string(tb_last_col) & LF
                        & "Got.:" & to_string(tb_pixel_col)
                    severity failure; 
            end if; 
        end loop;
    end process;

    CHECK_ROW: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' then
                -- Read data and request next
                if tb_last_col = 639 then
                    -- New row expected
                    assert tb_pixel_row = (tb_last_row + 1) mod 480
                        report "Wrong pixel row received!" & LF
                            & "Exp.:" & to_string((tb_last_row + 1) mod 480) & LF
                            & "Got.:" & to_string(tb_pixel_row)
                        severity failure; 
                        tb_test_ended_row <= true;
                else
                    assert tb_pixel_row = tb_last_row
                        report "Wrong pixel row received in mid of a row!" & LF
                            & "Exp.:" & to_string(tb_last_row) & LF
                            & "Got.:" & to_string(tb_pixel_row)
                        severity failure; 
                end if;
            else
                assert tb_pixel_row = tb_last_row or
                    (tb_pixel_col = tb_last_col + 1 and tb_last_fetch_next = '1')
                    report "Wrong pixel row received while fetch disabled!" & LF
                        & "Exp.:" & to_string(tb_last_row) & LF
                        & "Got.:" & to_string(tb_pixel_row)
                    severity failure; 
            end if;
        end loop;
    end process;

    CHECK_MINI_MAP: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if tb_pixel_col <= 160 and tb_pixel_row >= 360 then 
                assert c_is_in_minimap = '1' 
                    report "Pixel not flaged as mini map area pixel but pixel should be!"
                    severity failure;
            else
                assert c_is_in_minimap = '0' 
                    report "Pixel flaged as mini map area pixel but pixel should not be!"
                    severity failure;
            end if;
            tb_test_ended_mini_map <= true;
        end loop;
    end process;

    CHECK_FRAME_IDX: process
        variable last_idx : integer := 4;
	begin
        wait until s_resetn = '1';
        for i in 0 to 5 loop
            wait until tb_frame_idx /= last_idx;
            assert tb_frame_idx = (i + 1) mod 4
                report "Wrong frame idx received!"
                    & " Exp.:" & to_string((i + 1) mod 4)
                    & " Got.:" & to_string(tb_frame_idx)
                severity failure;
            last_idx := tb_frame_idx;
        end loop;
        wait until rising_edge(s_clk);
        tb_test_ended_frame_idx <= true;
        wait;
    end process;

    tb_test_ended <= tb_test_ended_frame_idx and tb_test_ended_col and tb_test_ended_row and tb_test_ended_mini_map;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 7*640*480*tbase;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            wait for tbase;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;