----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/25/2026 03:20:00 PM
-- Design Name: 
-- Module Name: Calculation - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Calculation of the Mandelbrot set equation in parallel cores.
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

library work;
use work.Pkg_Core.all;

entity Mengenberechnung is
    generic(
        g_AMOUNT_CORES: natural := 40
    );
    port(
        i_resetn_calc : in std_logic;
        i_clk_calc : in std_logic;
        -- Input AXI Stream like interface
        i_clk_init: in std_logic;
        i_resetn_init: in std_logic;
        i_valid : in std_logic;
        i_video_pix_col : in std_logic_vector(9 downto 0);
        i_video_pix_row : in std_logic_vector(8 downto 0);
        i_video_frame_idx : in std_logic_vector(1 downto 0);
        i_z0_real : in std_logic_vector(17 downto 0);
        i_z0_img : in std_logic_vector(17 downto 0);
        i_c_real : in std_logic_vector(17 downto 0);
        i_c_img : in std_logic_vector(17 downto 0);
        o_ready : out std_logic;
        -- Output AXI Stream like interface
        i_clk_color : in std_logic;
        i_resetn_color : in std_logic;
        i_ready : in std_logic;
        o_valid : out std_logic;
        o_video_pix_col : out std_logic_vector(9 downto 0);
        o_video_pix_row : out std_logic_vector(8 downto 0);
        o_video_frame_idx : out std_logic_vector(1 downto 0);
        o_is_convergent : out std_logic;
        o_cycles_until_divergent : out std_logic_vector(7 downto 0)
    );
end Mengenberechnung;

architecture Behavioral of Mengenberechnung is
    component AXIS_ASyncFIFO_Dispatcher is
        Port ( 
            s_axis_aresetn : in STD_LOGIC;
            s_axis_aclk : in STD_LOGIC;
            s_axis_tvalid : in STD_LOGIC;
            s_axis_tready : out STD_LOGIC;
            s_axis_tdata : in STD_LOGIC_VECTOR(95 downto 0);
            m_axis_aclk : in STD_LOGIC;
            m_axis_tvalid : out STD_LOGIC;
            m_axis_tready : in STD_LOGIC;
            m_axis_tdata : out STD_LOGIC_VECTOR(95 downto 0)
        );
    end component;
    component Dispatcher is
        port(
            i_resetn : in std_logic;
            i_clk : in std_logic;
            -- Input
            i_valid : in std_logic;
            i_pixel_data : in t_pixel_data;
            o_ready : out std_logic;
            -- Output 1
            i_s1_ready : in std_logic;
            o_s1_valid : out std_logic;
            o_s1_pixel_data : out t_pixel_data;
            -- Output 2
            i_s2_ready : in std_logic;
            o_s2_valid : out std_logic;
            o_s2_pixel_data : out t_pixel_data
        );
    end component;
    component Core is
        port(
            i_resetn : in std_logic;
            i_clk : in std_logic;
            -- In
            i_pixel_data : in t_pixel_data;
            i_valid : in std_logic;
            o_ready : out std_logic;
            -- Out
            i_ready : in std_logic;
            o_valid : out std_logic;
            o_pixel_result : out t_pixel_result
        );
    end component;
    component Arbiter is
        port(
            i_resetn : in std_logic;
            i_clk : in std_logic;
            -- Input 1
            i_m1_valid : in std_logic;
            o_m1_ready : out std_logic;
            i_m1_pixel_result : in t_pixel_result;
            -- Input 2
            i_m2_valid : in std_logic;
            o_m2_ready : out std_logic;
            i_m2_pixel_result : in t_pixel_result;
            -- Output
            i_ready : in std_logic;
            o_valid : out std_logic;
            o_pixel_result : out t_pixel_result
        );
    end component;
    component AXIS_ASyncFIFO_Arbiter is
        Port ( 
            s_axis_aresetn : in STD_LOGIC;
            s_axis_aclk : in STD_LOGIC;
            s_axis_tvalid : in STD_LOGIC;
            s_axis_tready : out STD_LOGIC;
            s_axis_tdata : in STD_LOGIC_VECTOR(31 downto 0);
            m_axis_aclk : in STD_LOGIC;
            m_axis_tvalid : out STD_LOGIC;
            m_axis_tready : in STD_LOGIC;
            m_axis_tdata : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- CLK Init
    signal w_init_pixel_data : t_pixel_data;
    signal w_init_fifo_pixel_data_in : std_logic_vector(95 downto 0) := (others => '0');
    
    -- CLK Calc
    signal w_init_fifo_pixel_data_out : std_logic_vector(95 downto 0) := (others => '0');

    -- GENERATE signals
    -- DISP
    signal w_disp_valid : std_logic_vector((g_AMOUNT_CORES * 2) - 2 downto 0);
    signal w_disp_ready : std_logic_vector((g_AMOUNT_CORES * 2) - 2 downto 0);
    type t_disp_data_array is array((g_AMOUNT_CORES * 2) - 2 downto 0) of t_pixel_data;
    signal w_disp_data_array : t_disp_data_array;
    -- ARBIT
    signal w_arbit_valid : std_logic_vector((g_AMOUNT_CORES * 2) - 2 downto 0);
    signal w_arbit_ready : std_logic_vector((g_AMOUNT_CORES * 2) - 2 downto 0);
    type t_arbit_data_array is array((g_AMOUNT_CORES * 2) - 2 downto 0) of t_pixel_result;
    signal w_arbit_data_array : t_arbit_data_array;
    -- GENERATE signal end

    signal w_arbit_fifo_pixel_data_in : std_logic_vector(31 downto 0) := (others => '0');

    -- CLK Arbiter
    signal w_arbit_fifo_pixel_data_out : std_logic_vector(31 downto 0) := (others => '0');
    signal w_arbit_pixel_result : t_pixel_result;

begin

    assert g_AMOUNT_CORES > 2 
        report "g_AMOUNT_CORES has to be at least 2!"
        severity failure;

    w_init_pixel_data.video_frame_idx <= i_video_frame_idx;
    w_init_pixel_data.video_pix_col <= i_video_pix_col;
    w_init_pixel_data.video_pix_row <= i_video_pix_row;
    w_init_pixel_data.z_real <= i_z0_real;
    w_init_pixel_data.z_img <= i_z0_img;
    w_init_pixel_data.c_real <= i_c_real;
    w_init_pixel_data.c_img <= i_c_img;

    w_init_fifo_pixel_data_in(92 downto 0) <= to_std_logic_vector(w_init_pixel_data);

    DISPATCH_FIFO: AXIS_ASyncFIFO_Dispatcher
    port map (
        s_axis_aresetn => i_resetn_init,
        s_axis_aclk    => i_clk_init,
        s_axis_tvalid  => i_valid,
        s_axis_tready  => o_ready,
        s_axis_tdata   => w_init_fifo_pixel_data_in,
        m_axis_aclk    => i_clk_calc,
        m_axis_tvalid  => w_disp_valid(0),
        m_axis_tready  => w_disp_ready(0),
        m_axis_tdata   => w_init_fifo_pixel_data_out
    );

    w_disp_data_array(0) <= to_pixel_data(w_init_fifo_pixel_data_out(92 downto 0));

    gen_DISP: for idx in 0 to g_AMOUNT_CORES - 2 generate
        DISP: Dispatcher
        port map (
            i_resetn        => i_resetn_calc,
            i_clk           => i_clk_calc,
            i_valid         => w_disp_valid(idx),
            i_pixel_data    => w_disp_data_array(idx),
            o_ready         => w_disp_ready(idx),
            i_s1_ready      => w_disp_ready((idx * 2) + 1),
            o_s1_valid      => w_disp_valid((idx * 2) + 1),
            o_s1_pixel_data => w_disp_data_array((idx * 2) + 1),
            i_s2_ready      => w_disp_ready((idx * 2) + 2),
            o_s2_valid      => w_disp_valid((idx * 2) + 2),
            o_s2_pixel_data => w_disp_data_array((idx * 2) + 2)
            
        );
    end generate;

    gen_CORE: for idx in g_AMOUNT_CORES - 1 to 2 * (g_AMOUNT_CORES - 1) generate
        COR: Core
        port map (
            i_resetn                 => i_resetn_calc,
            i_clk                    => i_clk_calc,
            i_pixel_data             => w_disp_data_array(idx),
            i_valid                  => w_disp_valid(idx),
            o_ready                  => w_disp_ready(idx),
            i_ready                  => w_arbit_ready(idx),
            o_valid                  => w_arbit_valid(idx),
            o_pixel_result           => w_arbit_data_array(idx)
        );
    end generate;

    gen_ARBIT: for idx in g_AMOUNT_CORES - 2 downto 0 generate
        ARB: Arbiter
        port map (
            i_resetn            => i_resetn_calc,
            i_clk               => i_clk_calc,
            i_m1_valid          => w_arbit_valid((idx * 2) + 1),
            o_m1_ready          => w_arbit_ready((idx * 2) + 1),
            i_m1_pixel_result   => w_arbit_data_array((idx * 2) + 1),
            i_m2_valid          => w_arbit_valid((idx * 2) + 2),
            o_m2_ready          => w_arbit_ready((idx * 2) + 2),
            i_m2_pixel_result   => w_arbit_data_array((idx * 2) + 2),
            i_ready             => w_arbit_ready(idx),
            o_valid             => w_arbit_valid(idx),
            o_pixel_result      => w_arbit_data_array(idx)
        );
    end generate;

    w_arbit_fifo_pixel_data_in(29 downto 0) <= to_std_logic_vector(w_arbit_data_array(0));

    ARBITE_FIFO: AXIS_ASyncFIFO_Arbiter
    port map (
        s_axis_aresetn => i_resetn_color,
        s_axis_aclk    => i_clk_calc,
        s_axis_tvalid  => w_arbit_valid(0),
        s_axis_tready  => w_arbit_ready(0),
        s_axis_tdata   => w_arbit_fifo_pixel_data_in,
        m_axis_aclk    => i_clk_color,
        m_axis_tvalid  => o_valid,
        m_axis_tready  => i_ready,
        m_axis_tdata   => w_arbit_fifo_pixel_data_out
    );

    w_arbit_pixel_result <= to_pixel_result(w_arbit_fifo_pixel_data_out(29 downto 0));

    o_video_frame_idx <= w_arbit_pixel_result.video_frame_idx;
    o_video_pix_col <= w_arbit_pixel_result.video_pix_col;
    o_video_pix_row <= w_arbit_pixel_result.video_pix_row;
    o_is_convergent <= w_arbit_pixel_result.is_convergent;
    o_cycles_until_divergent <= w_arbit_pixel_result.cycles_until_divergent;

end Behavioral;