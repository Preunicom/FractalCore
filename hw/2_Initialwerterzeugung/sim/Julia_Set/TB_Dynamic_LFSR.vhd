----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/15/2026 19:00:00 AM
-- Design Name: 
-- Module Name: TB_Dynamic_LFSR - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Dynamic LFSR.
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

entity TB_Dynamic_LFSR is
end TB_Dynamic_LFSR;

architecture Testbench of TB_Dynamic_LFSR is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_en : std_logic;
    signal s_load_en : std_logic;
    signal s_load_data : std_logic_vector(2 downto 0);
    signal s_xor_mask : std_logic_vector(1 downto 0);
    
    -- CHECK
    signal c_data : std_logic_vector(2 downto 0);

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Dynamic_LFSR
    generic map (
        g_WIDTH => 3
    )
    port map (
        i_resetn    => s_resetn,
        i_clk       => s_clk,
        i_en        => s_en,
        i_load_en   => s_load_en,
        i_load_data => s_load_data,
        i_xor_mask  => s_xor_mask,
        o_data      => c_data
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- Load 110
        s_en <= '0';
        s_load_en <= '1';
        s_load_data <= "110";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Load 001 (while enabled)
        s_en <= '1';
        s_load_en <= '1';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Stay
        s_en <= '0';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "10";
        wait until rising_edge(s_clk);
        -- Shift with new xor 
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "11";
        wait until rising_edge(s_clk);
        -- Shift with new xor 
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "11";
        wait until rising_edge(s_clk);
        -- Shift with new xor 
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "11";
        wait until rising_edge(s_clk);
        -- Shift with no xor 
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "00";
        wait until rising_edge(s_clk);
        -- Shift with no xor 
        s_en <= '1';
        s_load_en <= '0';
        s_load_data <= "001";
        s_xor_mask <= "00";
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait until rising_edge(s_clk);
        wait until rising_edge(s_clk);
        assert c_data = "110" 
            report "Wrong data loaded. Exp.: 110, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        assert c_data = "001" 
            report "Wrong data loaded. Exp.: 001, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 0 xor 0 | 1 | 0
        assert c_data = "010" 
            report "Wrong data shifted. Exp.: 010, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- Stay
        assert c_data = "010" 
            report "Wrong data stayed. Exp.: 010, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 0 xor 1 | 0 | 0
        assert c_data = "100" 
            report "Wrong data shifted. Exp.: 100, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 xor 0 | 0 | 1
        assert c_data = "101" 
            report "Wrong data shifted. Exp.: 101, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 xor 0 | 1 | 1
        assert c_data = "111" 
            report "Wrong data shifted. Exp.: 111, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 xor 1 | 1 | 1
        assert c_data = "011" 
            report "Wrong data shifted. Exp.: 011, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 0 xor 1 | 1 | 0
        assert c_data = "110" 
            report "Wrong data shifted. Exp.: 110, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 xor 1 | 0 | 1
        assert c_data = "001" 
            report "Wrong data shifted. Exp.: 001, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 0 xor 0 | 1 | 0 (repeat)
        assert c_data = "010" 
            report "Wrong data shifted. Exp.: 010, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 0 xor 1 | 0 xor 0 | 0
        assert c_data = "100" 
            report "Wrong data shifted. Exp.: 100, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 xor 0 | 1 xor 0 | 1
        assert c_data = "111" 
            report "Wrong data shifted. Exp.: 111, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 xor 1 | 1 xor 1 | 1
        assert c_data = "001" 
            report "Wrong data shifted. Exp.: 001, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 0 | 1 | 0
        assert c_data = "010" 
            report "Wrong data shifted. Exp.: 010, Got: " & to_string(c_data)
            severity failure;
        wait until rising_edge(s_clk);
        -- 1 | 0 | 0
        assert c_data = "100" 
            report "Wrong data shifted. Exp.: 100, Got: " & to_string(c_data)
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