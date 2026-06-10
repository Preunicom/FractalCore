----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2026 08:31:42 AM
-- Design Name: 
-- Module Name: vga - Behavioral
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
    port (
        i_clk    : in std_logic;
        i_resetn : in std_logic;

        o_rd_x : out std_logic_vector(9 downto 0);
        o_rd_y : out std_logic_vector(8 downto 0);

        o_visible : out std_logic;
        o_HSync        : out std_logic;
        o_VSync        : out std_logic
    );
end VGA;

architecture Behavioral of VGA is

    constant H_VISIBLE : integer := 640;
    constant H_FRONT   : integer := 16;
    constant H_SYNC    : integer := 96;
    constant H_BACK    : integer := 48;
    constant H_TOTAL   : integer := H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    constant V_VISIBLE : integer := 480;
    constant V_FRONT   : integer := 10;
    constant V_SYNC    : integer := 2;
    constant V_BACK    : integer := 33;
    constant V_TOTAL   : integer := V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    signal h_count : integer range 0 to H_TOTAL - 1 := 0;
    signal v_count : integer range 0 to V_TOTAL - 1 := 0;

    signal video_active_i : std_logic;

begin

    video_active_i <= '1' when h_count < H_VISIBLE and v_count < V_VISIBLE else '0';

    o_visible <= video_active_i;

    o_rd_x <= std_logic_vector(to_unsigned(h_count, 10)) when h_count < H_VISIBLE
              else (others => '0');

    o_rd_y <= std_logic_vector(to_unsigned(v_count, 9)) when v_count < V_VISIBLE
              else (others => '0');

    -- VGA Sync ist normalerweise active-low
    o_HSync <= '0' when h_count >= H_VISIBLE + H_FRONT and
                        h_count <  H_VISIBLE + H_FRONT + H_SYNC
               else '1';

    o_VSync <= '0' when v_count >= V_VISIBLE + V_FRONT and
                        v_count <  V_VISIBLE + V_FRONT + V_SYNC
               else '1';

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                h_count <= 0;
                v_count <= 0;
            else
                if h_count = H_TOTAL - 1 then
                    h_count <= 0;

                    if v_count = V_TOTAL - 1 then
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

end Behavioral;