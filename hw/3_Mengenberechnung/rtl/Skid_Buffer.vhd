----------------------------------------------------------------------------------
-- Company: OTH Regensburg
-- Engineer: Markus Remy
-- 
-- Create Date: 03/30/2026 6:09:00 PM
-- Design Name: 
-- Module Name: Skid_Buffer - Behavioral
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: Pipelines data with backpressure. Also pipelines all control paths.
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

-- This entity pipelines all signals (also the control signals) of AXI Stream data.
-- It buffers the data if the slave is unexpectedly not ready for it.
entity Skid_Buffer is
    generic(
        g_DATA_WIDTH : natural 
    );
    port(
        i_resetn : in std_logic;
        i_clk : in std_logic;
        -- Input
        i_valid : in std_logic;
        i_data : in std_logic_vector(g_DATA_WIDTH - 1 downto 0);
        o_ready : out std_logic;
        -- Output 1
        i_ready : in std_logic;
        o_valid : out std_logic;
        o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)
    );
end Skid_Buffer;

architecture Behavioral of Skid_Buffer is
    -- Control path
    type t_state_type is (s_IDLE, s_FLOW, s_BACKPRESSURE); 
    signal r_state, w_next_state : t_state_type;
    -- Data path
    signal r_buffer : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal w_output_write_en : std_logic;
    signal w_buffer_write_en : std_logic;
    -- Support signals
    signal w_is_read_handshake : std_logic;
    signal w_is_write_handshake : std_logic;
    signal w_ready : std_logic;
    signal w_valid : std_logic;
begin

    -- Support signals

    w_is_read_handshake <= i_valid and w_ready;
    w_is_write_handshake <= i_ready and w_valid;
    o_ready <= w_ready;
    o_valid <= w_valid;

    -- Control path

    FSM_OUTPUT_AND_STATE_REG: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_state <= s_IDLE;
                w_valid <= '0';
                w_ready <= '1';
            else
                r_state <= w_next_state;
                -- Registered control path outputs
                if w_next_state /= s_BACKPRESSURE then
                    w_ready <= '1';
                else
                    w_ready <= '0';
                end if;
                if w_next_state /= s_IDLE then
                    w_valid <= '1';
                else
                    w_valid <= '0';
                end if;
            end if;
        end if;
    end process;

    NEXT_STATE_LOGIC: process(r_state, w_is_read_handshake, w_is_write_handshake)
    begin
        w_next_state <= r_state;
        case r_state is
            when s_IDLE =>
                if w_is_read_handshake = '1' then
                    w_next_state <= s_FLOW;
                end if;
            when s_FLOW =>
                if w_is_read_handshake = '1' and w_is_write_handshake = '0' then
                    w_next_state <= s_BACKPRESSURE;
                elsif w_is_read_handshake = '0' and w_is_write_handshake = '1' then
                    w_next_state <= s_IDLE;
                end if;
            when s_BACKPRESSURE =>
                if w_is_write_handshake = '1' then
                    w_next_state <= s_FLOW;
                end if;
            when others => null;
        end case;
    end process;

    BUF_CONTROL: process(r_state, w_is_read_handshake, w_is_write_handshake)
	begin
        w_buffer_write_en <= '0';
        w_output_write_en <= '0';
        if r_state = s_FLOW and w_is_read_handshake = '1' and w_is_write_handshake = '0' then
            w_buffer_write_en <= '1';
        end if;
        if ((r_state = s_IDLE and w_is_read_handshake = '1' and w_is_write_handshake = '0') 
        or (r_state = s_FLOW and w_is_read_handshake = '1' and w_is_write_handshake = '1')
        or (r_state = s_BACKPRESSURE and w_is_read_handshake = '0' and w_is_write_handshake = '1')) then
            w_output_write_en <= '1';
        end if;

    end process;

    -- Datapath

    BUF: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_data <= (others => '0');
                r_buffer <= (others => '0');
            else
                if w_output_write_en = '1' then
                    if r_state = s_BACKPRESSURE then
                        o_data <= r_buffer;
                    else
                        o_data <= i_data;
                    end if;
                end if;
                if w_buffer_write_en = '1' then
                    r_buffer <= i_data;
                end if;
            end if;
        end if;
    end process;
   
end Behavioral;