library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pkg_Utils.all;

entity Initialwerterzeugung is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
		-- AXI Stream like interface to Mengenberechnung
        i_ready : in std_logic;
        o_valid : out std_logic;
        o_video_pix_col : out std_logic_vector(9 downto 0);
        o_video_pix_row : out std_logic_vector(8 downto 0);
        o_video_frame_idx : out std_logic_vector(1 downto 0);
        o_z0_real : out std_logic_vector(17 downto 0);
        o_z0_img : out std_logic_vector(17 downto 0);
        o_c_real : out std_logic_vector(17 downto 0);
        o_c_img : out std_logic_vector(17 downto 0);
        -- Highlight data to Visualization
		o_highlight_ch0 : out std_logic_vector(38 downto 0);
		o_highlight_ch1 : out std_logic_vector(38 downto 0);
		o_highlight_ch2 : out std_logic_vector(38 downto 0);
		o_highlight_ch3 : out std_logic_vector(38 downto 0);
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
end Initialwerterzeugung;

architecture arch_imp of Initialwerterzeugung is

	-- component declaration
	component Initialwerterzeugung_AXI is
		generic (
			C_S_AXI_DATA_WIDTH	: integer	:= 32;
			C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (
			o_pixel_distance: out  std_logic_vector(7 downto 0);
			o_frames_per_step : out std_logic_vector(15 downto 0);
			o_mode : out std_logic_vector(1 downto 0);
			o_enable_minimap : out std_logic;
			o_step_width : out std_logic_vector(16 downto 0);
			o_lfsr_seed_re : out std_logic_vector(17 downto 0);
			o_lfsr_seed_im : out std_logic_vector(17 downto 0);
			o_lfsr_xor_mask_re : out std_logic_vector(16 downto 0);
			o_lfsr_xor_mask_im : out std_logic_vector(16 downto 0);
			o_diamond_heigh : out std_logic_vector(16 downto 0);
			o_diamond_width : out std_logic_vector(16 downto 0);
			o_load_seed : out std_logic;
			S_AXI_ACLK	: in std_logic;
			S_AXI_ARESETN	: in std_logic;
			S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
			S_AXI_AWVALID	: in std_logic;
			S_AXI_AWREADY	: out std_logic;
			S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID	: in std_logic;
			S_AXI_WREADY	: out std_logic;
			S_AXI_BRESP	: out std_logic_vector(1 downto 0);
			S_AXI_BVALID	: out std_logic;
			S_AXI_BREADY	: in std_logic;
			S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
			S_AXI_ARVALID	: in std_logic;
			S_AXI_ARREADY	: out std_logic;
			S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP	: out std_logic_vector(1 downto 0);
			S_AXI_RVALID	: out std_logic;
			S_AXI_RREADY	: in std_logic
		);
	end component;

	component Pixel_Data_Generation_Pipeline is
		port (
			i_resetn : in  std_logic;
			i_clk : in  std_logic;
			-- Settings
			i_pixel_distance: in  std_logic_vector(7 downto 0);
			i_frames_per_step : in std_logic_vector(15 downto 0);
			i_mode : in std_logic_vector(1 downto 0);
			i_enable_minimap : in std_logic;
			i_step_width : in std_logic_vector(16 downto 0);
			i_lfsr_seed_re : in std_logic_vector(17 downto 0);
			i_lfsr_seed_im : in std_logic_vector(17 downto 0);
			i_lfsr_xor_mask_re : in std_logic_vector(16 downto 0);
			i_lfsr_xor_mask_im : in std_logic_vector(16 downto 0);
			i_diamond_heigh : in std_logic_vector(16 downto 0);
			i_diamond_width : in std_logic_vector(16 downto 0);
			-- Control
			i_load_seed : in std_logic;
			-- AXI Stream like interface
			i_ready : in std_logic;
			o_valid : out std_logic;
			o_video_pix_col : out std_logic_vector(9 downto 0);
			o_video_pix_row : out std_logic_vector(8 downto 0);
			o_video_frame_idx : out std_logic_vector(1 downto 0);
			o_z0_real : out std_logic_vector(17 downto 0);
			o_z0_img : out std_logic_vector(17 downto 0);
			o_c_real : out std_logic_vector(17 downto 0);
			o_c_img : out std_logic_vector(17 downto 0);
			-- Highlight data
			o_highlight : out t_highlight_info
		);
	end component;

	signal w_highlight : t_highlight_info;

	signal w_pixel_distance   : std_logic_vector(7 downto 0);
	signal w_frames_per_step  : std_logic_vector(15 downto 0);
	signal w_mode             : std_logic_vector(1 downto 0);
	signal w_enable_minimap   : std_logic;
	signal w_step_width       : std_logic_vector(16 downto 0);
	signal w_lfsr_seed_re     : std_logic_vector(17 downto 0);
	signal w_lfsr_seed_im     : std_logic_vector(17 downto 0);
	signal w_lfsr_xor_mask_re : std_logic_vector(16 downto 0);
	signal w_lfsr_xor_mask_im : std_logic_vector(16 downto 0);
	signal w_diamond_heigh    : std_logic_vector(16 downto 0);
	signal w_diamond_width    : std_logic_vector(16 downto 0);
	signal w_load_seed : std_logic;
begin

	-- Instantiation of Axi Bus Interface S00_AXI
	initialwerterzeugung_axi_inst: Initialwerterzeugung_AXI
	generic map (
		C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
	)
	port map (
		o_pixel_distance   => w_pixel_distance,
		o_frames_per_step  => w_frames_per_step,
		o_mode             => w_mode,
		o_enable_minimap   => w_enable_minimap,
		o_step_width       => w_step_width,
		o_lfsr_seed_re     => w_lfsr_seed_re,
		o_lfsr_seed_im     => w_lfsr_seed_im,
		o_lfsr_xor_mask_re => w_lfsr_xor_mask_re,
		o_lfsr_xor_mask_im => w_lfsr_xor_mask_im,
		o_diamond_heigh    => w_diamond_heigh,
		o_diamond_width    => w_diamond_width,
		o_load_seed        => w_load_seed,
		S_AXI_ACLK         => S00_AXI_ACLK,
		S_AXI_ARESETN      => S00_AXI_ARESETN,
		S_AXI_AWADDR       => S00_AXI_AWADDR,
		S_AXI_AWPROT       => S00_AXI_AWPROT,
		S_AXI_AWVALID      => S00_AXI_AWVALID,
		S_AXI_AWREADY      => S00_AXI_AWREADY,
		S_AXI_WDATA        => S00_AXI_WDATA,
		S_AXI_WSTRB        => S00_AXI_WSTRB,
		S_AXI_WVALID       => S00_AXI_WVALID,
		S_AXI_WREADY       => S00_AXI_WREADY,
		S_AXI_BRESP        => S00_AXI_BRESP,
		S_AXI_BVALID       => S00_AXI_BVALID,
		S_AXI_BREADY       => S00_AXI_BREADY,
		S_AXI_ARADDR       => S00_AXI_ARADDR,
		S_AXI_ARPROT       => S00_AXI_ARPROT,
		S_AXI_ARVALID      => S00_AXI_ARVALID,
		S_AXI_ARREADY      => S00_AXI_ARREADY,
		S_AXI_RDATA        => S00_AXI_RDATA,
		S_AXI_RRESP        => S00_AXI_RRESP,
		S_AXI_RVALID       => S00_AXI_RVALID,
		S_AXI_RREADY       => S00_AXI_RREADY
	);	

	-- Add user logic here
	Pixel_Gen: Pixel_Data_Generation_Pipeline
	port map (
		i_resetn           => s00_axi_aresetn,
		i_clk              => s00_axi_aclk,
		i_pixel_distance   => w_pixel_distance,
		i_frames_per_step  => w_frames_per_step,
		i_mode             => w_mode,
		i_enable_minimap   => w_enable_minimap,
		i_step_width       => w_step_width,
		i_lfsr_seed_re     => w_lfsr_seed_re,
		i_lfsr_seed_im     => w_lfsr_seed_im,
		i_lfsr_xor_mask_re => w_lfsr_xor_mask_re,
		i_lfsr_xor_mask_im => w_lfsr_xor_mask_im,
		i_diamond_heigh    => w_diamond_heigh,
		i_diamond_width    => w_diamond_width,
		i_load_seed        => w_load_seed,
		i_ready            => i_ready,
		o_valid            => o_valid,
		o_video_pix_col    => o_video_pix_col,
		o_video_pix_row    => o_video_pix_row,
		o_video_frame_idx  => o_video_frame_idx,
		o_z0_real          => o_z0_real,
		o_z0_img           => o_z0_img,
		o_c_real           => o_c_real,
		o_c_img            => o_c_img,
		o_highlight        => w_highlight
	);

	o_highlight_ch0 <= to_std_logic_vector(w_highlight(0));
	o_highlight_ch1 <= to_std_logic_vector(w_highlight(1));
	o_highlight_ch2 <= to_std_logic_vector(w_highlight(2));
	o_highlight_ch3 <= to_std_logic_vector(w_highlight(3));

	-- User logic ends

end arch_imp;
