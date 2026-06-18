----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/27/2026 14:14:00 AM
-- Design Name: 
-- Module Name: TB_Highlight_Calculation - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Highlight calculation.
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

entity TB_Highlight_Calculation is
end TB_Highlight_Calculation;

architecture Testbench of TB_Highlight_Calculation is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn               : std_logic;
    signal s_clk                  : std_logic := '0';
    signal s_valid                : std_logic;
    signal s_frame_idx            : std_logic_vector(1 downto 0);
    signal s_pixel_col            : std_logic_vector(9 downto 0);
    signal s_pixel_row            : std_logic_vector(8 downto 0);
    signal s_pixel_coord_re       : std_logic_vector(17 downto 0);
    signal s_pixel_coord_im       : std_logic_vector(17 downto 0);
    signal s_c_coord_re           : std_logic_vector(17 downto 0);
    signal s_c_coord_im           : std_logic_vector(17 downto 0);
    signal s_target_coord_re      : std_logic_vector(17 downto 0);
    signal s_target_coord_im      : std_logic_vector(17 downto 0);
    signal s_is_in_minimap        : std_logic;

    signal tb_frame_idx           : integer;
    signal tb_pixel_col           : integer;
    signal tb_pixel_row           : integer;
    signal tb_pixel_coord_re      : integer;
    signal tb_pixel_coord_im      : integer;
    signal tb_c_coord_re          : integer;
    signal tb_c_coord_im          : integer;
    signal tb_target_coord_re     : integer;
    signal tb_target_coord_im     : integer;

    -- CHECK
    signal c_highlight_info : t_highlight_info;

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

    procedure check_highlight_data(
        signal highlight_info : in t_highlight_pixel;
        constant valid : std_logic;
        constant curr_pixel_col : in integer;
        constant curr_pixel_row : in integer;
        constant target_pixel_col : in integer;
        constant target_pixel_row : in integer;
        constant debug_info : in string
    ) is 
    begin
        assert highlight_info.valid = valid
            report "Wrong valid signal received!" & "(" & debug_info & ")" & LF &
                "Exp.: " & std_logic'image(valid) & LF &
                "Got:  " & std_logic'image(highlight_info.valid)
            severity failure;
        assert to_integer(unsigned(highlight_info.current_pixel_col)) = curr_pixel_col
            report "Wrong current pixel column signal received!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(curr_pixel_col) & LF &
                "Got:  " & to_string(to_integer(unsigned(highlight_info.current_pixel_col)))
            severity failure;
        assert to_integer(unsigned(highlight_info.current_pixel_row)) = curr_pixel_row
            report "Wrong current pixel row signal received!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(curr_pixel_row) & LF &
                "Got:  " & to_string(to_integer(unsigned(highlight_info.current_pixel_row)))
            severity failure;
        assert to_integer(unsigned(highlight_info.target_pixel_col)) = target_pixel_col
            report "Wrong target pixel column signal received!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(target_pixel_col) & LF &
                "Got:  " & to_string(to_integer(unsigned(highlight_info.target_pixel_col)))
            severity failure;
        assert to_integer(unsigned(highlight_info.target_pixel_row)) = target_pixel_row
            report "Wrong target pixel row signal received!" & "(" & debug_info & ")" & LF &
                "Exp.: " & to_string(target_pixel_row) & LF &
                "Got:  " & to_string(to_integer(unsigned(highlight_info.target_pixel_row)))
            severity failure;
    end procedure; 

begin

    UUT: entity work.Highlight_Calculation
    port map (
        i_resetn          => s_resetn,
        i_clk             => s_clk,
        i_valid           => s_valid,
        i_frame_idx       => s_frame_idx,
        i_pixel_col       => s_pixel_col,
        i_pixel_row       => s_pixel_row,
        i_pixel_coord_re  => s_pixel_coord_re,
        i_pixel_coord_im  => s_pixel_coord_im,
        i_c_coord_re      => s_c_coord_re,
        i_c_coord_im      => s_c_coord_im,
        i_c_target_coord_re => s_target_coord_re,
        i_c_target_coord_im => s_target_coord_im,
        i_is_in_minimap   => s_is_in_minimap,
        o_highlight_info  => c_highlight_info
    );

    s_clk <= not s_clk after 0.5*tbase;
    s_resetn <= '0', '1' after 1*tbase;

    s_frame_idx        <= std_logic_vector(to_unsigned(tb_frame_idx, 2));
    s_pixel_col        <= std_logic_vector(to_unsigned(tb_pixel_col, 10));
    s_pixel_row        <= std_logic_vector(to_unsigned(tb_pixel_row, 9));
    s_pixel_coord_re   <= std_logic_vector(to_signed(tb_pixel_coord_re, 18));
    s_pixel_coord_im   <= std_logic_vector(to_signed(tb_pixel_coord_im, 18));
    s_c_coord_re       <= std_logic_vector(to_signed(tb_c_coord_re, 18));
    s_c_coord_im       <= std_logic_vector(to_signed(tb_c_coord_im, 18));
    s_target_coord_re  <= std_logic_vector(to_signed(tb_target_coord_re, 18));
    s_target_coord_im  <= std_logic_vector(to_signed(tb_target_coord_im, 18));

    STIMULI: process
        constant c_MINIMAP_DISTANCE : integer := 1112;
	begin
        wait until s_resetn = '1';
        -- Frame 0
        s_valid <= '0';
        tb_frame_idx <= 0;
        tb_pixel_col <= 1;
        tb_pixel_row <= 10;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2) - 1;
        tb_c_coord_im <= 1000 - (c_MINIMAP_DISTANCE / 2) + 1;
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2) + 1;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 0;
        tb_pixel_col <= 1;
        tb_pixel_row <= 10;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2) - 1;
        tb_c_coord_im <= 1000 - (c_MINIMAP_DISTANCE / 2) + 1;
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2) + 1;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 0;
        tb_pixel_col <= 2;
        tb_pixel_row <= 20;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2) - 1;
        tb_c_coord_im <= 1000 - (c_MINIMAP_DISTANCE / 2) + 1;
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2) + 1;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 0;
        tb_pixel_col <= 3;
        tb_pixel_row <= 30;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + ((c_MINIMAP_DISTANCE / 2) * 3);
        tb_c_coord_im <= 100 + (c_MINIMAP_DISTANCE);
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE / 2);
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 0;
        tb_pixel_col <= 4;
        tb_pixel_row <= 40;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + (c_MINIMAP_DISTANCE);
        tb_c_coord_im <= 100 + (c_MINIMAP_DISTANCE / 2);
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE);
        tb_target_coord_im <= 1000 + (c_MINIMAP_DISTANCE * 3);
        s_is_in_minimap <= '1';
        wait until rising_edge(s_clk);
        -- Frame 1
        s_valid <= '1';
        tb_frame_idx <= 1;
        tb_pixel_col <= 5;
        tb_pixel_row <= 50;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + (c_MINIMAP_DISTANCE * 3);
        tb_c_coord_im <= 1000 - (c_MINIMAP_DISTANCE * 9);
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE * 4);
        tb_target_coord_im <= 1000 + (c_MINIMAP_DISTANCE * 7);
        s_is_in_minimap <= '1';
        wait until rising_edge(s_clk);
        -- Frame 2
        s_valid <= '1';
        tb_frame_idx <= 2;
        tb_pixel_col <= 6;
        tb_pixel_row <= 60;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100 + (c_MINIMAP_DISTANCE);
        tb_c_coord_im <= 100 - (c_MINIMAP_DISTANCE * 9);
        tb_target_coord_re <= 100 + (c_MINIMAP_DISTANCE);
        tb_target_coord_im <= 1000 + (c_MINIMAP_DISTANCE * 3);
        s_is_in_minimap <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 2;
        tb_pixel_col <= 7;
        tb_pixel_row <= 70;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100;
        tb_c_coord_im <= 1000;
        tb_target_coord_re <= 100;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '0';
        wait until rising_edge(s_clk);
        -- Frame 3
        s_valid <= '1';
        tb_frame_idx <= 3;
        tb_pixel_col <= 8;
        tb_pixel_row <= 80;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100;
        tb_c_coord_im <= 1000;
        tb_target_coord_re <= 100;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '0';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 3;
        tb_pixel_col <= 9;
        tb_pixel_row <= 90;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100;
        tb_c_coord_im <= 1000;
        tb_target_coord_re <= 100;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '1';
        wait until rising_edge(s_clk);
        s_valid <= '1';
        tb_frame_idx <= 3;
        tb_pixel_col <= 9;
        tb_pixel_row <= 90;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100;
        tb_c_coord_im <= 1000;
        tb_target_coord_re <= 100;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '0';
        wait until rising_edge(s_clk);
        -- Frame 0
        s_valid <= '1';
        tb_frame_idx <= 0;
        tb_pixel_col <= 9;
        tb_pixel_row <= 90;
        tb_pixel_coord_re <= 100;
        tb_pixel_coord_im <= 1000;
        tb_c_coord_re <= 100;
        tb_c_coord_im <= 1000;
        tb_target_coord_re <= 100;
        tb_target_coord_im <= 1000;
        s_is_in_minimap <= '0';
        wait until rising_edge(s_clk);
        wait;
    end process;

    CHECK: process
	begin
        wait until s_resetn = '1';
        wait until rising_edge(s_clk); -- Reset values
        check_highlight_data(c_highlight_info(0), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        -- Frame 0
        wait until rising_edge(s_clk); -- Not enabled
        check_highlight_data(c_highlight_info(0), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        wait until rising_edge(s_clk); -- Set current pixel highlight
        check_highlight_data(c_highlight_info(0), '1', 1, 10, (2**10)-1, (2**9)-1, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        wait until rising_edge(s_clk); -- Stays (not in minimap)
        check_highlight_data(c_highlight_info(0), '1', 1, 10, (2**10)-1, (2**9)-1, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        wait until rising_edge(s_clk); -- Set target highlight
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        wait until rising_edge(s_clk); -- Stays (not near enough)
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        --Frame 1
        wait until rising_edge(s_clk); -- New frame with minimap
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        --Frame 2
        wait until rising_edge(s_clk);  -- New frame without minimap
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        wait until rising_edge(s_clk); -- Frame with no minimap
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        --Frame 3
        wait until rising_edge(s_clk); -- New frame with minimap
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 3");
        wait until rising_edge(s_clk); -- Pixel and target set
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '1', 9, 90, 9, 90, "Frame: 3");
        wait until rising_edge(s_clk); -- Not in minimap
        check_highlight_data(c_highlight_info(0), '1', 1, 10, 3, 30, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '1', 9, 90, 9, 90, "Frame: 3");
        -- Frame 0
        wait until rising_edge(s_clk); -- No minimap
        check_highlight_data(c_highlight_info(0), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 0");
        check_highlight_data(c_highlight_info(1), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 1");
        check_highlight_data(c_highlight_info(2), '0', (2**10)-1,(2**9)-1, (2**10)-1,(2**9)-1, "Frame: 2");
        check_highlight_data(c_highlight_info(3), '1', 9, 90, 9, 90, "Frame: 3");
        wait until rising_edge(s_clk);
        tb_test_ended <= true;
        wait;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 100*tbase;
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