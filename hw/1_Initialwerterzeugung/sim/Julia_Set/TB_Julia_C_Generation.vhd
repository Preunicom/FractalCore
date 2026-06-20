----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/23/2026 04:46:00 AM
-- Design Name: 
-- Module Name: TB_Julia_C_Generation - Testbench
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Testing the Julia c generation.
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
use work.Pkg_TB_Utils.all;

entity TB_Julia_C_Generation is
end TB_Julia_C_Generation;

architecture Testbench of TB_Julia_C_Generation is
    constant tbase : time := 10 ns;
    -- STIMULI
    signal s_resetn : std_logic;
    signal s_clk : std_logic := '0';
    signal s_en : std_logic;
    signal s_frames_per_step : std_logic_vector(15 downto 0);
    signal s_step_width : std_logic_vector(16 downto 0);
    signal s_mode : std_logic; -- 0: Diamond, 1: LFSR
    signal s_load_seed : std_logic;
    signal s_lfsr_seed_re : std_logic_vector(16 downto 0);
    signal s_lfsr_seed_im : std_logic_vector(16 downto 0);
    signal s_lfsr_xor_mask_re : std_logic_vector(15 downto 0);
    signal s_lfsr_xor_mask_im : std_logic_vector(15 downto 0);
    signal s_diamond_height: std_logic_vector(15 downto 0);
    signal s_diamond_width : std_logic_vector(15 downto 0);
    
    -- CHECK
    signal c_target_re : std_logic_vector(17 downto 0);
    signal c_target_im : std_logic_vector(17 downto 0);        
    signal c_current_coord_re : std_logic_vector(17 downto 0);
    signal c_current_coord_im : std_logic_vector(17 downto 0);

    signal tb_current_target_re : integer;
    signal tb_current_target_im : integer;
    signal tb_current_coord_re : integer;
    signal tb_current_coord_im : integer;
    signal tb_step_width : integer;

    signal tb_test_ended : boolean := false;
    signal tb_test_passed : boolean := false;

begin
    UUT: entity work.Julia_C_Generation
    port map (
        i_resetn           => s_resetn,
        i_clk              => s_clk,
        i_en               => s_en,
        i_frames_per_step  => s_frames_per_step,
        i_step_width       => s_step_width,
        i_mode             => s_mode,
        i_load_seed        => s_load_seed,
        i_lfsr_seed_re     => s_lfsr_seed_re,
        i_lfsr_seed_im     => s_lfsr_seed_im,
        i_lfsr_xor_mask_re => s_lfsr_xor_mask_re,
        i_lfsr_xor_mask_im => s_lfsr_xor_mask_im,
        i_diamond_height   => s_diamond_height,
        i_diamond_width    => s_diamond_width,
        o_target_re        => c_target_re,
        o_target_im        => c_target_im,
        o_current_coord_re => c_current_coord_re,
        o_current_coord_im => c_current_coord_im
    );

    s_resetn <= '0', '1' after 1*tbase;
    s_clk <= not s_clk after 0.5*tbase;

    STIMULI: process
	begin
        wait until s_resetn = '1';
        -- Test diamond mode - step width 0, height 0, width 0
        s_en <= '1';
        s_diamond_height <= std_logic_vector(to_unsigned(0, 16));
        s_diamond_width <= std_logic_vector(to_unsigned(0, 16));
        s_frames_per_step <= std_logic_vector(to_unsigned(0, 16));
        s_step_width <= std_logic_vector(to_unsigned(0, 17)); 
        s_mode <= '0';
        s_load_seed <= '0';
        s_lfsr_seed_re <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_seed_im <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(0, 16));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(0, 16));
        wait_for_clock_cycles(s_clk, 5);
        -- Test diamond mode
        s_en <= '1';
        s_diamond_height <= std_logic_vector(to_unsigned(300, 16));
        s_diamond_width <= std_logic_vector(to_unsigned(200, 16));
        s_frames_per_step <= std_logic_vector(to_unsigned(1, 16));
        s_step_width <= std_logic_vector(to_unsigned(100, 17)); 
        s_mode <= '0';
        wait_for_clock_cycles(s_clk, 5);
        -- Test diamond mode
        s_en <= '1';
        s_diamond_height <= std_logic_vector(to_unsigned(1000, 16));
        s_diamond_width <= std_logic_vector(to_unsigned(1000, 16));
        s_frames_per_step <= std_logic_vector(to_unsigned(2, 16));
        s_step_width <= std_logic_vector(to_unsigned(100, 17)); 
        s_mode <= '0';
        wait_for_clock_cycles(s_clk, 10);
        -- Test diamond mode
        s_en <= '1';
        s_diamond_height <= std_logic_vector(to_unsigned(10, 16));
        s_diamond_width <= std_logic_vector(to_unsigned(10, 16));
        s_frames_per_step <= std_logic_vector(to_unsigned(4, 16));
        s_step_width <= std_logic_vector(to_unsigned(100, 17)); 
        s_mode <= '0';
        wait_for_clock_cycles(s_clk, 20);
        s_en <= '0';
        wait_for_clock_cycles(s_clk, 2);
        s_en <= '1';
        wait_for_clock_cycles(s_clk, 20);
        -- Test lfsr mode
        s_en <= '1';
        s_frames_per_step <= std_logic_vector(to_unsigned(1, 16));
        s_step_width <= (others => '1'); 
        s_mode <= '1';
        s_load_seed <= '0';
        s_lfsr_seed_re <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_seed_im <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(0, 16));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(0, 16));
        wait_for_clock_cycles(s_clk, 10);
        -- Test diamond mode
        s_en <= '1';
        s_diamond_height <= (others => '1');
        s_diamond_width <= (others => '1');
        s_frames_per_step <= std_logic_vector(to_unsigned(1, 16));
        s_step_width <= (others => '1'); 
        s_mode <= '0';
        wait_for_clock_cycles(s_clk, 10);
        -- Test lfsr mode
        s_en <= '1';
        s_frames_per_step <= std_logic_vector(to_unsigned(2, 16));
        s_step_width <= std_logic_vector(to_unsigned(1000, 17));
        s_mode <= '1';
        s_load_seed <= '1';
        s_lfsr_seed_re <= std_logic_vector(to_unsigned(10, 17));
        s_lfsr_seed_im <= std_logic_vector(to_unsigned(200, 17));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(1027, 16));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(1025, 16));
        wait until rising_edge(s_clk);
        s_load_seed <= '0';
        wait_for_clock_cycles(s_clk, 9);
        -- Test lfsr mode
        s_en <= '1';
        s_frames_per_step <= std_logic_vector(to_unsigned(5, 16));
        s_step_width <= std_logic_vector(to_unsigned(0, 17));
        s_mode <= '1';
        s_load_seed <= '0';
        s_lfsr_seed_re <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_seed_im <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(0, 16));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(0, 16));
        wait_for_clock_cycles(s_clk, 15);
        s_en <= '0';
        wait_for_clock_cycles(s_clk, 10);
        s_en <= '1';
        wait_for_clock_cycles(s_clk, 15);
        -- Test lfsr mode
        s_en <= '1';
        s_frames_per_step <= std_logic_vector(to_unsigned(3, 16));
        s_step_width <= std_logic_vector(to_unsigned(10000, 17));
        s_mode <= '1';
        s_load_seed <= '0';
        s_lfsr_seed_re <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_seed_im <= std_logic_vector(to_unsigned(0, 17));
        s_lfsr_xor_mask_re <= std_logic_vector(to_unsigned(0, 16));
        s_lfsr_xor_mask_im <= std_logic_vector(to_unsigned(0, 16));
        for i in 0 to 50 loop
            wait_for_clock_cycles(s_clk, 1);
            s_en <= '0';
            wait_for_clock_cycles(s_clk, 2);
            s_en <= '1';
        end loop;
        wait_for_clock_cycles(s_clk, 10);
        tb_test_ended <= true;
        wait;
    end process;

    tb_current_target_re <= to_integer(signed(c_target_re));
    tb_current_target_im <= to_integer(signed(c_target_im));
    tb_current_coord_re <= to_integer(signed(c_current_coord_re));
    tb_current_coord_im <= to_integer(signed(c_current_coord_im));
    tb_step_width <= to_integer(unsigned(s_step_width));

    CHECK_FRAMES: process
        variable last_value_re : integer := 0;
        variable last_value_im : integer := 0;
        variable iteration : integer := 0;
        variable last_frames_per_step : integer := 0;
        variable saved_frames_per_step : integer := 0;
	begin
        wait until s_resetn = '1';
        while true loop
            wait_for_enabled_clock(s_clk, s_en);
            iteration := iteration + 1;
                if (last_value_re /= tb_current_coord_re) or (last_value_im /= tb_current_coord_im) then
                    -- Stepped one step
                    iteration := 0;
                    -- Delays the frames per step target by two clock cycles (cc)
                    -- One cc delay for the synchronous load of the value (so the currently read value is not read yet)
                    -- Second cc delay for the synchronous next step load internal signal depending on the one cc delay of the sync. load
                    if last_frames_per_step /= to_integer(unsigned(s_frames_per_step)) then
                        saved_frames_per_step := last_frames_per_step;
                    end if;
                    -- Check frame amount of the last step
                    assert (iteration < to_integer(unsigned(s_frames_per_step))) 
                    or (iteration < saved_frames_per_step)
                        report "Iteration amount not expected!" & LF
                            & "Exp. lower than: " & to_string(saved_frames_per_step) & "OR" & to_string(to_integer(unsigned(s_frames_per_step))) & LF
                            & "Got.: " & to_string(iteration)
                        severity failure;
                        -- Set current value as last value of enabled clock
                        last_frames_per_step := to_integer(unsigned(s_frames_per_step));
                -- Set current values as last values to detect edges in the signals
                last_value_re := tb_current_coord_re;
                last_value_im := tb_current_coord_im;
            end if;
        end loop;
    end process;

    CHECK_VALUE: process
        variable last_value_re : integer := 0;
        variable last_value_im : integer := 0;
        variable last_step_width : integer := 0;
	begin
        wait until s_resetn = '1';
        while true loop
            wait_for_enabled_clock(s_clk, s_en);
            if (last_value_re /= tb_current_coord_re) or (last_value_im /= tb_current_coord_im) then
                -- Stepped one step
                -- Test distance between current and last value
                assert (tb_current_coord_re = last_step_width + last_value_re) -- Step in pos. dir.
                or (tb_current_coord_re = last_value_re - last_step_width) -- Step in neg. dir
                or tb_current_coord_re = last_value_re  -- No step as we would get an overflow
                    report "No valid new value for the coordinates in RE!" & LF
                    & "Last: " & to_string(last_value_re) & LF
                    & "New: " & to_string(tb_current_coord_re) & LF
                    & "Exp. delta: " & to_string(last_step_width)
                    severity failure;
                assert (tb_current_coord_im = last_step_width + last_value_im)  -- Step in pos. dir.
                or (tb_current_coord_im = last_value_im - last_step_width)  -- Step in neg. dir
                or tb_current_coord_im = last_value_im  -- No step as we would get an overflow
                    report "No valid new value for the coordinates in IM!" & LF
                    & "Last: " & to_string(last_value_im) & LF
                    & "New: " & to_string(tb_current_coord_im) & LF
                    & "Exp. delta: " & to_string(last_step_width)
                    severity failure;
                -- Set current values as last values
                last_value_re := tb_current_coord_re;
                last_value_im := tb_current_coord_im;
            end if;
            last_step_width := tb_step_width;
        end loop;
    end process;

    CHECK_REPEATING_VALUES: process
        variable last_value_re : integer := 0;
        variable last_value_im : integer := 0;
        variable same_counter_amount_re : integer := 0;
        variable same_counter_amount_im : integer := 0;
	begin
        wait until s_resetn = '1';
        while true loop
            wait_for_enabled_clock(s_clk, s_en);
            if (last_value_re /= tb_current_coord_re) or (last_value_im /= tb_current_coord_im) then
                -- Stepped one step
                if tb_current_coord_re = last_value_re then
                    same_counter_amount_re := same_counter_amount_re + 1;
                end if;
                if tb_current_coord_im = last_value_im then
                    same_counter_amount_im := same_counter_amount_im + 1;
                end if;
                assert same_counter_amount_re < 50 -- Chosen as this would create an error if nothing changes at all
                    report "Too many values in RE stayed the same"
                    severity failure;
                assert same_counter_amount_im < 50 -- Chosen as this would create an error if nothing changes at all
                    report "Too many values in IM stayed the same"
                    severity failure;
            end if;
        end loop;
    end process;

    CHECK_SEED: process
        variable last_load_seed : std_logic := '0';
	begin
        wait until s_resetn = '1';
        while true loop
            wait_for_enabled_clock(s_clk, s_en);
            if last_load_seed = '1' then
                -- Check LFSR target
                assert c_target_re = '0' & s_lfsr_seed_re
                    report "Seed not set in RE!" & LF
                        & "Exp.: " & to_string('0' & s_lfsr_seed_re) & LF
                        & "Got:  " & to_string(c_target_re)
                    severity failure;
                assert c_target_im = '0' & s_lfsr_seed_im
                    report "Seed not set in IM!" & LF
                        & "Exp.: " & to_string('0' & s_lfsr_seed_im) & LF
                        & "Got:  " & to_string(c_target_im)
                    severity failure;
            end if;
            if s_mode = '0' then
                -- Check Diamond target
                assert (c_target_re = "00" & s_diamond_width and c_target_im = std_logic_vector(to_signed(0, 18)))
                or (c_target_re = std_logic_vector(to_signed(0, 18)) and c_target_im = "00" & s_diamond_height)
                or (c_target_re = std_logic_vector(-signed("00" & s_diamond_width)) and c_target_im = std_logic_vector(to_signed(0, 18)))
                or (c_target_re = std_logic_vector(to_signed(0, 18)) and c_target_im = std_logic_vector(-signed("00" & s_diamond_height)))
                    report "Diamond targets not set!" & LF
                        & "Exp.: Width (RE): " & to_string("00" & s_diamond_width) & " | Height (IM): " & to_string("00" & s_diamond_height) & LF
                        & "Got:  RE: " & to_string(c_target_re) & " | IM: " & to_string(c_target_im)
                    severity failure;
            end if;
            last_load_seed := s_load_seed; -- Delays the load by one enabled clock cycle
        end loop;
    end process;

    END_TEST_CHECK: process
    begin
        wait until tb_test_ended = true for 1000*tbase;
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