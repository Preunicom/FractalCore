----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: Farbcodierung
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

entity Farbcodierung is
    generic (
        DATA_WIDTH : integer := 9;
        AXI_DATA_WIDTH : integer := 32;
        AXI_ADDR_WIDTH : integer := 4
    );
    port (
        i_data : in std_logic_vector(DATA_WIDTH-1 downto 0);

        o_red : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue : out std_logic_vector(3 downto 0);

        AXI_A_CLK    : in std_logic;
        AXI_A_RESETN : in std_logic;

        AXI_AW_ADDR  : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        AXI_AW_VALID : in std_logic;
        AXI_AW_READY : out std_logic;

        AXI_DW_DATA  : in std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        AXI_DW_STRB  : in std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
        AXI_DW_VALID : in std_logic;
        AXI_DW_READY : out std_logic;

        AXI_RW_RESP  : out std_logic_vector(1 downto 0);
        AXI_RW_VALID : out std_logic;
        AXI_RW_READY : in std_logic;

        AXI_AR_ADDR  : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        AXI_AR_VALID : in std_logic;
        AXI_AR_READY : out std_logic;

        AXI_DR_DATA  : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        AXI_DR_RESP  : out std_logic_vector(1 downto 0);
        AXI_DR_VALID : out std_logic;
        AXI_DR_READY : in std_logic
    );
end Farbcodierung;

architecture Behavioral of Farbcodierung is

    signal slv_reg0 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');

        signal awready_i : std_logic := '0';
        signal wready_i  : std_logic := '0';
        signal bvalid_i  : std_logic := '0';
        signal arready_i : std_logic := '0';
        signal rvalid_i  : std_logic := '0';
        signal rdata_i   : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');

        signal axi_color_scheme : std_logic_vector(1 downto 0);
begin

    AXI_AW_READY <= awready_i;
    AXI_DW_READY <= wready_i;
    AXI_RW_VALID <= bvalid_i;
    AXI_RW_RESP  <= "00";

    AXI_AR_READY <= arready_i;
    AXI_DR_VALID <= rvalid_i;
    AXI_DR_DATA  <= rdata_i;
    AXI_DR_RESP  <= "00";

    axi_color_scheme <= slv_reg0(1 downto 0);

    -- AXI WRITE
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

    -- AXI READ
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

    process(i_data, axi_color_scheme)
        variable value : integer;
        variable level : unsigned(3 downto 0);
        variable highlight : std_logic;
    begin
        highlight := i_data(DATA_WIDTH-1);
        value := to_integer(unsigned(i_data(7 downto 0)));
        level := unsigned(i_data(7 downto 4));

        if highlight = '1' then
            case axi_color_scheme is
                when "00" =>
                    -- Konvergenzfarbe: Weiß
                    o_red   <= "1111";
                    o_green <= "1111";
                    o_blue  <= "1111";

                when "01" =>
                    -- Highlightfarbe: Magenta
                    o_red   <= "1111";
                    o_green <= "0000";
                    o_blue  <= "1111";

                when "10" =>
                    -- Highlightfarbe: Cyan
                    o_red   <= "0000";
                    o_green <= "1111";
                    o_blue  <= "1111";

                when others =>
                    -- Highlightfarbe: Gelb
                    o_red   <= "1111";
                    o_green <= "1111";
                    o_blue  <= "0000";
            end case;
        else
            case axi_color_scheme is

                -- 00: Graustufen
                when "00" =>
                        o_red <= std_logic_vector(level);
                        o_green <= std_logic_vector(level);
                        o_blue <= std_logic_vector(level);

                -- 01: Blau -> Gruen -> Gelb -> Rot
                when "01" =>
                    if value = 0 then
                        o_red <= "0000";
                        o_green <= "0000";
                        o_blue  <= "0000";

                    elsif value < 32 then
                        o_red <= "0000";
                        o_green <= std_logic_vector(to_unsigned(value / 2, 4));
                        o_blue <= "1111";

                    elsif value < 64 then
                        o_red <= "0000";
                        o_green <= "1111";
                        o_blue <= std_logic_vector(to_unsigned(15 - ((value - 32) / 2), 4));

                    elsif value < 128 then
                        o_red <= std_logic_vector(to_unsigned((value - 64) / 4, 4));
                        o_green <= "1111";
                        o_blue <= "0000";

                    else
                        o_red <= "1111";

                        if value > 248 then
                            o_green <= "0000";
                        else
                            o_green <= std_logic_vector(to_unsigned(15 - ((value - 128) / 8), 4));
                        end if;

                        o_blue <= "0000";
                    end if;

                -- 10: Schwarz/Weiss
                when "10" =>
                    if value = 0 then
                        o_red <= "0000";
                        o_green <= "0000";
                        o_blue <= "0000";
                    else
                        o_red <= "1111";
                        o_green <= "1111";
                        o_blue <= "1111";
                    end if;

                -- 11: Fire-Style
                when others =>
                    if value = 0 then
                        o_red <= "0000";
                        o_green <= "0000";
                        o_blue <= "0000";

                    elsif value < 64 then
                        o_red <= std_logic_vector(to_unsigned(value / 4, 4));
                        o_green <= "0000";
                        o_blue <= "0000";

                    elsif value < 128 then
                        o_red <= "1111";
                        o_green <= std_logic_vector(to_unsigned((value - 64) / 4, 4));
                        o_blue <= "0000";

                    elsif value < 192 then
                        o_red <= "1111";
                        o_green <= "1111";
                        o_blue <= std_logic_vector(to_unsigned((value - 128) / 4, 4));

                    else
                        o_red <= "1111";
                        o_green <= "1111";
                        o_blue <= "1111";
                    end if;

            end case;
        end if;
    end process;

end Behavioral;