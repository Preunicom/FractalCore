----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: VGA_Output_MUX
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

entity VGA_Output_MUX is
    port (
        i_video_active : in std_logic;

        i_red   : in std_logic_vector(3 downto 0);
        i_green : in std_logic_vector(3 downto 0);
        i_blue  : in std_logic_vector(3 downto 0);

        i_HSync : in std_logic;
        i_VSync : in std_logic;

        o_red   : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue  : out std_logic_vector(3 downto 0);

        o_HSync : out std_logic;
        o_VSync : out std_logic
    );
end VGA_Output_MUX;

architecture Behavioral of VGA_Output_MUX is
begin

    o_HSync <= i_HSync;
    o_VSync <= i_VSync;

    o_red   <= i_red   when i_video_active = '1' else "0000";
    o_green <= i_green when i_video_active = '1' else "0000";
    o_blue  <= i_blue  when i_video_active = '1' else "0000";

end Behavioral;