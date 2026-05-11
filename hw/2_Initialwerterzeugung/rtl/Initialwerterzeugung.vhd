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
		i_clk_init : in std_logic;
		i_resetn_init : in std_logic;
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
        o_highlight : out t_highlight_info;
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
	end component Initialwerterzeugung_AXI;

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

begin

-- Instantiation of Axi Bus Interface S00_AXI
Initialwerterzeugung_AXI_inst : Initialwerterzeugung_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

	-- TODO: CDC (besonders load, da es sonst verschluckt wird!!!)
	
	-- User logic ends

end arch_imp;
