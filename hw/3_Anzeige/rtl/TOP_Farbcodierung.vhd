library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_Farbcodierung is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 6
    );
    port (
        i_clk_calc   : in std_logic;
        i_rstn_calc  : in std_logic;
        i_pixel_clk  : in std_logic;
        i_pixel_rstn : in std_logic;

        o_ready : out std_logic;
        i_valid : in std_logic;

        i_video_pix_col          : in std_logic_vector(9 downto 0);
        i_video_pix_row          : in std_logic_vector(8 downto 0);
        i_video_frame_idx        : in std_logic_vector(1 downto 0);
        i_is_convergent          : in std_logic;
        i_cycles_until_divergent : in std_logic_vector(7 downto 0);

        o_vsync : out std_logic;
        o_hsync : out std_logic;
        o_red   : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue  : out std_logic_vector(3 downto 0);

        S_AXI_ACLK    : in std_logic;
        S_AXI_ARESETN : in std_logic;
        S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID  : in std_logic;
        S_AXI_WREADY  : out std_logic;
        S_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S_AXI_BVALID  : out std_logic;
        S_AXI_BREADY  : in std_logic;
        S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in std_logic
    );
end Top_Farbcodierung;

architecture Behavioral of Top_Farbcodierung is

    component FIFO_Presorting_Farbcodierung
        port (
            wr_rst_busy   : out std_logic;
            rd_rst_busy   : out std_logic;
            s_aclk        : in std_logic;
            s_aresetn     : in std_logic;
            s_axis_tvalid : in std_logic;
            s_axis_tready : out std_logic;
            s_axis_tdata  : in std_logic_vector(31 downto 0);
            m_axis_tvalid : out std_logic;
            m_axis_tready : in std_logic;
            m_axis_tdata  : out std_logic_vector(31 downto 0)
        );
    end component;

    constant C_ZERO_X : std_logic_vector(9 downto 0) := (others => '0');
    constant C_ZERO_Y : std_logic_vector(8 downto 0) := (others => '0');

    signal w_color_scheme : std_logic_vector(1 downto 0);
    signal w_input_data_combined : std_logic_vector(31 downto 0);

    signal w_fifo_0_in_valid  : std_logic;
    signal w_fifo_0_in_ready  : std_logic;
    signal w_fifo_0_in_data   : std_logic_vector(31 downto 0);
    signal w_fifo_0_out_valid : std_logic;
    signal w_fifo_0_out_ready : std_logic;
    signal w_fifo_0_out_data  : std_logic_vector(31 downto 0);

    signal w_fifo_1_in_valid  : std_logic;
    signal w_fifo_1_in_ready  : std_logic;
    signal w_fifo_1_in_data   : std_logic_vector(31 downto 0);
    signal w_fifo_1_out_valid : std_logic;
    signal w_fifo_1_out_ready : std_logic;
    signal w_fifo_1_out_data  : std_logic_vector(31 downto 0);

    signal w_write_en_buf_in : std_logic;
    signal w_x_buf_in        : std_logic_vector(9 downto 0);
    signal w_y_buf_in        : std_logic_vector(8 downto 0);
    signal w_data_buf_in     : std_logic_vector(8 downto 0);
    signal w_data_buf_out    : std_logic_vector(8 downto 0);

    signal w_hsync_vga_out  : std_logic;
    signal w_vsync_vga_out  : std_logic;
    signal w_visible_vga_out : std_logic;
    signal w_x_vga_out      : std_logic_vector(9 downto 0);
    signal w_y_vga_out      : std_logic_vector(8 downto 0);

    signal r_delay_h_sync_buf       : std_logic := '1';
    signal r_delay_v_sync_buf       : std_logic := '1';
    signal r_delay_visible_sync_buf : std_logic := '0';

    signal r_read_select_vga      : std_logic := '0';
    signal w_last_vsync_vga_out   : std_logic := '1';
    signal r_read_select_meta     : std_logic := '0';
    signal r_read_select_calc     : std_logic := '0';

    signal w_red_color_cod_out   : std_logic_vector(3 downto 0);
    signal w_green_color_cod_out : std_logic_vector(3 downto 0);
    signal w_blue_color_cod_out  : std_logic_vector(3 downto 0);

begin

    -- Paketformat:
    -- bit 31          : unbenutzt
    -- bit 30          : FIFO-Auswahl aus frame_idx(0)
    -- bits 29 downto 20 : X
    -- bits 19 downto 11 : Y
    -- bits 10 downto 2  : Pixeldaten, 9 Bit
    -- bits 1 downto 0   : unbenutzt
    w_input_data_combined(31) <= '0';
    w_input_data_combined(30) <= i_video_frame_idx(0);
    w_input_data_combined(29 downto 20) <= i_video_pix_col;
    w_input_data_combined(19 downto 11) <= i_video_pix_row;
    w_input_data_combined(10) <= i_is_convergent;
    w_input_data_combined(9 downto 2) <= i_cycles_until_divergent;
    w_input_data_combined(1 downto 0) <= (others => '0');

    AXI_PIX_MUX_i: entity work.Axis_Pixel_DMUX
        port map (
            i_clk          => i_clk_calc,
            i_resetn       => i_rstn_calc,
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
            s_aclk        => i_clk_calc,
            s_aresetn     => i_rstn_calc,
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
            s_aclk        => i_clk_calc,
            s_aresetn     => i_rstn_calc,
            s_axis_tvalid => w_fifo_1_in_valid,
            s_axis_tready => w_fifo_1_in_ready,
            s_axis_tdata  => w_fifo_1_in_data,
            m_axis_tvalid => w_fifo_1_out_valid,
            m_axis_tready => w_fifo_1_out_ready,
            m_axis_tdata  => w_fifo_1_out_data
        );

    AXI_READ_FIFO_i: entity work.Axis_FIFO_MUX_Reader
        port map (
            i_clk          => i_clk_calc,
            i_resetn       => i_rstn_calc,
            i_read_select  => r_read_select_calc,
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

    FRAME_BUF_i: entity work.Framebuffer
        generic map (
            WIDTH      => 640,
            HEIGHT     => 480,
            DATA_WIDTH => 9
        )
        port map (
            i_clk_wr  => i_clk_calc,
            i_we      => w_write_en_buf_in,
            i_wr_x    => w_x_buf_in,
            i_wr_y    => w_y_buf_in,
            i_wr_data => w_data_buf_in,
            i_clk_rd  => i_pixel_clk,
            i_rd_x    => w_x_vga_out,
            i_rd_y    => w_y_vga_out,
            o_rd_data => w_data_buf_out
        );

    VGA_i: entity work.VGA
        port map (
            i_clk          => i_pixel_clk,
            i_resetn       => i_pixel_rstn,
            o_rd_x         => w_x_vga_out,
            o_rd_y         => w_y_vga_out,
            o_visible      => w_visible_vga_out,
            o_HSync        => w_hsync_vga_out,
            o_VSync        => w_vsync_vga_out
        );

    FRAME_SELECT_PROC: process(i_pixel_clk)
    begin
        if rising_edge(i_pixel_clk) then
            if i_pixel_rstn = '0' then
                r_read_select_vga  <= '0';
                w_last_vsync_vga_out <= '1';
            else
                w_last_vsync_vga_out <= w_vsync_vga_out;
                if w_last_vsync_vga_out = '1' and w_vsync_vga_out = '0' then
                    r_read_select_vga <= not r_read_select_vga;
                end if;
            end if;
        end if;
    end process;

    READ_SELECT_SYNC_PROC: process(i_clk_calc)
    begin
        if rising_edge(i_clk_calc) then
            if i_rstn_calc = '0' then
                r_read_select_meta <= '0';
                r_read_select_calc <= '0';
            else
                r_read_select_meta <= r_read_select_vga;
                r_read_select_calc <= r_read_select_meta;
            end if;
        end if;
    end process;

    FRAMEBUF_DELAY_SYNC_SIG: process(i_pixel_clk)
    begin
        if rising_edge(i_pixel_clk) then
            if i_pixel_rstn = '0' then
                r_delay_h_sync_buf       <= '1';
                r_delay_v_sync_buf       <= '1';
                r_delay_visible_sync_buf <= '0';
            else
                r_delay_h_sync_buf       <= w_hsync_vga_out;
                r_delay_v_sync_buf       <= w_vsync_vga_out;
                r_delay_visible_sync_buf <= w_visible_vga_out;
            end if;
        end if;
    end process;

    AXI_LITE_CONF_i: entity work.AXI_Lite_Color_Config
        generic map (
            C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
        )
        port map (
            i_clk_vga      => i_pixel_clk,
            o_color_scheme => w_color_scheme,

            S_AXI_ACLK    => S_AXI_ACLK,
            S_AXI_ARESETN => S_AXI_ARESETN,

            S_AXI_AWADDR  => S_AXI_AWADDR,
            S_AXI_AWPROT  => S_AXI_AWPROT,
            S_AXI_AWVALID => S_AXI_AWVALID,
            S_AXI_AWREADY => S_AXI_AWREADY,

            S_AXI_WDATA  => S_AXI_WDATA,
            S_AXI_WSTRB  => S_AXI_WSTRB,
            S_AXI_WVALID => S_AXI_WVALID,
            S_AXI_WREADY => S_AXI_WREADY,

            S_AXI_BRESP  => S_AXI_BRESP,
            S_AXI_BVALID => S_AXI_BVALID,
            S_AXI_BREADY => S_AXI_BREADY,

            S_AXI_ARADDR  => S_AXI_ARADDR,
            S_AXI_ARPROT  => S_AXI_ARPROT,
            S_AXI_ARVALID => S_AXI_ARVALID,
            S_AXI_ARREADY => S_AXI_ARREADY,

            S_AXI_RDATA  => S_AXI_RDATA,
            S_AXI_RRESP  => S_AXI_RRESP,
            S_AXI_RVALID => S_AXI_RVALID,
            S_AXI_RREADY => S_AXI_RREADY
        );

    FARB_COD_i: entity work.Farbcodierung
        generic map (
            DATA_WIDTH => 9
        )
        port map (
            i_data         => w_data_buf_out,
            i_color_scheme => w_color_scheme,
            o_red          => w_red_color_cod_out,
            o_green        => w_green_color_cod_out,
            o_blue         => w_blue_color_cod_out
        );

    VGA_OUTPUT_MUX_i: entity work.VGA_Output_MUX
        port map (
            i_video_active => r_delay_visible_sync_buf,
            i_red          => w_red_color_cod_out,
            i_green        => w_green_color_cod_out,
            i_blue         => w_blue_color_cod_out,
            i_HSync        => r_delay_h_sync_buf,
            i_VSync        => r_delay_v_sync_buf,
            o_red          => o_red,
            o_green        => o_green,
            o_blue         => o_blue,
            o_HSync        => o_hsync,
            o_VSync        => o_vsync
        );

end Behavioral;