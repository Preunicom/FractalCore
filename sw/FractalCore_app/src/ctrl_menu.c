// @author: Markus Remy
//
// UART-based configuration menu for FractalCore hardware.
// Navigation: digits 1-9 select, 'q' cancels/goes back.
//
// All register values are entered and displayed as raw unsigned factors.
// The factor is multiplied by the hardware's smallest step (1 LSB) to
// produce the actual value. Use hex input (e.g. 0x1FFFF) for precision.

/***************************** Include Files *******************************/
#include "ctrl_menu.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xstatus.h"

// inbyte() provided by the Xilinx BSP
extern char inbyte(void);

/************************** Constant Definitions ***************************/

#define MENU_BUF_SIZE 32

/**************************** Type Definitions *****************************/

/************************** Variable Definitions ***************************/

static uint8_t g_active_color_scheme = 0; // 0 = custom, 1..9 = named scheme

static const char *g_color_scheme_names[] = {
    "Custom",
    "Grayscale",
    "Red",
    "Green",
    "Blue",
    "Plasma",
    "Rainbow",
    "Fire",
    "Jet",
    "Hot"
};

/************************** Function Prototypes ****************************/
// Input helpers
char menu_getkey(void);
XStatus menu_read_line(char *buf, int max_len);
XStatus menu_read_uint32(uint32_t *out, uint32_t min, uint32_t max);
XStatus menu_read_hex32(uint32_t *out, uint32_t min, uint32_t max);
XStatus menu_parse_uint32(const char *buf, uint32_t *out);
XStatus menu_parse_hex32(const char *buf, uint32_t *out);
// Menu screens
void menu_fractal_mode(CTRL_Data *ctrl);
void menu_animation_speed(CTRL_Data *ctrl);
void menu_stepwidth(CTRL_Data *ctrl);
void menu_zoom(CTRL_Data *ctrl);
void menu_lfsr(CTRL_Data *ctrl);
void menu_diamond(CTRL_Data *ctrl);
void menu_system_info(CTRL_Data *ctrl);
void menu_status(CTRL_Data *ctrl);
/************************** Function Definitions ***************************/

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
            xil_printf("  Error: Value must be between %u and %u.\n\r", min, max);
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
            xil_printf("  Error: Value must be between 0x%X and 0x%X.\n\r", min, max);
            continue;
        }
        *out = val;
        return XST_SUCCESS;
    }
}

// ================================================================
//  MENUS
// ================================================================

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
        } else { // Mandelbrot mode is 1X --> 10 or 11
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
    xil_printf("Current: %u frames per animation step\n\r", current);
    xil_printf("New value (1-65535, q=cancel):\n\r");
    if (menu_read_uint32(&val, 1, 65535) != XST_SUCCESS) return;
    CTRL_SetAnimationSpeed(ctrl, val);
    xil_printf("\n\rAnimation Speed = %u\n\r", val);
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
    xil_printf("Current: %u (0x%05X)\n\r", sw, sw);
    xil_printf("New step width factor (Hex 0x00000-0x1FFFF, q=cancel):\n\r");
    if (menu_read_hex32(&val, 0, 0x1FFFF) != XST_SUCCESS) return;
    CTRL_SetStepWidth(ctrl, val);
    xil_printf("\n\rStep width factor = %u (0x%05X)\n\r", val, val);
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
    xil_printf("Current pixel distance (zoom) factor: %u\n\r", dist);
    xil_printf("New pixel distance factor (1-255, q=cancel):\n\r");
    if (menu_read_uint32(&val, 1, 255) != XST_SUCCESS) return;
    CTRL_SetPixelDistance(ctrl, val);
    xil_printf("\n\rPixel distance = %u\n\r", val);
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
        xil_printf("  XOR mask Real:  0x%04X\n\r", xor_re);
        xil_printf("  XOR mask Imag:  0x%04X\n\r", xor_im);
        xil_printf("  Seed Real factor: %u (0x%05X)\n\r", seed_re, seed_re);
        xil_printf("  Seed Imag factor: %u (0x%05X)\n\r", seed_im, seed_im);
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
                xil_printf("Current: 0x%04X\n\rNew XOR mask Real (Hex 0x0000-0xFFFF, q=cancel):\n\r", xor_re);
                if (menu_read_hex32(&val, 0, 0xFFFF) == XST_SUCCESS) {
                    CTRL_SetXorMaskLfsrRe(ctrl, val);
                    xil_printf("XOR mask Real = 0x%04X\n\r", val);
                }
                break;
            }
            case '2': {
                uint32_t val;
                xil_printf("Current: 0x%04X\n\rNew XOR mask Imag (Hex 0x0000-0xFFFF, q=cancel):\n\r", xor_im);
                if (menu_read_hex32(&val, 0, 0xFFFF) == XST_SUCCESS) {
                    CTRL_SetXorMaskLfsrIm(ctrl, val);
                    xil_printf("XOR mask Imag = 0x%04X\n\r", val);
                }
                break;
            }
            case '3': {
                uint32_t val;
                xil_printf("Current: %u (0x%05X)\n\rNew Seed Real (Hex 0x00000-0x1FFFF, q=cancel):\n\r", seed_re, seed_re);
                if (menu_read_hex32(&val, 0, 0x1FFFF) == XST_SUCCESS) {
                    CTRL_SetSeedLfsrRe(ctrl, val);
                    xil_printf("Seed Real = %u (0x%05X)\n\r", val, val);
                }
                break;
            }
            case '4': {
                uint32_t val;
                xil_printf("Current: %u (0x%05X)\n\rNew Seed Imag (Hex 0x00000-0x1FFFF, q=cancel):\n\r", seed_im, seed_im);
                if (menu_read_hex32(&val, 0, 0x1FFFF) == XST_SUCCESS) {
                    CTRL_SetSeedLfsrIm(ctrl, val);
                    xil_printf("Seed Imag = %u (0x%05X)\n\r", val, val);
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
        xil_printf("  Width factor:  %u (0x%04X)\n\r", dw, dw);
        xil_printf("  Height factor: %u (0x%04X)\n\r", dh, dh);
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
                xil_printf("Current: %u (0x%04X)\n\rNew width factor (Hex 0x0000-0xFFFF, q=cancel):\n\r", dw, dw);
                if (menu_read_hex32(&val, 0, 0xFFFF) == XST_SUCCESS) {
                    CTRL_SetDiamondWidth(ctrl, val);
                    xil_printf("Diamond width factor = %u (0x%04X)\n\r", val, val);
                }
                break;
            }
            case '2': {
                uint32_t val;
                xil_printf("Current: %u (0x%04X)\n\rNew height factor (Hex 0x0000-0xFFFF, q=cancel):\n\r", dh, dh);
                if (menu_read_hex32(&val, 0, 0xFFFF) == XST_SUCCESS) {
                    CTRL_SetDiamondHeight(ctrl, val);
                    xil_printf("Diamond height factor = %u (0x%04X)\n\r", val, val);
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
//  SYSTEM INFO
//  Read-only: displays CTRL hardware ID (IDR) and version (VERR).
// ----------------------------------------------------------------
void menu_system_info(CTRL_Data *ctrl) {
    char c;
    xil_printf("\n\r");
    xil_printf("===== System Info =====\n\r");
    xil_printf(" ID: 0x%08X\n\r", CTRL_GetId(ctrl));
    xil_printf(" Version: 0x%08X\n\r", CTRL_GetVersion(ctrl));
    xil_printf("========================\n\r");
    xil_printf("Press 'q' to continue.\n\r");
    do { c = menu_getkey(); } while (c != 'q' && c != 'Q');
    xil_printf("\n\r");
}

// ----------------------------------------------------------------
//  ALL SETTINGS DISPLAY
//  Read-only: dumps every CTRL register value at once.
// ----------------------------------------------------------------
void menu_status(CTRL_Data *ctrl) {
    char c;
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
    xil_printf("  Frames per animation step: 0x%08X\n\r", speed);
    xil_printf("  Step width factor:         0x%08X\n\r", sw);
    xil_printf("  Zoom factor:               0x%08X\n\r", dist);
    xil_printf("  XOR mask Real:             0x%08X\n\r", xor_re);
    xil_printf("  XOR mask Imag:             0x%08X\n\r", xor_im);
    xil_printf("  Seed Real factor:          0x%08X\n\r", seed_re);
    xil_printf("  Seed Imag factor:          0x%08X\n\r", seed_im);
    xil_printf("  Diamond width factor:      0x%08X\n\r", dw);
    xil_printf("  Diamond height factor:     0x%08X\n\r", dh);
    xil_printf("  Minimap:                   %s\n\r", mm_state ? "On" : "Off");
    xil_printf("================================\n\r");
    xil_printf("Press 'q' to continue.\n\r");
    do { c = menu_getkey(); } while (c != 'q' && c != 'Q');
    xil_printf("\n\r");
}