----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/17/2026 10:01:00 PM
-- Design Name: 
-- Module Name: TB_Framebuffer - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Testing the Framebuffer.
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

entity TB_Framebuffer is
end TB_Framebuffer;

architecture Testbench of TB_Framebuffer is
    constant tbase_w : time := 10 ns;
    constant tbase_r : time := 13 ns;
    -- STIMULI
    signal s_clk_w : std_logic := '0';
    signal s_en_w : std_logic := '0';
    signal s_write_en : std_logic := '0';
    signal s_addr_w : std_logic_vector(18 downto 0);
    signal s_data_w : std_logic_vector(8 downto 0);
    signal s_clk_r : std_logic := '0';
    signal s_en_r : std_logic := '0';
    signal s_addr_r : std_logic_vector(18 downto 0);

    -- CHECK
    signal c_data_r : std_logic_vector(8 downto 0);
   
    -- TB MANAGE SIGNALS
    signal tb_last_r_en : std_logic;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    UUT: entity work.Framebuffer
        port map(
            i_clk_w => s_clk_w,
            i_en_w => s_en_w,
            i_write_en => s_write_en,
            i_addr_w => s_addr_w,
            i_data_w => s_data_w,

            i_clk_r => s_clk_r,
            i_en_r => s_en_r,
            i_addr_r => s_addr_r,
            o_data_r=> c_data_r
        );

    s_clk_w <= not s_clk_w after 0.5*tbase_w;
    s_clk_r <= not s_clk_r after 0.5*tbase_r;

    STIMULI: process
	begin
        s_en_w <= '0';
        s_write_en <= '0';
        wait until rising_edge(s_clk_w);
        s_en_w <= '1';
        s_write_en <= '1';
        s_addr_w <= std_logic_vector(to_unsigned(1, 19));
        s_data_w <= std_logic_vector(to_unsigned(1, 9));
        wait until rising_edge(s_clk_w);
        s_en_w <= '1';
        s_write_en <= '1';
        s_addr_w <= std_logic_vector(to_unsigned(2, 19));
        s_data_w <= std_logic_vector(to_unsigned(2, 9));
        wait until rising_edge(s_clk_w);
        s_en_w <= '1';
        s_write_en <= '1';
        s_addr_w <= std_logic_vector(to_unsigned(3, 19));
        s_data_w <= std_logic_vector(to_unsigned(3, 9));
        wait until rising_edge(s_clk_w);
        s_en_w <= '1';
        s_write_en <= '0';
        s_addr_w <= std_logic_vector(to_unsigned(3, 19));
        s_data_w <= std_logic_vector(to_unsigned(0, 9));
        wait until rising_edge(s_clk_r);
        s_en_r <= '1';
        s_addr_r <= std_logic_vector(to_unsigned(1, 19));
        wait until rising_edge(s_clk_r);
        s_en_r <= '1';
        s_addr_r <= std_logic_vector(to_unsigned(2, 19));
        wait until rising_edge(s_clk_r);
        s_en_r <= '1';
        s_addr_r <= std_logic_vector(to_unsigned(3, 19));
        wait;
    end process;

    CHECK: process
	begin
        wait until rising_edge(s_clk_r) and tb_last_r_en = '1';
        assert to_integer(unsigned(c_data_r)) = 1
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(1) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_data_r)))
                severity failure;
        wait until rising_edge(s_clk_r) and tb_last_r_en = '1';
        assert to_integer(unsigned(c_data_r)) = 2
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(2) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_data_r)))
                severity failure;
        wait until rising_edge(s_clk_r) and tb_last_r_en = '1';
        assert to_integer(unsigned(c_data_r)) = 3
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(3) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_data_r)))
                severity failure;
        wait until rising_edge(s_clk_r);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 100*tbase_w;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            wait for tbase_w;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

    LAST: process(s_clk_r)
	begin
        if rising_edge(s_clk_r) then
            tb_last_r_en <= s_en_r;
        end if;
    end process;

end Testbench;