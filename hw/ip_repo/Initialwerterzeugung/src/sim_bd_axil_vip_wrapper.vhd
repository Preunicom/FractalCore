--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
--Date        : Wed May 20 18:14:30 2026
--Host        : bf632314f015 running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target sim_bd_axil_vip_wrapper.bd
--Design      : sim_bd_axil_vip_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity sim_bd_axil_vip_wrapper is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    i_ready_0 : in STD_LOGIC;
    o_c_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_highlight_ch0_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch0_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch0_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch0_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch0_valid_0 : out STD_LOGIC;
    o_highlight_ch1_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch1_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch1_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch1_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch1_valid_0 : out STD_LOGIC;
    o_highlight_ch2_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch2_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch2_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch2_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch2_valid_0 : out STD_LOGIC;
    o_highlight_ch3_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch3_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch3_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch3_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch3_valid_0 : out STD_LOGIC;
    o_valid_0 : out STD_LOGIC;
    o_video_frame_idx_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_video_pix_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_video_pix_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_z0_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_z0_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 )
  );
end sim_bd_axil_vip_wrapper;

architecture STRUCTURE of sim_bd_axil_vip_wrapper is
  component sim_bd_axil_vip is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    i_ready_0 : in STD_LOGIC;
    o_valid_0 : out STD_LOGIC;
    o_video_pix_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_video_pix_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_video_frame_idx_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_z0_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_z0_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_highlight_ch0_valid_0 : out STD_LOGIC;
    o_highlight_ch0_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch0_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch0_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch0_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch1_valid_0 : out STD_LOGIC;
    o_highlight_ch1_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch1_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch1_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch1_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch2_valid_0 : out STD_LOGIC;
    o_highlight_ch2_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch2_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch2_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch2_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch3_valid_0 : out STD_LOGIC;
    o_highlight_ch3_current_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch3_current_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_highlight_ch3_target_pixel_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_highlight_ch3_target_pixel_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 )
  );
  end component sim_bd_axil_vip;
begin
sim_bd_axil_vip_i: component sim_bd_axil_vip
     port map (
      ACLK => ACLK,
      ARESETN => ARESETN,
      i_ready_0 => i_ready_0,
      o_c_img_0(17 downto 0) => o_c_img_0(17 downto 0),
      o_c_real_0(17 downto 0) => o_c_real_0(17 downto 0),
      o_highlight_ch0_current_pixel_col_0(9 downto 0) => o_highlight_ch0_current_pixel_col_0(9 downto 0),
      o_highlight_ch0_current_pixel_row_0(8 downto 0) => o_highlight_ch0_current_pixel_row_0(8 downto 0),
      o_highlight_ch0_target_pixel_col_0(9 downto 0) => o_highlight_ch0_target_pixel_col_0(9 downto 0),
      o_highlight_ch0_target_pixel_row_0(8 downto 0) => o_highlight_ch0_target_pixel_row_0(8 downto 0),
      o_highlight_ch0_valid_0 => o_highlight_ch0_valid_0,
      o_highlight_ch1_current_pixel_col_0(9 downto 0) => o_highlight_ch1_current_pixel_col_0(9 downto 0),
      o_highlight_ch1_current_pixel_row_0(8 downto 0) => o_highlight_ch1_current_pixel_row_0(8 downto 0),
      o_highlight_ch1_target_pixel_col_0(9 downto 0) => o_highlight_ch1_target_pixel_col_0(9 downto 0),
      o_highlight_ch1_target_pixel_row_0(8 downto 0) => o_highlight_ch1_target_pixel_row_0(8 downto 0),
      o_highlight_ch1_valid_0 => o_highlight_ch1_valid_0,
      o_highlight_ch2_current_pixel_col_0(9 downto 0) => o_highlight_ch2_current_pixel_col_0(9 downto 0),
      o_highlight_ch2_current_pixel_row_0(8 downto 0) => o_highlight_ch2_current_pixel_row_0(8 downto 0),
      o_highlight_ch2_target_pixel_col_0(9 downto 0) => o_highlight_ch2_target_pixel_col_0(9 downto 0),
      o_highlight_ch2_target_pixel_row_0(8 downto 0) => o_highlight_ch2_target_pixel_row_0(8 downto 0),
      o_highlight_ch2_valid_0 => o_highlight_ch2_valid_0,
      o_highlight_ch3_current_pixel_col_0(9 downto 0) => o_highlight_ch3_current_pixel_col_0(9 downto 0),
      o_highlight_ch3_current_pixel_row_0(8 downto 0) => o_highlight_ch3_current_pixel_row_0(8 downto 0),
      o_highlight_ch3_target_pixel_col_0(9 downto 0) => o_highlight_ch3_target_pixel_col_0(9 downto 0),
      o_highlight_ch3_target_pixel_row_0(8 downto 0) => o_highlight_ch3_target_pixel_row_0(8 downto 0),
      o_highlight_ch3_valid_0 => o_highlight_ch3_valid_0,
      o_valid_0 => o_valid_0,
      o_video_frame_idx_0(1 downto 0) => o_video_frame_idx_0(1 downto 0),
      o_video_pix_col_0(9 downto 0) => o_video_pix_col_0(9 downto 0),
      o_video_pix_row_0(8 downto 0) => o_video_pix_row_0(8 downto 0),
      o_z0_img_0(17 downto 0) => o_z0_img_0(17 downto 0),
      o_z0_real_0(17 downto 0) => o_z0_real_0(17 downto 0)
    );
end STRUCTURE;
