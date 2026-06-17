library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;

entity TB_Farbcodierung is
end TB_Farbcodierung;

architecture Testbench of TB_Farbcodierung is
    constant DATA_WIDTH : integer := 9;
    constant tbase : time := 10 ns;

    signal i_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal i_color_scheme : std_logic_vector(1 downto 0) := "00";

    signal o_red   : std_logic_vector(3 downto 0);
    signal o_green : std_logic_vector(3 downto 0);
    signal o_blue  : std_logic_vector(3 downto 0);

    signal tb_test_done : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    uut: entity work.Farbcodierung
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            i_data => i_data,
            i_color_scheme => i_color_scheme,
            o_red => o_red,
            o_green => o_green,
            o_blue => o_blue
        );

    STIMULI : process
        procedure check_color(
            constant data_in : in std_logic_vector(8 downto 0);
            constant scheme  : in std_logic_vector(1 downto 0);
            constant exp_r   : in std_logic_vector(3 downto 0);
            constant exp_g   : in std_logic_vector(3 downto 0);
            constant exp_b   : in std_logic_vector(3 downto 0);
            constant msg     : in string
        ) is
        begin
            i_data <= data_in;
            i_color_scheme <= scheme;
            wait for tbase;

        end procedure;
    begin
        check_color('0' & x"00", "00", "0000", "0000", "0000", "Graustufen 0 falsch");
        check_color('0' & x"F0", "00", "1111", "1111", "1111", "Graustufen F0 falsch");

        check_color('0' & x"10", "01", "0000", "1000", "1111", "Farbschema 01 Wert 16 falsch");
        check_color('0' & x"40", "01", "0000", "1111", "0000", "Farbschema 01 Wert 64 falsch");

        check_color('0' & x"00", "10", "0000", "0000", "0000", "Schwarz/Weiss 0 falsch");
        check_color('0' & x"01", "10", "1111", "1111", "1111", "Schwarz/Weiss 1 falsch");

        check_color('0' & x"40", "11", "1111", "0000", "0000", "Fire 64 falsch");
        check_color('0' & x"80", "11", "1111", "1111", "0000", "Fire 128 falsch");

        check_color('1' & x"55", "00", "1111", "1111", "1111", "Highlight Weiss falsch");
        check_color('1' & x"55", "01", "1111", "0000", "1111", "Highlight Magenta falsch");
        check_color('1' & x"55", "10", "0000", "1111", "1111", "Highlight Cyan falsch");
        check_color('1' & x"55", "11", "1111", "1111", "0000", "Highlight Gelb falsch");

        wait for 20 us;

        tb_test_done <= true;
        wait;
    end process;

    CHECK_PROC : process
    begin
        wait until tb_test_done = true;

        report "TEST PASSED!" severity note;
        tb_test_passed <= true;

        wait for tbase;
        finish;
    end process;

    TIMEOUT_PROC : process
    begin
        wait for 100*640*480*tbase;

        if tb_test_passed = false then
            assert false
                report "TEST TIMED OUT!"
                severity failure;
        end if;

        wait;
    end process;

end Testbench;