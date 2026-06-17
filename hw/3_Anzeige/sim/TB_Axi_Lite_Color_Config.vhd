----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: TB_AXI_Lite_Color_Config - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: 
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
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity TB_AXI_Lite_Color_Config is
end TB_AXI_Lite_Color_Config;

architecture Testbench of TB_AXI_Lite_Color_Config is
    constant tbase : time := 10 ns;
    constant AXI_DATA_WIDTH : integer := 32;
    constant AXI_ADDR_WIDTH : integer := 4;

    signal clk : std_logic := '0';
    signal resetn : std_logic := '0';

    signal o_color_scheme : std_logic_vector(1 downto 0);

    signal awaddr  : std_logic_vector(3 downto 0) := (others => '0');
    signal awvalid : std_logic := '0';
    signal awready : std_logic;

    signal wdata  : std_logic_vector(31 downto 0) := (others => '0');
    signal wstrb  : std_logic_vector(3 downto 0) := (others => '0');
    signal wvalid : std_logic := '0';
    signal wready : std_logic;

    signal bresp  : std_logic_vector(1 downto 0);
    signal bvalid : std_logic;
    signal bready : std_logic := '0';

    signal araddr  : std_logic_vector(3 downto 0) := (others => '0');
    signal arvalid : std_logic := '0';
    signal arready : std_logic;

    signal rdata  : std_logic_vector(31 downto 0);
    signal rresp  : std_logic_vector(1 downto 0);
    signal rvalid : std_logic;
    signal rready : std_logic := '0';

    signal tb_test_done : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    clk <= not clk after tbase / 2;

    uut: entity work.AXI_Lite_Color_Config
        generic map (
            AXI_DATA_WIDTH => AXI_DATA_WIDTH,
            AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
        )
        port map (
            o_color_scheme => o_color_scheme,

            AXI_A_CLK => clk,
            AXI_A_RESETN => resetn,

            AXI_AW_ADDR => awaddr,
            AXI_AW_VALID => awvalid,
            AXI_AW_READY => awready,

            AXI_DW_DATA => wdata,
            AXI_DW_STRB => wstrb,
            AXI_DW_VALID => wvalid,
            AXI_DW_READY => wready,

            AXI_RW_RESP => bresp,
            AXI_RW_VALID => bvalid,
            AXI_RW_READY => bready,

            AXI_AR_ADDR => araddr,
            AXI_AR_VALID => arvalid,
            AXI_AR_READY => arready,

            AXI_DR_DATA => rdata,
            AXI_DR_RESP => rresp,
            AXI_DR_VALID => rvalid,
            AXI_DR_READY => rready
        );

    STIMULI : process
        procedure tick is
        begin
            wait until rising_edge(clk);
            wait for 1 ns;
        end procedure;

        procedure axi_write(
            constant addr : in std_logic_vector(3 downto 0);
            constant data : in std_logic_vector(31 downto 0);
            constant strb : in std_logic_vector(3 downto 0)
        ) is
        begin
            awaddr <= addr;
            wdata <= data;
            wstrb <= strb;
            awvalid <= '1';
            wvalid <= '1';
            bready <= '1';

            loop
                tick;
                exit when awready = '1' and wready = '1';
            end loop;

            awvalid <= '0';
            wvalid <= '0';

            assert bvalid = '1' and bresp = "00"
                report "AXI write response falsch"
                severity failure;

            tick;
            bready <= '0';
        end procedure;

        procedure axi_read(
            constant addr : in std_logic_vector(3 downto 0);
            constant expected : in std_logic_vector(31 downto 0);
            constant msg : in string
        ) is
        begin
            araddr <= addr;
            arvalid <= '1';
            rready <= '1';

            loop
                tick;
                exit when arready = '1';
            end loop;

            arvalid <= '0';

            assert rvalid = '1' and rresp = "00"
                report "AXI read response falsch"
                severity failure;

            assert rdata = expected
                report msg
                severity failure;

            tick;
            rready <= '0';
        end procedure;

    begin
        resetn <= '0';
        tick;
        tick;

        assert o_color_scheme = "00"
            report "Resetwert von o_color_scheme falsch"
            severity failure;

        resetn <= '1';
        tick;

        axi_write(x"0", x"00000003", "0001");

        assert o_color_scheme = "11"
            report "o_color_scheme nach Write 3 falsch"
            severity failure;

        axi_read(x"0", x"00000003", "Register Readback falsch");

        axi_write(x"0", x"00000002", "0000");

        assert o_color_scheme = "11"
            report "Register darf sich bei WSTRB=0000 nicht aendern"
            severity failure;

        axi_write(x"4", x"00000001", "0001");

        assert o_color_scheme = "11"
            report "Ungueltige Adresse darf Register nicht aendern"
            severity failure;

        axi_read(x"4", x"00000000", "Ungueltige Adresse sollte 0 lesen");

        tb_test_done <= true;
        wait;
    end process;

    CHECK_PROC : process
    begin
        wait until tb_test_done = true;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for tbase;
        finish;
    end process;

    TIMEOUT_PROC : process
    begin
        wait for 100*640*480*tbase;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;