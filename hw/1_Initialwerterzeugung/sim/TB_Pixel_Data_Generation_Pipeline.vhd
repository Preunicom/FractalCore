----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 05/03/2026 09:49:00 AM
-- Design Name: 
-- Module Name: TB_Pixel_Data_Generation_Pipeline - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Pixel Data Generation Pipeline.
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
use std.env.finish;

library work;
use work.Pkg_Utils.all;
use work.Pkg_TB_Utils.all;

entity TB_Pixel_Data_Generation_Pipeline is
end TB_Pixel_Data_Generation_Pipeline;

architecture Testbench of TB_Pixel_Data_Generation_Pipeline is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn              : std_logic;
    signal s_clk                 : std_logic := '0';
    signal s_pixel_distance      : std_logic_vector(7 downto 0);
    signal s_frames_per_step     : std_logic_vector(15 downto 0);
    signal s_mode                : std_logic_vector(1 downto 0);
    signal s_enable_minimap      : std_logic;
    signal s_step_width          : std_logic_vector(16 downto 0);
    signal s_lfsr_seed_re        : std_logic_vector(17 downto 0);
    signal s_lfsr_seed_im        : std_logic_vector(17 downto 0);
    signal s_lfsr_xor_mask_re    : std_logic_vector(16 downto 0);
    signal s_lfsr_xor_mask_im    : std_logic_vector(16 downto 0);
    signal s_diamond_heigh       : std_logic_vector(16 downto 0);
    signal s_diamond_width       : std_logic_vector(16 downto 0);
    signal s_load_seed           : std_logic;
    signal s_ready               : std_logic;

    -- CHECK
    signal c_valid               : std_logic;
    signal c_video_pix_col       : std_logic_vector(9 downto 0);
    signal c_video_pix_row       : std_logic_vector(8 downto 0);
    signal c_video_frame_idx     : std_logic_vector(1 downto 0);
    signal c_z0_real             : std_logic_vector(17 downto 0);
    signal c_z0_img              : std_logic_vector(17 downto 0);
    signal c_c_real              : std_logic_vector(17 downto 0);
    signal c_c_img               : std_logic_vector(17 downto 0);
    signal c_highlight           : t_highlight_info;

    signal tb_last_col           : integer;
    signal tb_last_row           : integer;
    signal tb_last_frame_idx     : std_logic_vector(1 downto 0);
    signal tb_last_distance      : std_logic_vector(7 downto 0);
    signal tb_curr_c_real_frame  : std_logic_vector(17 downto 0);
    signal tb_curr_c_img_frame   : std_logic_vector(17 downto 0);


    signal tb_test_ended_col : boolean := false;
    signal tb_test_ended_row : boolean := false;
    signal tb_test_ended_c : boolean := false;
    signal tb_test_ended_coord : boolean := false;
    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Pixel_Data_Generation_Pipeline
    port map (
        i_resetn           => s_resetn,
        i_clk              => s_clk,
        i_pixel_distance   => s_pixel_distance,
        i_frames_per_step  => s_frames_per_step,
        i_mode             => s_mode,
        i_enable_minimap   => s_enable_minimap,
        i_step_width       => s_step_width,
        i_lfsr_seed_re     => s_lfsr_seed_re,
        i_lfsr_seed_im     => s_lfsr_seed_im,
        i_lfsr_xor_mask_re => s_lfsr_xor_mask_re,
        i_lfsr_xor_mask_im => s_lfsr_xor_mask_im,
        i_diamond_heigh    => s_diamond_heigh,
        i_diamond_width    => s_diamond_width,
        i_load_seed        => s_load_seed,
        i_ready            => s_ready,
        o_valid            => c_valid,
        o_video_pix_col    => c_video_pix_col,
        o_video_pix_row    => c_video_pix_row,
        o_video_frame_idx  => c_video_frame_idx,
        o_z0_real          => c_z0_real,
        o_z0_img           => c_z0_img,
        o_c_real           => c_c_real,
        o_c_img            => c_c_img,
        o_highlight        => c_highlight
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "10"; -- Mandelbrot
        s_enable_minimap   <= '0'; 
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '1'; 
        -- Control
        s_ready            <= '0';
        wait until rising_edge(s_clk);
        s_ready            <= '1';
        wait until rising_edge(s_clk);
        s_ready            <= '0';
        wait until rising_edge(s_clk);
        s_ready            <= '1';
        wait for 640*2*tbase; -- Wait some time of the frame
        s_ready            <= '0';
        wait for 640*tbase; -- Wait some time
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "10"; -- Mandelbrot
        s_enable_minimap   <= '1'; 
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '1'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "01";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '0'; 
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "10";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(2, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '1'; 
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "11";
        wait until c_video_frame_idx = "00";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "01"; -- LFSR
        s_enable_minimap   <= '1';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "01";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "01"; -- LFSR
        s_enable_minimap   <= '1';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "10";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "01"; -- LFSR
        s_enable_minimap   <= '0';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "11";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '0';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "00";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '0';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(3, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "01";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '0';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(1, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "10";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '0';
        s_step_width       <= std_logic_vector(to_unsigned(1, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(1, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "11";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(1, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '1';
        s_step_width       <= std_logic_vector(to_unsigned(2, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(2, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(1, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "00";
        wait until c_video_frame_idx = "01";
        wait until c_video_frame_idx = "10";
        wait until c_video_frame_idx = "11";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(3, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "10"; -- Mandelbrot
        s_enable_minimap   <= '1';
        s_step_width       <= std_logic_vector(to_unsigned(2, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(1, 17));
        s_load_seed        <= '0';
        -- Control
        s_ready            <= '1';
        wait until c_video_frame_idx = "00";
        -- Config
        s_pixel_distance   <= std_logic_vector(to_unsigned(3, 8));
        s_frames_per_step  <= std_logic_vector(to_unsigned(1, 16));
        s_mode             <= "00"; -- Diamond
        s_enable_minimap   <= '1';
        s_step_width       <= std_logic_vector(to_unsigned(2, 17));
        s_lfsr_seed_re     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_seed_im     <= std_logic_vector(to_unsigned(1, 18));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(3, 17));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(3, 17));
        s_diamond_heigh    <= std_logic_vector(to_unsigned(1, 17));
        s_diamond_width    <= std_logic_vector(to_unsigned(1, 17));
        s_load_seed        <= '0'; 
        -- Control
        s_ready            <= '1';
        wait;
    end process;

    SET_LAST: process(s_clk)
	begin
        if rising_edge(s_clk) then
            if s_resetn = '0' then
                tb_last_col <= 639;
                tb_last_row <= 479;
                tb_last_frame_idx <= "11";
            else
                if s_ready = '1' and c_valid = '1' then
                    tb_last_col <= to_integer(unsigned(c_video_pix_col));
                    tb_last_row <= to_integer(unsigned(c_video_pix_row));
                    tb_last_frame_idx <= c_video_frame_idx;
                    tb_last_distance <= s_pixel_distance;
                    if tb_last_frame_idx /= c_video_frame_idx then
                        tb_curr_c_real_frame <= c_c_real;
                        tb_curr_c_img_frame <= c_c_img;
                    end if;
                end if;
            end if;
        end if;
    end process;

    CHECK_COL: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if c_valid = '1' then
                if s_ready = '1' then 
                    -- Read data and request next
                    assert to_integer(unsigned(c_video_pix_col)) = (tb_last_col + 1) mod 640
                        report "Wrong pixel column received!" & LF
                            & "Exp.:" & to_string((tb_last_col + 1) mod 640) & LF
                            & "Got.:" & to_string(to_integer(unsigned(c_video_pix_col)))
                        severity failure;
                    tb_test_ended_col <= true;
                else
                    assert to_integer(unsigned(c_video_pix_col)) = tb_last_col or
                        (to_integer(unsigned(c_video_pix_col)) = tb_last_col + 1)
                        report "Pixel column changed without fetch next!" & LF
                            & "Exp.:" & to_string(tb_last_col) & LF
                            & "Got.:" & to_string(to_integer(unsigned(c_video_pix_col)))
                        severity failure; 
                end if;
            end if;
        end loop;
    end process;

    CHECK_ROW: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait until rising_edge(s_clk);
            if c_valid = '1' then
                if s_ready = '1' then
                    -- Read data and request next
                    if tb_last_col = 639 then
                        -- New row expected
                        assert to_integer(unsigned(c_video_pix_row)) = (tb_last_row + 1) mod 480
                            report "Wrong pixel row received!" & LF
                                & "Exp.:" & to_string((tb_last_row + 1) mod 480) & LF
                                & "Got.:" & to_string(to_integer(unsigned(c_video_pix_row)))
                            severity failure; 
                            tb_test_ended_row <= true;
                    else
                        assert to_integer(unsigned(c_video_pix_row)) = tb_last_row
                            report "Wrong pixel row received in mid of a row!" & LF
                                & "Exp.:" & to_string(tb_last_row) & LF
                                & "Got.:" & to_string(to_integer(unsigned(c_video_pix_row)))
                            severity failure; 
                    end if;
                else
                    assert to_integer(unsigned(c_video_pix_row)) = tb_last_row or
                        (to_integer(unsigned(c_video_pix_row)) = tb_last_row + 1)
                        report "Wrong pixel row received while fetch disabled!" & LF
                            & "Exp.:" & to_string(tb_last_row) & LF
                            & "Got.:" & to_string(to_integer(unsigned(c_video_pix_row)))
                        severity failure;
                end if;
            end if;
        end loop;
    end process;

    CHECK_SAME_C_FOR_FRAME: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait_for_handshake(s_clk, c_valid, s_ready);
            if tb_last_frame_idx = c_video_frame_idx then
                -- Same frame as last --> current c already set
                -- Same c as beginn of frame or minimap --> Mandelbrot mode
                assert tb_curr_c_real_frame = c_c_real or 
                    (c_z0_real = std_logic_vector(to_signed(0, 18)) and 
                    c_z0_img = std_logic_vector(to_signed(0, 18)))
                    report "Real c does not match the first c of the frame or minimap pixel c not 0!" & LF
                        & "Exp.:" & to_string(tb_curr_c_real_frame) & LF
                        & "Got.:" & to_string(c_c_real) & LF
                        & "Is Mandelbrot: " & to_string(c_z0_real = std_logic_vector(to_signed(0, 18)) and c_z0_img = std_logic_vector(to_signed(0, 18)))
                        & " Exp. if Mandelbrot : Pixel coordinate"
                    severity failure;
                assert tb_curr_c_img_frame = c_c_img or 
                        (c_z0_real = std_logic_vector(to_signed(0, 18)) and 
                        c_z0_img = std_logic_vector(to_signed(0, 18)))
                    report "Img. c does not match the first c of the frame or minimap pixel c not 0!" & LF
                        & "Exp.:" & to_string(tb_curr_c_img_frame) & LF
                        & "Got.:" & to_string(c_c_img) & LF
                        & "Is Mandelbrot: " & to_string(c_z0_real = std_logic_vector(to_signed(0, 18)) and c_z0_img = std_logic_vector(to_signed(0, 18)))
                        & " Exp. if Mandelbrot :Pixel coordinate"
                    severity failure;
                tb_test_ended_c <= true;
            end if;
        end loop;
    end process;

    CHECK_FIRST_COORD: process
	begin
        wait until s_resetn = '1';
        while True loop
            wait_for_handshake(s_clk, c_valid, s_ready);
            if tb_last_frame_idx /= c_video_frame_idx then
                -- New frame
                assert c_z0_real = std_logic_vector(to_signed(-320 * to_integer(unsigned(tb_last_distance)), 18)) or 
                    (c_z0_real = std_logic_vector(to_signed(0, 18)) and 
                    c_z0_img = std_logic_vector(to_signed(0, 18)))
                    report "First RE z0 of frame wrong!" & LF
                        & "Exp.:" & to_string(std_logic_vector(to_signed(-320 * to_integer(unsigned(tb_last_distance)), 18))) & LF
                        & "Got.:" & to_string(c_z0_real) & LF
                        & "Is Mandelbrot: " & to_string(c_z0_real = std_logic_vector(to_signed(-320 * to_integer(unsigned(tb_last_distance)), 18)) and (c_z0_real = std_logic_vector(to_signed(0, 18)) and c_z0_img = std_logic_vector(to_signed(0, 18))))
                        & " Exp. if Mandelbrot : 0"
                    severity failure;
                assert c_z0_img = std_logic_vector(to_signed(240 * to_integer(unsigned(tb_last_distance)), 18)) or 
                    (c_z0_real = std_logic_vector(to_signed(0, 18)) and 
                    c_z0_img = std_logic_vector(to_signed(0, 18)))
                    report "First IM z0 of frame wrong!" & LF
                        & "Exp.:" & to_string(std_logic_vector(to_signed(240 * to_integer(unsigned(tb_last_distance)), 18))) & LF
                        & "Got.:" & to_string(c_z0_img) & LF
                        & "Is Mandelbrot: " & to_string(c_z0_img = std_logic_vector(to_signed(240 * to_integer(unsigned(tb_last_distance)), 18)) and (c_z0_real = std_logic_vector(to_signed(0, 18)) and c_z0_img = std_logic_vector(to_signed(0, 18))))
                        & " Exp. if Mandelbrot : 0"
                    severity failure;
                tb_test_ended_coord <= true;
            end if;
        end loop;
    end process;

    tb_test_ended <= tb_test_ended_row and tb_test_ended_col and tb_test_ended_c and tb_test_ended_coord;

    END_TEST_CHECK: process
    begin
        wait for 20*640*480*tbase;
        if tb_test_ended = true then
            report "TEST PASSED!"
                severity note;
            tb_test_passed <= true;
            wait for tbase;
            finish;
        else
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;
    end process;

end Testbench;