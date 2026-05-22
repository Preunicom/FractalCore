----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/18/2026 13:13:00 PM
-- Design Name: 
-- Module Name: VGA_Control - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Controls the VGA data and creates the vga data stream.
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
use ieee.numeric_std.all;

library work;
use work.Pkg_VGA.all;
use work.Pkg_Utils.all;

entity VGA_Control is
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        -- Input data
        i_valid : in std_logic;
        i_video_pix_col : in std_logic_vector(9 downto 0);
        i_video_pix_row : in std_logic_vector(8 downto 0);
        i_video_frame_idx : in std_logic_vector(1 downto 0);
        i_is_convergent : in std_logic;
        i_cycles_until_divergent : in std_logic_vector(7 downto 0);
        o_ready : out std_logic;
        -- Highlight data
        i_highlight_info : in t_highlight_info;
        -- VGA data
        i_vga_clk : in std_logic;
        i_vga_resetn : in std_logic;
        o_vga_h_sync : out std_logic;
		o_vga_v_sync : out std_logic;
		o_vga_blank : out std_logic;
        o_vga_is_convergent : out std_logic;
        o_vga_cycles_until_divergent : out std_logic_vector(7 downto 0);
        o_vga_is_highlighted : out std_logic;
        o_vga_is_highlighted_target : out std_logic
    );
end VGA_Control;

architecture Behavioral of VGA_Control is
    component Framebuffer_Manager is
        port(
            i_resetn : in std_logic;
            i_clk : in std_logic;
            -- Input data
            i_valid : in std_logic;
            i_video_pix_col : in std_logic_vector(9 downto 0);
            i_video_pix_row : in std_logic_vector(8 downto 0);
            i_video_frame_idx : in std_logic_vector(1 downto 0);
            i_is_convergent : in std_logic;
            i_cycles_until_divergent : in std_logic_vector(7 downto 0);
            o_ready : out std_logic;
            -- Read Framebuffer
            i_vga_clk : in std_logic;
            i_vga_resetn : in std_logic;
            i_buf_read_en : in std_logic;
            i_buf_frame_idx : in std_logic_vector(1 downto 0);
            i_buf_column : in std_logic_vector(c_COLS_BUS_WIDTH - 1 downto 0);
            i_buf_row : in std_logic_vector(c_ROWS_BUS_WIDTH - 1 downto 0);
            o_buf_is_convergent : out std_logic;
            o_buf_cycles_until_divergent : out std_logic_vector(7 downto 0)
        );
    end component;

    signal r_row_count : unsigned(c_ROWS_BUS_WIDTH - 1 downto 0);
    signal r_col_count : unsigned(c_COLS_BUS_WIDTH - 1 downto 0);
    signal r_is_blank : std_logic;
    signal w_active_area : std_logic;
    signal r_frame_idx : unsigned(1 downto 0);

    signal w_hightlighted_col : std_logic;
    signal w_hightlighted_row : std_logic;
    signal w_hightlighted_target_col : std_logic;
    signal w_hightlighted_target_row : std_logic;
begin
    FRAME_BUF_MANAGER: Framebuffer_Manager
    port map (
        i_resetn                     => i_resetn,
        i_clk                        => i_clk,
        i_valid                      => i_valid,
        i_video_pix_col              => i_video_pix_col,
        i_video_pix_row              => i_video_pix_row,
        i_video_frame_idx            => i_video_frame_idx,
        i_is_convergent              => i_is_convergent,
        i_cycles_until_divergent     => i_cycles_until_divergent,
        o_ready                      => o_ready,
        i_vga_clk                    => i_vga_clk,
        i_vga_resetn                 => i_vga_resetn,
        i_buf_read_en                => w_active_area,
        i_buf_frame_idx              => std_logic_vector(r_frame_idx),
        i_buf_column                 => std_logic_vector(r_col_count),
        i_buf_row                    => std_logic_vector(r_row_count),
        o_buf_is_convergent          => o_vga_is_convergent,
        o_buf_cycles_until_divergent => o_vga_cycles_until_divergent
    );

    -- Cannot use blank for read_en as it is delayed by one clock cycle
    w_active_area <= '1' when (r_col_count <= c_COLS - 1 and r_row_count <= c_ROWS - 1) else '0';
    o_vga_blank <= r_is_blank;

    COL_COUNTER: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                r_col_count <= (others => '0');
            else
                if r_col_count = c_COLS_SUM - 1 then
                    r_col_count <= (others => '0');
                else
                    r_col_count <= r_col_count + 1;
                end if;
            end if;
        end if;
    end process;

    ROW_COUNTER: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                r_row_count <= (others => '0');
            else
                if r_col_count = c_COLS_SUM - 1 then 
                    -- Last column --> New row
                    if r_row_count = c_ROWS_SUM - 1 then 
                        -- Was last row of frame
                        r_row_count <= (others => '0');
                    else
                        r_row_count <= r_row_count + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    H_SYNC_GEN: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                o_vga_h_sync <= '1';
            else
                if r_col_count = c_COLS + c_COLS_BACKPORCH - 1 then
                    -- 0 while sync time
                    o_vga_h_sync <= '0';
                elsif r_col_count = c_COLS_SUM - c_COLS_FRONTPORCH - 1 then
                    -- 1 while frontporch, display area and backporch
                    o_vga_h_sync <= '1';
                end if;
            end if;
        end if;
    end process;

    V_SYNC_GEN: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                o_vga_v_sync <= '1';
            else
                if r_row_count = c_ROWS + c_ROWS_BACKPORCH - 1 then
                    -- 0 while sync time
                    o_vga_v_sync <= '0';
                elsif r_row_count = c_ROWS_SUM - c_ROWS_FRONTPORCH - 1 then
                    -- 1 while frontporch, display area and backporch
                    o_vga_v_sync <= '1';
                end if;
            end if;
        end if;
    end process;

    BLANK_GEN: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                r_is_blank <= '1';
            else
                -- Delayed async active area signal to match all other timings and also have the buffer enable async in the same clock cycle then the counters
                r_is_blank <= not w_active_area;
            end if;
        end if;
    end process;

    FRAME_COUNTER: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                r_frame_idx <= (others => '0');
            else
                if r_row_count = c_ROWS_SUM - 1 and r_col_count = c_COLS_SUM - 1 then
                    r_frame_idx <= r_frame_idx + 1; -- Overflow is intended
                end if;
            end if;
        end if;
    end process;

    w_hightlighted_col <= '1' when (r_col_count <= unsigned(i_highlight_info(to_integer(r_frame_idx)).current_pixel_col) + 1 and
                                    r_col_count + 1 >= unsigned(i_highlight_info(to_integer(r_frame_idx)).current_pixel_col))
                            else '0';

    w_hightlighted_row <= '1' when (r_row_count <= unsigned(i_highlight_info(to_integer(r_frame_idx)).current_pixel_row) + 1 and
                                    r_row_count + 1 >= unsigned(i_highlight_info(to_integer(r_frame_idx)).current_pixel_row))
                            else '0';

    w_hightlighted_target_col <= '1' when (r_col_count <= unsigned(i_highlight_info(to_integer(r_frame_idx)).target_pixel_col) + 1 and
                                    r_col_count + 1 >= unsigned(i_highlight_info(to_integer(r_frame_idx)).target_pixel_col))
                            else '0';

    w_hightlighted_target_row <= '1' when (r_row_count <= unsigned(i_highlight_info(to_integer(r_frame_idx)).target_pixel_row) + 1 and
                                    r_row_count + 1 >= unsigned(i_highlight_info(to_integer(r_frame_idx)).target_pixel_row))
                            else '0';

    HIGHLIGHT: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                o_vga_is_highlighted <= '0';
                o_vga_is_highlighted_target <= '0';
            else
                o_vga_is_highlighted <= '0';
                o_vga_is_highlighted_target <= '0';
                if i_highlight_info(to_integer(r_frame_idx)).valid = '1' then
                    if w_hightlighted_col = '1' and w_hightlighted_row = '1' then
                        -- This pixel is in area of the pixel to highlight
                        o_vga_is_highlighted <= '1';
                    end if;
                    if w_hightlighted_target_col = '1' and w_hightlighted_target_row = '1' then
                        -- This pixel is in area of the target to highlight
                        o_vga_is_highlighted_target <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;