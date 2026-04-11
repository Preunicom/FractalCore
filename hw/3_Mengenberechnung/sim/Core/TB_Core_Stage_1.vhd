----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/27/2026 06:10:00 PM
-- Design Name: 
-- Module Name: TB_Core_Stage_1 - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing stage 1 of the core.
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
use std.textio.all;

library work;
use work.Pkg_Core.all;

entity TB_Core_Stage_1 is
end TB_Core_Stage_1;

architecture Testbench of TB_Core_Stage_1 is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_clk : std_logic := '0';
    signal s_resetn : std_logic;
    signal s_stage_data : t_stage_data := c_STAGE_DATA_RESET;
    
    -- CHECK
    signal c_stage_data : t_stage_data;
    signal c_zr_add_zi : signed(18 downto 0);
    signal c_zr_sub_zi : signed(18 downto 0);
    signal c_2zr_mul_zi : signed(36 downto 0);
    signal c_zr_mul_zr : signed(35 downto 0);
    signal c_zi_mul_zi : signed(35 downto 0);

    -- TEST MANAGEMENT
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    
    UUT: entity work.Core_Stage_1
    port map (
        i_resetn     => s_resetn,
        i_clk        => s_clk,
        i_stage_data => s_stage_data,
        o_stage_data => c_stage_data,
        o_zr_add_zi  => c_zr_add_zi,
        o_zr_sub_zi  => c_zr_sub_zi,
        o_2zr_mul_zi => c_2zr_mul_zi,
        o_zr_mul_zr  => c_zr_mul_zr,
        o_zi_mul_zi  => c_zi_mul_zi
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        s_stage_data.video_frame_idx <= "01";
        s_stage_data.video_pix_col <= "0000000010";
        s_stage_data.video_pix_row <= "000000011";
        s_stage_data.z_real <= to_signed(2, 18) sll 15; -- 2 in 3.15 
        s_stage_data.z_img <= to_signed(1, 18) sll 15; -- 1 in 3.15 
        wait until rising_edge(s_clk);
        s_stage_data.z_real <= to_signed(5, 18) sll 13; -- 1.25 in 3.15 (1.01 --> Shift - 2)
        s_stage_data.z_img <= to_signed(-5, 18) sll 14; -- -2.5 in 3.15 (10.1 --> Shift - 1 --> *-1)
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait until rising_edge(s_clk);
        ---- TEST no fract bits and positive numbers
        -- RE: 2 in 3.15 
        -- IM: 1 in 3.15 
        wait until rising_edge(s_clk);
        assert c_zr_add_zi = to_signed(3, 19) sll 15
            report "z_r + z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(3, 19) sll 15) & LF
                & " Got:  " & to_string(c_zr_add_zi)
            severity failure;
        assert c_zr_sub_zi = to_signed(1, 19) sll 15
            report "z_r - z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(1, 19) sll 15) & LF
                & " Got:  " & to_string(c_zr_sub_zi)
            severity failure;
        assert c_zr_mul_zr = to_signed(4, 36) sll 30
            report "z_r * z_r failed!" & LF
                & " Exp.: " & to_string(to_signed(4, 36) sll 30) & LF
                & " Got:  " & to_string(c_zr_mul_zr)
            severity failure;
        assert c_zi_mul_zi = to_signed(1, 36) sll 30
            report "z_i * z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(1, 36) sll 30) & LF
                & " Got:  " & to_string(c_zi_mul_zi)
            severity failure;
        assert c_2zr_mul_zi = to_signed(4, 37) sll 30
            report "2z_r * z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(4, 37) sll 30) & LF
                & " Got:  " & to_string(c_2zr_mul_zi)
            severity failure;
        assert c_stage_data.video_frame_idx = "01" 
            and c_stage_data.video_pix_col = "0000000010" 
            and c_stage_data.video_pix_row = "000000011"
            and c_stage_data.z_real = to_signed(2, 18) sll 15
            and c_stage_data.z_img = to_signed(1, 18) sll 15
            report "Error in stage data!" & LF
                & " Exp.: 01 - 0000000010 - 000000011 - " 
                & to_String(to_signed(2, 18) sll 15) 
                & " - " & to_String(to_signed(1, 18) sll 15) & LF
                & " Got:  " & to_string(c_stage_data.video_frame_idx) 
                & " - " & to_string(c_stage_data.video_pix_col) 
                & " - " & to_string(c_stage_data.video_pix_row) 
                & " - " & to_string(c_stage_data.z_real) 
                & " - " & to_string(c_stage_data.z_img) 
            severity failure;
        ---- TEST with fract bits and negative numbers
        -- RE: 1.25 in 3.15 
        -- IM: -2.5 in 3.15 
        wait until rising_edge(s_clk);
        assert c_zr_add_zi = to_signed(-5, 19) sll 13 -- (-1.25) 1.01 --> Shift -2
            report "z_r + z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(-5, 19) sll 13) & " (-1.25)" & LF
                & " Got:  " & to_string(c_zr_add_zi)
            severity failure;
        assert c_zr_sub_zi = to_signed(15, 19) sll 13 -- (3.75) 11.11 --> Shift -2
            report "z_r - z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(15, 19) sll 13) & " (3.75)" & LF
                & " Got:  " & to_string(c_zr_sub_zi)
            severity failure;
        assert c_zr_mul_zr = to_signed(25, 36) sll 26 -- (1.5625) 1.1001 --> Shift -4
            report "z_r * z_r failed!" & LF
                & " Exp.: " & to_string(to_signed(25, 36) sll 26) & " (1.5625)" & LF
                & " Got:  " & to_string(c_zr_mul_zr)
            severity failure;
        assert c_zi_mul_zi = to_signed(25, 36) sll 28 -- (6.25) 110.01 --> Shift -2
            report "z_i * z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(25, 36) sll 28) & " (6.25)" & LF
                & " Got:  " & to_string(c_zi_mul_zi)
            severity failure;
        assert c_2zr_mul_zi = to_signed(-25, 37) sll 28 -- (-6.25) 110.01 --> Shift -2
            report "2z_r * z_i failed!" & LF
                & " Exp.: " & to_string(to_signed(-25, 37) sll 28) & " (-6.25)" & LF
                & " Got:  " & to_string(c_2zr_mul_zi)
            severity failure;
        wait until rising_edge(s_clk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 100*tbase;
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
