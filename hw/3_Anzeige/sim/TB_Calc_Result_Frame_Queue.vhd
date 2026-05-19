----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/17/2026 10:08:00 PM
-- Design Name: 
-- Module Name: TB_Calc_Result_Frame_Queue - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Testing the result sorting FIFO.
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

entity TB_Calc_Result_Frame_Queue is
end TB_Calc_Result_Frame_Queue;

architecture Testbench of TB_Calc_Result_Frame_Queue is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_s_aclk : std_logic := '0';
    signal s_s_aresetn : std_logic;
    signal s_s_axis_tvalid : std_logic := '0';
    signal s_s_axis_tdata : std_logic_vector(31 downto 0) := (others => '0');
    signal s_m_axis_tready : std_logic := '0';

    -- CHECK
    signal c_s_axis_tready : std_logic := '0';  
    signal c_m_axis_tvalid : std_logic := '0';
    signal c_m_axis_tdata : std_logic_vector(31 downto 0) := (others => '0');
   
    -- TB MANAGE SIGNALS
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    UUT: entity work.Calc_Result_Frame_Queue
    port map (
        wr_rst_busy => open,
        rd_rst_busy => open,
        s_aclk => s_s_aclk,
        s_aresetn => s_s_aresetn,
        s_axis_tvalid => s_s_axis_tvalid,
        s_axis_tready => c_s_axis_tready,
        s_axis_tdata => s_s_axis_tdata,
        m_axis_tvalid => c_m_axis_tvalid,
        m_axis_tready => s_m_axis_tready,
        m_axis_tdata => c_m_axis_tdata
    );

    s_s_aresetn <= '0', '1' after 10*tbase;
    s_s_aclk <= not s_s_aclk after 0.5*tbase;

    STIMULI_WRITE: process
	begin
        wait until s_s_aresetn = '1';
        wait for 20*tbase;
        for i in 0 to 20000 loop
            s_s_axis_tdata <= "00" & std_logic_vector(to_unsigned(i, 30));
            s_s_axis_tvalid <= '1';
            wait_for_handshake(s_s_aclk, s_s_axis_tvalid, c_s_axis_tready);
        end loop;
        s_s_axis_tvalid <= '0';
        wait;
    end process;

    STIMULI_READ: process
	begin
        wait until s_s_aresetn = '1';
        wait until c_s_axis_tready = '0'; -- wait until full
        wait for 20*tbase;
        for i in 0 to 20000 loop
            s_m_axis_tready <= '1';
            wait_for_handshake(s_s_aclk, c_m_axis_tvalid, s_m_axis_tready);
        end loop;
        wait;
    end process;

    CHECK: process
	begin
        wait until rising_edge(s_s_aclk);
        for i in 0 to 20000 loop
            wait_for_handshake(s_s_aclk, c_m_axis_tvalid, s_m_axis_tready);
            assert to_integer(unsigned(c_m_axis_tdata)) = i
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(i) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_m_axis_tdata)))
                severity failure;
        end loop;
        wait until rising_edge(s_s_aclk);
        assert c_m_axis_tvalid = '0'
            report "FIFO is not empty at the end but should be!"
            severity failure;
        wait until rising_edge(s_s_aclk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 50000*tbase;
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
