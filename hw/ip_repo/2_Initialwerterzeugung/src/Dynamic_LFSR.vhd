----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/15/2026 18:30:00 AM
-- Design Name: 
-- Module Name: Dynamic_LFSR - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: LFSR - Configured with a xor mask. Can also be loaded with a seed.
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

-- Creates pseudo random numbers with configurable seed and xor configuration.
entity Dynamic_LFSR is
	generic (
		g_WIDTH : natural range 2 to natural'high
	);
	port (
		i_resetn    : in  std_logic;
		i_clk       : in  std_logic;
		i_en        : in  std_logic;
		i_load_en   : in  std_logic;
		i_load_data : in  std_logic_vector(g_WIDTH - 1 downto 0);
		i_xor_mask  : in  std_logic_vector(g_WIDTH - 2 downto 0);
		o_data      : out std_logic_vector(g_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of Dynamic_LFSR is
	component Dynamic_LFSR_Bit is
		port (
			i_resetn    : in  std_logic;
			i_clk       : in  std_logic;
			i_en        : in  std_logic;
			i_load_en   : in  std_logic;
			i_load_data : in  std_logic;
			i_prev_data : in  std_logic;
			i_use_xor   : in  std_logic;
			i_xor_data  : in  std_logic;
			o_data      : out std_logic
		);
	end component;
	signal w_data : std_logic_vector(g_WIDTH - 1 downto 0) := (others => '1');
begin
	BITS: for idx in g_WIDTH - 1 downto 1 generate
	begin
		BIT: Dynamic_LFSR_Bit
			port map (
				i_resetn    => i_resetn,
				i_clk       => i_clk,
				i_en        => i_en,
				i_load_en   => i_load_en,
				i_load_data => i_load_data(idx),
				i_prev_data => w_data(idx - 1),
				i_use_xor   => i_xor_mask(idx - 1),
				i_xor_data  => w_data(g_WIDTH - 1),
				o_data      => w_data(idx)
			);
	end generate;

	LSB: Dynamic_LFSR_Bit
		port map (
			i_resetn    => i_resetn,
			i_clk       => i_clk,
			i_en        => i_en,
			i_load_en   => i_load_en,
			i_load_data => i_load_data(0),
			i_prev_data => w_data(g_WIDTH - 1),
			i_use_xor   => '0',
			i_xor_data  => '0',
			o_data      => w_data(0)
		);

    o_data <= w_data;

end architecture;