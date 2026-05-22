--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
--Date        : Wed May 20 19:11:23 2026
--Host        : bf632314f015 running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target AXI_Color_RAM_CTRL.bd
--Design      : AXI_Color_RAM_CTRL
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity AXI_Color_RAM_CTRL is
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
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of AXI_Color_RAM_CTRL : entity is "AXI_Color_RAM_CTRL,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=AXI_Color_RAM_CTRL,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_bram_cntlr_cnt=1,synth_mode=Hierarchical}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of AXI_Color_RAM_CTRL : entity is "AXI_Color_RAM_CTRL.hwdef";
end AXI_Color_RAM_CTRL;

architecture STRUCTURE of AXI_Color_RAM_CTRL is
  component AXI_Color_RAM_CTRL_axi_bram_ctrl_0_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    bram_rst_a : out STD_LOGIC;
    bram_clk_a : out STD_LOGIC;
    bram_en_a : out STD_LOGIC;
    bram_we_a : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_a : out STD_LOGIC_VECTOR ( 11 downto 0 );
    bram_wrdata_a : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component AXI_Color_RAM_CTRL_axi_bram_ctrl_0_0;
  component AXI_Color_RAM_CTRL_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 3 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    clkb : in STD_LOGIC;
    rstb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 3 downto 0 );
    addrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 31 downto 0 );
    rsta_busy : out STD_LOGIC;
    rstb_busy : out STD_LOGIC
  );
  end component AXI_Color_RAM_CTRL_blk_mem_gen_0_0;
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_ADDR : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_CLK : STD_LOGIC;
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_DIN : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_DOUT : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_EN : STD_LOGIC;
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_RST : STD_LOGIC;
  signal AXIL_COLOR_RAM_CTRL_BRAM_PORTA_WE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal BRAM_PORTB_0_1_ADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTB_0_1_CLK : STD_LOGIC;
  signal BRAM_PORTB_0_1_DIN : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTB_0_1_DOUT : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTB_0_1_EN : STD_LOGIC;
  signal BRAM_PORTB_0_1_RST : STD_LOGIC;
  signal BRAM_PORTB_0_1_WE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal COLOR_RAM_rsta_busy : STD_LOGIC;
  signal COLOR_RAM_rstb_busy : STD_LOGIC;
  signal S_AXI_0_1_ARADDR : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal S_AXI_0_1_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_ARREADY : STD_LOGIC;
  signal S_AXI_0_1_ARVALID : STD_LOGIC;
  signal S_AXI_0_1_AWADDR : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal S_AXI_0_1_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_AWREADY : STD_LOGIC;
  signal S_AXI_0_1_AWVALID : STD_LOGIC;
  signal S_AXI_0_1_BREADY : STD_LOGIC;
  signal S_AXI_0_1_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_BVALID : STD_LOGIC;
  signal S_AXI_0_1_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXI_0_1_RREADY : STD_LOGIC;
  signal S_AXI_0_1_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_RVALID : STD_LOGIC;
  signal S_AXI_0_1_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXI_0_1_WREADY : STD_LOGIC;
  signal S_AXI_0_1_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_WVALID : STD_LOGIC;
  signal s_axi_aclk_0_1 : STD_LOGIC;
  signal s_axi_aresetn_0_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_clk : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 CLK";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_en : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 EN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_rst : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 RST";
  attribute X_INTERFACE_INFO of S_AXI_0_arready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_arvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_awready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_awvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_bready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_bvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_rready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_rvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_wready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_wvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WVALID";
  attribute X_INTERFACE_INFO of s_axi_aclk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.S_AXI_ACLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of s_axi_aclk_0 : signal is "XIL_INTERFACENAME CLK.S_AXI_ACLK_0, ASSOCIATED_BUSIF S_AXI_0, ASSOCIATED_RESET s_axi_aresetn_0, CLK_DOMAIN AXI_Color_RAM_CTRL_s_axi_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of s_axi_aresetn_0 : signal is "xilinx.com:signal:reset:1.0 RST.S_AXI_ARESETN_0 RST";
  attribute X_INTERFACE_PARAMETER of s_axi_aresetn_0 : signal is "XIL_INTERFACENAME RST.S_AXI_ARESETN_0, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 ADDR";
  attribute X_INTERFACE_PARAMETER of BRAM_PORTB_0_addr : signal is "XIL_INTERFACENAME BRAM_PORTB_0, MASTER_TYPE BRAM_CTRL, MEM_ECC NONE, MEM_SIZE 8192, MEM_WIDTH 32, READ_LATENCY 1";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 DOUT";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 WE";
  attribute X_INTERFACE_INFO of S_AXI_0_araddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARADDR";
  attribute X_INTERFACE_PARAMETER of S_AXI_0_araddr : signal is "XIL_INTERFACENAME S_AXI_0, ADDR_WIDTH 12, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN AXI_Color_RAM_CTRL_s_axi_aclk_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXI_0_arprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARPROT";
  attribute X_INTERFACE_INFO of S_AXI_0_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWADDR";
  attribute X_INTERFACE_INFO of S_AXI_0_awprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWPROT";
  attribute X_INTERFACE_INFO of S_AXI_0_bresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BRESP";
  attribute X_INTERFACE_INFO of S_AXI_0_rdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RDATA";
  attribute X_INTERFACE_INFO of S_AXI_0_rresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RRESP";
  attribute X_INTERFACE_INFO of S_AXI_0_wdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WDATA";
  attribute X_INTERFACE_INFO of S_AXI_0_wstrb : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WSTRB";
begin
  BRAM_PORTB_0_1_ADDR(31 downto 0) <= BRAM_PORTB_0_addr(31 downto 0);
  BRAM_PORTB_0_1_CLK <= BRAM_PORTB_0_clk;
  BRAM_PORTB_0_1_DIN(31 downto 0) <= BRAM_PORTB_0_din(31 downto 0);
  BRAM_PORTB_0_1_EN <= BRAM_PORTB_0_en;
  BRAM_PORTB_0_1_RST <= BRAM_PORTB_0_rst;
  BRAM_PORTB_0_1_WE(3 downto 0) <= BRAM_PORTB_0_we(3 downto 0);
  BRAM_PORTB_0_dout(31 downto 0) <= BRAM_PORTB_0_1_DOUT(31 downto 0);
  S_AXI_0_1_ARADDR(11 downto 0) <= S_AXI_0_araddr(11 downto 0);
  S_AXI_0_1_ARPROT(2 downto 0) <= S_AXI_0_arprot(2 downto 0);
  S_AXI_0_1_ARVALID <= S_AXI_0_arvalid;
  S_AXI_0_1_AWADDR(11 downto 0) <= S_AXI_0_awaddr(11 downto 0);
  S_AXI_0_1_AWPROT(2 downto 0) <= S_AXI_0_awprot(2 downto 0);
  S_AXI_0_1_AWVALID <= S_AXI_0_awvalid;
  S_AXI_0_1_BREADY <= S_AXI_0_bready;
  S_AXI_0_1_RREADY <= S_AXI_0_rready;
  S_AXI_0_1_WDATA(31 downto 0) <= S_AXI_0_wdata(31 downto 0);
  S_AXI_0_1_WSTRB(3 downto 0) <= S_AXI_0_wstrb(3 downto 0);
  S_AXI_0_1_WVALID <= S_AXI_0_wvalid;
  S_AXI_0_arready <= S_AXI_0_1_ARREADY;
  S_AXI_0_awready <= S_AXI_0_1_AWREADY;
  S_AXI_0_bresp(1 downto 0) <= S_AXI_0_1_BRESP(1 downto 0);
  S_AXI_0_bvalid <= S_AXI_0_1_BVALID;
  S_AXI_0_rdata(31 downto 0) <= S_AXI_0_1_RDATA(31 downto 0);
  S_AXI_0_rresp(1 downto 0) <= S_AXI_0_1_RRESP(1 downto 0);
  S_AXI_0_rvalid <= S_AXI_0_1_RVALID;
  S_AXI_0_wready <= S_AXI_0_1_WREADY;
  rsta_busy_0 <= COLOR_RAM_rsta_busy;
  rstb_busy_0 <= COLOR_RAM_rstb_busy;
  s_axi_aclk_0_1 <= s_axi_aclk_0;
  s_axi_aresetn_0_1 <= s_axi_aresetn_0;
AXIL_COLOR_RAM_CTRL: component AXI_Color_RAM_CTRL_axi_bram_ctrl_0_0
     port map (
      bram_addr_a(11 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_ADDR(11 downto 0),
      bram_clk_a => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_CLK,
      bram_en_a => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_EN,
      bram_rddata_a(31 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_DOUT(31 downto 0),
      bram_rst_a => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_RST,
      bram_we_a(3 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_WE(3 downto 0),
      bram_wrdata_a(31 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_DIN(31 downto 0),
      s_axi_aclk => s_axi_aclk_0_1,
      s_axi_araddr(11 downto 0) => S_AXI_0_1_ARADDR(11 downto 0),
      s_axi_aresetn => s_axi_aresetn_0_1,
      s_axi_arprot(2 downto 0) => S_AXI_0_1_ARPROT(2 downto 0),
      s_axi_arready => S_AXI_0_1_ARREADY,
      s_axi_arvalid => S_AXI_0_1_ARVALID,
      s_axi_awaddr(11 downto 0) => S_AXI_0_1_AWADDR(11 downto 0),
      s_axi_awprot(2 downto 0) => S_AXI_0_1_AWPROT(2 downto 0),
      s_axi_awready => S_AXI_0_1_AWREADY,
      s_axi_awvalid => S_AXI_0_1_AWVALID,
      s_axi_bready => S_AXI_0_1_BREADY,
      s_axi_bresp(1 downto 0) => S_AXI_0_1_BRESP(1 downto 0),
      s_axi_bvalid => S_AXI_0_1_BVALID,
      s_axi_rdata(31 downto 0) => S_AXI_0_1_RDATA(31 downto 0),
      s_axi_rready => S_AXI_0_1_RREADY,
      s_axi_rresp(1 downto 0) => S_AXI_0_1_RRESP(1 downto 0),
      s_axi_rvalid => S_AXI_0_1_RVALID,
      s_axi_wdata(31 downto 0) => S_AXI_0_1_WDATA(31 downto 0),
      s_axi_wready => S_AXI_0_1_WREADY,
      s_axi_wstrb(3 downto 0) => S_AXI_0_1_WSTRB(3 downto 0),
      s_axi_wvalid => S_AXI_0_1_WVALID
    );
COLOR_RAM: component AXI_Color_RAM_CTRL_blk_mem_gen_0_0
     port map (
      addra(31 downto 12) => B"00000000000000000000",
      addra(11 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_ADDR(11 downto 0),
      addrb(31 downto 0) => BRAM_PORTB_0_1_ADDR(31 downto 0),
      clka => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_CLK,
      clkb => BRAM_PORTB_0_1_CLK,
      dina(31 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_DIN(31 downto 0),
      dinb(31 downto 0) => BRAM_PORTB_0_1_DIN(31 downto 0),
      douta(31 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_DOUT(31 downto 0),
      doutb(31 downto 0) => BRAM_PORTB_0_1_DOUT(31 downto 0),
      ena => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_EN,
      enb => BRAM_PORTB_0_1_EN,
      rsta => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_RST,
      rsta_busy => COLOR_RAM_rsta_busy,
      rstb => BRAM_PORTB_0_1_RST,
      rstb_busy => COLOR_RAM_rstb_busy,
      wea(3 downto 0) => AXIL_COLOR_RAM_CTRL_BRAM_PORTA_WE(3 downto 0),
      web(3 downto 0) => BRAM_PORTB_0_1_WE(3 downto 0)
    );
end STRUCTURE;
