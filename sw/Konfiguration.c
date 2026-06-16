/* 
-- Company: OTH Regensburg
-- Engineer: Thomas Schiergl
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: Konfiguration
-- Project Name: FractalCore
-- Target Devices: Arty A7 100T
-- Tool Versions: 2023.2
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
*/

#include <string.h>

#include "color_config_driver.h"

#define COLOR_BASEADDR TOP_FARBCODIERUNG_0_S_AXI_BASEADDR

#define CMD_BUFFER_SIZE 32

static void print_help(void)
{
    xil_printf("\r\n");
    xil_printf("=== FractalCore Farbschema-Konsole ===\r\n");
    xil_printf("0/gray   Graustufen\r\n");
    xil_printf("1/color  Blau-Gruen-Gelb-Rot\r\n");
    xil_printf("2/bw     Schwarz/Weiss\r\n");
    xil_printf("3/fire   Fire-Style\r\n");
    xil_printf("read     Aktuelles Farbschema lesen\r\n");
    xil_printf("help     Hilfe anzeigen\r\n\r\n");
}

static void read_line(char *buffer, unsigned int max_len)
{
    unsigned int index = 0;
    char c;

    while (1)
    {
        c = inbyte();

        if (c == '\r' || c == '\n')
        {
            buffer[index] = '\0';
            xil_printf("\r\n");
            return;
        }

        if ((c == '\b' || c == 0x7F) && index > 0)
        {
            index--;
            xil_printf("\b \b");
            continue;
        }

        if (index < max_len - 1)
        {
            buffer[index++] = c;
            xil_printf("%c", c);
        }
    }
}

static void set_scheme(uint32_t scheme)
{
    ColorConfig_SetScheme(COLOR_BASEADDR, scheme);

    xil_printf("Farbschema gesetzt: %s (%lu)\r\n",
               ColorConfig_GetSchemeName(scheme),
               (unsigned long)(scheme & COLOR_CONFIG_SCHEME_MASK));
}

static void print_current_scheme(void)
{
    uint32_t scheme = ColorConfig_GetScheme(COLOR_BASEADDR);

    xil_printf("Aktives Farbschema: %s (%lu)\r\n",
               ColorConfig_GetSchemeName(scheme),
               (unsigned long)scheme);
}

static void handle_command(const char *cmd)
{
    if (strcmp(cmd, "0") == 0 || strcmp(cmd, "gray") == 0)
        set_scheme(COLOR_SCHEME_GRAY);
    else if (strcmp(cmd, "1") == 0 || strcmp(cmd, "color") == 0)
        set_scheme(COLOR_SCHEME_COLOR);
    else if (strcmp(cmd, "2") == 0 || strcmp(cmd, "bw") == 0)
        set_scheme(COLOR_SCHEME_BW);
    else if (strcmp(cmd, "3") == 0 || strcmp(cmd, "fire") == 0)
        set_scheme(COLOR_SCHEME_FIRE);
    else if (strcmp(cmd, "read") == 0 || strcmp(cmd, "r") == 0)
        print_current_scheme();
    else if (strcmp(cmd, "help") == 0 || strcmp(cmd, "h") == 0 || strcmp(cmd, "?") == 0)
        print_help();
    else if (strcmp(cmd, "") != 0)
        xil_printf("Unbekannter Befehl. Tippe 'help'.\r\n");
}

int main(void)
{
    char command[CMD_BUFFER_SIZE];

    xil_printf("\r\nFractalCore Konfiguration gestartet\r\n");

    set_scheme(COLOR_SCHEME_GRAY);
    print_help();

    while (1)
    {
        xil_printf("fractal> ");
        read_line(command, CMD_BUFFER_SIZE);
        handle_command(command);
    }

    return 0;
}