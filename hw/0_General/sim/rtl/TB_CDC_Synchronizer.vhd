----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/11/2026 03:15:00 PM
-- Design Name: 
-- Module Name: TB_CDC_Synchronizer - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the CDC Synchronizer.
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
use std.env.finish;

entity TB_CDC_Synchronizer is
end TB_CDC_Synchronizer;

architecture Behavioral of TB_CDC_Synchronizer is
    constant tbase_in : time := 10 ns;
    constant tbase_out : time := 33 ns;
    -- STIMULI
    signal s_clk_out : std_logic := '0';
    signal s_data : std_logic := '0';
    -- CHECK
    signal c_data : std_logic;

    signal tb_clk_in: std_logic := '0';

    signal tb_test_passed : boolean := false;
begin

    UUT: entity work.CDC_Synchronizer
    port map (
        i_data    => s_data,
        i_clk_out => s_clk_out,
        o_data    => c_data
    );

    tb_clk_in <= not tb_clk_in after 0.5*tbase_in;
    s_clk_out <= not s_clk_out after 0.5*tbase_out;

    STIMULI: process
	begin
        s_data <= '1';
        wait until rising_edge(tb_clk_in);
        s_data <= '1';
        wait until rising_edge(tb_clk_in);
        s_data <= '1';
        wait until rising_edge(tb_clk_in);
        s_data <= '0';
        wait until rising_edge(tb_clk_in);
        s_data <= '0';
        wait until rising_edge(tb_clk_in);
        s_data <= '0';
        wait until rising_edge(tb_clk_in);
        s_data <= '1';
        wait until rising_edge(tb_clk_in);
        s_data <= '1';
        wait until rising_edge(tb_clk_in);
        s_data <= '1';
        wait;
	end process;

    CHECK: process
	begin
    wait until rising_edge(s_clk_out); -- First FF
    wait until rising_edge(s_clk_out); -- Second FF
    wait until rising_edge(s_clk_out); -- Data Valid
    assert c_data = '1'
        report "Wrong synced data!"
            & " Exp.: 1"
            & " Got.: " & std_logic'image(c_data)
        severity failure;
    wait until rising_edge(s_clk_out);
    assert c_data = '0'
        report "Wrong synced data!"
            & " Exp.: 0"
            & " Got.: " & std_logic'image(c_data)
        severity failure;
    wait until rising_edge(s_clk_out);
    assert c_data = '1'
        report "Wrong synced data!"
            & " Exp.: 1"
            & " Got.: " & std_logic'image(c_data)
        severity failure;
    wait for tbase_in;
    report "TEST PASSED!"
        severity note;
    tb_test_passed <= true;
    wait for tbase_in;
    finish;
    end process;

end Behavioral;