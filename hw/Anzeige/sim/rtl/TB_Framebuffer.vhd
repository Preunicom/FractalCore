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
    signal s_clka : std_logic := '0';
    signal s_ena : std_logic := '0';
    signal s_wea : std_logic := '0';
    signal s_addra : std_logic_vector(18 downto 0);
    signal s_dina : std_logic_vector(8 downto 0);
    signal s_clkb : std_logic := '0';
    signal s_enb : std_logic := '0';
    signal s_addrb : std_logic_vector(18 downto 0);

    -- CHECK
    signal c_doutb : std_logic_vector(8 downto 0);
   
    -- TB MANAGE SIGNALS
    signal tb_last_r_en : std_logic;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    
    UUT: entity work.Framebuffer
    port map (
        clka    => s_clka,
        ena     => s_ena,
        wea     => s_wea,
        addra   => s_addra,
        dina    => s_dina,
        clkb    => s_clkb,
        enb     => s_enb,
        addrb   => s_addrb,
        doutb   => c_doutb
    );

    s_clka <= not s_clka after 0.5*tbase_w;
    s_clkb <= not s_clkb after 0.5*tbase_r;

    STIMULI: process
	begin
        s_ena <= '0';
        s_wea <= '0';
        wait until rising_edge(s_clka);
        s_ena <= '1';
        s_wea <= '1';
        s_addra <= std_logic_vector(to_unsigned(1, 19));
        s_dina <= std_logic_vector(to_unsigned(1, 9));
        wait until rising_edge(s_clka);
        s_ena <= '1';
        s_wea <= '1';
        s_addra <= std_logic_vector(to_unsigned(2, 19));
        s_dina <= std_logic_vector(to_unsigned(2, 9));
        wait until rising_edge(s_clka);
        s_ena <= '1';
        s_wea <= '1';
        s_addra <= std_logic_vector(to_unsigned(3, 19));
        s_dina <= std_logic_vector(to_unsigned(3, 9));
        wait until rising_edge(s_clka);
        s_ena <= '1';
        s_wea <= '0';
        s_addra <= std_logic_vector(to_unsigned(3, 19));
        s_dina <= std_logic_vector(to_unsigned(0, 9));
        wait until rising_edge(s_clkb);
        s_enb <= '1';
        s_addrb <= std_logic_vector(to_unsigned(1, 19));
        wait until rising_edge(s_clkb);
        s_enb <= '1';
        s_addrb <= std_logic_vector(to_unsigned(2, 19));
        wait until rising_edge(s_clkb);
        s_enb <= '1';
        s_addrb <= std_logic_vector(to_unsigned(3, 19));
        wait;
    end process;

    CHECK: process
	begin
        wait until rising_edge(s_clkb) and tb_last_r_en = '1';
        assert to_integer(unsigned(c_doutb)) = 1
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(1) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_doutb)))
                severity failure;
        wait until rising_edge(s_clkb) and tb_last_r_en = '1';
        assert to_integer(unsigned(c_doutb)) = 2
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(2) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_doutb)))
                severity failure;
        wait until rising_edge(s_clkb) and tb_last_r_en = '1';
        assert to_integer(unsigned(c_doutb)) = 3
                report "Wrong value!" & LF
                        & " Exp.: " & to_string(3) & LF
                        & " Got:  " & to_string(to_integer(unsigned(c_doutb)))
                severity failure;
        wait until rising_edge(s_clkb);
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

    LAST: process(s_clkb)
	begin
        if rising_edge(s_clkb) then
            tb_last_r_en <= s_enb;
        end if;
    end process;

end Testbench;