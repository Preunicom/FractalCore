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
    signal r_data_buffer : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal w_use_data_buffer : std_logic := '0';
    signal w_write_data_buffer : std_logic := '0';
begin

    -- Control path

    CONTROL_FSM_STATE: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                r_state <= s_IDLE;
            else
                r_state <= w_next_state;
            end if;
        end if;
    end process;

    CONTROL_FSM_TRANSITION: process(r_state, i_valid, i_ready)
    begin
        w_next_state <= r_state;
        o_ready <= '1';
        o_valid <= '1';
        w_write_data_buffer <= '1';
        w_use_data_buffer <= '0';
        case r_state is
            when s_IDLE =>
                if i_valid = '1' then
                    w_next_state <= s_FLOW;
                    o_valid <= '0';
                else
                    o_valid <= '0';
                end if;
            when s_FLOW =>
                if i_valid = '1' and i_ready = '0' then
                    w_next_state <= s_BACKPRESSURE;
                    o_ready <= '0';
                    w_write_data_buffer <= '0';
                    w_use_data_buffer <= '1';
                elsif i_valid = '0' and i_ready = '1' then
                    w_next_state <= s_IDLE;
                    o_valid <= '1';
                end if;
            when s_BACKPRESSURE =>
                if i_ready = '1' then
                    w_next_state <= s_FLOW;
                else
                    o_ready <= '0';
                    w_write_data_buffer <= '0';
                    w_use_data_buffer <= '1';
                end if;
            when others => null;
        end case;
    end process;

    -- Datapath

    REG: process(i_clk)
	begin
        if rising_edge(i_clk) then
            if i_resetn = '0' then
                o_data <= (others => '0');
                r_data_buffer <= (others => '0');
            else
                if w_write_data_buffer = '1' then
                    r_data_buffer <= i_data;
                end if;
                if w_use_data_buffer = '1' then
                    o_data <= r_data_buffer;
                else
                    o_data <= i_data;
                end if;
            end if;
        end if;
    end process;
   
end Behavioral;