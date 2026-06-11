--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
--Date        : Fri May 29 16:05:33 2026
--Host        : 401d88d3f06c running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target VIP_AXIL_Initialwerterzeugung_TB.bd
--Design      : VIP_AXIL_Initialwerterzeugung_TB
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity VIP_AXIL_Initialwerterzeugung_TB is
  port (
    i_aclk_0 : in STD_LOGIC;
    i_aresetn_0 : in STD_LOGIC;
    i_ready_0 : in STD_LOGIC;
    o_c_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_highlight_ch0_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch1_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch2_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch3_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_valid_0 : out STD_LOGIC;
    o_video_frame_idx_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_video_pix_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_video_pix_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_z0_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_z0_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 )
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of VIP_AXIL_Initialwerterzeugung_TB : entity is "VIP_AXIL_Initialwerterzeugung_TB,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=VIP_AXIL_Initialwerterzeugung_TB,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=None}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of VIP_AXIL_Initialwerterzeugung_TB : entity is "VIP_AXIL_Initialwerterzeugung_TB.hwdef";
end VIP_AXIL_Initialwerterzeugung_TB;

architecture STRUCTURE of VIP_AXIL_Initialwerterzeugung_TB is
  component VIP_AXIL_Initialwerterzeugung_TB_axi_vip_0_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC
  );
  end component VIP_AXIL_Initialwerterzeugung_TB_axi_vip_0_0;
  component VIP_AXIL_Initialwerterzeugung_TB_Initialwerterzeugung_0_0 is
  port (
    i_ready : in STD_LOGIC;
    o_valid : out STD_LOGIC;
    o_video_pix_col : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_video_pix_row : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_video_frame_idx : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_z0_real : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_z0_img : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_real : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_img : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_highlight_ch0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch1 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch2 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch3 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    s00_axi_aclk : in STD_LOGIC;
    s00_axi_aresetn : in STD_LOGIC;
    s00_axi_awaddr : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s00_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_awvalid : in STD_LOGIC;
    s00_axi_awready : out STD_LOGIC;
    s00_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axi_wvalid : in STD_LOGIC;
    s00_axi_wready : out STD_LOGIC;
    s00_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_bvalid : out STD_LOGIC;
    s00_axi_bready : in STD_LOGIC;
    s00_axi_araddr : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s00_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_arvalid : in STD_LOGIC;
    s00_axi_arready : out STD_LOGIC;
    s00_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_rvalid : out STD_LOGIC;
    s00_axi_rready : in STD_LOGIC
  );
  end component VIP_AXIL_Initialwerterzeugung_TB_Initialwerterzeugung_0_0;
  signal Initialwerterzeugung_0_o_c_img : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal Initialwerterzeugung_0_o_c_real : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal Initialwerterzeugung_0_o_highlight_ch0 : STD_LOGIC_VECTOR ( 38 downto 0 );
  signal Initialwerterzeugung_0_o_highlight_ch1 : STD_LOGIC_VECTOR ( 38 downto 0 );
  signal Initialwerterzeugung_0_o_highlight_ch2 : STD_LOGIC_VECTOR ( 38 downto 0 );
  signal Initialwerterzeugung_0_o_highlight_ch3 : STD_LOGIC_VECTOR ( 38 downto 0 );
  signal Initialwerterzeugung_0_o_valid : STD_LOGIC;
  signal Initialwerterzeugung_0_o_video_frame_idx : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Initialwerterzeugung_0_o_video_pix_col : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal Initialwerterzeugung_0_o_video_pix_row : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal Initialwerterzeugung_0_o_z0_img : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal Initialwerterzeugung_0_o_z0_real : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal aclk_0_1 : STD_LOGIC;
  signal aresetn_0_1 : STD_LOGIC;
  signal axi_vip_0_M_AXI_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_vip_0_M_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_vip_0_M_AXI_ARREADY : STD_LOGIC;
  signal axi_vip_0_M_AXI_ARVALID : STD_LOGIC;
  signal axi_vip_0_M_AXI_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_vip_0_M_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_vip_0_M_AXI_AWREADY : STD_LOGIC;
  signal axi_vip_0_M_AXI_AWVALID : STD_LOGIC;
  signal axi_vip_0_M_AXI_BREADY : STD_LOGIC;
  signal axi_vip_0_M_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_vip_0_M_AXI_BVALID : STD_LOGIC;
  signal axi_vip_0_M_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_vip_0_M_AXI_RREADY : STD_LOGIC;
  signal axi_vip_0_M_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_vip_0_M_AXI_RVALID : STD_LOGIC;
  signal axi_vip_0_M_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_vip_0_M_AXI_WREADY : STD_LOGIC;
  signal axi_vip_0_M_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_vip_0_M_AXI_WVALID : STD_LOGIC;
  signal i_ready_0_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of i_aclk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.I_ACLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of i_aclk_0 : signal is "XIL_INTERFACENAME CLK.I_ACLK_0, ASSOCIATED_RESET i_aresetn_0, CLK_DOMAIN VIP_AXIL_Initialwerterzeugung_TB_i_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of i_aresetn_0 : signal is "xilinx.com:signal:reset:1.0 RST.I_ARESETN_0 RST";
  attribute X_INTERFACE_PARAMETER of i_aresetn_0 : signal is "XIL_INTERFACENAME RST.I_ARESETN_0, INSERT_VIP 0, POLARITY ACTIVE_LOW";
begin
  aclk_0_1 <= i_aclk_0;
  aresetn_0_1 <= i_aresetn_0;
  i_ready_0_1 <= i_ready_0;
  o_c_img_0(17 downto 0) <= Initialwerterzeugung_0_o_c_img(17 downto 0);
  o_c_real_0(17 downto 0) <= Initialwerterzeugung_0_o_c_real(17 downto 0);
  o_highlight_ch0_0(38 downto 0) <= Initialwerterzeugung_0_o_highlight_ch0(38 downto 0);
  o_highlight_ch1_0(38 downto 0) <= Initialwerterzeugung_0_o_highlight_ch1(38 downto 0);
  o_highlight_ch2_0(38 downto 0) <= Initialwerterzeugung_0_o_highlight_ch2(38 downto 0);
  o_highlight_ch3_0(38 downto 0) <= Initialwerterzeugung_0_o_highlight_ch3(38 downto 0);
  o_valid_0 <= Initialwerterzeugung_0_o_valid;
  o_video_frame_idx_0(1 downto 0) <= Initialwerterzeugung_0_o_video_frame_idx(1 downto 0);
  o_video_pix_col_0(9 downto 0) <= Initialwerterzeugung_0_o_video_pix_col(9 downto 0);
  o_video_pix_row_0(8 downto 0) <= Initialwerterzeugung_0_o_video_pix_row(8 downto 0);
  o_z0_img_0(17 downto 0) <= Initialwerterzeugung_0_o_z0_img(17 downto 0);
  o_z0_real_0(17 downto 0) <= Initialwerterzeugung_0_o_z0_real(17 downto 0);
Initialwerterzeugung_0: component VIP_AXIL_Initialwerterzeugung_TB_Initialwerterzeugung_0_0
     port map (
      i_ready => i_ready_0_1,
      o_c_img(17 downto 0) => Initialwerterzeugung_0_o_c_img(17 downto 0),
      o_c_real(17 downto 0) => Initialwerterzeugung_0_o_c_real(17 downto 0),
      o_highlight_ch0(38 downto 0) => Initialwerterzeugung_0_o_highlight_ch0(38 downto 0),
      o_highlight_ch1(38 downto 0) => Initialwerterzeugung_0_o_highlight_ch1(38 downto 0),
      o_highlight_ch2(38 downto 0) => Initialwerterzeugung_0_o_highlight_ch2(38 downto 0),
      o_highlight_ch3(38 downto 0) => Initialwerterzeugung_0_o_highlight_ch3(38 downto 0),
      o_valid => Initialwerterzeugung_0_o_valid,
      o_video_frame_idx(1 downto 0) => Initialwerterzeugung_0_o_video_frame_idx(1 downto 0),
      o_video_pix_col(9 downto 0) => Initialwerterzeugung_0_o_video_pix_col(9 downto 0),
      o_video_pix_row(8 downto 0) => Initialwerterzeugung_0_o_video_pix_row(8 downto 0),
      o_z0_img(17 downto 0) => Initialwerterzeugung_0_o_z0_img(17 downto 0),
      o_z0_real(17 downto 0) => Initialwerterzeugung_0_o_z0_real(17 downto 0),
      s00_axi_aclk => aclk_0_1,
      s00_axi_araddr(5 downto 0) => axi_vip_0_M_AXI_ARADDR(5 downto 0),
      s00_axi_aresetn => aresetn_0_1,
      s00_axi_arprot(2 downto 0) => axi_vip_0_M_AXI_ARPROT(2 downto 0),
      s00_axi_arready => axi_vip_0_M_AXI_ARREADY,
      s00_axi_arvalid => axi_vip_0_M_AXI_ARVALID,
      s00_axi_awaddr(5 downto 0) => axi_vip_0_M_AXI_AWADDR(5 downto 0),
      s00_axi_awprot(2 downto 0) => axi_vip_0_M_AXI_AWPROT(2 downto 0),
      s00_axi_awready => axi_vip_0_M_AXI_AWREADY,
      s00_axi_awvalid => axi_vip_0_M_AXI_AWVALID,
      s00_axi_bready => axi_vip_0_M_AXI_BREADY,
      s00_axi_bresp(1 downto 0) => axi_vip_0_M_AXI_BRESP(1 downto 0),
      s00_axi_bvalid => axi_vip_0_M_AXI_BVALID,
      s00_axi_rdata(31 downto 0) => axi_vip_0_M_AXI_RDATA(31 downto 0),
      s00_axi_rready => axi_vip_0_M_AXI_RREADY,
      s00_axi_rresp(1 downto 0) => axi_vip_0_M_AXI_RRESP(1 downto 0),
      s00_axi_rvalid => axi_vip_0_M_AXI_RVALID,
      s00_axi_wdata(31 downto 0) => axi_vip_0_M_AXI_WDATA(31 downto 0),
      s00_axi_wready => axi_vip_0_M_AXI_WREADY,
      s00_axi_wstrb(3 downto 0) => axi_vip_0_M_AXI_WSTRB(3 downto 0),
      s00_axi_wvalid => axi_vip_0_M_AXI_WVALID
    );
axi_vip_0: component VIP_AXIL_Initialwerterzeugung_TB_axi_vip_0_0
     port map (
      aclk => aclk_0_1,
      aresetn => aresetn_0_1,
      m_axi_araddr(31 downto 0) => axi_vip_0_M_AXI_ARADDR(31 downto 0),
      m_axi_arprot(2 downto 0) => axi_vip_0_M_AXI_ARPROT(2 downto 0),
      m_axi_arready => axi_vip_0_M_AXI_ARREADY,
      m_axi_arvalid => axi_vip_0_M_AXI_ARVALID,
      m_axi_awaddr(31 downto 0) => axi_vip_0_M_AXI_AWADDR(31 downto 0),
      m_axi_awprot(2 downto 0) => axi_vip_0_M_AXI_AWPROT(2 downto 0),
      m_axi_awready => axi_vip_0_M_AXI_AWREADY,
      m_axi_awvalid => axi_vip_0_M_AXI_AWVALID,
      m_axi_bready => axi_vip_0_M_AXI_BREADY,
      m_axi_bresp(1 downto 0) => axi_vip_0_M_AXI_BRESP(1 downto 0),
      m_axi_bvalid => axi_vip_0_M_AXI_BVALID,
      m_axi_rdata(31 downto 0) => axi_vip_0_M_AXI_RDATA(31 downto 0),
      m_axi_rready => axi_vip_0_M_AXI_RREADY,
      m_axi_rresp(1 downto 0) => axi_vip_0_M_AXI_RRESP(1 downto 0),
      m_axi_rvalid => axi_vip_0_M_AXI_RVALID,
      m_axi_wdata(31 downto 0) => axi_vip_0_M_AXI_WDATA(31 downto 0),
      m_axi_wready => axi_vip_0_M_AXI_WREADY,
      m_axi_wstrb(3 downto 0) => axi_vip_0_M_AXI_WSTRB(3 downto 0),
      m_axi_wvalid => axi_vip_0_M_AXI_WVALID
    );
end STRUCTURE;
