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
    signal s_pixel_distance      : std_logic_vector(7 downto 0);
    signal s_enable_mini_map     : std_logic;

    -- CHECK
    signal c_valid               : std_logic;
    signal c_pixel_coord_re      : std_logic_vector(17 downto 0);
    signal c_pixel_coord_im      : std_logic_vector(17 downto 0);
    signal c_pixel_idx_re        : std_logic_vector(9 downto 0);
    signal c_pixel_idx_im        : std_logic_vector(8 downto 0);
    signal c_frame_idx           : std_logic_vector(1 downto 0);
    signal c_is_in_mini_map      : std_logic;

    signal tb_pixel_coord_re     : integer;
    signal tb_pixel_coord_im     : integer;
    signal tb_pixel_idx_re       : integer;
    signal tb_pixel_idx_im       : integer;
    signal tb_frame_idx          : integer;
    signal tb_current_active_pixel_distance : std_logic_vector(7 downto 0);
    signal tb_current_mini_map_en : std_logic;

    signal tb_test_ended_frame_idx : boolean := false;
    signal tb_test_ended_re : boolean := false;
    signal tb_test_ended_im : boolean := false;
    signal tb_test_ended_mini_map : boolean := false;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Pixel_Generation
    port map (
        i_resetn              => s_resetn,
        i_clk                 => s_clk,
        i_fetch_next          => s_fetch_next,
        i_pixel_distance      => s_pixel_distance,
        i_enable_mini_map     => s_enable_mini_map,
        o_valid               => c_valid,
        o_pixel_coord_re      => c_pixel_coord_re,
        o_pixel_coord_im      => c_pixel_coord_im,
        o_pixel_idx_re        => c_pixel_idx_re,
        o_pixel_idx_im        => c_pixel_idx_im,
        o_frame_idx           => c_frame_idx,
        o_is_in_mini_map      => c_is_in_mini_map
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    tb_pixel_coord_re <= to_integer(signed(c_pixel_coord_re));
    tb_pixel_coord_im <= to_integer(signed(c_pixel_coord_im));
    tb_pixel_idx_re <= to_integer(unsigned(c_pixel_idx_re));
    tb_pixel_idx_im <= to_integer(unsigned(c_pixel_idx_im));
    tb_frame_idx <= to_integer(unsigned(c_frame_idx));

    tb_current_active_pixel_distance <= std_logic_vector(to_signed(1, 8)) when c_frame_idx = "00" else 
                                            std_logic_vector(to_signed(100, 8)) when c_frame_idx = "01" else 
                                            std_logic_vector(to_signed(50, 8));
    tb_current_mini_map_en <= '0' when c_frame_idx = "00" else '1';

    STIMULI: process
	begin
        wait until s_resetn = '1';
        s_pixel_distance <= std_logic_vector(to_signed(100, 8));
        s_fetch_next <= '1';
        s_enable_mini_map <= '1';
        wait for 640*480*tbase; -- 1 Frame
        s_pixel_distance <= std_logic_vector(to_signed(50, 8));
        s_fetch_next <= '0';
        wait for 100*tbase;
        s_fetch_next <= '1';
        wait for 2*640*480*tbase; -- 2 Frame
        s_pixel_distance <= std_logic_vector(to_signed(1, 8));
        s_enable_mini_map <= '0';
        wait for 1*640*480*tbase; -- 1 Frame
        s_pixel_distance <= std_logic_vector(to_signed(100, 8));
        s_enable_mini_map <= '1';
        wait for 1*640*480*tbase; -- 1 Frame
        s_enable_mini_map <= '0';
        wait;
    end process;

    CHECK_RE: process
        variable last_idx : integer := 639;
        variable last_coord : integer := integer'high;
        variable last_mini_map_status : std_logic := '0';
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then 
                if last_idx = 639 then
                    assert tb_pixel_coord_re = -320 * to_integer(unsigned(tb_current_active_pixel_distance))
                        report "Wrong RE pixel coord received after reset!" & LF
                            & "Exp.:" & to_string(-320 * to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                            & "Got.:" & to_string(tb_pixel_coord_re)
                        severity failure; 
                    assert tb_pixel_idx_re = 0
                        report "Wrong RE pixel idx received at reset!" & LF
                            & "Exp.:" & to_string(0) & LF
                            & "Got.:" & to_string(tb_pixel_idx_re)
                        severity failure; 
                else
                    if c_is_in_mini_map = '0' and last_mini_map_status = '0' then
                        assert tb_pixel_coord_re = last_coord + to_integer(unsigned(tb_current_active_pixel_distance))
                            report "Wrong RE pixel coord received!" & LF
                                & "Exp.:" & to_string(last_coord + to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                                & "Got.:" & to_string(tb_pixel_coord_re)
                            severity failure;
                        last_mini_map_status := '0';
                    else 
                        last_mini_map_status := '1';
                    end if;
                    assert tb_pixel_idx_re = last_idx + 1
                        report "Wrong RE pixel idx received!" & LF
                            & "Exp.:" & to_string(last_idx + 1) & LF
                            & "Got.:" & to_string(tb_pixel_idx_re)
                        severity failure; 
                end if;
                tb_test_ended_re <= true;
                last_idx := tb_pixel_idx_re;
                last_coord := tb_pixel_coord_re;
            end if; 
        end loop;
    end process;

    CHECK_IM: process
        variable last_idx : integer := 479;
        variable last_coord : integer := integer'high;
        variable counter : integer := 0;
        variable last_mini_map_status : std_logic := '0';
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then 
                if counter = 639 then
                    counter := 0;
                    if last_idx = 479 then
                        assert tb_pixel_coord_im = 240 * to_integer(unsigned(tb_current_active_pixel_distance))
                            report "Wrong IM pixel coord received after reset!" & LF
                                & "Exp.:" & to_string(240 * to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                                & "Got.:" & to_string(tb_pixel_coord_im)
                            severity failure; 
                        assert tb_pixel_idx_im = 0
                            report "Wrong IM pixel idx received at reset!" & LF
                                & "Exp.:" & to_string(0) & LF
                                & "Got.:" & to_string(tb_pixel_idx_im)
                            severity failure; 
                    else
                        if c_is_in_mini_map = '0' and last_mini_map_status = '0' then
                            assert tb_pixel_coord_im = last_coord - to_integer(unsigned(tb_current_active_pixel_distance))
                                report "Wrong IM pixel coord received!" & LF
                                        & "Exp.:" & to_string(last_coord - to_integer(unsigned(tb_current_active_pixel_distance))) & LF
                                        & "Got.:" & to_string(tb_pixel_coord_im)
                                    severity failure;
                            last_mini_map_status := '0';
                        else 
                            last_mini_map_status := '1';
                        end if;
                        assert tb_pixel_idx_im = last_idx + 1
                            report "Wrong IM pixel idx received!" & LF
                                & "Exp.:" & to_string(last_idx + 1) & LF
                                & "Got.:" & to_string(tb_pixel_idx_im)
                            severity failure; 
                    end if;
                    tb_test_ended_im <= true;
                    last_idx := tb_pixel_idx_im;
                    last_coord := tb_pixel_coord_im;
                else
                    counter := counter + 1;
                end if;
            end if; 
        end loop;
    end process;

    CHECK_MINI_MAP: process
        variable last_re : integer := integer'high;
        variable last_im: integer := integer'high;
        variable last_mini_map_status : std_logic := '0';
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if s_fetch_next = '1' and c_valid = '1' then 
                if tb_pixel_idx_re <= 160 and tb_pixel_idx_im >= 360 and tb_current_mini_map_en = '1' then 
                    assert c_is_in_mini_map = '1' 
                        report "Pixel not flaged as mini map area pixel but pixel should be!"
                        severity failure;
                    -- Check mini map coords for re and im
                    if last_mini_map_status = '1' then
                        assert tb_pixel_coord_re = last_re + (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)
                            report "Wrong mini map RE pixel coord received!" & LF
                                    & "Exp.:" & to_string(last_re - (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)) & LF
                                    & "Got.:" & to_string(tb_pixel_coord_re)
                                severity failure;
                        if last_im /= tb_pixel_coord_im then
                            -- Same line --> Same im value
                            assert tb_pixel_coord_im = last_im - (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)
                                report "Wrong mini map IM pixel coord received!" & LF
                                        & "Exp.:" & to_string(last_im - (to_integer(unsigned(tb_current_active_pixel_distance)) * 4)) & LF
                                        & "Got.:" & to_string(tb_pixel_coord_im)
                                    severity failure;
                        end if;
                    end if;
                else
                    assert c_is_in_mini_map = '0' 
                        report "Pixel flaged as mini map area pixel but pixel should not be!"
                        severity failure;
                end if;
                tb_test_ended_mini_map <= true;
                last_re := tb_pixel_coord_re;
                last_im := tb_pixel_coord_im;
                last_mini_map_status := c_is_in_mini_map;
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

    tb_test_ended <= tb_test_ended_frame_idx and tb_test_ended_re and tb_test_ended_im and tb_test_ended_mini_map;

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