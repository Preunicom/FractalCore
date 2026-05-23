----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/15/2026 19:10:00 AM
-- Design Name: 
-- Module Name: TB_Dynamic_LFSR_Bit - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Dynamic LFSR Bit.
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

entity TB_Dynamic_LFSR_Bit is
end TB_Dynamic_LFSR_Bit;

architecture Testbench of TB_Dynamic_LFSR_Bit is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_en : std_logic;
    signal s_load_en : std_logic;
    signal s_load_data : std_logic;
    signal s_prev_data : std_logic;
    signal s_use_xor : std_logic;
    signal s_xor_data : std_logic;
    
    -- CHECK
    signal c_data : std_logic;

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Dynamic_LFSR_Bit
    port map (
        i_resetn    => s_resetn,
        i_clk       => s_clk,
        i_en        => s_en,
        i_load_en   => s_load_en,
        i_load_data => s_load_data,
        i_prev_data => s_prev_data,
        i_use_xor   => s_use_xor,
        i_xor_data  => s_xor_data,
        o_data      => c_data
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- Load 1
        s_en <= '0';
        s_load_en <= '1';
        s_load_data <= '1';
        s_prev_data <= '1';
        s_use_xor <= '0';
        s_xor_data <= '0';
        wait until rising_edge(s_clk);
        -- Load 0
        s_en <= '0';
        s_load_en <= '1';
        s_load_data <= '0';
        s_prev_data <= '1';
        s_use_xor <= '0';
        s_xor_data <= '0';
        wait until rising_edge(s_clk);
        -- Shift (0)
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= '1';
        s_prev_data <= '1';
        s_use_xor <= '1';
        s_xor_data <= '1';
        wait until rising_edge(s_clk);
        -- Stay
        s_en <= '0';
        s_load_en <= '0';
        s_load_data <= '1';
        s_prev_data <= '0';
        s_use_xor <= '1';
        s_xor_data <= '1';
        wait until rising_edge(s_clk);
        -- Shift (1)
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= '1';
        s_prev_data <= '0';
        s_use_xor <= '1';
        s_xor_data <= '1';
        wait until rising_edge(s_clk);
        -- Shift (0)
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= '1';
        s_prev_data <= '0';
        s_use_xor <= '0';
        s_xor_data <= '1';
        wait until rising_edge(s_clk);
        -- Load + En
        s_en <= '1';
        s_load_en <= '1';
        s_load_data <= '1';
        s_prev_data <= '0';
        s_use_xor <= '0';
        s_xor_data <= '1';
        wait until rising_edge(s_clk);
        s_en <= '0';
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        assert c_data = '1' 
            report "Wrong bit loaded. Exp.: 1, Got: " & std_logic'image(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = '0' 
            report "Wrong bit loaded. Exp.: 0, Got: " & std_logic'image(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = '0' 
            report "Wrong bit shifted (xor). Exp.: 0, Got: " & std_logic'image(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = '0' 
            report "Wrong bit. Should have stayed 0. Exp.: 0, Got: " & std_logic'image(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = '1' 
            report "Wrong bit shifted (xor). Exp.: 1, Got: " & std_logic'image(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = '0' 
            report "Wrong bit shifted. Exp.: 0, Got: " & std_logic'image(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = '1' 
            report "Wrong bit loaded while enabled. Exp.: 1, Got: " & std_logic'image(c_data)
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