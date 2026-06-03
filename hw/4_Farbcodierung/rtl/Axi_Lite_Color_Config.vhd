----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: Axi_Lite_Color_Config
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

entity AXI_Lite_Color_Config is
    generic (
        AXI_DATA_WIDTH : integer := 32;
        AXI_ADDR_WIDTH : integer := 4
    );
    port (
        o_color_scheme : out std_logic_vector(1 downto 0);

        AXI_A_CLK    : in std_logic;
        AXI_A_RESETN : in std_logic;

        -- AXI write address channel
        AXI_AW_ADDR  : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        AXI_AW_VALID : in std_logic;
        AXI_AW_READY : out std_logic;

        -- AXI write data channel
        AXI_DW_DATA   : in std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        AXI_DW_STRB   : in std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
        AXI_DW_VALID  : in std_logic;
        AXI_DW_READY  : out std_logic;

        -- AXI write response channel
        AXI_RW_RESP   : out std_logic_vector(1 downto 0);
        AXI_RW_VALID  : out std_logic;
        AXI_RW_READY  : in std_logic;

        -- AXI read address channel
        AXI_AR_ADDR  : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        AXI_AR_VALID : in std_logic;
        AXI_AR_READY : out std_logic;

        -- AXI read data channel
        AXI_DR_DATA   : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        AXI_DR_RESP   : out std_logic_vector(1 downto 0);
        AXI_DR_VALID  : out std_logic;
        AXI_DR_READY  : in std_logic
    );
end AXI_Lite_Color_Config;

architecture Behavioral of AXI_Lite_Color_Config is

    signal slv_reg0 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');

    signal awready_i : std_logic := '0';
    signal wready_i  : std_logic := '0';
    signal bvalid_i  : std_logic := '0';
    signal arready_i : std_logic := '0';
    signal rvalid_i  : std_logic := '0';
    signal rdata_i   : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');

begin

    AXI_AW_READY <= awready_i;
    AXI_DW_READY  <= wready_i;
    AXI_RW_VALID  <= bvalid_i;
    AXI_RW_RESP   <= "00"; -- OKAY

    AXI_AR_READY <= arready_i;
    AXI_DR_VALID  <= rvalid_i;
    AXI_DR_DATA   <= rdata_i;
    AXI_DR_RESP   <= "00"; -- OKAY

    o_color_scheme <= slv_reg0(1 downto 0);

    process(AXI_A_CLK)
    begin
        if rising_edge(AXI_A_CLK) then
            if AXI_A_RESETN = '0' then
                awready_i <= '0';
                wready_i  <= '0';
                bvalid_i  <= '0';
                slv_reg0  <= (others => '0');

            else
                awready_i <= '0';
                wready_i  <= '0';

                if awready_i = '0' and wready_i = '0' and
                   AXI_AW_VALID = '1' and AXI_DW_VALID = '1' and
                   bvalid_i = '0' then

                    awready_i <= '1';
                    wready_i  <= '1';

                    case AXI_AW_ADDR(3 downto 2) is
                        when "00" =>
                            if AXI_DW_STRB(0) = '1' then
                                slv_reg0(7 downto 0) <= AXI_DW_DATA(7 downto 0);
                            end if;

                        when others =>
                            null;
                    end case;

                    bvalid_i <= '1';
                end if;

                if bvalid_i = '1' and AXI_RW_READY = '1' then
                    bvalid_i <= '0';
                end if;
            end if;
        end if;
    end process;

    process(AXI_A_CLK)
    begin
        if rising_edge(AXI_A_CLK) then
            if AXI_A_RESETN = '0' then
                arready_i <= '0';
                rvalid_i  <= '0';
                rdata_i   <= (others => '0');

            else
                arready_i <= '0';

                if arready_i = '0' and AXI_AR_VALID = '1' and rvalid_i = '0' then
                    arready_i <= '1';

                    case AXI_AR_ADDR(3 downto 2) is
                        when "00" =>
                            rdata_i <= slv_reg0;

                        when others =>
                            rdata_i <= (others => '0');
                    end case;

                    rvalid_i <= '1';
                end if;

                if rvalid_i = '1' and AXI_DR_READY = '1' then
                    rvalid_i <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;