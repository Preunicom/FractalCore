----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/19/2026 15:19:00 PM
-- Design Name: 
-- Module Name: TB_VGA_Control - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Testing the VGA Control with data presorting, framebuffer manager and framebuffer.
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
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.Pkg_TB_Utils.all;
use work.Pkg_Utils.all;
use work.Pkg_VGA.all;

entity TB_VGA_Control is
end TB_VGA_Control;

architecture Testbench of TB_VGA_Control is
    constant tbase_data : time := 10 ns;
    constant tbase_vga : time := 33 ns;
    
    -- STIMULI
    signal s_resetn                        : std_logic; 
    signal s_clk                           : std_logic := '0'; 
    signal s_valid                         : std_logic; 
    signal s_video_pix_col                 : std_logic_vector(9 downto 0);
    signal s_video_pix_row                 : std_logic_vector(8 downto 0);
    signal s_video_frame_idx               : std_logic_vector(1 downto 0);
    signal s_is_convergent                 : std_logic; 
    signal s_cycles_until_divergent        : std_logic_vector(7 downto 0); 
    signal s_vga_clk                       : std_logic := '0'; 
    signal s_vga_resetn                    : std_logic; 
    signal s_highlight_info                : t_highlight_info := (others => c_HIGHLIGHT_PIXEL_RESET);

    -- CHECK
    signal c_ready                         : std_logic; 
    signal c_vga_h_sync                    : std_logic; 
    signal c_vga_v_sync                    : std_logic; 
    signal c_vga_blank                     : std_logic; 
    signal c_vga_is_convergent             : std_logic; 
    signal c_vga_cycles_until_divergent    : std_logic_vector(7 downto 0); 
    signal c_vga_is_highlighted            : std_logic;
    signal c_vga_is_highlighted_target     : std_logic;
   
    -- TB MANAGE SIGNALS
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.VGA_Control
    port map (
        i_resetn                     => s_resetn,
        i_clk                        => s_clk,
        i_valid                      => s_valid,
        i_video_pix_col              => s_video_pix_col,
        i_video_pix_row              => s_video_pix_row,
        i_video_frame_idx            => s_video_frame_idx,
        i_is_convergent              => s_is_convergent,
        i_cycles_until_divergent     => s_cycles_until_divergent,
        o_ready                      => c_ready,
        i_highlight_info             => s_highlight_info,
        i_vga_clk                    => s_vga_clk,
        i_vga_resetn                 => s_vga_resetn,
        o_vga_h_sync                 => c_vga_h_sync,
        o_vga_v_sync                 => c_vga_v_sync,
        o_vga_blank                  => c_vga_blank,
        o_vga_is_convergent          => c_vga_is_convergent,
        o_vga_cycles_until_divergent => c_vga_cycles_until_divergent,
        o_vga_is_highlighted         => c_vga_is_highlighted,
        o_vga_is_highlighted_target  => c_vga_is_highlighted_target
    );

    s_clk <= not s_clk after 0.5*tbase_data;
    s_resetn <= '0', '1' after 10*tbase_data;

    s_vga_clk <= not s_vga_clk after 0.5*tbase_vga;
    s_vga_resetn <= '0', '1' after 640*tbase_vga;

    s_highlight_info(0).valid <= '1';
    s_highlight_info(0).current_pixel_col <= std_logic_vector(to_unsigned(0, 10));
    s_highlight_info(0).current_pixel_row <= std_logic_vector(to_unsigned(479, 9));
    s_highlight_info(0).target_pixel_col <= std_logic_vector(to_unsigned(10, 10));
    s_highlight_info(0).target_pixel_row <= std_logic_vector(to_unsigned(370, 9));
    s_highlight_info(1).valid <= '0';
    s_highlight_info(2).valid <= '1';
    s_highlight_info(2).current_pixel_col <= std_logic_vector(to_unsigned(100, 10));
    s_highlight_info(2).current_pixel_row <= std_logic_vector(to_unsigned(130, 9));
    s_highlight_info(2).target_pixel_col <= std_logic_vector(to_unsigned(120, 10));
    s_highlight_info(2).target_pixel_row <= std_logic_vector(to_unsigned(479, 9));
    s_highlight_info(3).valid <= '0';

    STIMULI: process
        variable v_counter: integer := 0;
	begin
        wait until s_resetn = '1';
        -- Send data too early --> Should never show as it will be bypassed and then overridden
        for x in 0 to 639 loop
            s_valid                  <= '1';       
            s_video_pix_col          <= std_logic_vector(to_unsigned(x, 10));
            s_video_pix_row          <= std_logic_vector(to_unsigned(0, 9));
            s_video_frame_idx        <= "01"; -- Too early data
            s_cycles_until_divergent <= (others => '1');
            s_is_convergent          <= '0';  
            wait_for_handshake(s_clk, s_valid, c_ready);
        end loop;
        for idx in 0 to 9 loop
            for y in 0 to 479 loop
                for x in 0 to 639 loop
                    s_valid                  <= '1';       
                    s_video_pix_col          <= std_logic_vector(to_unsigned(x, 10));
                    s_video_pix_row          <= std_logic_vector(to_unsigned(y, 9));
                    s_video_frame_idx        <= std_logic_vector(to_unsigned(idx mod 4, 2));
                    s_cycles_until_divergent <= std_logic_vector(to_unsigned(v_counter, 8));
                    if v_counter = 101 then
                        s_is_convergent      <= '1';  
                    else
                        s_is_convergent      <= '0';
                    end if; 
                    wait_for_handshake(s_clk, s_valid, c_ready);
                    v_counter := v_counter + 1;
                    if v_counter = 102 then
                        v_counter := 0;
                    end if;
                end loop;
                v_counter := idx + (y mod 91);
            end loop;
            v_counter := idx;
        end loop;
        wait;
    end process;

    CHECK: process
        variable v_counter: integer := 0;
        variable v_visible_pixels : integer := 0;
        variable v_hsyc_pixels : integer := 0;
        variable v_vsyc_pixels : integer := 0;
        variable v_amount_highlighted_pixels : integer := 0;
        variable v_amount_highlighted_target_pixels : integer := 0;
	begin
        wait until s_vga_resetn = '1';
        wait until rising_edge(s_vga_clk); -- To wait for the delay of the RAM
        for idx in 0 to 9 loop
            v_amount_highlighted_pixels := 0;
            v_amount_highlighted_target_pixels := 0;
            v_visible_pixels := 0;
            v_vsyc_pixels := 0;
            for y in 0 to 524 loop -- with blanking
                v_hsyc_pixels := 0;
                for x in 0 to 799 loop -- with blanking
                    wait until rising_edge(s_vga_clk);
                    if c_vga_blank = '0' then
                        v_visible_pixels := v_visible_pixels + 1;
                        ------------------------------ CHECK PIXEL VALUES ------------------------------
                        assert to_integer(unsigned(c_vga_cycles_until_divergent)) = v_counter
                            report "Wrong cycles until divergent amount received!" &
                                "(Frame: " & to_string(idx) & ", Y: " & to_string(y) & " / X: " & to_string(x) & ")" & LF
                                & "Exp.: " & to_string(v_counter)
                                & " Got.: " & to_string(to_integer(unsigned(c_vga_cycles_until_divergent)))
                            severity failure;
                        if v_counter = 101 then
                            assert c_vga_is_convergent = '1'  
                                report "Wrong convergent flag received!" &
                                    "(Frame: " & to_string(idx) & ", Y: " & to_string(y) & " / X: " & to_string(x) & ")" & LF
                                    & "Exp.: 1"
                                    & " Got.: " & std_logic'image(c_vga_is_convergent)
                                severity failure;
                        else
                            assert c_vga_is_convergent = '0'  
                                report "Wrong convergent flag received!" &
                                    "(Frame: " & to_string(idx) & ", Y: " & to_string(y) & " / X: " & to_string(x) & ")" & LF
                                    & "Exp.: 0"
                                    & " Got.: " & std_logic'image(c_vga_is_convergent)
                                severity failure;
                        end if; 
                        ---------------------------- CHECK PIXEL VALUES  END ----------------------------
                        if c_vga_is_highlighted = '1' then
                            v_amount_highlighted_pixels := v_amount_highlighted_pixels + 1;
                        end if;
                        if c_vga_is_highlighted_target = '1' then
                            v_amount_highlighted_target_pixels := v_amount_highlighted_target_pixels + 1;
                        end if;
                    else
                        if c_vga_h_sync = '0' then
                            v_hsyc_pixels := v_hsyc_pixels + 1;
                        end if;
                        if c_vga_v_sync = '0' then
                            v_vsyc_pixels := v_vsyc_pixels + 1;
                        end if;
                    end if;   
                    v_counter := v_counter + 1;
                    if v_counter = 102 then
                        v_counter := 0;
                    end if;
                end loop;
                v_counter := idx + (y mod 91);
                assert v_hsyc_pixels = c_COLS_SYNCTIME
                    report "Amount of HSYNC pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string(c_COLS_SYNCTIME) 
                        & " Got.: " & to_string(v_hsyc_pixels)
                        & " (Row: " & to_string(y) & ")"
                    severity failure;
            end loop;
            v_counter := idx;
            assert v_vsyc_pixels = c_ROWS_SYNCTIME*c_COLS_SUM
                    report "Amount of VSYNC pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string(c_ROWS_SYNCTIME*c_COLS_SUM) 
                        & " Got.: " & to_string(v_vsyc_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
            assert v_visible_pixels = 640*480
                report "Amount of visible pixels does not match the expected value!" & LF
                    & "Exp.: " & to_string(640*480) 
                    & " Got.: " & to_string(v_visible_pixels)
                severity failure;
            ------------------------------ CHECK HIGHLIGHT ------------------------------
            if idx = 0 then
                assert v_amount_highlighted_pixels = 4
                    report "Amount of highlighted pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string(4) 
                        & " Got.: " & to_string(v_amount_highlighted_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
                assert v_amount_highlighted_target_pixels = (480 + 640)/4 - 1 -- - 1(col and row overlap)
                    report "Amount of highlighted target pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string((480 + 640)/4 - 1)
                        & " Got.: " & to_string(v_amount_highlighted_target_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
            elsif idx = 2 then
                assert v_amount_highlighted_pixels = 9
                    report "Amount of highlighted pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string(9) 
                        & " Got.: " & to_string(v_amount_highlighted_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
                assert v_amount_highlighted_target_pixels = (480 + 640)/4 - 1 -- - 1(col and row overlap)
                    report "Amount of highlighted target pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string((480 + 640)/4 - 1) 
                        & " Got.: " & to_string(v_amount_highlighted_target_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
            elsif idx = 1 or idx = 3 then
                assert v_amount_highlighted_pixels = 0
                    report "Amount of highlighted pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string(0) 
                        & " Got.: " & to_string(v_amount_highlighted_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
                assert v_amount_highlighted_target_pixels = 0
                    report "Amount of highlighted target pixels does not match the expected value!" & LF
                        & "Exp.: " & to_string(0) 
                        & " Got.: " & to_string(v_amount_highlighted_target_pixels)
                        & " (Frame: " & to_string(idx) & ")"
                    severity failure;
            end if;
            ---------------------------- CHECK HIGHLIGHT END ----------------------------
            report "Frame " & to_string(idx) & " successfully passed all tests!";
        end loop;
        wait until rising_edge(s_clk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 11*800*525*tbase_vga;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            wait for tbase_vga;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;
