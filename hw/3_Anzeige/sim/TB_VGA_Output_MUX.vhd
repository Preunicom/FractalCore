library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.finish;

entity TB_VGA_Output_MUX is
end TB_VGA_Output_MUX;

architecture Testbench of TB_VGA_Output_MUX is
    constant tbase : time := 10 ns;

    signal active : std_logic := '0';

    signal in_r : std_logic_vector(3 downto 0) := "1010";
    signal in_g : std_logic_vector(3 downto 0) := "0101";
    signal in_b : std_logic_vector(3 downto 0) := "1111";

    signal in_hsync : std_logic := '0';
    signal in_vsync : std_logic := '1';

    signal out_r : std_logic_vector(3 downto 0);
    signal out_g : std_logic_vector(3 downto 0);
    signal out_b : std_logic_vector(3 downto 0);

    signal out_hsync : std_logic;
    signal out_vsync : std_logic;

    signal tb_test_done : boolean := false;
    signal tb_test_passed : boolean := false;

begin

    uut: entity work.VGA_Output_MUX
        port map (
            i_video_active => active,
            i_red => in_r,
            i_green => in_g,
            i_blue => in_b,
            i_HSync => in_hsync,
            i_VSync => in_vsync,
            o_red => out_r,
            o_green => out_g,
            o_blue => out_b,
            o_HSync => out_hsync,
            o_VSync => out_vsync
        );

    STIMULI : process
    begin
        active <= '1';
        wait for tbase;

        assert out_r = in_r and out_g = in_g and out_b = in_b
            report "RGB wird bei active=1 nicht durchgereicht"
            severity failure;

        assert out_hsync = in_hsync and out_vsync = in_vsync
            report "Sync wird nicht durchgereicht"
            severity failure;

        active <= '0';
        wait for tbase;

        assert out_r = "0000" and out_g = "0000" and out_b = "0000"
            report "RGB wird bei active=0 nicht schwarz"
            severity failure;

        assert out_hsync = in_hsync and out_vsync = in_vsync
            report "Sync darf durch Blanking nicht veraendert werden"
            severity failure;

        report "TEST PASSED!" severity note;

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