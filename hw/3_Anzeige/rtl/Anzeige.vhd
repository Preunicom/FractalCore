----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/19/2026 15:19:00 PM
-- Design Name: 
-- Module Name: Anzeige - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Manages the visualization of the FractalCore Project.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Anzeige is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 9
	);
	port (
		-- Users to add ports here
		-- INPUT DATA
		i_resetn                   		: in std_logic;
		i_clk                      		: in std_logic;
		i_valid                    		: in std_logic;
		i_video_pix_col            		: in std_logic_vector(9 downto 0);
		i_video_pix_row            		: in std_logic_vector(8 downto 0);
		i_video_frame_idx          		: in std_logic_vector(1 downto 0);
		i_is_convergent            		: in std_logic;
		i_cycles_until_divergent   		: in std_logic_vector(7 downto 0);
		o_ready                    		: out std_logic;
		-- VGA DATA
		i_vga_clk 					  	: in std_logic;
		i_vga_rst 					  	: in std_logic;
		o_vga_h_sync                	: out std_logic;
		o_vga_v_sync                	: out std_logic;
		o_vga_blank                 	: out std_logic;
		o_vga_red         				: out std_logic_vector(7 downto 0);
		o_vga_green						: out std_logic_vector(7 downto 0);
		o_vga_blue						: out std_logic_vector(7 downto 0);


		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end Anzeige;

architecture arch_imp of Anzeige is
	component AXI_Color_RAM_CTRL_wrapper is
	  port (
		BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 31 downto 0 );
		BRAM_PORTB_0_clk : in STD_LOGIC;
		BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
		BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
		BRAM_PORTB_0_en : in STD_LOGIC;
		BRAM_PORTB_0_rst : in STD_LOGIC;
		BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 3 downto 0 );
		S_AXI_0_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
		S_AXI_0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
		S_AXI_0_arready : out STD_LOGIC;
		S_AXI_0_arvalid : in STD_LOGIC;
		S_AXI_0_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
		S_AXI_0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
		S_AXI_0_awready : out STD_LOGIC;
		S_AXI_0_awvalid : in STD_LOGIC;
		S_AXI_0_bready : in STD_LOGIC;
		S_AXI_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
		S_AXI_0_bvalid : out STD_LOGIC;
		S_AXI_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
		S_AXI_0_rready : in STD_LOGIC;
		S_AXI_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
		S_AXI_0_rvalid : out STD_LOGIC;
		S_AXI_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
		S_AXI_0_wready : out STD_LOGIC;
		S_AXI_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
		S_AXI_0_wvalid : in STD_LOGIC;
		rsta_busy_0 : out STD_LOGIC;
		rstb_busy_0 : out STD_LOGIC;
		s_axi_aclk_0 : in STD_LOGIC;
		s_axi_aresetn_0 : in STD_LOGIC
	  );
	end component;
	component VGA_Control is
		port(
			i_resetn : in std_logic;
			i_clk : in std_logic;
			-- Input data
			i_valid : in std_logic;
			i_video_pix_col : in std_logic_vector(9 downto 0);
			i_video_pix_row : in std_logic_vector(8 downto 0);
			i_video_frame_idx : in std_logic_vector(1 downto 0);
			i_is_convergent : in std_logic;
			i_cycles_until_divergent : in std_logic_vector(7 downto 0);
			o_ready : out std_logic;
			-- VGA data
			i_vga_clk : in std_logic;
			i_vga_reset : in std_logic;
			o_vga_h_sync : out std_logic;
			o_vga_v_sync : out std_logic;
			o_vga_blank : out std_logic;
			o_vga_is_convergent : out std_logic;
			o_vga_cycles_until_divergent : out std_logic_vector(7 downto 0)
		);
	end component;
	signal w_vga_h_sync                 : std_logic;
	signal w_vga_v_sync                 : std_logic;
	signal w_vga_blank                  : std_logic;
	signal r_vga_h_sync                 : std_logic;
	signal r_vga_v_sync                 : std_logic;
	signal r_vga_blank                  : std_logic;
	signal w_vga_is_convergent          : std_logic;
	signal w_vga_cycles_until_divergent : std_logic_vector(7 downto 0);
	signal w_bram_addr : std_logic_vector(7 downto 0);
	signal w_bram_en : std_logic;
	signal w_bram_data_rgb : std_logic_vector(23 downto 0);
begin

	AXI_COLOR_MAP: AXI_Color_RAM_CTRL_wrapper
	port map (
		BRAM_PORTB_0_addr => w_bram_addr,
		BRAM_PORTB_0_clk  => i_vga_clk,
		BRAM_PORTB_0_din  => (others => '0'),
		BRAM_PORTB_0_dout => w_bram_data_rgb,
		BRAM_PORTB_0_en   => w_bram_en,
		BRAM_PORTB_0_rst  => i_vga_rst,
		BRAM_PORTB_0_we   => '0',
		S_AXI_0_araddr    => S00_AXI_araddr,
		S_AXI_0_arprot    => S00_AXI_arprot,
		S_AXI_0_arready   => S00_AXI_arready,
		S_AXI_0_arvalid   => S00_AXI_arvalid,
		S_AXI_0_awaddr    => S00_AXI_awaddr,
		S_AXI_0_awprot    => S00_AXI_awprot,
		S_AXI_0_awready   => S00_AXI_awready,
		S_AXI_0_awvalid   => S00_AXI_awvalid,
		S_AXI_0_bready    => S00_AXI_bready,
		S_AXI_0_bresp     => S00_AXI_bresp,
		S_AXI_0_bvalid    => S00_AXI_bvalid,
		S_AXI_0_rdata     => S00_AXI_rdata,
		S_AXI_0_rready    => S00_AXI_rready,
		S_AXI_0_rresp     => S00_AXI_rresp,
		S_AXI_0_rvalid    => S00_AXI_rvalid,
		S_AXI_0_wdata     => S00_AXI_wdata,
		S_AXI_0_wready    => S00_AXI_wready,
		S_AXI_0_wstrb     => S00_AXI_wstrb,
		S_AXI_0_wvalid    => S00_AXI_wvalid,
		rsta_busy_0       => open,
		rstb_busy_0       => open,
		s_axi_aclk_0      => S00_AXI_ACLK,
		s_axi_aresetn_0   => S00_AXI_ARESETN
	);
	VGA_CTRL: VGA_Control
	port map (
		i_resetn                     => i_resetn,
		i_clk                        => i_clk,
		i_valid                      => i_valid,
		i_video_pix_col              => i_video_pix_col,
		i_video_pix_row              => i_video_pix_row,
		i_video_frame_idx            => i_video_frame_idx,
		i_is_convergent              => i_is_convergent,
		i_cycles_until_divergent     => i_cycles_until_divergent,
		o_ready                      => o_ready,
		i_vga_clk                    => i_vga_clk,
		i_vga_reset                  => i_vga_rst,
		o_vga_h_sync                 => w_vga_h_sync,
		o_vga_v_sync                 => w_vga_v_sync,
		o_vga_blank                  => w_vga_blank,
		o_vga_is_convergent          => w_vga_is_convergent,
		o_vga_cycles_until_divergent => w_vga_cycles_until_divergent
	);

	w_bram_en <= not w_vga_blank;
	w_bram_addr <= w_vga_cycles_until_divergent when w_vga_is_convergent = '0' else x"65"; -- 101 if convergent

	o_vga_red <= w_bram_data_rgb(7 downto 0) when r_vga_blank = '0' else (others => '0');
	o_vga_green <= w_bram_data_rgb(15 downto 8) when r_vga_blank = '0' else (others => '0');
	o_vga_blue  <= w_bram_data_rgb(23 downto 16) when r_vga_blank = '0' else (others => '0');

	DELAY_CTRL_SIG: process(i_vga_clk)
	begin
		if rising_edge(i_vga_clk) then
			if i_vga_rst = '1' then
				r_vga_h_sync <= (others => '0');
				r_vga_v_sync <= (others => '0');
				r_vga_blank <= (others => '0');
			else
				r_vga_h_sync <= w_vga_h_sync;
				r_vga_v_sync <= w_vga_v_sync;
				r_vga_blank <= w_vga_blank;
			end if;
		end if;
	end process;

	o_vga_blank <= r_vga_blank;
	o_vga_h_sync <= r_vga_h_sync;
	o_vga_v_sync <= r_vga_v_sync;

end arch_imp;
