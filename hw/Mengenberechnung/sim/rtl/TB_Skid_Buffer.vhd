----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/20/2026 06:58:00 PM
-- Design Name: 
-- Module Name: TB_Skid_Buffer - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Skid Buffer.
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

entity TB_Skid_Buffer is
end TB_Skid_Buffer;

architecture Testbench of TB_Skid_Buffer is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_valid : std_logic := '0';
    signal s_ready : std_logic := '0';
    signal s_data : std_logic_vector(3 downto 0) := (others => '0');
    -- CHECK
    signal c_ready : std_logic;
    signal c_valid : std_logic;
    signal c_data : std_logic_vector(3 downto 0);

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    UUT: entity work.Skid_Buffer
    generic map (
        g_DATA_WIDTH => 4
    )
    port map (
        i_resetn => s_resetn,
        i_clk    => s_clk,
        i_valid  => s_valid,
        i_data   => s_data,
        o_ready  => c_ready,
        i_ready  => s_ready,
        o_valid  => c_valid,
        o_data   => c_data
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI_MASTER: process
	begin
        wait until s_resetn = '1';
        for i in 1 to 10 loop
            s_valid <= '1';
            s_data <= std_logic_vector(to_unsigned(i, 4));
            wait_for_handshake(s_clk, s_valid, c_ready);
            if i = 7 then
                s_valid <= '0';
                wait for 5*tbase;
                wait until rising_edge(s_clk);
            end if;
        end loop;
        wait;
    end process;

    STIMULI_SLAVE: process
	begin
        wait until s_resetn = '1';
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '0';
        wait until rising_edge(s_clk);
        s_ready <= '0';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '0';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '0';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        s_ready <= '0';
        wait until rising_edge(s_clk);
        s_ready <= '1';
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        for i in 1 to 10 loop
            wait_for_handshake(s_clk, c_valid, s_ready);
            assert c_data = std_logic_vector(to_unsigned(i, 4))
                report "Wrong data sent!" & LF
                    & "Exp.: " & to_string(std_logic_vector(to_unsigned(i, 4))) & LF
                    & "Got:  " & to_string(c_data)
                severity failure;
        end loop;
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 50*tbase;
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
