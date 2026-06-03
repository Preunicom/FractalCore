----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2026 01:16:28 PM
-- Design Name: 
-- Module Name: TOP_farbcodierung - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity TOP_farbcodierung is
    Port (

        i_clk          : in  std_logic;
        i_clk_vga      : in  std_logic;
        i_resetn       : in  std_logic;

        i_arb_tdata    : in  std_logic_vector(31 downto 0);
        i_arb_tvalid   : in  std_logic;
        o_arb_tready   : out std_logic;

        i_color_scheme : in  std_logic_vector(1 downto 0);

        o_red          : out std_logic_vector(3 downto 0);
        o_green        : out std_logic_vector(3 downto 0);
        o_blue         : out std_logic_vector(3 downto 0);

        o_HSync        : out std_logic;
        o_VSync        : out std_logic
    );
end TOP_farbcodierung;

architecture Behavioral of TOP_farbcodierung is

    signal fifo0_s_tdata  : std_logic_vector(31 downto 0);
    signal fifo0_s_tvalid : std_logic;
    signal fifo0_s_tready : std_logic;

    signal fifo1_s_tdata  : std_logic_vector(31 downto 0);
    signal fifo1_s_tvalid : std_logic;
    signal fifo1_s_tready : std_logic;

    signal fifo0_m_tdata  : std_logic_vector(31 downto 0);
    signal fifo0_m_tvalid : std_logic;
    signal fifo0_m_tready : std_logic;

    signal fifo1_m_tdata  : std_logic_vector(31 downto 0);
    signal fifo1_m_tvalid : std_logic;
    signal fifo1_m_tready : std_logic;

    signal fb_we      : std_logic;
    signal fb_wr_x    : std_logic_vector(9 downto 0);
    signal fb_wr_y    : std_logic_vector(8 downto 0);
    signal fb_wr_data : std_logic_vector(7 downto 0);

    signal vga_x       : std_logic_vector(9 downto 0);
    signal vga_y       : std_logic_vector(8 downto 0);
    signal vga_visible : std_logic;

    signal fb_rd_data : std_logic_vector(7 downto 0);

    signal color_red   : std_logic_vector(3 downto 0);
    signal color_green : std_logic_vector(3 downto 0);
    signal color_blue  : std_logic_vector(3 downto 0);

    signal read_select : std_logic := '0';

begin

    dmux_inst : entity work.Axis_Pixel_DMUX
        port map (

            i_clk    => i_clk,
            i_resetn => i_resetn,

            s_axis_tdata  => i_arb_tdata,
            s_axis_tvalid => i_arb_tvalid,
            s_axis_tready => o_arb_tready,

            m0_axis_tdata  => fifo0_s_tdata,
            m0_axis_tvalid => fifo0_s_tvalid,
            m0_axis_tready => fifo0_s_tready,

            m1_axis_tdata  => fifo1_s_tdata,
            m1_axis_tvalid => fifo1_s_tvalid,
            m1_axis_tready => fifo1_s_tready
        );

    fifo0_inst : entity work.axis_data_fifo_0
        port map (

            s_axis_aclk    => i_clk,
            s_axis_aresetn => i_resetn,

            s_axis_tvalid => fifo0_s_tvalid,
            s_axis_tready => fifo0_s_tready,
            s_axis_tdata  => fifo0_s_tdata,

            m_axis_tvalid => fifo0_m_tvalid,
            m_axis_tready => fifo0_m_tready,
            m_axis_tdata  => fifo0_m_tdata
        );

    fifo1_inst : entity work.axis_data_fifo_1
        port map (

            s_axis_aclk    => i_clk,
            s_axis_aresetn => i_resetn,

            s_axis_tvalid => fifo1_s_tvalid,
            s_axis_tready => fifo1_s_tready,
            s_axis_tdata  => fifo1_s_tdata,

            m_axis_tvalid => fifo1_m_tvalid,
            m_axis_tready => fifo1_m_tready,
            m_axis_tdata  => fifo1_m_tdata
        );

    mux_reader_inst : entity work.Axis_FIFO_MUX_Reader
        port map (

            i_clk    => i_clk,
            i_resetn => i_resetn,

            i_read_select => read_select,

            s0_axis_tdata  => fifo0_m_tdata,
            s0_axis_tvalid => fifo0_m_tvalid,
            s0_axis_tready => fifo0_m_tready,

            s1_axis_tdata  => fifo1_m_tdata,
            s1_axis_tvalid => fifo1_m_tvalid,
            s1_axis_tready => fifo1_m_tready,

            o_fb_we      => fb_we,
            o_fb_wr_x    => fb_wr_x,
            o_fb_wr_y    => fb_wr_y,
            o_fb_wr_data => fb_wr_data
        );

    process(i_clk)
    begin
        if rising_edge(i_clk) then

            if i_resetn = '0' then
                read_select <= '0';

            else

                if fifo0_m_tvalid = '0' and fifo1_m_tvalid = '1' then
                    read_select <= '1';

                elsif fifo1_m_tvalid = '0' and fifo0_m_tvalid = '1' then
                    read_select <= '0';

                end if;

            end if;

        end if;
    end process;

    framebuffer_inst : entity work.Framebuffer
        generic map (
            WIDTH      => 640,
            HEIGHT     => 480,
            DATA_WIDTH => 8
        )
        port map (

            i_clk_wr  => i_clk,
            i_we      => fb_we,
            i_wr_x    => fb_wr_x,
            i_wr_y    => fb_wr_y,
            i_wr_data => fb_wr_data,

            i_clk_rd  => i_clk_vga,
            i_rd_x    => vga_x,
            i_rd_y    => vga_y,
            o_rd_data => fb_rd_data
        );

    farbcodierung_inst : entity work.Farbcodierung
        generic map (
            DATA_WIDTH => 8
        )
        port map (

            i_data         => fb_rd_data,
            i_color_scheme => i_color_scheme,

            o_red          => color_red,
            o_green        => color_green,
            o_blue         => color_blue
        );

end Behavioral;
