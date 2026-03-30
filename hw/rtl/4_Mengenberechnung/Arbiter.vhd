----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/29/2026 8:09:00 AM
-- Design Name: 
-- Module Name: Arbiter - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Arbites two input to one output based on the lower pixel.
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
use IEEE.numeric_std.all;

library work;
use work.Pkg_Core.all;

entity Arbiter is
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
end Arbiter;

architecture Behavioral of Arbiter is
    signal w_m1_ready : std_logic;
    signal w_m2_ready : std_logic;

    signal r_buf_m1_full : std_logic;
    signal r_buf_m1 : t_pixel_result;
    signal r_buf_m2_full : std_logic;
    signal r_buf_m2 : t_pixel_result;

    signal w_m1_prio : std_logic_vector(20 downto 0);
    signal w_m2_prio : std_logic_vector(20 downto 0);
    signal w_selected_m1 : std_logic;

    signal w_valid : std_logic;
begin

    REG: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_buf_m1_full <= '0';
                r_buf_m1 <= c_PIXEL_RESULT_RESET;
                r_buf_m2_full <= '0';
                r_buf_m2 <= c_PIXEL_RESULT_RESET;
            else
                -- Reset buffer full flag
                if w_valid = '1' and i_ready = '1' then
                    if w_selected_m1 = '1' then
                        -- m1 data was transmitted
                        r_buf_m1_full <= '0';
                    else
                        -- m2 data was transmitted
                        r_buf_m2_full <= '0';
                    end if;
                end if;

                -- Receive data in buffer
                if i_m1_valid = '1' and w_m1_ready = '1' then
                    -- Load buffer 1
                    r_buf_m1 <= i_m1_pixel_result;
                    r_buf_m1_full <= '1';
                end if;
                if i_m2_valid = '1' and w_m2_ready = '1' then
                    -- Load buffer 2
                    r_buf_m2 <= i_m2_pixel_result;
                    r_buf_m2_full <= '1';
                end if;
            end if;
        end if;
    end process;

    w_m1_prio <= r_buf_m1.video_frame_idx & r_buf_m1.video_pix_row & r_buf_m1.video_pix_col;
    w_m2_prio <= r_buf_m2.video_frame_idx & r_buf_m2.video_pix_row & r_buf_m2.video_pix_col;

    ARBIT: process(r_buf_m1_full, r_buf_m2_full, w_m1_prio, w_m2_prio, r_buf_m1.video_frame_idx, r_buf_m2.video_frame_idx)
	begin
        w_selected_m1 <= '1';
        if r_buf_m1_full = '1' and r_buf_m2_full = '0' then
            w_selected_m1 <= '1';
        elsif r_buf_m1_full = '0' and r_buf_m2_full = '1' then
            w_selected_m1 <= '0';
        else
            -- Both valid
            if (w_m1_prio < w_m2_prio or (r_buf_m1.video_frame_idx = "11" and r_buf_m2.video_frame_idx = "00"))
            and not (r_buf_m1.video_frame_idx = "00" and r_buf_m2.video_frame_idx = "11") then -- Overflow in frame
                -- m1 has lower prio index --> m1 is more important
                w_selected_m1 <= '1';
            else
                -- m2 has lower prio index --> m2 is more important
                w_selected_m1 <= '0';
            end if;
        end if;
    end process;

    TRANSMIT: process(r_buf_m1_full, r_buf_m2_full, w_selected_m1, r_buf_m1, r_buf_m2)
    begin
        o_pixel_result <= c_PIXEL_RESULT_RESET;
        w_valid <= '0';
        if r_buf_m1_full = '1' and w_selected_m1 = '1' then
            -- Transmit m1 buffer
            o_pixel_result <= r_buf_m1;
            w_valid <= '1';
        elsif r_buf_m2_full = '1' and w_selected_m1 = '0' then
            -- Transmit m2 buffer
            o_pixel_result <= r_buf_m2;
            w_valid <= '1';
        end if;
    end process;

    -- Ready if buffer is empty or buffer is read
    w_m1_ready <= not r_buf_m1_full or (w_selected_m1 and w_valid and i_ready); 
    w_m2_ready <= not r_buf_m2_full or (not w_selected_m1 and w_valid and i_ready);

    o_m1_ready <= w_m1_ready;
    o_m2_ready <= w_m2_ready;
    o_valid <= w_valid;
   
end Behavioral;