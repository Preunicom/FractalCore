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
        DATA_WIDTH : integer := 9
    );
    port (
        i_data         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_color_scheme : in std_logic_vector(1 downto 0);

        o_red   : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue  : out std_logic_vector(3 downto 0)
    );
end Farbcodierung;

architecture Behavioral of Farbcodierung is
begin

    process(i_data, i_color_scheme)
        variable value     : integer;
        variable level     : unsigned(3 downto 0);
        variable highlight : std_logic;
    begin
        highlight := i_data(DATA_WIDTH-1);
        value     := to_integer(unsigned(i_data(7 downto 0)));
        level     := unsigned(i_data(7 downto 4));

        if highlight = '1' then
            case i_color_scheme is
                when "00" =>
                    o_red   <= "1111";
                    o_green <= "1111";
                    o_blue  <= "1111";

                when "01" =>
                    o_red   <= "1111";
                    o_green <= "0000";
                    o_blue  <= "1111";

                when "10" =>
                    o_red   <= "0000";
                    o_green <= "1111";
                    o_blue  <= "1111";

                when others =>
                    o_red   <= "1111";
                    o_green <= "1111";
                    o_blue  <= "0000";
            end case;

        else
            case i_color_scheme is
                when "00" =>
                    o_red   <= std_logic_vector(level);
                    o_green <= std_logic_vector(level);
                    o_blue  <= std_logic_vector(level);

                when "01" =>
                    if value = 0 then
                        o_red   <= "0000";
                        o_green <= "0000";
                        o_blue  <= "0000";

                    elsif value < 32 then
                        o_red   <= "0000";
                        o_green <= std_logic_vector(to_unsigned(value / 2, 4));
                        o_blue  <= "1111";

                    elsif value < 64 then
                        o_red   <= "0000";
                        o_green <= "1111";
                        o_blue  <= std_logic_vector(to_unsigned(15 - ((value - 32) / 2), 4));

                    elsif value < 128 then
                        o_red   <= std_logic_vector(to_unsigned((value - 64) / 4, 4));
                        o_green <= "1111";
                        o_blue  <= "0000";

                    else
                        o_red <= "1111";

                        if value > 248 then
                            o_green <= "0000";
                        else
                            o_green <= std_logic_vector(to_unsigned(15 - ((value - 128) / 8), 4));
                        end if;

                        o_blue <= "0000";
                    end if;

                when "10" =>
                    if value = 0 then
                        o_red   <= "0000";
                        o_green <= "0000";
                        o_blue  <= "0000";
                    else
                        o_red   <= "1111";
                        o_green <= "1111";
                        o_blue  <= "1111";
                    end if;

                when others =>
                    if value = 0 then
                        o_red   <= "0000";
                        o_green <= "0000";
                        o_blue  <= "0000";

                    elsif value < 64 then
                        o_red   <= std_logic_vector(to_unsigned(value / 4, 4));
                        o_green <= "0000";
                        o_blue  <= "0000";

                    elsif value < 128 then
                        o_red   <= "1111";
                        o_green <= std_logic_vector(to_unsigned((value - 64) / 4, 4));
                        o_blue  <= "0000";

                    elsif value < 192 then
                        o_red   <= "1111";
                        o_green <= "1111";
                        o_blue  <= std_logic_vector(to_unsigned((value - 128) / 4, 4));

                    else
                        o_red   <= "1111";
                        o_green <= "1111";
                        o_blue  <= "1111";
                    end if;
            end case;
        end if;
    end process;

end Behavioral;