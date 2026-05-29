----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/22/2026 04:29:00 AM
-- Design Name: 
-- Module Name: Diamond - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Creating target points at the end of an diamond shape.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.numeric_std.all;

entity Diamond is
	port (
		i_resetn    : in  std_logic;
		i_clk       : in  std_logic;
		i_en        : in  std_logic;
        i_diamond_heigh : in std_logic_vector(15 downto 0);
        i_diamond_width : in std_logic_vector(15 downto 0);
        o_target_re : out std_logic_vector(16 downto 0);
        o_target_im : out std_logic_vector(16 downto 0)
	);
end entity;

architecture Behavioral of Diamond is
    type state_t is (s_RIGHT, s_TOP, s_LEFT, s_BOTTOM);
    signal r_state, w_next_state : state_t;
begin

    STATE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_state <= s_RIGHT;
            else
                r_state <= w_next_state;
            end if;
        end if;
    end process;

    -- Target points by counter clock wise rotation of 90 degree starting on the right
    TRANSITION: process(r_state, i_diamond_heigh, i_diamond_width, i_en)
	begin
        w_next_state <= r_state;
        case(r_state) is
            when s_RIGHT =>
                o_target_re <= '0' & i_diamond_width;
                o_target_im <= (others => '0');
                if i_en = '1' then
                    w_next_state <= s_TOP;
                end if;
            when s_TOP =>
                o_target_re <= (others => '0');
                o_target_im <= '0' & i_diamond_heigh;
                if i_en = '1' then
                    w_next_state <= s_LEFT;
                end if;
            when s_LEFT =>
                o_target_re <= std_logic_vector(-signed('0' & i_diamond_width));
                o_target_im <= (others => '0');
                if i_en = '1' then
                    w_next_state <= s_BOTTOM;
                end if;
            when s_BOTTOM =>
                o_target_re <= (others => '0');
                o_target_im <= std_logic_vector(-signed('0' & i_diamond_heigh));
                if i_en = '1' then
                    w_next_state <= s_RIGHT;
                end if;
            when others => null;
        end case;
    end process;
    
end architecture;