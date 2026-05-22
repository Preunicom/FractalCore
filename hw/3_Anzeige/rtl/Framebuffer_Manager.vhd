----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/18/2026 11:21:00 PM
-- Design Name: 
-- Module Name: Framebuffer_Manager - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty Z7-20
-- Tool Versions: 2023.2
-- Description: Buffers the input data and presorts it to frames and fills the framebuffer.
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

entity Framebuffer_Manager is
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
end Framebuffer_Manager;

architecture Behavioral of Framebuffer_Manager is
    component Result_Frame_Presorting is
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
    end component;
    -- Using IP instead of infering BRAM as it needs nearly half of BRAMs of the inferred one with same specifications.
    component Framebuffer is
        Port ( 
            clka : in STD_LOGIC;
            ena : in STD_LOGIC;
            wea : in STD_LOGIC_VECTOR ( 0 to 0 );
            addra : in STD_LOGIC_VECTOR ( 18 downto 0 );
            dina : in STD_LOGIC_VECTOR ( 8 downto 0 );
            clkb : in STD_LOGIC;
            enb : in STD_LOGIC;
            addrb : in STD_LOGIC_VECTOR ( 18 downto 0 );
            doutb : out STD_LOGIC_VECTOR ( 8 downto 0 )
        );
    end component;

    type statetype_t is (s_FRAME_TOP_EVEN, s_FRAME_TOP_ODD, s_FRAME_LOWER_ODD, s_FRAME_LOWER_EVEN);
    signal r_state, r_nextstate : statetype_t;

    signal w_f_X0_valid : std_logic;
    signal w_f_X0_ready : std_logic;
    signal w_f_X0_frame_idx : std_logic_vector(1 downto 0);
    signal w_f_X0_row : std_logic_vector(8 downto 0);
    signal w_f_X0_col : std_logic_vector(9 downto 0);
    signal w_f_X0_data : std_logic_vector(8 downto 0);

    signal w_f_X1_valid : std_logic;
    signal w_f_X1_ready : std_logic;
    signal w_f_X1_frame_idx : std_logic_vector(1 downto 0);
    signal w_f_X1_row : std_logic_vector(8 downto 0);
    signal w_f_X1_col : std_logic_vector(9 downto 0);
    signal w_f_X1_data : std_logic_vector(8 downto 0);

    signal w_to_buf_write_en : std_logic_vector(0 downto 0);
    signal w_to_buf_row : std_logic_vector(8 downto 0);
    signal w_to_buf_col : std_logic_vector(9 downto 0);
    signal w_to_buf_data : std_logic_vector(8 downto 0);
    signal w_to_buf_addr : std_logic_vector(18 downto 0);

    signal w_buf_addr_r : std_logic_vector(18 downto 0);
    signal w_buf_out : std_logic_vector(8 downto 0);

    signal r_is_lower_half_of_frame : std_logic;
    signal r_cdc_is_lower_half_of_frame : std_logic;
    signal r_stable_is_lower_half_of_frame : std_logic;

    signal r_frame_idx_grey_code : std_logic_vector(1 downto 0);
    signal r_cdc_frame_idx_grey_code : std_logic_vector(1 downto 0);
    signal r_stable_frame_idx_grey_code : std_logic_vector(1 downto 0);
    signal r_stable_frame_idx : std_logic_vector(1 downto 0);

begin
    PRESORTING: Result_Frame_Presorting
    port map (
        i_resetn                      => i_resetn,
        i_clk                         => i_clk,
        i_valid                       => i_valid,
        i_video_pix_col               => i_video_pix_col,
        i_video_pix_row               => i_video_pix_row,
        i_video_frame_idx             => i_video_frame_idx,
        i_is_convergent               => i_is_convergent,
        i_cycles_until_divergent      => i_cycles_until_divergent,
        o_ready                       => o_ready,
        i_f_X0_ready                  => w_f_X0_ready,
        o_f_X0_valid                  => w_f_X0_valid,
        o_f_X0_video_pix_col          => w_f_X0_col,
        o_f_X0_video_pix_row          => w_f_X0_row,
        o_f_X0_video_frame_idx        => w_f_X0_frame_idx,
        o_f_X0_is_convergent          => w_f_X0_data(8),
        o_f_X0_cycles_until_divergent => w_f_X0_data(7 downto 0),
        i_f_X1_ready                  => w_f_X1_ready,
        o_f_X1_valid                  => w_f_X1_valid,
        o_f_X1_video_pix_col          => w_f_X1_col,
        o_f_X1_video_pix_row          => w_f_X1_row,
        o_f_X1_video_frame_idx        => w_f_X1_frame_idx,
        o_f_X1_is_convergent          => w_f_X1_data(8),
        o_f_X1_cycles_until_divergent => w_f_X1_data(7 downto 0)
    );

    -- FRAME BUFFER WRITE

    STATE_CHART: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_state <= s_FRAME_TOP_EVEN;
            else
                r_state <= r_nextstate;
            end if;
        end if;
    end process;

    NEXT_STATE_LOGIC: process(r_stable_is_lower_half_of_frame, r_stable_frame_idx(0))
    begin
        if r_stable_is_lower_half_of_frame = '0' then
            if r_stable_frame_idx(0) = '0' then
                r_nextstate <= s_FRAME_TOP_EVEN;
            else
                r_nextstate <= s_FRAME_TOP_ODD;
            end if;
        else
            if r_stable_frame_idx(0) = '0' then
                r_nextstate <= s_FRAME_LOWER_EVEN;
            else
                r_nextstate <= s_FRAME_LOWER_ODD;
            end if;
        end if;
    end process;

    -- The AXI Stream liake handshake does not meet the AXI Stream specifications as its ready depends on the given data
    -- This is no problem in this case as it is designed to work with this dependency.
    CONTROL_LOGIC: process(r_state, r_stable_frame_idx, w_f_X0_frame_idx, w_f_X0_valid, w_f_X0_col, w_f_X0_row, w_f_X0_data, w_f_X1_frame_idx, w_f_X1_valid, w_f_X1_col, w_f_X1_row, w_f_X1_data)
    begin
        w_f_X0_ready <= '0';
        w_f_X1_ready <= '0';
        w_to_buf_write_en <= (others => '0');
        w_to_buf_col <= (others => '0');
        w_to_buf_row <= (others => '0');
        w_to_buf_data <= (others => '0');
        case r_state is
            when s_FRAME_TOP_EVEN =>
                if w_f_X0_frame_idx = r_stable_frame_idx then
                    w_f_X0_ready <= '1';
                    w_to_buf_write_en(0) <= w_f_X0_valid;
                    w_to_buf_col <= w_f_X0_col;
                    w_to_buf_row <= w_f_X0_row;
                    w_to_buf_data <= w_f_X0_data;
                end if;
            when s_FRAME_TOP_ODD => 
                if w_f_X1_frame_idx = r_stable_frame_idx then
                    w_f_X1_ready <= '1';
                    w_to_buf_write_en(0) <= w_f_X1_valid;
                    w_to_buf_col <= w_f_X1_col;
                    w_to_buf_row <= w_f_X1_row;
                    w_to_buf_data <= w_f_X1_data;
                end if;
            when s_FRAME_LOWER_EVEN =>
                if w_f_X0_frame_idx = r_stable_frame_idx and w_f_X0_valid = '1' then
                    -- Current frame data available
                    w_f_X0_ready <= '1';
                    w_to_buf_write_en(0) <= '1';
                    w_to_buf_col <= w_f_X0_col;
                    w_to_buf_row <= w_f_X0_row;
                    w_to_buf_data <= w_f_X0_data;
                elsif to_integer(unsigned(w_f_X1_row)) < c_ROWS / 2 then
                    -- Only next frame data in top half available or no valid data
                    -- FIFO data must be in correct frame, or in old frame and overwritten afterwards
                    w_f_X1_ready <= '1';
                    w_to_buf_write_en(0) <= w_f_X1_valid;
                    w_to_buf_col <= w_f_X1_col;
                    w_to_buf_row <= w_f_X1_row;
                    w_to_buf_data <= w_f_X1_data;
                end if;
            when s_FRAME_LOWER_ODD =>
                if w_f_X1_frame_idx = r_stable_frame_idx and w_f_X1_valid = '1' then
                    -- Current frame data available
                    w_f_X1_ready <= '1';
                    w_to_buf_write_en(0) <= '1';
                    w_to_buf_col <= w_f_X1_col;
                    w_to_buf_row <= w_f_X1_row;
                    w_to_buf_data <= w_f_X1_data;
                elsif to_integer(unsigned(w_f_X0_row)) < c_ROWS / 2 then
                    -- Only next frame data in top half available or no valid data
                    -- FIFO data must be in correct frame, or in old frame and overwritten afterwards
                    w_f_X0_ready <= '1';
                    w_to_buf_write_en(0) <= w_f_X0_valid;
                    w_to_buf_col <= w_f_X0_col;
                    w_to_buf_row <= w_f_X0_row;
                    w_to_buf_data <= w_f_X0_data;
                end if;
            when others => null;
        end case;
    end process;

    w_to_buf_addr <= w_to_buf_row & w_to_buf_col;

    -- FRAME BUFFER READ
    w_buf_addr_r <= i_buf_row(8 downto 0) & i_buf_column(9 downto 0);

    FRAME_BUFFER: Framebuffer
    port map (
        clka    => i_clk,
        ena     => w_to_buf_write_en(0),
        wea     => w_to_buf_write_en,
        addra   => w_to_buf_addr,
        dina    => w_to_buf_data,
        clkb    => i_vga_clk,
        enb     => i_buf_read_en,
        addrb   => w_buf_addr_r,
        doutb   => w_buf_out
    );

    o_buf_cycles_until_divergent <= w_buf_out(7 downto 0);
    o_buf_is_convergent <= w_buf_out(8);

    -- Determine the stage of the read operation
    READ_STAGE: process(i_vga_clk)
	begin
        if rising_edge(i_vga_clk) then
            if i_vga_resetn = '0' then
                r_is_lower_half_of_frame <= '0';
            else
                if i_buf_read_en = '1' then
                    if to_integer(unsigned(i_buf_row)) >= c_ROWS / 2 then
                        -- Lower Part
                        r_is_lower_half_of_frame <= '1';
                    else
                        -- Upper Part
                        r_is_lower_half_of_frame <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Port the read stage and frame idx to the write clock domain
    CDC_VGA_2_WRITE: process(i_clk)
    begin
        if rising_edge(i_clk) then
            r_cdc_is_lower_half_of_frame <= r_is_lower_half_of_frame;
            r_stable_is_lower_half_of_frame <= r_cdc_is_lower_half_of_frame;
            r_cdc_frame_idx_grey_code <= r_frame_idx_grey_code;
            r_stable_frame_idx_grey_code <= r_cdc_frame_idx_grey_code;
        end if;
    end process;

    -- Encode frame idx in gray code for cdc (always old or new state when metastable)
    -- Encode
    with i_buf_frame_idx select
        r_frame_idx_grey_code <=
            "00" when "00",
            "01" when "01",
            "11" when "10",
            "10" when "11",
            "00" when others;
    -- Decode
    with r_stable_frame_idx_grey_code select
        r_stable_frame_idx <=
            "00" when "00",
            "01" when "01",
            "10" when "11",
            "11" when "10",
            "00" when others;

end Behavioral;