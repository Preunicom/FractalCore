----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2026 08:31:42 AM
-- Design Name: 
-- Module Name: vga_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity VGA is
    Port (
        o_ready : out std_logic;
        i_valid : in std_logic;
        i_pix_col : in std_logic_vector(9 downto 0);
        i_pix_row : in std_logic_vector(8 downto 0);
        i_frame_idx : in std_logic_vector(1 downto 0);
        i_red : in std_logic_vector(3 downto 0);
        i_green : in std_logic_vector(3 downto 0);
        i_blue : in std_logic_vector(3 downto 0);
        i_CLK_VGA : in std_logic;
        i_CLK_Arbiter : in std_logic;
        i_resetn_vga : in std_logic;
        i_resetn_arbiter : in std_logic;
        o_blue : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_red : out std_logic_vector(3 downto 0);
        o_VSync : out std_logic;
        o_HSync : out std_logic
    );
end VGA;

architecture Behavioral of VGA is

    signal h_count : integer range 0 to 799 := 0;
    signal v_count : integer range 0 to 524 := 0;
    signal visible : std_logic;

begin

    o_ready <= '1';

    visible <= '1' when (h_count < 640 and v_count < 480) else '0';

    o_HSync <= '0' when (h_count >= 656 and h_count < 752) else '1';
    o_VSync <= '0' when (v_count >= 490 and v_count < 492) else '1';

    -- horizontal- / vertikal-Zähler
    process(i_CLK_VGA)
    begin
        if rising_edge(i_CLK_VGA) then
            if i_resetn_vga = '0' then
                h_count <= 0;
                v_count <= 0;
            else
                if h_count = 799 then
                    h_count <= 0;

                    if v_count = 524 then
                        v_count <= 0;
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- Farbausgabe
    process(i_CLK_VGA)
    begin
        if rising_edge(i_CLK_VGA) then
            if i_resetn_vga = '0' then
                o_red   <= (others => '0');
                o_green <= (others => '0');
                o_blue  <= (others => '0');
            else
                if visible = '1' and i_valid = '1' then
                    o_red   <= i_red;
                    o_green <= i_green;
                    o_blue  <= i_blue;
                else
                    o_red   <= (others => '0');
                    o_green <= (others => '0');
                    o_blue  <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end Behavioral;
