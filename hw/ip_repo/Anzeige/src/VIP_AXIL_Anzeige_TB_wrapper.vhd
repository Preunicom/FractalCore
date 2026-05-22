--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
--Date        : Thu May 21 04:09:28 2026
--Host        : 88c66c4878fa running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target VIP_AXIL_Anzeige_TB_wrapper.bd
--Design      : VIP_AXIL_Anzeige_TB_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity VIP_AXIL_Anzeige_TB_wrapper is
  port (
    i_axi_clk : in STD_LOGIC;
    i_axi_rst_n : in STD_LOGIC;
    i_clk_0 : in STD_LOGIC;
    i_cycles_until_divergent_0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_highlight_ch0_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch0_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch0_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch0_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch0_valid_0 : in STD_LOGIC;
    i_highlight_ch1_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch1_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch1_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch1_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch1_valid_0 : in STD_LOGIC;
    i_highlight_ch2_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch2_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch2_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch2_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch2_valid_0 : in STD_LOGIC;
    i_highlight_ch3_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch3_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch3_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch3_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch3_valid_0 : in STD_LOGIC;
    i_is_convergent_0 : in STD_LOGIC;
    i_rst_n : in STD_LOGIC;
    i_valid_0 : in STD_LOGIC;
    i_vga_clk_0 : in STD_LOGIC;
    i_vga_rst : in STD_LOGIC;
    i_video_frame_idx_0 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_video_pix_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_video_pix_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    o_ready_0 : out STD_LOGIC;
    o_vga_blank_0 : out STD_LOGIC;
    o_vga_blue_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_vga_green_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_vga_h_sync_0 : out STD_LOGIC;
    o_vga_red_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_vga_v_sync_0 : out STD_LOGIC
  );
end VIP_AXIL_Anzeige_TB_wrapper;

architecture STRUCTURE of VIP_AXIL_Anzeige_TB_wrapper is
  component VIP_AXIL_Anzeige_TB is
  port (
    i_cycles_until_divergent_0 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_is_convergent_0 : in STD_LOGIC;
    i_video_frame_idx_0 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_video_pix_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_video_pix_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_valid_0 : in STD_LOGIC;
    i_highlight_ch0_valid_0 : in STD_LOGIC;
    i_highlight_ch0_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch0_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch0_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch0_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch1_valid_0 : in STD_LOGIC;
    i_highlight_ch1_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch1_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch1_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch1_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch2_valid_0 : in STD_LOGIC;
    i_highlight_ch2_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch2_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch2_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch2_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch3_valid_0 : in STD_LOGIC;
    i_highlight_ch3_current_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch3_current_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    i_highlight_ch3_target_pixel_col_0 : in STD_LOGIC_VECTOR ( 9 downto 0 );
    i_highlight_ch3_target_pixel_row_0 : in STD_LOGIC_VECTOR ( 8 downto 0 );
    o_ready_0 : out STD_LOGIC;
    o_vga_h_sync_0 : out STD_LOGIC;
    o_vga_v_sync_0 : out STD_LOGIC;
    o_vga_blank_0 : out STD_LOGIC;
    o_vga_red_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_vga_green_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_vga_blue_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    i_rst_n : in STD_LOGIC;
    i_clk_0 : in STD_LOGIC;
    i_vga_clk_0 : in STD_LOGIC;
    i_vga_rst : in STD_LOGIC;
    i_axi_clk : in STD_LOGIC;
    i_axi_rst_n : in STD_LOGIC
  );
  end component VIP_AXIL_Anzeige_TB;
begin
VIP_AXIL_Anzeige_TB_i: component VIP_AXIL_Anzeige_TB
     port map (
      i_axi_clk => i_axi_clk,
      i_axi_rst_n => i_axi_rst_n,
      i_clk_0 => i_clk_0,
      i_cycles_until_divergent_0(7 downto 0) => i_cycles_until_divergent_0(7 downto 0),
      i_highlight_ch0_current_pixel_col_0(9 downto 0) => i_highlight_ch0_current_pixel_col_0(9 downto 0),
      i_highlight_ch0_current_pixel_row_0(8 downto 0) => i_highlight_ch0_current_pixel_row_0(8 downto 0),
      i_highlight_ch0_target_pixel_col_0(9 downto 0) => i_highlight_ch0_target_pixel_col_0(9 downto 0),
      i_highlight_ch0_target_pixel_row_0(8 downto 0) => i_highlight_ch0_target_pixel_row_0(8 downto 0),
      i_highlight_ch0_valid_0 => i_highlight_ch0_valid_0,
      i_highlight_ch1_current_pixel_col_0(9 downto 0) => i_highlight_ch1_current_pixel_col_0(9 downto 0),
      i_highlight_ch1_current_pixel_row_0(8 downto 0) => i_highlight_ch1_current_pixel_row_0(8 downto 0),
      i_highlight_ch1_target_pixel_col_0(9 downto 0) => i_highlight_ch1_target_pixel_col_0(9 downto 0),
      i_highlight_ch1_target_pixel_row_0(8 downto 0) => i_highlight_ch1_target_pixel_row_0(8 downto 0),
      i_highlight_ch1_valid_0 => i_highlight_ch1_valid_0,
      i_highlight_ch2_current_pixel_col_0(9 downto 0) => i_highlight_ch2_current_pixel_col_0(9 downto 0),
      i_highlight_ch2_current_pixel_row_0(8 downto 0) => i_highlight_ch2_current_pixel_row_0(8 downto 0),
      i_highlight_ch2_target_pixel_col_0(9 downto 0) => i_highlight_ch2_target_pixel_col_0(9 downto 0),
      i_highlight_ch2_target_pixel_row_0(8 downto 0) => i_highlight_ch2_target_pixel_row_0(8 downto 0),
      i_highlight_ch2_valid_0 => i_highlight_ch2_valid_0,
      i_highlight_ch3_current_pixel_col_0(9 downto 0) => i_highlight_ch3_current_pixel_col_0(9 downto 0),
      i_highlight_ch3_current_pixel_row_0(8 downto 0) => i_highlight_ch3_current_pixel_row_0(8 downto 0),
      i_highlight_ch3_target_pixel_col_0(9 downto 0) => i_highlight_ch3_target_pixel_col_0(9 downto 0),
      i_highlight_ch3_target_pixel_row_0(8 downto 0) => i_highlight_ch3_target_pixel_row_0(8 downto 0),
      i_highlight_ch3_valid_0 => i_highlight_ch3_valid_0,
      i_is_convergent_0 => i_is_convergent_0,
      i_rst_n => i_rst_n,
      i_valid_0 => i_valid_0,
      i_vga_clk_0 => i_vga_clk_0,
      i_vga_rst => i_vga_rst,
      i_video_frame_idx_0(1 downto 0) => i_video_frame_idx_0(1 downto 0),
      i_video_pix_col_0(9 downto 0) => i_video_pix_col_0(9 downto 0),
      i_video_pix_row_0(8 downto 0) => i_video_pix_row_0(8 downto 0),
      o_ready_0 => o_ready_0,
      o_vga_blank_0 => o_vga_blank_0,
      o_vga_blue_0(7 downto 0) => o_vga_blue_0(7 downto 0),
      o_vga_green_0(7 downto 0) => o_vga_green_0(7 downto 0),
      o_vga_h_sync_0 => o_vga_h_sync_0,
      o_vga_red_0(7 downto 0) => o_vga_red_0(7 downto 0),
      o_vga_v_sync_0 => o_vga_v_sync_0
    );
end STRUCTURE;
