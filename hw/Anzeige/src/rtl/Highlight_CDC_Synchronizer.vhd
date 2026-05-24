----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/21/2026 06:10:00 PM
-- Design Name: 
-- Module Name: Highlight_CDC_Synchronizer - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Synchronizes the highlight input data from the input clock domain to the output of the output clock domain with two Flip Flops in the output domain.
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


library work;
use work.Pkg_Utils.all;

entity Highlight_CDC_Synchronizer is
    port(
		i_dest_clk : in std_logic;
		i_highlight : in t_highlight_info;
		o_highlight : out t_highlight_info
    );
end Highlight_CDC_Synchronizer;

architecture Behavioral of Highlight_CDC_Synchronizer is
    signal r_highlight_info : t_highlight_info;
begin

    -- These signals change infrequent and there is a lot of time to stabilize before used due to the stages in the cores and scheduling/arbitration
    CDC_CROSS: process(i_dest_clk)
	begin
        if rising_edge(i_dest_clk) then
            r_highlight_info <= i_highlight;
            o_highlight <= r_highlight_info;
        end if;
    end process;

end Behavioral;