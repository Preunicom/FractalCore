----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/20/2026 14:09:00 AM
-- Design Name: 
-- Module Name: TB_Coordinate_Mapping - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Coordinate Mapping with help by Pixel_Generation.
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
use work.Pkg_TB_Utils.all;

entity TB_Coordinate_Mapping is
end TB_Coordinate_Mapping;

architecture Testbench of TB_Coordinate_Mapping is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn              : std_logic;
    signal s_clk                 : std_logic := '0';
    signal s_fetch_next          : std_logic;
    signal s_pixel_distance      : std_logic_vector(7 downto 0);
    signal s_enable_minimap      : std_logic;

    -- CHECK
    signal c_valid               : std_logic;
    signal c_pixel_coord_re      : std_logic_vector(17 downto 0);
    signal c_pixel_coord_im      : std_logic_vector(17 downto 0);
    signal c_pixel_col           : std_logic_vector(9 downto 0);
    signal c_pixel_row           : std_logic_vector(8 downto 0);
    signal c_frame_idx           : std_logic_vector(1 downto 0);
    signal c_is_in_minimap       : std_logic;
    signal c_pixel_distance      : std_logic_vector(7 downto 0); 

    signal tb_pixel_coord_re     : integer;
    signal tb_pixel_coord_im     : integer;
    signal tb_pixel_col          : integer;
    signal tb_pixel_row          : integer;
    signal tb_frame_idx          : integer;
    signal tb_current_active_pixel_distance : std_logic_vector(7 downto 0);
    signal tb_current_minimap_en : std_logic;
    signal tb_is_in_minimap      : std_logic;
    signal tb_last_pixel_col     : integer;
    signal tb_last_pixel_row     : integer;
    signal tb_last_pixel_coord_re: integer;
    signal tb_last_pixel_coord_im: integer;
    signal tb_last_minimap_status: std_logic;

    signal tb_test_ended_frame_idx : boolean := false;
    signal tb_test_ended_re : boolean := false;
    signal tb_test_ended_im : boolean := false;
    signal tb_test_ended_minimap : boolean := false;
    signal tb_test_ended : boolean := false;
    signal tb_test_ended_distance : boolean := false;
    signal tb_test_passed : boolean := false;

    signal w_pixel_col : std_logic_vector(9 downto 0);
    signal w_pixel_row : std_logic_vector(8 downto 0);
    signal w_frame_idx : std_logic_vector(1 downto 0);
    signal w_is_in_minimap_area : std_logic;

begin
    PIXEL_HELPER: entity work.Pixel_Generation
    port map (
        i_resetn                => s_resetn,
        i_clk                   => s_clk,
        i_fetch_next            => s_fetch_next,
        o_frame_idx             => w_frame_idx,
        o_pixel_col             => w_pixel_col,
        o_pixel_row             => w_pixel_row,
        o_is_in_minimap_area    => w_is_in_minimap_area
    );

    UUT: entity work.Coordinate_Mapping
    port map (
        i_resetn                => s_resetn,
        i_clk                   => s_clk,
        i_fetch_next            => s_fetch_next,
        i_frame_idx             => w_frame_idx,
        i_pixel_col             => w_pixel_col,
        i_pixel_row             => w_pixel_row,
        i_is_in_minimap_area    => w_is_in_minimap_area,
        i_minimap_en            => s_enable_minimap,
        i_pixel_distance        => s_pixel_distance,
        o_valid                 => c_valid,
        o_frame_idx             => c_frame_idx,
        o_pixel_col             => c_pixel_col,
        o_pixel_row             => c_pixel_row,
        o_pixel_coord_re        => c_pixel_coord_re,
        o_pixel_coord_im        => c_pixel_coord_im,
        o_is_in_minimap         => c_is_in_minimap,
        o_pixel_distance        => c_pixel_distance
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    tb_pixel_coord_re <= to_integer(signed(c_pixel_coord_re));
    tb_pixel_coord_im <= to_integer(signed(c_pixel_coord_im));
    tb_pixel_col <= to_integer(unsigned(c_pixel_col));
    tb_pixel_row <= to_integer(unsigned(c_pixel_row));
    tb_frame_idx <= to_integer(unsigned(c_frame_idx));
    tb_is_in_minimap <= '1' when tb_pixel_col <= 160 and tb_pixel_row >= 360 and tb_current_minimap_en = '1' else '0';

    tb_current_active_pixel_distance <= std_logic_vector(to_signed(1, 8)) when c_frame_idx = "00" else 
                                            std_logic_vector(to_signed(100, 8)) when c_frame_idx = "01" else 
                                            std_logic_vector(to_signed(50, 8));
    tb_current_minimap_en <= '0' when c_frame_idx = "00" else '1';

    STIMULI: process
	begin
        wait until s_resetn = '1';
        s_pixel_distance <= std_logic_vector(to_signed(1, 8));
        s_fetch_next <= '1';
        s_enable_minimap <= '0';
        wait_for_clock_cycles(s_clk, 640*240); -- 1/2 Frame
        s_enable_minimap <= '1';
        s_pixel_distance <= std_logic_vector(to_signed(100, 8));
        wait_for_clock_cycles(s_clk, 640*240); -- 1/2 Frame
        wait until rising_edge(s_clk); -- Delay one clock cycle to set the new values
        s_pixel_distance <= std_logic_vector(to_signed(50, 8));
        s_fetch_next <= '0';
        wait_for_clock_cycles(s_clk, 100);
        s_fetch_next <= '1';
        wait_for_clock_cycles(s_clk, 2*640*480); -- 2 Frame
        s_pixel_distance <= std_logic_vector(to_signed(1, 8));
        s_enable_minimap <= '0';
        wait_for_clock_cycles(s_clk, 640*480); -- 1 Frame
        s_pixel_distance <= std_logic_vector(to_signed(100, 8));
        s_enable_minimap <= '1';
        wait_for_clock_cycles(s_clk, 640*480); -- 1 Frame
        s_enable_minimap <= '0';
        wait;
    end process;

    SET_LAST: process(s_clk)
	begin
        if rising_edge(s_clk) then
            if s_resetn = '0' then
                tb_last_pixel_col <= 639;
                tb_last_pixel_row <= 479;
                tb_last_minimap_status <= '0';
                tb_last_pixel_coord_re <= integer'high;
                tb_last_pixel_coord_im <= integer'high;
            else
                if s_fetch_next = '1' and c_valid = '1' then
                    tb_last_pixel_col <= tb_pixel_col;
                    tb_last_pixel_row <= tb_pixel_row;
                    tb_last_minimap_status <= tb_is_in_minimap;
                    tb_last_pixel_coord_re <= tb_pixel_coord_re;
                    tb_last_pixel_coord_im <= tb_pixel_coord_im;
                end if;
            end if;
        end if;
    end process;

    CHECK_RE: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then
                -- Check pixel idx
                assert tb_pixel_col = (tb_last_pixel_col + 1) mod 640
                    report "Wrong pixel col received!" & LF
                        & "Exp.:" & to_string((tb_last_pixel_col + 1) mod 640) & LF
                        & "Got.:" & to_string(tb_pixel_col)
                    severity failure; 
                -- Check pixel coord.
                if tb_last_pixel_col = 639 then
                    assert tb_pixel_coord_re = -320 * to_integer(unsigned(tb_current_active_pixel_distance))
                        report "Wrong RE pixel coord received after reset!" & LF
                            & "Exp.:" & to_string(-320 * to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                            & "Got.:" & to_string(tb_pixel_coord_re)
                        severity failure;
                else
                    if tb_last_minimap_status = '0' and tb_is_in_minimap = '0' then
                        assert tb_pixel_coord_re = tb_last_pixel_coord_re + to_integer(unsigned(tb_current_active_pixel_distance))
                            report "Wrong RE pixel coord received!" & LF
                                & "Exp.:" & to_string(tb_last_pixel_coord_re + to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                                & "Got.:" & to_string(tb_pixel_coord_re)
                            severity failure;
                    end if;
                end if;
                tb_test_ended_re <= true;
            end if; 
        end loop;
    end process;

    CHECK_IM: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then 
                if tb_last_pixel_col = 639 then
                    -- Check pixel idx
                    assert tb_pixel_row = (tb_last_pixel_row + 1) mod 480
                        report "Wrong pixel row received!" & LF
                            & "Exp.:" & to_string((tb_last_pixel_row + 1) mod 480) & LF
                            & "Got.:" & to_string(tb_pixel_row)
                        severity failure;
                    -- Check pixel coord.
                    if tb_last_pixel_row = 479 then
                        assert tb_pixel_coord_im = 240 * to_integer(unsigned(tb_current_active_pixel_distance))
                            report "Wrong IM pixel coord received after reset!" & LF
                                & "Exp.:" & to_string(240 * to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                                & "Got.:" & to_string(tb_pixel_coord_im)
                            severity failure; 
                    else
                        if tb_last_minimap_status = '0' and tb_is_in_minimap = '0' then
                            assert tb_pixel_coord_im = tb_last_pixel_coord_im - to_integer(unsigned(tb_current_active_pixel_distance))
                                report "Wrong IM pixel coord received!" & LF
                                        & "Exp.:" & to_string(tb_last_pixel_coord_im - to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                                        & "Got.:" & to_string(tb_pixel_coord_im)
                                    severity failure;
                        end if;
                    end if;
                    tb_test_ended_im <= true;
                end if;
            end if; 
        end loop;
    end process;

    CHECK_PIXEL_DIST: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then
                assert c_pixel_distance = tb_current_active_pixel_distance
                    report "Pixel distance not correct!" & LF
                        & "Exp.:" & to_string(tb_current_active_pixel_distance) & LF
                        & "Got.:" & to_string(c_pixel_distance)
                    severity failure;
                tb_test_ended_distance <= true;
            end if;
        end loop;
    end process;

    CHECK_MINI_MAP: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then 
                -- Check minimap flag
                assert c_is_in_minimap = tb_is_in_minimap
                    report "Mininmap status of the pixel is not correctly flagged!" & LF
                        & "Exp.:" & std_logic'image(tb_is_in_minimap) & LF
                        & "Got.:" & std_logic'image(c_is_in_minimap)
                    severity failure;
                if tb_is_in_minimap = '1' then
                    -- Check mini map coords for re and im
                    if tb_last_minimap_status = '1' then
                        -- Check RE
                        assert tb_pixel_coord_re = tb_last_pixel_coord_re + (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)
                            report "Wrong mini map RE pixel coord received!" & LF
                                & "Exp.:" & to_string(tb_last_pixel_coord_re - (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)) & LF
                                & "Got.:" & to_string(tb_pixel_coord_re)
                            severity failure;
                        -- Check IM
                        if tb_last_pixel_coord_im /= tb_pixel_coord_im then
                            -- Next row --> Next IM value
                            assert tb_pixel_coord_im = tb_last_pixel_coord_im - (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)
                                report "Wrong mini map IM pixel coord received!" & LF
                                    & "Exp.:" & to_string(tb_last_pixel_coord_im - (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)) & LF
                                    & "Got.:" & to_string(tb_pixel_coord_im)
                                severity failure;
                        end if;
                    end if;
                end if;
                tb_test_ended_minimap <= true;
            end if;
        end loop;
    end process;

    CHECK_FRAME_IDX: process
        variable last_value : integer := 4;
	begin
        wait until s_resetn = '1';
        for i in 0 to 4 loop
            wait until tb_frame_idx /= last_value;
            assert tb_frame_idx = (i + 1) mod 4
                report "Wrong frame idx received!"
                    & " Exp.:" & to_string((i + 1) mod 4)
                    & " Got.:" & to_string(tb_frame_idx)
                severity failure;
            last_value := tb_frame_idx;
        end loop;
        wait until rising_edge(s_clk);
        tb_test_ended_frame_idx <= true;
        wait;
    end process;

    tb_test_ended <= tb_test_ended_frame_idx and tb_test_ended_re and tb_test_ended_im and tb_test_ended_minimap and tb_test_ended_distance;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 6*640*480*tbase;
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