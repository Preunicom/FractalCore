----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2026 12:07:35 PM
-- Design Name: 
-- Module Name: Axis_Pixel_DMUX - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Axis_Pixel_DMUX is
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
        
end Axis_Pixel_DMUX;

architecture Behavioral of Axis_Pixel_DMUX is

    signal fifo_select : std_logic;

begin

    fifo_select <= s_axis_tdata(1); -- Choose from Frame Idx

    m0_axis_tdata <= s_axis_tdata;
    m1_axis_tdata <= s_axis_tdata;

    m0_axis_tvalid <= s_axis_tvalid when fifo_select = '0' else '0';

    m1_axis_tvalid <= s_axis_tvalid when fifo_select = '1' else '0';

    s_axis_tready <= m0_axis_tready when fifo_select = '0'
                     else m1_axis_tready;

end Behavioral;
