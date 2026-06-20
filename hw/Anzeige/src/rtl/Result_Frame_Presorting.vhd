----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/17/2026 15:42:00 PM
-- Design Name: 
-- Module Name: Result_Frame_Presorting - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Presorts the result data in two FIFOs for even and odd frames.
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

entity Result_Frame_Presorting is
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        -- Input
        i_valid : in std_logic;
        i_video_pix_col : in std_logic_vector(9 downto 0);
        i_video_pix_row : in std_logic_vector(8 downto 0);
        i_video_frame_idx : in std_logic_vector(1 downto 0);
        i_is_convergent : in std_logic;
        i_cycles_until_divergent : in std_logic_vector(7 downto 0);
        o_ready : out std_logic;
        -- Output even frame data
        i_f_X0_ready : in std_logic;
        o_f_X0_valid : out std_logic;
        o_f_X0_video_pix_col : out std_logic_vector(9 downto 0);
        o_f_X0_video_pix_row : out std_logic_vector(8 downto 0);
        o_f_X0_video_frame_idx : out std_logic_vector(1 downto 0);
        o_f_X0_is_convergent : out std_logic;
        o_f_X0_cycles_until_divergent : out std_logic_vector(7 downto 0);
        -- Output odd frame data
        i_f_X1_ready : in std_logic;
        o_f_X1_valid : out std_logic;
        o_f_X1_video_pix_col : out std_logic_vector(9 downto 0);
        o_f_X1_video_pix_row : out std_logic_vector(8 downto 0);
        o_f_X1_video_frame_idx : out std_logic_vector(1 downto 0);
        o_f_X1_is_convergent : out std_logic;
        o_f_X1_cycles_until_divergent : out std_logic_vector(7 downto 0)
    );
end Result_Frame_Presorting;

architecture Behavioral of Result_Frame_Presorting is
    component Calc_Result_Frame_Queue is
      Port ( 
        wr_rst_busy : out STD_LOGIC;
        rd_rst_busy : out STD_LOGIC;
        s_aclk : in STD_LOGIC;
        s_aresetn : in STD_LOGIC;
        s_axis_tvalid : in STD_LOGIC;
        s_axis_tready : out STD_LOGIC;
        s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
        m_axis_tvalid : out STD_LOGIC;
        m_axis_tready : in STD_LOGIC;
        m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
      );
    end component;

    signal w_data_in : std_logic_vector(31 downto 0);

    signal w_f_X0_valid : std_logic;
    signal w_f_X0_ready : std_logic;
    signal w_f_X0_data_out : std_logic_vector(31 downto 0);
    signal w_f_X1_valid : std_logic;
    signal w_f_X1_ready : std_logic;
    signal w_f_X1_data_out : std_logic_vector(31 downto 0);
begin

    -- This process maps the data to the FIFO
    -- This does not meet the AXI Stream specifications but does not lead to problems in this case
    SORT: process(i_valid, w_f_X0_ready, w_f_X1_ready, i_video_frame_idx(0))
    begin
        if i_video_frame_idx(0) = '0' then
            -- Even
            w_f_X0_valid <= i_valid;
            w_f_X1_valid <= '0';
            o_ready <= w_f_X0_ready;
        else
            -- Odd
            w_f_X0_valid <= '0';
            w_f_X1_valid <= i_valid;
            o_ready <= w_f_X1_ready;
        end if;
    end process;

    w_data_in <= "00" & i_video_frame_idx & i_video_pix_row & i_video_pix_col & i_is_convergent & i_cycles_until_divergent;

    EVEN_FRAME_DATA: Calc_Result_Frame_Queue
    port map (
        wr_rst_busy   => open,
        rd_rst_busy   => open,
        s_aclk        => i_clk,
        s_aresetn     => i_resetn,
        s_axis_tvalid => w_f_X0_valid,
        s_axis_tready => w_f_X0_ready,
        s_axis_tdata  => w_data_in,
        m_axis_tvalid => o_f_X0_valid,
        m_axis_tready => i_f_X0_ready,
        m_axis_tdata  => w_f_X0_data_out
    );

    o_f_X0_video_frame_idx          <= w_f_X0_data_out(29 downto 28);
    o_f_X0_video_pix_row            <= w_f_X0_data_out(27 downto 19);
    o_f_X0_video_pix_col            <= w_f_X0_data_out(18 downto 9);
    o_f_X0_is_convergent            <= w_f_X0_data_out(8);
    o_f_X0_cycles_until_divergent   <= w_f_X0_data_out(7 downto 0);

    ODD_FRAME_DATA: Calc_Result_Frame_Queue
    port map (
        wr_rst_busy   => open,
        rd_rst_busy   => open,
        s_aclk        => i_clk,
        s_aresetn     => i_resetn,
        s_axis_tvalid => w_f_X1_valid,
        s_axis_tready => w_f_X1_ready,
        s_axis_tdata  => w_data_in,
        m_axis_tvalid => o_f_X1_valid,
        m_axis_tready => i_f_X1_ready,
        m_axis_tdata  => w_f_X1_data_out
    );

    o_f_X1_video_frame_idx          <= w_f_X1_data_out(29 downto 28);
    o_f_X1_video_pix_row            <= w_f_X1_data_out(27 downto 19);
    o_f_X1_video_pix_col            <= w_f_X1_data_out(18 downto 9);
    o_f_X1_is_convergent            <= w_f_X1_data_out(8);
    o_f_X1_cycles_until_divergent   <= w_f_X1_data_out(7 downto 0);
   
end Behavioral;