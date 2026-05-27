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

entity Framebuffer is
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
end Framebuffer;

architecture Behavioral of Framebuffer is

    constant MEM_SIZE : integer := WIDTH * HEIGHT;

    type mem_t is array (0 to MEM_SIZE - 1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal mem : mem_t := (others => (others => '0'));

    signal rd_addr : integer range 0 to MEM_SIZE - 1 := 0;

begin

    process(i_clk_wr)
        variable wr_x_int : integer;
        variable wr_y_int : integer;
        variable wr_addr : integer;
    begin
        if rising_edge(i_clk_wr) then
            if i_we = '1' then
                wr_x_int := to_integer(unsigned(i_wr_x));
                wr_y_int := to_integer(unsigned(i_wr_y));

                if (wr_x_int < WIDTH) and (wr_y_int < HEIGHT) then
                    wr_addr := wr_y_int * WIDTH + wr_x_int;
                    mem(wr_addr) <= i_wr_data;
                end if;
            end if;
        end if;
    end process;

    process(i_rd_x, i_rd_y)
        variable rd_x_int : integer;
        variable rd_y_int : integer;
    begin
        rd_x_int := to_integer(unsigned(i_rd_x));
        rd_y_int := to_integer(unsigned(i_rd_y));

        if (rd_x_int < WIDTH) and (rd_y_int < HEIGHT) then
            rd_addr <= rd_y_int * WIDTH + rd_x_int;
        else
            rd_addr <= 0;
        end if;
    end process;

    process(i_clk_rd)
    begin
        if rising_edge(i_clk_rd) then
            o_rd_data <= mem(rd_addr);
        end if;
    end process;

end Behavioral;