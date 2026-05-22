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
        -- Highlight data to Visualization - INPUT
		-- CH 0
		i_highlight_ch0_valid : in std_logic;
		i_highlight_ch0_current_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch0_current_pixel_row : in std_logic_vector(8 downto 0);
        i_highlight_ch0_target_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch0_target_pixel_row : in std_logic_vector(8 downto 0);
		-- CH 1
		i_highlight_ch1_valid : in std_logic;
		i_highlight_ch1_current_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch1_current_pixel_row : in std_logic_vector(8 downto 0);
        i_highlight_ch1_target_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch1_target_pixel_row : in std_logic_vector(8 downto 0);
		-- CH 2
		i_highlight_ch2_valid : in std_logic;
		i_highlight_ch2_current_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch2_current_pixel_row : in std_logic_vector(8 downto 0);
        i_highlight_ch2_target_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch2_target_pixel_row : in std_logic_vector(8 downto 0);
		-- CH 3
		i_highlight_ch3_valid : in std_logic;
		i_highlight_ch3_current_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch3_current_pixel_row : in std_logic_vector(8 downto 0);
        i_highlight_ch3_target_pixel_col : in std_logic_vector(9 downto 0);
        i_highlight_ch3_target_pixel_row : in std_logic_vector(8 downto 0);
        -- Highlight data to Visualization - OUTPUT
		-- CH 0
		o_highlight_ch0_valid : out std_logic;
		o_highlight_ch0_current_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch0_current_pixel_row : out std_logic_vector(8 downto 0);
        o_highlight_ch0_target_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch0_target_pixel_row : out std_logic_vector(8 downto 0);
		-- CH 1
		o_highlight_ch1_valid : out std_logic;
		o_highlight_ch1_current_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch1_current_pixel_row : out std_logic_vector(8 downto 0);
        o_highlight_ch1_target_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch1_target_pixel_row : out std_logic_vector(8 downto 0);
		-- CH 2
		o_highlight_ch2_valid : out std_logic;
		o_highlight_ch2_current_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch2_current_pixel_row : out std_logic_vector(8 downto 0);
        o_highlight_ch2_target_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch2_target_pixel_row : out std_logic_vector(8 downto 0);
		-- CH 3
		o_highlight_ch3_valid : out std_logic;
		o_highlight_ch3_current_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch3_current_pixel_row : out std_logic_vector(8 downto 0);
        o_highlight_ch3_target_pixel_col : out std_logic_vector(9 downto 0);
        o_highlight_ch3_target_pixel_row : out std_logic_vector(8 downto 0)
    );
end Highlight_CDC_Synchronizer;

architecture Behavioral of Highlight_CDC_Synchronizer is
    signal w_highlight_info_inp : t_highlight_info;
    signal r_highlight_info : t_highlight_info;
    signal w_highlight_info_out : t_highlight_info;
begin

    -- These signals change infrequent and there is a lot of time to stabilize before used due to the stages in the cores and scheduling/arbitration
    CDC_CROSS: process(i_dest_clk)
	begin
        if rising_edge(i_dest_clk) then
            r_highlight_info <= w_highlight_info_inp;
            w_highlight_info_out <= r_highlight_info;
        end if;
    end process;

    w_highlight_info_inp(0).valid 				<= i_highlight_ch0_valid;
	w_highlight_info_inp(0).current_pixel_col 	<= i_highlight_ch0_current_pixel_col;
	w_highlight_info_inp(0).current_pixel_row 	<= i_highlight_ch0_current_pixel_row;
	w_highlight_info_inp(0).target_pixel_col 	<= i_highlight_ch0_target_pixel_col;
	w_highlight_info_inp(0).target_pixel_row 	<= i_highlight_ch0_target_pixel_row;

	w_highlight_info_inp(1).valid 				<= i_highlight_ch1_valid;
	w_highlight_info_inp(1).current_pixel_col 	<= i_highlight_ch1_current_pixel_col;
	w_highlight_info_inp(1).current_pixel_row 	<= i_highlight_ch1_current_pixel_row;
	w_highlight_info_inp(1).target_pixel_col 	<= i_highlight_ch1_target_pixel_col;
	w_highlight_info_inp(1).target_pixel_row 	<= i_highlight_ch1_target_pixel_row;

	w_highlight_info_inp(2).valid 				<= i_highlight_ch2_valid;
	w_highlight_info_inp(2).current_pixel_col 	<= i_highlight_ch2_current_pixel_col;
	w_highlight_info_inp(2).current_pixel_row 	<= i_highlight_ch2_current_pixel_row;
	w_highlight_info_inp(2).target_pixel_col 	<= i_highlight_ch2_target_pixel_col;
	w_highlight_info_inp(2).target_pixel_row 	<= i_highlight_ch2_target_pixel_row;

	w_highlight_info_inp(3).valid 				<= i_highlight_ch3_valid;
	w_highlight_info_inp(3).current_pixel_col 	<= i_highlight_ch3_current_pixel_col;
	w_highlight_info_inp(3).current_pixel_row 	<= i_highlight_ch3_current_pixel_row;
	w_highlight_info_inp(3).target_pixel_col 	<= i_highlight_ch3_target_pixel_col;
	w_highlight_info_inp(3).target_pixel_row 	<= i_highlight_ch3_target_pixel_row;

    o_highlight_ch0_valid             <= w_highlight_info_out(0).valid;
	o_highlight_ch0_current_pixel_col <= w_highlight_info_out(0).current_pixel_col;
	o_highlight_ch0_current_pixel_row <= w_highlight_info_out(0).current_pixel_row;
	o_highlight_ch0_target_pixel_col  <= w_highlight_info_out(0).target_pixel_col;
	o_highlight_ch0_target_pixel_row  <= w_highlight_info_out(0).target_pixel_row;

	o_highlight_ch1_valid             <= w_highlight_info_out(1).valid;
	o_highlight_ch1_current_pixel_col <= w_highlight_info_out(1).current_pixel_col;
	o_highlight_ch1_current_pixel_row <= w_highlight_info_out(1).current_pixel_row;
	o_highlight_ch1_target_pixel_col  <= w_highlight_info_out(1).target_pixel_col;
	o_highlight_ch1_target_pixel_row  <= w_highlight_info_out(1).target_pixel_row;

	o_highlight_ch2_valid             <= w_highlight_info_out(2).valid;
	o_highlight_ch2_current_pixel_col <= w_highlight_info_out(2).current_pixel_col;
	o_highlight_ch2_current_pixel_row <= w_highlight_info_out(2).current_pixel_row;
	o_highlight_ch2_target_pixel_col  <= w_highlight_info_out(2).target_pixel_col;
	o_highlight_ch2_target_pixel_row  <= w_highlight_info_out(2).target_pixel_row;

	o_highlight_ch3_valid             <= w_highlight_info_out(3).valid;
	o_highlight_ch3_current_pixel_col <= w_highlight_info_out(3).current_pixel_col;
	o_highlight_ch3_current_pixel_row <= w_highlight_info_out(3).current_pixel_row;
	o_highlight_ch3_target_pixel_col  <= w_highlight_info_out(3).target_pixel_col;
	o_highlight_ch3_target_pixel_row  <= w_highlight_info_out(3).target_pixel_row;

end Behavioral;