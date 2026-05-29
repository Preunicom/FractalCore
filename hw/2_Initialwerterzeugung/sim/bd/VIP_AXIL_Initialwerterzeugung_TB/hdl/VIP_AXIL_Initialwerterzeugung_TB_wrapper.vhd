--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
--Date        : Fri May 29 16:05:34 2026
--Host        : 401d88d3f06c running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target VIP_AXIL_Initialwerterzeugung_TB_wrapper.bd
--Design      : VIP_AXIL_Initialwerterzeugung_TB_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity VIP_AXIL_Initialwerterzeugung_TB_wrapper is
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
end VIP_AXIL_Initialwerterzeugung_TB_wrapper;

architecture STRUCTURE of VIP_AXIL_Initialwerterzeugung_TB_wrapper is
  component VIP_AXIL_Initialwerterzeugung_TB is
  port (
    i_aclk_0 : in STD_LOGIC;
    i_aresetn_0 : in STD_LOGIC;
    i_ready_0 : in STD_LOGIC;
    o_valid_0 : out STD_LOGIC;
    o_video_pix_col_0 : out STD_LOGIC_VECTOR ( 9 downto 0 );
    o_video_pix_row_0 : out STD_LOGIC_VECTOR ( 8 downto 0 );
    o_video_frame_idx_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_z0_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_z0_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_real_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_c_img_0 : out STD_LOGIC_VECTOR ( 17 downto 0 );
    o_highlight_ch0_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch1_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch2_0 : out STD_LOGIC_VECTOR ( 38 downto 0 );
    o_highlight_ch3_0 : out STD_LOGIC_VECTOR ( 38 downto 0 )
  );
  end component VIP_AXIL_Initialwerterzeugung_TB;
begin
VIP_AXIL_Initialwerterzeugung_TB_i: component VIP_AXIL_Initialwerterzeugung_TB
     port map (
      i_aclk_0 => i_aclk_0,
      i_aresetn_0 => i_aresetn_0,
      i_ready_0 => i_ready_0,
      o_c_img_0(17 downto 0) => o_c_img_0(17 downto 0),
      o_c_real_0(17 downto 0) => o_c_real_0(17 downto 0),
      o_highlight_ch0_0(38 downto 0) => o_highlight_ch0_0(38 downto 0),
      o_highlight_ch1_0(38 downto 0) => o_highlight_ch1_0(38 downto 0),
      o_highlight_ch2_0(38 downto 0) => o_highlight_ch2_0(38 downto 0),
      o_highlight_ch3_0(38 downto 0) => o_highlight_ch3_0(38 downto 0),
      o_valid_0 => o_valid_0,
      o_video_frame_idx_0(1 downto 0) => o_video_frame_idx_0(1 downto 0),
      o_video_pix_col_0(9 downto 0) => o_video_pix_col_0(9 downto 0),
      o_video_pix_row_0(8 downto 0) => o_video_pix_row_0(8 downto 0),
      o_z0_img_0(17 downto 0) => o_z0_img_0(17 downto 0),
      o_z0_real_0(17 downto 0) => o_z0_real_0(17 downto 0)
    );
end STRUCTURE;
