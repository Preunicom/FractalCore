-- @author: Markus Remy
-- Used AXI Lite Template from Xilinx

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Initialwerterzeugung_AXI is
	generic (
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		o_pixel_distance: out  std_logic_vector(7 downto 0);
		o_frames_per_step : out std_logic_vector(15 downto 0);
		o_mode : out std_logic_vector(1 downto 0);
		o_enable_minimap : out std_logic;
		o_step_width : out std_logic_vector(16 downto 0);
		o_lfsr_seed_re : out std_logic_vector(16 downto 0);
		o_lfsr_seed_im : out std_logic_vector(16 downto 0);
		o_lfsr_xor_mask_re : out std_logic_vector(15 downto 0);
		o_lfsr_xor_mask_im : out std_logic_vector(15 downto 0);
		o_diamond_height : out std_logic_vector(15 downto 0);
		o_diamond_width : out std_logic_vector(15 downto 0);
		o_load_seed : out std_logic;

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end Initialwerterzeugung_AXI;

architecture arch_imp of Initialwerterzeugung_AXI is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;
	------------------------------------------------
	---- Signals for registers
	--------------------------------------------------
	---- Number of Slave Registers 16
	signal GSCR_reg		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal GIER_reg		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal IPIER_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal IPISR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal IDR_reg		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal VERR_reg		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal SETCR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal SPECR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal CSWCR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal XMRCR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal XMICR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal LSRCR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal LSICR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal DWCR_reg		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal DHCR_reg		: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal ZOMCR_reg	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en		: std_logic;

	--Register Addresses
	constant GSCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"0"; -- offset x"00"
	constant GIER_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"1"; -- offset x"04"
	constant IPIER_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"2"; -- offset x"08"
	constant IPISR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"3"; -- offset x"0C"
	constant IDR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"4"; -- offset x"10"
	constant VERR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"5"; -- offset x"14"
	constant SETCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"6"; -- offset x"18"
	constant SPECR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"7"; -- offset x"1C"
	constant CSWCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"8"; -- offset x"20"
	constant XMRCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"9"; -- offset x"24"
	constant XMICR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"a"; -- offset x"28"
	constant LSRCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"b"; -- offset x"2C"
	constant LSICR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"c"; -- offset x"30"
	constant DWCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"d"; -- offset x"34"
	constant DHCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"e"; -- offset x"38"
	constant ZOMCR_ADDR	: std_logic_vector(OPT_MEM_ADDR_BITS downto 0) := x"f"; -- offset x"3C"
	
begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;

	-- Register Overview
	---- GSCR General Status Control Register 0x00
	GSCR_reg(31 downto 0) <= (others => '0'); -- reserved

	---- GIER Global Interrupt Enable Register 0x04
	GIER_reg(31 downto 0) <= (others => '0'); -- reserved

	---- IPIER IP Interrupt Enable Register 0x08
	IPIER_reg(31 downto 0) <= (others => '0'); -- reserved

	---- IPISR IP Interrupt Status Register 0x0C
	IPISR_reg(31 downto 0) <= (others => '0'); -- reserved

	---- IDR ID Register 0x10
	IDR_reg(31 downto 0) <= x"0000FEED"; -- const axi r ip rw

	---- VERR Version Register 0x14
	VERR_reg(31 downto 0) <= x"00000001"; -- const axi r ip rw

	---- SETCR Setup Control Register 0x18
	o_mode <= SETCR_reg(1 downto 0); -- axi rw ip r
	SETCR_reg(7 downto 2) <= (others => '0'); -- reserved
	o_load_seed <= SETCR_reg(8); -- axi rw ip rw
	SETCR_reg(15 downto 9) <= (others => '0'); -- reserved
	o_enable_minimap <= SETCR_reg(16); -- axi rw ip r
	SETCR_reg(31 downto 17) <= (others => '0'); -- reserved

	---- SPECR Speed Control Register 0x1C
	o_frames_per_step <= SPECR_reg(15 downto 0); -- axi rw ip r
	SPECR_reg(31 downto 16) <= (others => '0'); -- reserved

	---- CSWCR C Step Width Control Register 0x20
	o_step_width <= CSWCR_reg(16 downto 0); -- axi rw ip r
	CSWCR_reg(31 downto 17) <= (others => '0'); -- reserved

	---- XMRCR XOR Mask RE Control Register 0x24
	o_lfsr_xor_mask_re <= XMRCR_reg(15 downto 0); -- axi rw ip r
	XMRCR_reg(31 downto 16) <= (others => '0'); -- reserved

	---- XMICR XOR Mask IM Control Register 0x28
	o_lfsr_xor_mask_im <= XMICR_reg(15 downto 0); -- axi rw ip r
	XMICR_reg(31 downto 16) <= (others => '0'); -- reserved

	---- LSRCR LFSR Seed RE Control Register 0x2C
	o_lfsr_seed_re <= LSRCR_reg(16 downto 0); -- axi rw ip r
	LSRCR_reg(31 downto 17) <= (others => '0'); -- reserved

	---- LSICR LFSR Seed IM Control Register 0x30
	o_lfsr_seed_im <= LSICR_reg(16 downto 0); -- axi rw ip r
	LSICR_reg(31 downto 17) <= (others => '0'); -- reserved

	---- DWCR Diamond Width Control Register 0x34
	o_diamond_width <= DWCR_reg(15 downto 0); -- axi rw ip r
	DWCR_reg(31 downto 16) <= (others => '0'); -- reserved

	---- DHCR Diamond Height Control Register 0x38
	o_diamond_height <= DHCR_reg(15 downto 0); -- axi rw ip r
	DHCR_reg(31 downto 16) <= (others => '0'); -- reserved

	---- ZOMCR Zoom Control Register 0x3C
	o_pixel_distance <= ZOMCR_reg(7 downto 0); -- axi rw ip r
	ZOMCR_reg(31 downto 8) <= (others => '0'); -- reserved

	-- Write Register - AXI Only [axi rw ip r]

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
		variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
			SETCR_reg(1 downto 0) <= "00";
			SETCR_reg(16) <= '0';
			SPECR_reg(15 downto 0) <= std_logic_vector(to_unsigned(1, 16)); 
			CSWCR_reg(16 downto 0) <= std_logic_vector(to_unsigned(50, 17)); 
			XMRCR_reg(15 downto 0) <= std_logic_vector(to_unsigned(1, 16)); 
			XMICR_reg(15 downto 0) <= std_logic_vector(to_unsigned(1, 16)); 
			LSRCR_reg(16 downto 0) <= std_logic_vector(to_unsigned(1, 17)); 
			LSICR_reg(16 downto 0) <= std_logic_vector(to_unsigned(1, 17)); 
			DWCR_reg(15 downto 0) <= std_logic_vector(to_unsigned(10000, 16)); 
			DHCR_reg(15 downto 0) <= std_logic_vector(to_unsigned(10000, 16)); 
			ZOMCR_reg(7 downto 0) <= std_logic_vector(to_unsigned(255, 8));
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is
				when SETCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						SETCR_reg(1 downto 0) <= S_AXI_WDATA(1 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						null;
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						SETCR_reg(16) <= S_AXI_WDATA(16);
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when SPECR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						SPECR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						SPECR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						null;
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when CSWCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						CSWCR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						CSWCR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						CSWCR_reg(16) <= S_AXI_WDATA(16);
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when XMRCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						XMRCR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						XMRCR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						null;
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when XMICR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						XMICR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						XMICR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						null;
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when LSRCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						LSRCR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						LSRCR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						LSRCR_reg(16) <= S_AXI_WDATA(16);
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when LSICR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						LSICR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						LSICR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						LSICR_reg(16) <= S_AXI_WDATA(16);
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when DWCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						DWCR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						DWCR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						null;
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when DHCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						DHCR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						DHCR_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						null;
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when ZOMCR_ADDR =>
					if ( S_AXI_WSTRB(0) = '1' ) then --(7 downto 0)
						ZOMCR_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
					end if;
					if ( S_AXI_WSTRB(1) = '1' ) then --(15 downto 8)
						null;
					end if;  
					if ( S_AXI_WSTRB(2) = '1' ) then --(23 downto 16)
						null;
					end if;  
					if ( S_AXI_WSTRB(3) = '1' ) then --(31 downto 24)
						null;
					end if;
				when others => 
					null;
				end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Write Register - IP only [axi r ip rw]
	-- NONE

	-- Write Register - IP and AXI [axi rw ip rw]

	process (S_AXI_ACLK)
		variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
		if rising_edge(S_AXI_ACLK) then
		if S_AXI_ARESETN = '0' then
			SETCR_reg(8) <= '0';
		else
			loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
			if(axi_wready = '1' and loc_addr = SETCR_ADDR  
					and S_AXI_WSTRB(1) = '1' and S_AXI_WDATA(8)='1') then
				SETCR_reg(8) <= '1';               
			else
				SETCR_reg(8) <= '0';
			end if;
		end if;
		end if;  
	end process;

	-- Read Register

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (GSCR_reg, GIER_reg, IPIER_reg, IPISR_reg, IDR_reg, VERR_reg, SETCR_reg, SPECR_reg, CSWCR_reg, XMRCR_reg, XMICR_reg, LSRCR_reg, LSICR_reg, DWCR_reg, DHCR_reg, ZOMCR_reg, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	        when GSCR_ADDR =>
	            reg_data_out <= GSCR_reg;
	        when GIER_ADDR =>
	            reg_data_out <= GIER_reg;
	        when IPIER_ADDR =>
	            reg_data_out <= IPIER_reg;
	        when IPISR_ADDR =>
	            reg_data_out <= IPISR_reg;
	        when IDR_ADDR =>
	            reg_data_out <= IDR_reg;
	        when VERR_ADDR =>
	            reg_data_out <= VERR_reg;
	        when SETCR_ADDR =>
	            reg_data_out <= SETCR_reg;
	        when SPECR_ADDR =>
	            reg_data_out <= SPECR_reg;
	        when CSWCR_ADDR =>
	            reg_data_out <= CSWCR_reg;
	        when XMRCR_ADDR =>
	            reg_data_out <= XMRCR_reg;
	        when XMICR_ADDR =>
	            reg_data_out <= XMICR_reg;
	        when LSRCR_ADDR =>
	            reg_data_out <= LSRCR_reg;
	        when LSICR_ADDR =>
	            reg_data_out <= LSICR_reg;
	        when DWCR_ADDR =>
	            reg_data_out <= DWCR_reg;
	        when DHCR_ADDR =>
	            reg_data_out <= DHCR_reg;
	        when ZOMCR_ADDR =>
	            reg_data_out <= ZOMCR_reg;
	        when others =>
	            reg_data_out <= (others => '0');
	    end case;
	end process; 

end arch_imp;