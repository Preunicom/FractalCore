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
-- Description: Testing the VGA Control with data presorting, fraembuffer manager and framebuffer.
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
    signal s_vga_reset                     : std_logic; 

    -- CHECK
    signal c_ready                         : std_logic; 
    signal c_vga_h_sync                    : std_logic; 
    signal c_vga_v_sync                    : std_logic; 
    signal c_vga_blank                     : std_logic; 
    signal c_vga_is_convergent             : std_logic; 
    signal c_vga_cycles_until_divergent    : std_logic_vector(7 downto 0); 
   
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
        i_vga_clk                    => s_vga_clk,
        i_vga_reset                  => s_vga_reset,
        o_vga_h_sync                 => c_vga_h_sync,
        o_vga_v_sync                 => c_vga_v_sync,
        o_vga_blank                  => c_vga_blank,
        o_vga_is_convergent          => c_vga_is_convergent,
        o_vga_cycles_until_divergent => c_vga_cycles_until_divergent
    );

    s_clk <= not s_clk after 0.5*tbase_data;
    s_resetn <= '0', '1' after 10*tbase_data;

    s_vga_clk <= not s_vga_clk after 0.5*tbase_vga;
    s_vga_reset <= '1', '0' after 640*tbase_vga;

    STIMULI: process
        variable v_counter: integer := 0;
	begin
        wait until s_resetn = '1';
        -- Send data to early --> Should never show as it will be bypassed and then overriden
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

    -- Only checking data (VGA Sync signals have to be checked manually!)
    CHECK: process
        variable v_counter: integer := 0;
	begin
        wait until s_vga_reset = '0';
        --wait until rising_edge(s_vga_clk); -- To wait delay of RAMs
        for idx in 0 to 9 loop
            for y in 0 to 524 loop -- with blanking
                for x in 0 to 799 loop -- with blanking
                    wait until rising_edge(s_vga_clk);
                    if c_vga_blank = '0' then
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
                    end if;   
                    v_counter := v_counter + 1;
                    if v_counter = 102 then
                        v_counter := 0;
                    end if;
                end loop;
                v_counter := idx + (y mod 91);
            end loop;
            v_counter := idx;
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
