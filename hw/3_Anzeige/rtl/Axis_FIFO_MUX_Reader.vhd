----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2026 12:07:35 PM
-- Design Name: 
-- Module Name: Axis_FIFO_MUX_Reader - Behavioral
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

entity Axis_FIFO_MUX_Reader is
    port (
        i_clk : in std_logic;
        i_resetn : in std_logic;

        i_read_select : in std_logic;

        s0_axis_tdata : in std_logic_vector(31 downto 0);
        s0_axis_tvalid : in std_logic;
        s0_axis_tready : out std_logic;

        s1_axis_tdata  : in std_logic_vector(31 downto 0);
        s1_axis_tvalid : in std_logic;
        s1_axis_tready : out std_logic;

        o_fb_we : out std_logic;
        o_fb_wr_x : out std_logic_vector(9 downto 0);
        o_fb_wr_y : out std_logic_vector(8 downto 0);
        o_fb_wr_data : out std_logic_vector(8 downto 0)
    );
end Axis_FIFO_MUX_Reader;

architecture Behavioral of Axis_FIFO_MUX_Reader is

    signal selected_tdata : std_logic_vector(31 downto 0);
    signal selected_tvalid : std_logic;

begin

    selected_tdata <= s0_axis_tdata when i_read_select = '0' else s1_axis_tdata;
    selected_tvalid <= s0_axis_tvalid when i_read_select = '0' else s1_axis_tvalid;

    s0_axis_tready <= '1' when i_read_select = '0' else '0';
    s1_axis_tready <= '1' when i_read_select = '1' else '0';

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_fb_we <= '0';
                o_fb_wr_x <= (others => '0');
                o_fb_wr_y <= (others => '0');
                o_fb_wr_data <= (others => '0');
            else
                if selected_tvalid = '1' then
                    o_fb_we <= '1';
                    o_fb_wr_x <= selected_tdata(30 downto 21);
                    o_fb_wr_y <= selected_tdata(20 downto 12);
                    o_fb_wr_data <= selected_tdata(11 downto 3);
                else
                    o_fb_we <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;