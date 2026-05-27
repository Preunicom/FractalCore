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
        DATA_WIDTH : integer := 8
    );
    port (
        i_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_color_scheme : in std_logic_vector(1 downto 0);

        o_red : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue : out std_logic_vector(3 downto 0)
    );
end Farbcodierung;

architecture Behavioral of Farbcodierung is

begin

    process(i_data, i_color_scheme)
        variable value : integer;
        variable level : unsigned(3 downto 0);
    begin
        value := to_integer(unsigned(i_data));

        if DATA_WIDTH >= 4 then
            level := unsigned(i_data(DATA_WIDTH-1 downto DATA_WIDTH-4));
        else
            level := resize(unsigned(i_data), 4);
        end if;

        case i_color_scheme is

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
    end process;

end Behavioral;