----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/15/2026 16:00:00 PM
-- Design Name: 
-- Module Name: Framebuffer - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Framebuffer to store the iteration amounts and convergent flags.
--
-- Infere simple dual port BRAM with dual clocks 
-- Source: https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Simple-Dual-Port-Block-RAM-with-Dual-Clocks-VHDL
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity Dual_Port_RAM is
    generic(
        g_DATA_WIDTH : natural;
        g_ADDR_BUS_WIDTH: natural
    );
    port(
        i_clk_w : in std_logic;
        i_en_w : in std_logic;
        i_write_en : in std_logic;
        i_addr_w : in std_logic_vector(g_ADDR_BUS_WIDTH - 1 downto 0);
        i_data_w : in std_logic_vector(g_DATA_WIDTH - 1 downto 0);

        i_clk_r : in std_logic;
        i_en_r : in std_logic;
        i_addr_r : in std_logic_vector(g_ADDR_BUS_WIDTH - 1 downto 0);
        o_data_r : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)
    );
end Dual_Port_RAM;

architecture Behavioral of Dual_Port_RAM is
    constant c_ram_depth : natural := 2 ** g_ADDR_BUS_WIDTH;
    type ram_type is array (c_ram_depth - 1 downto 0) of std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    shared variable RAM : ram_type := (others => (others => '0'));
begin

    process(i_clk_w)
    begin
        if rising_edge(i_clk_w) then
            if i_en_w = '1' then
                if i_write_en = '1' then
                    RAM(conv_integer(i_addr_w)) := i_data_w;
                end if;
            end if;
        end if;
    end process;

    process(i_clk_r)
    begin
        if rising_edge(i_clk_r) then
            if i_en_r = '1' then
                o_data_r <= RAM(conv_integer(i_addr_r));
            end if;
        end if;
    end process;

end Behavioral;