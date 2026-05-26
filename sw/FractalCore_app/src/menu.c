// @author: Markus Remy
//
// UART-based configuration menu for FractalCore hardware.
// Navigation: digits 1-9 select, 'q' cancels/goes back.
//
// All register values are entered and displayed as raw unsigned factors.
// The factor is multiplied by the hardware's smallest step (1 LSB) to
// produce the actual value. Use hex input (e.g. 0x1FFFF) for precision.

/***************************** Include Files *******************************/
#include "menu.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xstatus.h"

// inbyte() provided by the Xilinx BSP
extern char inbyte(void);

/************************** Constant Definitions ***************************/

#define MENU_BUF_SIZE 32

/**************************** Type Definitions *****************************/

/************************** Variable Definitions ***************************/

/************************** Function Prototypes ****************************/
// Input helpers
char menu_getkey(void);
XStatus menu_read_line(char *buf, int max_len);
XStatus menu_parse_uint32(const char *buf, uint32_t *out);
XStatus menu_parse_hex32(const char *buf, uint32_t *out);
// Display helpers
// Menu screens
void menu_main(CTRL_Data *ctrl, COL_Data *col);
void menu_fractal_mode(CTRL_Data *ctrl);
void menu_animation_speed(CTRL_Data *ctrl);
void menu_stepwidth(CTRL_Data *ctrl);
void menu_zoom(CTRL_Data *ctrl);
void menu_lfsr(CTRL_Data *ctrl);
void menu_diamond(CTRL_Data *ctrl);
void menu_color(CTRL_Data *ctrl, COL_Data *col);
void menu_minimap(CTRL_Data *ctrl);
void menu_system_info(CTRL_Data *ctrl);
void menu_status(CTRL_Data *ctrl, COL_Data *col);
static XStatus menu_edit_color(COLOR_t *color);

/************************** Function Definitions ***************************/

// Entry point: prints a banner then enters the main menu loop.
void menu_run(CTRL_Data *ctrl, COL_Data *col) {
    xil_printf("\n\r");
    xil_printf("===================================\n\r");
    xil_printf("  FractalCore — Configuration Menu\n\r");
    xil_printf("===================================\n\r");
    xil_printf("  Press q at any time to go back\n\r");
    xil_printf("  or cancel.\n\r");
    xil_printf("===================================\n\r");
    menu_main(ctrl, col);
    xil_printf("Menu ended.\n\r");
}

// ================================================================
//  INPUT HELPERS
// ================================================================

char menu_getkey(void) {
    return (char)inbyte();
}

// Reads a line from UART into buf (max max_len chars, null-terminated).
// Returns XST_SUCCESS on Enter (accept), XST_FAILURE on 'q' or 'Q' (cancel).
// Echoes printable characters, handles backspace (\b or DEL 0x7F),
// and falls through with a truncated buffer if max_len is exceeded.
XStatus menu_read_line(char *buf, int max_len) {
    int i = 0;
    char c;
    while (i < max_len - 1) {
        c = menu_getkey();
        if (c == '\r' || c == '\n') {
            buf[i] = '\0';
            return XST_SUCCESS;
        } else if (c == 'q' || c == 'Q') {
            buf[i] = '\0';
            return XST_FAILURE;
        } else if (c == '\b' || c == 127) { 
            // Backspace
            if (i > 0) {
                i--;
                xil_printf("\b \b");
            }
        } else if (c >= ' ') {
            buf[i++] = c;
            xil_printf("%c", c);
        }
    }
    buf[i] = '\0';
    xil_printf("\n\r");
    return XST_SUCCESS;
}

// Parse a decimal number from buf. Returns XST_SUCCESS on success, XST_FAILURE on failure.
XStatus menu_parse_uint32(const char *buf, uint32_t *out) {
    uint32_t val = 0;
    const char *p = buf;
    if (*p == '\0') return XST_FAILURE; // Empty String
    while (*p >= '0' && *p <= '9') {
        val = val * 10 + (uint32_t)(*p - '0');
        p++;
    }
    if (*p != '\0') return XST_FAILURE;
    *out = val;
    return XST_SUCCESS;
}

// Parse a string hex number (with or without 0x prefix). Returns XST_SUCCESS on success, XST_FAILURE otherwise.
// Assumes the buf is \0 terminated
XStatus menu_parse_hex32(const char *buf, uint32_t *out) {
    uint32_t val = 0;
    const char *p = buf;
    if (*p == '\0') return XST_FAILURE; // Emtpy String
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) p += 2;
    while ((*p >= '0' && *p <= '9') ||
           (*p >= 'a' && *p <= 'f') ||
           (*p >= 'A' && *p <= 'F')) {
        val <<= 4;
        if (*p >= '0' && *p <= '9')      val |= (uint32_t)(*p - '0');
        else if (*p >= 'a' && *p <= 'f') val |= (uint32_t)(*p - 'a' + 10);
        else if (*p >= 'A' && *p <= 'F') val |= (uint32_t)(*p - 'A' + 10);
        p++;
    }
    if (*p != '\0') return XST_FAILURE;
    *out = val;
    return XST_SUCCESS;
}

// Prompt the user for a decimal unsigned integer in [min, max].
// Loops until valid input or 'q' (returns XST_FAILURE on cancel).
XStatus menu_read_uint32(uint32_t *out, uint32_t min, uint32_t max) {
    char buf[MENU_BUF_SIZE];
    uint32_t val;
    while (1) {
        xil_printf("  >> ");
        if (menu_read_line(buf, sizeof(buf)) != XST_SUCCESS) {
            xil_printf("  Cancelled.\n\r");
            return XST_FAILURE;
        }
        if (menu_parse_uint32(buf, &val) != XST_SUCCESS) {
            xil_printf("  Error: Invalid decimal number.\n\r");
            continue;
        }
        if (val < min || val > max) {
            xil_printf("  Error: Value must be between %lu and %lu.\n\r", min, max);
            continue;
        }
        *out = val;
        return XST_SUCCESS;
    }
}

// Prompt the user for a hex number in [min, max]. Loops until valid or 'q' (returns XST_FAILURE on cancel).
XStatus menu_read_hex32(uint32_t *out, uint32_t min, uint32_t max) {
    char buf[MENU_BUF_SIZE];
    uint32_t val;
    while (1) {
        xil_printf("  >> ");
        if (menu_read_line(buf, sizeof(buf)) != XST_SUCCESS) {
            xil_printf("  Cancelled.\n\r");
            return XST_FAILURE;
        }
        if (menu_parse_hex32(buf, &val) != XST_SUCCESS) {
            xil_printf("  Error: Invalid hex number (e.g. 0x1A3B7).\n\r");
            continue;
        }
        if (val < min || val > max) {
            xil_printf("  Error: Value must be between 0x%lX and 0x%lX.\n\r", min, max);
            continue;
        }
        *out = val;
        return XST_SUCCESS;
    }
}

// Prompt for R, G, B values (each 0-255). Returns XST_FAILURE if any prompt is cancelled.
XStatus menu_read_rgb(uint8_t *r, uint8_t *g, uint8_t *b) {
    uint32_t val;
    xil_printf("  Red (0-255): ");
    if (menu_read_uint32(&val, 0, 255) != XST_SUCCESS) return XST_FAILURE;
    *r = (uint8_t)val;
    xil_printf("  Green (0-255): ");
    if (menu_read_uint32(&val, 0, 255) != XST_SUCCESS) return XST_FAILURE;
    *g = (uint8_t)val;
    xil_printf("  Blue (0-255): ");
    if (menu_read_uint32(&val, 0, 255) != XST_SUCCESS) return XST_FAILURE;
    *b = (uint8_t)val;
    return XST_SUCCESS;
}

// ================================================================
//  EDIT COLOR
//  Prompts user for new R/G/B values, updates *color on success.
//  No hardware access — caller owns the get/set via driver.
// ================================================================

static XStatus menu_edit_color(COLOR_t *color) {
    xil_printf("Current color: R=%u G=%u B=%u\n\r",
        color->red, color->green, color->blue);
    xil_printf("  New color (q=cancel):\n\r");
    uint8_t red, green, blue;
    if (menu_read_rgb(&red, &green, &blue) != XST_SUCCESS) return XST_FAILURE;
    color->red = red;
    color->green = green;
    color->blue = blue;
    xil_printf("  Color set: R=%u G=%u B=%u\n\r",
        color->red, color->green, color->blue);
    return XST_SUCCESS;
}

// ================================================================
//  MENUS
// ================================================================

// ----------------------------------------------------------------
//  MAIN MENU
//  Top-level menu: dispatch to all submenus.
// ----------------------------------------------------------------
void menu_main(CTRL_Data *ctrl, COL_Data *col) {
    char c;
    while (1) {
        xil_printf("\n\r");
        xil_printf("===================================\n\r");
        xil_printf("  Main Menu\n\r");
        xil_printf("===================================\n\r");
        xil_printf("  1 - Fractal Mode\n\r");
        xil_printf("  2 - Animation Speed\n\r");
        xil_printf("  3 - Step Width\n\r");
        xil_printf("  4 - Zoom\n\r");
        xil_printf("  5 - LFSR Settings\n\r");
        xil_printf("  6 - Diamond Settings\n\r");
        xil_printf("  7 - Color Settings\n\r");
        xil_printf("  8 - Minimap\n\r");
        xil_printf("  9 - System Info\n\r");
        xil_printf("  0 - Show All Settings\n\r");
        xil_printf("-----------------------------------\n\r");
        xil_printf("  q - Exit\n\r");
        xil_printf("===================================\n\r");
        xil_printf("Choice: ");

        c = menu_getkey();
        xil_printf("\n\r");
        switch (c) {
            case '1': menu_fractal_mode(ctrl); break;
            case '2': menu_animation_speed(ctrl); break;
            case '3': menu_stepwidth(ctrl); break;
            case '4': menu_zoom(ctrl); break;
            case '5': menu_lfsr(ctrl); break;
            case '6': menu_diamond(ctrl); break;
            case '7': menu_color(ctrl, col); break;
            case '8': menu_minimap(ctrl); break;
            case '9': menu_system_info(ctrl); break;
            case '0': menu_status(ctrl, col); break;
            case 'q': case 'Q': return;
            default:
                xil_printf("Invalid input.\n\r");
                break;
        }
    }
}

// ----------------------------------------------------------------
//  FRACTAL MODE
//  Selects Mandelbrot, Julia Diamond, or Julia LFSR via SETCR.
// ----------------------------------------------------------------
void menu_fractal_mode(CTRL_Data *ctrl) {
    char c;
    while (1) {
        uint32_t mode = CTRL_GetMode(ctrl);
        const char *mode_str; // Const data
        if (mode == SETCR_JULIA_DIAMOND_MODE_MASK) {
            mode_str = "Julia Diamond";
        } else if (mode == SETCR_JULIA_LFSR_MODE_MASK) {
            mode_str = "Julia LFSR";
        } else { // 1X --> 10 or 11
            mode_str = "Mandelbrot";
        }

        xil_printf("\n\r");
        xil_printf("===== Fractal Mode =====\n\r");
        xil_printf("Current: %s\n\r", mode_str);
        xil_printf(" 1 - Mandelbrot\n\r");
        xil_printf(" 2 - Julia Diamond\n\r");
        xil_printf(" 3 - Julia LFSR\n\r");
        xil_printf(" q - Back\n\r");
        xil_printf("==========================\n\r");
        xil_printf("Choice: ");

        c = menu_getkey();
        xil_printf("\n\r");
        switch (c) {
            case '1':
                CTRL_SetMandelbrotMode(ctrl);
                xil_printf("Mode: Mandelbrot\n\r");
                break;
            case '2':
                CTRL_SetJuliaDiamondMode(ctrl);
                xil_printf("Mode: Julia Diamond\n\r");
                break;
            case '3':
                CTRL_SetJuliaLfsrMode(ctrl);
                xil_printf("Mode: Julia LFSR\n\r");
                break;
            case 'q': case 'Q': return;
            default:
                xil_printf("Invalid input.\n\r");
                break;
        }
    }
}

// ----------------------------------------------------------------
//  ANIMATION SPEED
//  Sets SPECR (Animation Speed Register), 0-65535.
// ----------------------------------------------------------------
void menu_animation_speed(CTRL_Data *ctrl) {
    uint32_t current = CTRL_GetAnimationSpeed(ctrl);
    uint32_t val;
    xil_printf("\n\r");
    xil_printf("===== Animation Speed =====\n\r");
    xil_printf("Current: %lu frames per animation step\n\r", current);
    xil_printf("New value (0-65535, q=cancel):\n\r");
    if (menu_read_uint32(&val, 0, 65535) != XST_SUCCESS) return;
    CTRL_SetAnimationSpeed(ctrl, val);
    xil_printf("Animation Speed = %lu\n\r", val);
}

// ----------------------------------------------------------------
//  STEP WIDTH
//  Sets CSWCR (Step Width factor).
// ----------------------------------------------------------------
void menu_stepwidth(CTRL_Data *ctrl) {
    uint32_t sw = CTRL_GetStepWidth(ctrl);
    uint32_t val;
    xil_printf("\n\r");
    xil_printf("===== Step Width =====\n\r");
    xil_printf("Current: %lu (0x%05lX)\n\r", sw, sw);
    xil_printf("New step width factor (Hex 0x00000-0x1FFFF, q=cancel):\n\r");
    if (menu_read_hex32(&val, 0, 0x1FFFF) != XST_SUCCESS) return;
    CTRL_SetStepWidth(ctrl, val & 0x1FFFF);
    xil_printf("Step width factor = %lu (0x%05lX)\n\r", val, val);
}

// ----------------------------------------------------------------
//  ZOOM
//  Sets ZOMCR (Pixel Distance).
// ----------------------------------------------------------------
void menu_zoom(CTRL_Data *ctrl) {
    uint32_t dist = CTRL_GetPixelDistance(ctrl);
    uint32_t val;
    xil_printf("\n\r");
    xil_printf("===== Zoom =====\n\r");
    xil_printf("Current pixel distance factor: %lu\n\r", dist);
    xil_printf("New pixel distance factor (1-255, q=cancel):\n\r");
    if (menu_read_uint32(&val, 1, 255) != XST_SUCCESS) return;
    CTRL_SetPixelDistance(ctrl, val);
    xil_printf("Pixel distance = %lu\n\r", val);
}

// ----------------------------------------------------------------
//  LFSR SETTINGS
//  XOR masks (XMRCR/XMICR, 17-bit hex) and seeds (LSRCR/LSICR, raw factor).
//  Seeds must be explicitly loaded into hardware via option 5.
// ----------------------------------------------------------------
void menu_lfsr(CTRL_Data *ctrl) {
    char c;
    while (1) {
        uint32_t xor_re = CTRL_GetXorMaskLfsrRe(ctrl);
        uint32_t xor_im = CTRL_GetXorMaskLfsrIm(ctrl);
        uint32_t seed_re = CTRL_GetSeedLfsrRe(ctrl);
        uint32_t seed_im = CTRL_GetSeedLfsrIm(ctrl);

        xil_printf("\n\r");
        xil_printf("===== LFSR Settings =====\n\r");
        xil_printf("  XOR mask Real:  0x%05lX\n\r", xor_re);
        xil_printf("  XOR mask Imag:  0x%05lX\n\r", xor_im);
        xil_printf("  Seed Real factor: %lu (0x%05lX)\n\r", seed_re, seed_re);
        xil_printf("  Seed Imag factor: %lu (0x%05lX)\n\r", seed_im, seed_im);
        xil_printf(" 1 - XOR mask Real\n\r");
        xil_printf(" 2 - XOR mask Imag\n\r");
        xil_printf(" 3 - Seed Real\n\r");
        xil_printf(" 4 - Seed Imag\n\r");
        xil_printf(" 5 - Load seeds into hardware\n\r");
        xil_printf(" q - Back\n\r");
        xil_printf("===============================\n\r");
        xil_printf("Choice: ");

        c = menu_getkey();
        xil_printf("\n\r");
        switch (c) {
            case '1': {
                uint32_t val;
                xil_printf("Current: 0x%05lX\n\rNew XOR mask Real (Hex 0x00000-0x1FFFF, q=cancel):\n\r", xor_re);
                if (menu_read_hex32(&val, 0, 0x1FFFF) == XST_SUCCESS) {
                    CTRL_SetXorMaskLfsrRe(ctrl, val);
                    xil_printf("XOR mask Real = 0x%05lX\n\r", val);
                }
                break;
            }
            case '2': {
                uint32_t val;
                xil_printf("Current: 0x%05lX\n\rNew XOR mask Imag (Hex 0x00000-0x1FFFF, q=cancel):\n\r", xor_im);
                if (menu_read_hex32(&val, 0, 0x1FFFF) == XST_SUCCESS) {
                    CTRL_SetXorMaskLfsrIm(ctrl, val);
                    xil_printf("XOR mask Imag = 0x%05lX\n\r", val);
                }
                break;
            }
            case '3': {
                uint32_t val;
                xil_printf("Current: %lu (0x%05lX)\n\rNew Seed Real (Hex 0x00000-0x3FFFF, q=cancel):\n\r", seed_re, seed_re);
                if (menu_read_hex32(&val, 0, 0x3FFFF) == XST_SUCCESS) {
                    CTRL_SetSeedLfsrRe(ctrl, val & 0x3FFFF);
                    xil_printf("Seed Real = %lu (0x%05lX)\n\r", val, val);
                }
                break;
            }
            case '4': {
                uint32_t val;
                xil_printf("Current: %lu (0x%05lX)\n\rNew Seed Imag (Hex 0x00000-0x3FFFF, q=cancel):\n\r", seed_im, seed_im);
                if (menu_read_hex32(&val, 0, 0x3FFFF) == XST_SUCCESS) {
                    CTRL_SetSeedLfsrIm(ctrl, val & 0x3FFFF);
                    xil_printf("Seed Imag = %lu (0x%05lX)\n\r", val, val);
                }
                break;
            }
            case '5':
                CTRL_LoadLfsrSeeds(ctrl);
                xil_printf("LFSR seeds loaded into hardware.\n\r");
                break;
            case 'q': case 'Q': return;
            default:
                xil_printf("Invalid input.\n\r");
                break;
        }
    }
}

// ----------------------------------------------------------------
//  DIAMOND SETTINGS
//  Sets DWCR (Width) and DHCR (Height), raw factor.
// ----------------------------------------------------------------
void menu_diamond(CTRL_Data *ctrl) {
    char c;
    while (1) {
        uint32_t dw = CTRL_GetDiamondWidth(ctrl);
        uint32_t dh = CTRL_GetDiamondHeight(ctrl);

        xil_printf("\n\r");
        xil_printf("===== Diamond Settings =====\n\r");
        xil_printf("  Width factor:  %lu (0x%05lX)\n\r", dw, dw);
        xil_printf("  Height factor: %lu (0x%05lX)\n\r", dh, dh);
        xil_printf(" 1 - Diamond Width (factor)\n\r");
        xil_printf(" 2 - Diamond Height (factor)\n\r");
        xil_printf(" q - Back\n\r");
        xil_printf("===============================\n\r");
        xil_printf("Choice: ");

        c = menu_getkey();
        xil_printf("\n\r");
        switch (c) {
            case '1': {
                uint32_t val;
                xil_printf("Current: %lu (0x%05lX)\n\rNew width factor (Hex 0x00000-0x1FFFF, q=cancel):\n\r", dw, dw);
                if (menu_read_hex32(&val, 0, 0x1FFFF) == XST_SUCCESS) {
                    CTRL_SetDiamondWidth(ctrl, val & 0x1FFFF);
                    xil_printf("Diamond width factor = %lu (0x%05lX)\n\r", val, val);
                }
                break;
            }
            case '2': {
                uint32_t val;
                xil_printf("Current: %lu (0x%05lX)\n\rNew height factor (Hex 0x00000-0x1FFFF, q=cancel):\n\r", dh, dh);
                if (menu_read_hex32(&val, 0, 0x1FFFF) == XST_SUCCESS) {
                    CTRL_SetDiamondHeight(ctrl, val & 0x1FFFF);
                    xil_printf("Diamond height factor = %lu (0x%05lX)\n\r", val, val);
                }
                break;
            }
            case 'q': case 'Q': return;
            default:
                xil_printf("Invalid input.\n\r");
                break;
        }
    }
}

// ----------------------------------------------------------------
//  COLOR
//  Edit iteration colors (COL_ITER_BASE_ADDR_OFFSET_START + iter*4),
//  convergent pixel color (COL_CONV_ADDR_OFFSET),
//  minimap target/pixel colors (COL_MINIMAP_*_ADDR_OFFSET).
// ----------------------------------------------------------------
void menu_color(CTRL_Data *ctrl, COL_Data *col) {
    char c;
    while (1) {
        xil_printf("\n\r");
        xil_printf("===== Color Palette =====\n\r");
        xil_printf(" 1 - Set iteration color (0-100)\n\r");
        xil_printf(" 2 - Convergent color\n\r");
        xil_printf(" 3 - Minimap target color\n\r");
        xil_printf(" 4 - Minimap pixel color\n\r");
        xil_printf(" q - Back\n\r");
        xil_printf("========================\n\r");
        xil_printf("Choice: ");

        c = menu_getkey();
        xil_printf("\n\r");
        switch (c) {
            case '1': {
                uint32_t iteration;
                COLOR_t color;
                xil_printf("Iteration index (0-255, q=cancel):\n\r");
                if (menu_read_uint32(&iteration, 0, 255) != XST_SUCCESS) break;
                COL_GetIterationColor(col, (uint8_t)iteration, &color);
                if (menu_edit_color(&color) == XST_SUCCESS)
                    COL_SetIterationColor(col, (uint8_t)iteration, &color);
                break;
            }
            case '2': {
                COLOR_t color;
                xil_printf("Set convergent pixel color:\n\r");
                COL_GetConvergentColor(col, &color);
                if (menu_edit_color(&color) == XST_SUCCESS)
                    COL_SetConvergentColor(col, &color);
                break;
            }
            case '3': {
                COLOR_t color;
                xil_printf("Set minimap target color:\n\r");
                COL_GetTargetMinimapColor(col, &color);
                if (menu_edit_color(&color) == XST_SUCCESS)
                    COL_SetTargetMinimapColor(col, &color);
                break;
            }
            case '4': {
                COLOR_t color;
                xil_printf("Set current minimap pixel color:\n\r");
                COL_GetCurrentMinimapColor(col, &color);
                if (menu_edit_color(&color) == XST_SUCCESS)
                    COL_SetCurrentMinimapColor(col, &color);
                break;
            }
            case 'q': case 'Q': return;
            default:
                xil_printf("Invalid input.\n\r");
                break;
        }
    }
}

// ----------------------------------------------------------------
//  MINIMAP
//  Toggle minimap enable/disable via CTRL SETCR_MME bit.
// ----------------------------------------------------------------
void menu_minimap(CTRL_Data *ctrl) {
    uint32_t state = CTRL_GetMinimapState(ctrl);
    xil_printf("\n\r");
    xil_printf("===== Minimap =====\n\r");
    xil_printf("Current: %s\n\r", state ? "On" : "Off");
    xil_printf(" 1 - On\n\r");
    xil_printf(" 2 - Off\n\r");
    xil_printf(" q - Back\n\r");
    xil_printf("====================\n\r");
    xil_printf("Choice: ");

    char c = menu_getkey();
    xil_printf("\n\r");
    switch (c) {
        case '1':
            CTRL_SetMinimapEnable(ctrl, 1);
            xil_printf("Minimap enabled.\n\r");
            break;
        case '2':
            CTRL_SetMinimapEnable(ctrl, 0);
            xil_printf("Minimap disabled.\n\r");
            break;
        case 'q': case 'Q': break;
        default:
            xil_printf("Invalid input.\n\r");
            break;
    }
}

// ----------------------------------------------------------------
//  SYSTEM INFO
//  Read-only: displays CTRL hardware ID (IDR) and version (VERR).
// ----------------------------------------------------------------
void menu_system_info(CTRL_Data *ctrl) {
    xil_printf("\n\r");
    xil_printf("===== System Info =====\n\r");
    xil_printf(" ID: 0x%08lX\n\r", CTRL_GetId(ctrl));
    xil_printf(" Version: 0x%08lX\n\r", CTRL_GetVersion(ctrl));
    xil_printf("========================\n\r");
}

// ----------------------------------------------------------------
//  ALL SETTINGS DISPLAY
//  Read-only: dumps every CTRL register value at once.
// ----------------------------------------------------------------
void menu_status(CTRL_Data *ctrl, COL_Data *col) {
    uint32_t mode = CTRL_GetMode(ctrl);
    const char *mode_str;
    if (mode == SETCR_JULIA_DIAMOND_MODE_MASK) {
        mode_str = "Julia Diamond";
    } else if (mode == SETCR_JULIA_LFSR_MODE_MASK) {
        mode_str = "Julia LFSR";
    } else { // 1X --> 10 or 11
        mode_str = "Mandelbrot";
    }

    uint32_t mm_state = CTRL_GetMinimapState(ctrl);
    uint32_t speed = CTRL_GetAnimationSpeed(ctrl);
    uint32_t dist = CTRL_GetPixelDistance(ctrl);
    uint32_t xor_re = CTRL_GetXorMaskLfsrRe(ctrl);
    uint32_t xor_im = CTRL_GetXorMaskLfsrIm(ctrl);
    uint32_t sw = CTRL_GetStepWidth(ctrl);
    uint32_t seed_re = CTRL_GetSeedLfsrRe(ctrl);
    uint32_t seed_im = CTRL_GetSeedLfsrIm(ctrl);
    uint32_t dw = CTRL_GetDiamondWidth(ctrl);
    uint32_t dh = CTRL_GetDiamondHeight(ctrl);

    xil_printf("\n\r");
    xil_printf("===== All Settings =====\n\r");
    xil_printf("  Mode:                      %s\n\r", mode_str);
    xil_printf("  Frames per animation step: %lu\n\r", speed);
    xil_printf("  Step width factor:         %lu\n\r", sw);
    xil_printf("  Pixel distance:            %lu\n\r", dist);
    xil_printf("  XOR mask Real:             0x%05lX\n\r", xor_re);
    xil_printf("  XOR mask Imag:             0x%05lX\n\r", xor_im);
    xil_printf("  Seed Real factor:          %lu (0x%05lX)\n\r", seed_re, seed_re);
    xil_printf("  Seed Imag factor:          %lu (0x%05lX)\n\r", seed_im, seed_im);
    xil_printf("  Diamond width factor:      %lu\n\r", dw);
    xil_printf("  Diamond height factor:     %lu\n\r", dh);
    xil_printf("  Minimap:                   %s\n\r", mm_state ? "On" : "Off");
    xil_printf("================================\n\r");
}
