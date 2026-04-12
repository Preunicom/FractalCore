----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/27/2026 04:15:00 PM
-- Design Name: 
-- Module Name: TB_Core_Control - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Core Controller.
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
use work.Pkg_Core.all;
use work.Pkg_TB_Utils.all;

entity TB_Core_Control is
end TB_Core_Control;

architecture Testbench of TB_Core_Control is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_clk : std_logic := '0';
    signal s_resetn : std_logic;
    signal s_magnitude : signed(36 downto 0);
    signal s_load_data_valid : std_logic;
    signal s_transmit_partner_ready : std_logic;
    -- CHECK
    signal c_transmit_data_valid : std_logic;
    signal c_transmit_is_convergent : std_logic;
    signal c_transmit_iteration_data : std_logic_vector(7 downto 0);
    signal c_load_data_ready : std_logic;
    signal c_select_loaded_data : std_logic;

    signal tb_transmit_test_ended : boolean := false;
    signal tb_load_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    
    UUT: entity work.Core_Control
    port map (
        i_resetn                  => s_resetn,
        i_clk                     => s_clk,
        i_magnitude               => s_magnitude,
        i_load_data_valid         => s_load_data_valid,
        i_transmit_partner_ready  => s_transmit_partner_ready,
        o_transmit_data_valid     => c_transmit_data_valid,
        o_transmit_is_convergent  => c_transmit_is_convergent,
        o_transmit_iteration_data => c_transmit_iteration_data,
        o_load_data_ready         => c_load_data_ready,
        o_select_loaded_data      => c_select_loaded_data
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        s_magnitude <= (others => '0');
        s_load_data_valid <= '0';
        s_transmit_partner_ready <= '1';
        -- Check idle
        for i in 1 to 10 loop
            wait until rising_edge(s_clk);
        end loop;
        -- Load data
        s_load_data_valid <= '1';
        wait_for_handshake(s_clk, s_load_data_valid, c_load_data_ready);
        s_load_data_valid <= '0';
        -- Delayed
        wait until rising_edge(s_clk); 
        -- S1
        wait until rising_edge(s_clk);
        -- S2
        wait until rising_edge(s_clk);
        s_magnitude <= (others => '1'); -- Too high --> Finish calc. (Result: 0 Iterations, divergent)
        wait until rising_edge(s_clk);
        s_magnitude <= (others => '0');
        s_load_data_valid <= '1';
        wait_for_handshake(s_clk, s_load_data_valid, c_load_data_ready); -- Load 1
        wait_for_handshake(s_clk, s_load_data_valid, c_load_data_ready); -- Load 2
        wait_for_handshake(s_clk, s_load_data_valid, c_load_data_ready); -- Load 3
        -- All stages taken
        s_load_data_valid <= '0';
        for i in 1 to 30 loop -- 10 Iterations for all
            wait until rising_edge(s_clk);
        end loop;
        s_magnitude <= to_signed(1, 37) sll 31; -- Too low
        wait until rising_edge(s_clk);
        s_magnitude <= to_signed(2, 37) sll 33; -- Too high --> Finish calc.
        wait until rising_edge(s_clk);
        s_transmit_partner_ready <= '0';
        s_magnitude <= to_signed(2, 37) sll 34; -- Too high --> Finish calc.
        wait until rising_edge(s_clk);
        s_magnitude <= (others => '0');
        for i in 1 to 10 loop
            wait until rising_edge(s_clk);
        end loop;
        s_transmit_partner_ready <= '1';
        wait;
    end process;

    -- Checks all time for load (sets finished after the first successfull check of an loaded data)
    CHECK_LOAD: process
	begin
        wait until s_resetn = '1';
        loop
            wait until rising_edge(s_clk);
            if s_load_data_valid = '1' and c_load_data_ready = '1' then
                wait for 0.5*tbase;
                assert c_select_loaded_data = '1'
                    report "Select signal wrong!" 
                        & " Exp.: 1"
                        & " Got: " & std_logic'image(c_select_loaded_data)
                    severity failure;
                tb_load_test_ended <= true;
            else
                wait for 0.5*tbase;
                assert c_select_loaded_data = '0'
                    report "Select signal wrong!" 
                        & " Exp.: 0"
                        & " Got: " & std_logic'image(c_select_loaded_data)
                    severity failure;
            end if;
        end loop;
    end process;

    CHECK_TRANSMIT: process
	begin
        wait until s_resetn = '1';
        wait_for_handshake(s_clk, c_transmit_data_valid, s_transmit_partner_ready);
        assert c_transmit_is_convergent = '0'
            report "First convergent flag is set wrong!"
                & " Exp.: 0"
                & " Got: " & std_logic'image(c_transmit_is_convergent)
            severity failure;
        assert c_transmit_iteration_data = x"00"
            report "First iteration amount is set wrong!" 
                & " Exp.: 00000000"
                & " Got: " & to_string(c_transmit_iteration_data)
            severity failure;
        wait_for_handshake(s_clk, c_transmit_data_valid, s_transmit_partner_ready);
        assert c_transmit_is_convergent = '0'
            report "Second convergent flag is set wrong!"
                & " Exp.: 0"
                & " Got: " & std_logic'image(c_transmit_is_convergent)
            severity failure;
        assert c_transmit_iteration_data = x"0A"
            report "Second iteration amount is set wrong!"
                & " Exp.: 00001010"
                & " Got: " & to_string(c_transmit_iteration_data)
            severity failure;
        wait_for_handshake(s_clk, c_transmit_data_valid, s_transmit_partner_ready);
        assert c_transmit_is_convergent = '0'
            report "Third convergent flag is set wrong!"
                & " Exp.: 0"
                & " Got: " & std_logic'image(c_transmit_is_convergent)
            severity failure;
        assert c_transmit_iteration_data = x"0A"
            report "Third iteration amount is set wrong!"
                & " Exp.: 00001010"
                & " Got: " & to_string(c_transmit_iteration_data)
            severity failure;
        wait_for_handshake(s_clk, c_transmit_data_valid, s_transmit_partner_ready);
        assert c_transmit_is_convergent = '1'
            report "Fourth convergent flag is set wrong!"
                & " Exp.: 1"
                & " Got: " & std_logic'image(c_transmit_is_convergent)
            severity failure;
        assert c_transmit_iteration_data = x"65"
            report "Fourth iteration amount is set wrong!"
                & " Exp.: 01100101" --101
                & " Got: " & to_string(c_transmit_iteration_data)
            severity failure;
        wait until rising_edge(s_clk);
        tb_transmit_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_transmit_test_ended = true and tb_load_test_ended = true for 500*tbase;
        if tb_transmit_test_ended = true and tb_load_test_ended = true then
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
