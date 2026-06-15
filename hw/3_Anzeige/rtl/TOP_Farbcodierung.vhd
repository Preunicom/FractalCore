----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: Framebuffer
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
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

entity Top_Farbcodierung is
    generic (
        C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
    );
    port(
        i_pixel_clk : in std_logic;
        i_pixel_rstn : in std_logic;
        o_ready : out std_logic;
        i_valid : in std_logic;
        i_video_pix_col : in std_logic_vector(9 downto 0);
        i_video_pix_row : in std_logic_vector(8 downto 0);
        i_video_frame_idx : in std_logic_vector(1 downto 0);
        i_is_convergent : std_logic;
        i_cycles_until_divergent : std_logic_vector(7 downto 0);
        o_vsync : out std_logic;
        o_hsync : out std_logic;
        o_red : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue : out std_logic_vector(3 downto 0);

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
end Top_Farbcodierung;

architecture Behavioral of Top_Farbcodierung is
    component VGA is
        Port (
            i_CLK_VGA : in std_logic;
            i_resetn_vga : in std_logic;
            o_visible : out std_logic;
            o_x: out std_logic_vector(9 downto 0);
            o_y : out std_logic_vector(8 downto 0);
            o_VSync : out std_logic;
            o_HSync : out std_logic;
            o_frame_counter : out std_logic_vector(1 downto 0)
        );
    end component;
    component Framebuffer is
        generic (
            WIDTH : integer := 640;
            HEIGHT : integer := 480;
            DATA_WIDTH : integer := 9
        );
        port (
            i_clk_wr : in std_logic;
            i_we : in std_logic;
            i_wr_x : in std_logic_vector(9 downto 0);
            i_wr_y : in std_logic_vector(8 downto 0);
            i_wr_data : in std_logic_vector(DATA_WIDTH-1 downto 0);

            i_clk_rd : in std_logic;
            i_rd_x : in std_logic_vector(9 downto 0);
            i_rd_y : in std_logic_vector(8 downto 0);
            o_rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    component Farbcodierung is
        port (
            i_data : in std_logic_vector(8 downto 0);
            i_color_scheme : in std_logic_vector(1 downto 0);

            o_red : out std_logic_vector(3 downto 0);
            o_green : out std_logic_vector(3 downto 0);
            o_blue : out std_logic_vector(3 downto 0)
        );
    end component;
    component AXI_Lite_Color_Config is
        generic (
            C_S_AXI_DATA_WIDTH	: integer	:= 32;
            C_S_AXI_ADDR_WIDTH	: integer	:= 6
        );
        port (
            i_clk_vga : in std_logic;
            o_color_scheme : out std_logic_vector(1 downto 0);
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
    component Axis_FIFO_MUX_Reader is
        port(
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
    end component;
    component Axis_Pixel_DMUX is
        Port ( 
            i_clk : in STD_LOGIC;
            i_resetn : in STD_LOGIC;
            
            s_axis_tdata : in STD_LOGIC_VECTOR (31 downto 0);
            s_axis_tvalid : in STD_LOGIC;
            s_axis_tready : out STD_LOGIC;
            
            m0_axis_tdata : out STD_LOGIC_VECTOR (31 downto 0);
            m0_axis_tvalid : out STD_LOGIC;
            m0_axis_tready : in STD_LOGIC;
            
            m1_axis_tdata : out STD_LOGIC_VECTOR (31 downto 0);
            m1_axis_tvalid : out STD_LOGIC;
            m1_axis_tready : in STD_LOGIC
         );
            
    end component;
    COMPONENT FIFO_Presorting_Farbcodierung
        PORT (
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC;
            s_aclk : IN STD_LOGIC;
            s_aresetn : IN STD_LOGIC;
            s_axis_tvalid : IN STD_LOGIC;
            s_axis_tready : OUT STD_LOGIC;
            s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_tvalid : OUT STD_LOGIC;
            m_axis_tready : IN STD_LOGIC;
            m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
        );
    END COMPONENT;

    signal w_color_scheme : std_logic_vector(1 downto 0);
    signal w_input_data_combined : std_logic_vector(31 downto 0) := (others => '0');

    -- Presorting FIFO Even
    signal w_fifo_0_in_valid : std_logic;
    signal w_fifo_0_in_ready : std_logic;
    signal w_fifo_0_in_data : std_logic_vector(31 downto 0);
    signal w_fifo_0_out_valid : std_logic;
    signal w_fifo_0_out_ready : std_logic;
    signal w_fifo_0_out_data : std_logic_vector(31 downto 0);

    -- Presorting FIFO Odd
    signal w_fifo_1_in_valid : std_logic;
    signal w_fifo_1_in_ready : std_logic;
    signal w_fifo_1_in_data : std_logic_vector(31 downto 0);
    signal w_fifo_1_out_valid : std_logic;
    signal w_fifo_1_out_ready : std_logic;
    signal w_fifo_1_out_data : std_logic_vector(31 downto 0);

    -- FRAME_BUF
    signal w_write_en_buf_in : std_logic;
    signal w_x_buf_in : std_logic_vector(9 downto 0);
    signal w_y_buf_in : std_logic_vector(8 downto 0);
    signal w_data_buf_in : std_logic_vector(8 downto 0);
    signal w_data_buf_out : std_logic_vector(8 downto 0);
    signal r_delay_v_sync_buf : std_logic;
    signal r_delay_h_sync_buf : std_logic;
    signal r_delay_visible_sync_buf : std_logic;

    -- VGA
    signal w_hsync_vga_out : std_logic;
    signal w_vsync_vga_out : std_logic;
    signal w_visible_vga_out : std_logic;
    signal w_x_vga_out : std_logic_vector(9 downto 0);
    signal w_y_vga_out : std_logic_vector(8 downto 0);
    signal w_frame_counter_vga_out : std_logic_vector(1 downto 0);

    -- FARBCODIERUNG
    signal w_red_color_cod_out : std_logic_vector(3 downto 0);
    signal w_green_color_cod_out : std_logic_vector(3 downto 0);
    signal w_blue_color_cod_out : std_logic_vector(3 downto 0);

begin

    w_input_data_combined(30 downto 21) <= i_video_pix_col;
    w_input_data_combined(20 downto 12) <= i_video_pix_row;
    w_input_data_combined(11) <= i_is_convergent;
    w_input_data_combined(10 downto 3) <= i_cycles_until_divergent;
    w_input_data_combined(2 downto 1) <= i_video_frame_idx;

    AXI_PIX_MUX_i: Axis_Pixel_DMUX
    port map (
        i_clk          => S_AXI_ACLK,
        i_resetn       => S_AXI_ARESETN,
        s_axis_tdata   => w_input_data_combined,
        s_axis_tvalid  => i_valid,
        s_axis_tready  => o_ready,
        m0_axis_tdata  => w_fifo_0_in_data,
        m0_axis_tvalid => w_fifo_0_in_valid,
        m0_axis_tready => w_fifo_0_in_ready,
        m1_axis_tdata  => w_fifo_1_in_data,
        m1_axis_tvalid => w_fifo_1_in_valid,
        m1_axis_tready => w_fifo_1_in_ready
    );

    FIFO_PRESORTING_0_i: FIFO_Presorting_Farbcodierung
    port map (
        wr_rst_busy   => open,
        rd_rst_busy   => open,
        s_aclk        => S_AXI_ACLK,
        s_aresetn     => S_AXI_ARESETN,
        s_axis_tvalid => w_fifo_0_in_valid,
        s_axis_tready => w_fifo_0_in_ready,
        s_axis_tdata  => w_fifo_0_in_data,
        m_axis_tvalid => w_fifo_0_out_valid,
        m_axis_tready => w_fifo_0_out_ready,
        m_axis_tdata  => w_fifo_0_out_data
    );

    FIFO_PRESORTING_1_i: FIFO_Presorting_Farbcodierung
    port map (
        wr_rst_busy   => open,
        rd_rst_busy   => open,
        s_aclk        => S_AXI_ACLK,
        s_aresetn     => S_AXI_ARESETN,
        s_axis_tvalid => w_fifo_1_in_valid,
        s_axis_tready => w_fifo_1_in_ready,
        s_axis_tdata  => w_fifo_1_in_data,
        m_axis_tvalid => w_fifo_1_out_valid,
        m_axis_tready => w_fifo_1_out_ready,
        m_axis_tdata  => w_fifo_1_out_data
    );

    AXI_READ_FIFO_i: Axis_FIFO_MUX_Reader
    port map (
        i_clk          => S_AXI_ACLK,
        i_resetn       => S_AXI_ARESETN,
        i_read_select  => w_frame_counter_vga_out(0),
        s0_axis_tdata  => w_fifo_0_out_data,
        s0_axis_tvalid => w_fifo_0_out_valid,
        s0_axis_tready => w_fifo_0_out_ready,
        s1_axis_tdata  => w_fifo_1_out_data,
        s1_axis_tvalid => w_fifo_1_out_valid,
        s1_axis_tready => w_fifo_1_out_ready,
        o_fb_we        => w_write_en_buf_in,
        o_fb_wr_x      => w_x_buf_in,
        o_fb_wr_y      => w_y_buf_in,
        o_fb_wr_data   => w_data_buf_in
    );

    FRAME_BUF_i: Framebuffer
    generic map (
        WIDTH => 640,
        HEIGHT => 480,
        DATA_WIDTH => 9
    )
    port map (
        i_clk_wr  => S_AXI_ACLK,
        i_we      => w_write_en_buf_in,
        i_wr_x    => w_x_buf_in,
        i_wr_y    => w_y_buf_in,
        i_wr_data => w_data_buf_in,
        i_clk_rd  => i_pixel_clk,
        i_rd_x    => w_x_vga_out,
        i_rd_y    => w_y_vga_out,
        o_rd_data => w_data_buf_out
    );

    VGA_i: VGA
    port map (
        i_CLK_VGA    => i_pixel_clk,
        i_resetn_vga => i_pixel_rstn,
        o_visible    => w_visible_vga_out,
        o_x          => w_x_vga_out,
        o_y          => w_y_vga_out,
        o_VSync      => w_vsync_vga_out,
        o_HSync      => w_hsync_vga_out,
        o_frame_counter => w_frame_counter_vga_out
    );

    FRAMEBUF_DELAY_SYNC_SIG: process(i_pixel_clk)
    begin
        if rising_edge(i_pixel_clk) then
            if i_pixel_rstn = '0' then
                r_delay_h_sync_buf <= '1';
                r_delay_v_sync_buf <= '1';
                r_delay_visible_sync_buf <= '0';
            else
                r_delay_h_sync_buf <= w_hsync_vga_out;
                r_delay_v_sync_buf <= w_vsync_vga_out;
                r_delay_visible_sync_buf <= w_visible_vga_out;
            end if;
        end if;
    end process;

    AXI_LITE_CONF_i: AXI_Lite_Color_Config
    generic map (
        C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
    )
    port map (
        i_clk_vga      => i_pixel_clk,
        o_color_scheme => w_color_scheme,
        S_AXI_ACLK     => S_AXI_ACLK,
        S_AXI_ARESETN  => S_AXI_ARESETN,
        S_AXI_AWADDR   => S_AXI_AWADDR,
        S_AXI_AWPROT   => S_AXI_AWPROT,
        S_AXI_AWVALID  => S_AXI_AWVALID,
        S_AXI_AWREADY  => S_AXI_AWREADY,
        S_AXI_WDATA    => S_AXI_WDATA,
        S_AXI_WSTRB    => S_AXI_WSTRB,
        S_AXI_WVALID   => S_AXI_WVALID,
        S_AXI_WREADY   => S_AXI_WREADY,
        S_AXI_BRESP    => S_AXI_BRESP,
        S_AXI_BVALID   => S_AXI_BVALID,
        S_AXI_BREADY   => S_AXI_BREADY,
        S_AXI_ARADDR   => S_AXI_ARADDR,
        S_AXI_ARPROT   => S_AXI_ARPROT,
        S_AXI_ARVALID  => S_AXI_ARVALID,
        S_AXI_ARREADY  => S_AXI_ARREADY,
        S_AXI_RDATA    => S_AXI_RDATA,
        S_AXI_RRESP    => S_AXI_RRESP,
        S_AXI_RVALID   => S_AXI_RVALID,
        S_AXI_RREADY   => S_AXI_RREADY
    );

    FARB_COD_i: Farbcodierung
    port map (
        i_data         => w_data_buf_out,
        i_color_scheme => w_color_scheme,
        o_red          => w_red_color_cod_out,
        o_green        => w_green_color_cod_out,
        o_blue         => w_blue_color_cod_out
    );

    o_red <= w_red_color_cod_out when r_delay_visible_sync_buf = '1' else (others => '0');
    o_green <= w_green_color_cod_out when r_delay_visible_sync_buf = '1' else (others => '0');
    o_blue <= w_blue_color_cod_out when r_delay_visible_sync_buf = '1' else (others => '0');

    o_hsync <= r_delay_h_sync_buf;
    o_vsync <= r_delay_v_sync_buf;

end Behavioral;