----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 04/22/2026 14:16:00 AM
-- Design Name: 
-- Module Name: Julia_C_Generation - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Creating animated c values for the julia set
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.numeric_std.all;

entity Julia_C_Generation is
	port (
		i_resetn    : in  std_logic;
		i_clk       : in  std_logic;
		i_en        : in  std_logic;
        i_frames_per_step : in std_logic_vector(15 downto 0);
        i_step_width : in std_logic_vector(16 downto 0);
        i_mode : in std_logic; -- 0: Diamond, 1: LFSR
        i_load_seed : in std_logic;
        i_lfsr_seed_re : in std_logic_vector(17 downto 0);
        i_lfsr_seed_im : in std_logic_vector(17 downto 0);
        i_lfsr_xor_mask_re : in std_logic_vector(16 downto 0);
        i_lfsr_xor_mask_im : in std_logic_vector(16 downto 0);
        i_diamond_heigh : in std_logic_vector(16 downto 0);
        i_diamond_width : in std_logic_vector(16 downto 0);
        o_target_re : out std_logic_vector(17 downto 0);
        o_target_im : out std_logic_vector(17 downto 0);        
        o_current_coord_re : out std_logic_vector(17 downto 0);
        o_current_coord_im : out std_logic_vector(17 downto 0)
	);
end entity;

architecture Behavioral of Julia_C_Generation is
	component Dynamic_LFSR is
        generic (
            g_WIDTH : natural range 2 to natural'high
        );
        port (
            i_clk       : in  std_logic;
            i_en        : in  std_logic;
            i_load_en   : in  std_logic;
            i_load_data : in  std_logic_vector(g_WIDTH - 1 downto 0);
            i_xor_mask  : in  std_logic_vector(g_WIDTH - 2 downto 0);
            o_data      : out std_logic_vector(g_WIDTH - 1 downto 0)
        );
    end component;
    component Diamond is
        port (
            i_resetn    : in  std_logic;
            i_clk       : in  std_logic;
            i_en        : in  std_logic;
            i_diamond_heigh : in std_logic_vector(16 downto 0);
            i_diamond_width : in std_logic_vector(16 downto 0);
            o_target_re : out std_logic_vector(17 downto 0);
            o_target_im : out std_logic_vector(17 downto 0)
        );
    end component;
    signal w_lfsr_target_re : std_logic_vector(17 downto 0);
    signal w_lfsr_target_im : std_logic_vector(17 downto 0);
    signal w_diamond_target_re : std_logic_vector(17 downto 0);
    signal w_diamond_target_im : std_logic_vector(17 downto 0);
    signal r_next_target_im : std_logic;
    signal r_next_target_re : std_logic;
    signal r_next_target_combined : std_logic;
    signal r_frames_per_step_counter : unsigned(15 downto 0);
    signal r_next_animation_step : std_logic;
    signal r_current_re : signed(17 downto 0);
    signal r_current_im : signed(17 downto 0);
    signal w_next_re_add : signed(17 downto 0);
    signal w_next_im_add : signed(17 downto 0);
    signal w_next_re_sub : signed(17 downto 0);
    signal w_next_im_sub : signed(17 downto 0);
    signal w_target_re : signed(17 downto 0);
    signal w_target_im : signed(17 downto 0);
begin
    LFSR_RE: Dynamic_LFSR
    generic map (
        g_WIDTH => 18
    )
    port map (
        i_clk       => i_clk,
        i_en        => r_next_target_re,
        i_load_en   => i_load_seed,
        i_load_data => i_lfsr_seed_re,
        i_xor_mask  => i_lfsr_xor_mask_re,
        o_data      => w_lfsr_target_re
    );
    LFSR_IM: Dynamic_LFSR
    generic map (
        g_WIDTH => 18
    )
    port map (
        i_clk       => i_clk,
        i_en        => r_next_target_im,
        i_load_en   => i_load_seed,
        i_load_data => i_lfsr_seed_im,
        i_xor_mask  => i_lfsr_xor_mask_im,
        o_data      => w_lfsr_target_im
    );
    DIA: Diamond
    port map (
        i_resetn        => i_resetn,
        i_clk           => i_clk,
        i_en            => r_next_target_combined,
        i_diamond_heigh => i_diamond_heigh,
        i_diamond_width => i_diamond_width,
        o_target_re     => w_diamond_target_re,
        o_target_im     => w_diamond_target_im
    );
	
    -- Counts the amount of frames (enables) and resets when the amount of frames per step is reached
    -- Sets r_next_animation_step for one clock cycle whenever the amount of frames is reached and the counter is reset
    FRAME_COUNTER: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_frames_per_step_counter <= (others => '0');
                r_next_animation_step <= '0'; -- Will be set first clock cycle after reset automatically
            else
                r_next_animation_step <= '0';
                if i_en = '1' then
                    if r_frames_per_step_counter = to_unsigned(0, 16) then
                        -- Overflow or reset happened
                        r_next_animation_step <= '1';
                    end if;
                    r_frames_per_step_counter <= r_frames_per_step_counter + 1;
                    if (i_frames_per_step = x"0000") or (r_frames_per_step_counter >= unsigned(i_frames_per_step) - 1) then
                        -- In case of the maximum target value this is not executed, but the overflow which will incure instead has the same effect
                        r_frames_per_step_counter <= (others => '0');
                    end if;
                end if;
			end if;
        end if;
    end process;

    -- Chose the target depending on the given mode
    w_target_re <= signed(w_diamond_target_re) when i_mode = '0' else signed(w_lfsr_target_re);
    w_target_im <= signed(w_diamond_target_im) when i_mode = '0' else signed(w_lfsr_target_im);

    -- Request next diamond target when target point is reached in both dimensions (faster dimension oscillates around the target)
    r_next_target_combined <= r_next_target_re and r_next_target_im;
    
    -- Calculates the next values
    w_next_re_add <= r_current_re + signed('0' & i_step_width);
    w_next_re_sub <= r_current_re - signed('0' & i_step_width);
    w_next_im_add <= r_current_im + signed('0' & i_step_width);
    w_next_im_sub <= r_current_im - signed('0' & i_step_width);

    -- Calculates the step towards the target
    STEP: process(i_clk)
	begin
        if rising_edge(i_clk) then
            r_next_target_re <= '0';
            r_next_target_im <= '0';
            if r_next_animation_step = '1' then
                -- RE step
                if w_target_re > r_current_re then
                    -- Step in positive direction if no overflow
                    if w_next_re_add >= r_current_re then
                        r_current_re <= w_next_re_add;
                    end if;
                    -- Target reached or overflow 
                    if (w_target_re <= w_next_re_add) or (w_next_re_add < r_current_re) then
                        -- Target reached or target unreachable because it is too near to an edge for the step width
                        r_next_target_re <= '1';
                    end if;
                else
                    -- Step in negative direction if no overflow
                    if w_next_re_sub <= r_current_re then
                        r_current_re <= w_next_re_sub;
                    end if;
                    -- Target reached or overflow 
                    if (w_target_re >= w_next_re_sub) or (w_next_re_sub > r_current_re) then
                        -- Target reached or target unreachable because it is too near to an edge for the step width
                        r_next_target_re <= '1';
                    end if;
                end if;
                -- IM step
                if w_target_im > r_current_im then
                    -- Step in positive direction if no overflow
                    if w_next_im_add >= r_current_im then
                        r_current_im <= w_next_im_add;
                    end if;
                    -- Target reached or overflow 
                    if (w_target_im <= w_next_im_add) or (w_next_im_add < r_current_im) then
                        -- Target reached or target unreachable because it is too near to an edge for the step width
                        r_next_target_im <= '1';
                    end if;
                else
                    -- Step in negative direction if no overflow
                    if w_next_im_sub <= r_current_im then
                        r_current_im <= w_next_im_sub;
                    end if;
                    -- Target reached or overflow 
                    if (w_target_im >= w_next_im_sub) or (w_next_im_sub > r_current_im) then
                        -- Target reached or target unreachable because it is too near to an edge for the step width
                        r_next_target_im <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Set outputs
    o_current_coord_re <= std_logic_vector(r_current_re);
    o_current_coord_im <= std_logic_vector(r_current_im);
    o_target_re <= std_logic_vector(w_target_re);
    o_target_im <= std_logic_vector(w_target_im);

end architecture;