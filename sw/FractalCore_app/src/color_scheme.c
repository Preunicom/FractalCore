// @author: Markus Remy
//
// Implementation of predefined colour palettes (color schemes).

/***************************** Include Files *******************************/
#include "color_scheme.h"
#include "xil_types.h"

/************************** Function Prototypes ****************************/

static void color_linear_gradient(COL_Data *COL,
    uint8_t r0, uint8_t g0, uint8_t b0,
    uint8_t r1, uint8_t g1, uint8_t b1);
static void color_set_common(COL_Data *COL,
    uint8_t cr, uint8_t cg, uint8_t cb,
    uint8_t mr, uint8_t mg, uint8_t mb,
    uint8_t tr, uint8_t tg, uint8_t tb);

// ================================================================
//  COLOR SCHEME HELPERS
// ================================================================

// ------------------------------------------------------------------
//  Helper: fill all 256 iteration colors with a linear gradient
// ------------------------------------------------------------------
static void color_linear_gradient(COL_Data *COL,
    uint8_t r0, uint8_t g0, uint8_t b0,
    uint8_t r1, uint8_t g1, uint8_t b1)
{
    for (uint16_5 i = 0; i < 256; i++) {
        COLOR_t c;
        c.red   = (uint8_t)(r0 + ((int)(r1 - r0) * i / 255));
        c.green = (uint8_t)(g0 + ((int)(g1 - g0) * i / 255));
        c.blue  = (uint8_t)(b0 + ((int)(b1 - b0) * i / 255));
        COL_SetIterationColor(COL, i, &c);
    }
}

// ------------------------------------------------------------------
//  Helper: set convergent + minimap colors for a scheme
// ------------------------------------------------------------------
static void color_set_common(COL_Data *COL,
    uint8_t cr, uint8_t cg, uint8_t cb,
    uint8_t mr, uint8_t mg, uint8_t mb,
    uint8_t tr, uint8_t tg, uint8_t tb)
{
    COLOR_t conv, minimap_cur, minimap_tgt;
    conv.red = cr; 
    conv.green = cg; 
    conv.blue = cb;
    COL_SetConvergentColor(COL, &conv);
    minimap_cur.red = mr; 
    minimap_cur.green = mg; 
    minimap_cur.blue = mb;
    COL_SetCurrentMinimapColor(COL, &minimap_cur);
    minimap_tgt.red = tr; 
    minimap_tgt.green = tg; 
    minimap_tgt.blue = tb;
    COL_SetTargetMinimapColor(COL, &minimap_tgt);
}

// ================================================================
//  COLOR SCHEME GENERATORS
// ================================================================

// ------------------------------------------------------------------
//  1 - Grayscale: black -> white
// ------------------------------------------------------------------
void color_scheme_grayscale(COL_Data *COL) {
    color_linear_gradient(COL, 0, 0, 0, 255, 255, 255);
    color_set_common(COL, 255, 255, 255, 255, 0, 0, 255, 255, 0);
}

// ------------------------------------------------------------------
//  2 - Red: dark red -> bright red
// ------------------------------------------------------------------
void color_scheme_red(COL_Data *COL) {
    color_linear_gradient(COL, 10, 0, 0, 255, 10, 10);
    color_set_common(COL, 255, 255, 255, 0, 255, 255, 255, 255, 0);
}

// ------------------------------------------------------------------
//  3 - Green: dark green -> bright green
// ------------------------------------------------------------------
void color_scheme_green(COL_Data *COL) {
    color_linear_gradient(COL, 0, 10, 0, 10, 255, 10);
    color_set_common(COL, 255, 255, 255, 255, 0, 255, 255, 255, 0);
}

// ------------------------------------------------------------------
//  4 - Blue: dark blue -> bright blue
// ------------------------------------------------------------------
void color_scheme_blue(COL_Data *COL) {
    color_linear_gradient(COL, 0, 0, 10, 10, 10, 255);
    color_set_common(COL, 255, 255, 255, 255, 255, 0, 255, 0, 0);
}

// ------------------------------------------------------------------
//  5 - Plasma: purple -> cyan
// ------------------------------------------------------------------
void color_scheme_plasma(COL_Data *COL) {
    color_linear_gradient(COL, 80, 0, 128, 0, 255, 200);
    color_set_common(COL, 255, 255, 255, 255, 255, 0, 255, 0, 255);
}

// ------------------------------------------------------------------
//  6 - Rainbow: HSV hue sweep (full saturation and value)
// ------------------------------------------------------------------
void color_scheme_rainbow(COL_Data *COL) {
    for (int i = 0; i < 256; i++) {
        int h = i;                      // 0..255 maps to 0..360 degrees
        int s = 255;                    // full saturation
        int v = 255;                    // full value
        int region = h / 43;
        int f = (h - region * 43) * 6;
        int p = (v * (255 - s)) >> 8;
        int q = (v * (255 - ((s * f) >> 8))) >> 8;
        int t = (v * (255 - ((s * (255 - f)) >> 8))) >> 8;
        COLOR_t c;
        switch (region) {
            case 0: c.red = v; c.green = t; c.blue = p; break;
            case 1: c.red = q; c.green = v; c.blue = p; break;
            case 2: c.red = p; c.green = v; c.blue = t; break;
            case 3: c.red = p; c.green = q; c.blue = v; break;
            case 4: c.red = t; c.green = p; c.blue = v; break;
            default: c.red = v; c.green = p; c.blue = q; break;
        }
        COL_SetIterationColor(COL, i, &c);
    }
    color_set_common(COL, 255, 255, 255, 255, 0, 0, 0, 255, 255);
}

// ------------------------------------------------------------------
//  7 - Fire: black -> red -> yellow -> white
// ------------------------------------------------------------------
void color_scheme_fire(COL_Data *COL) {
    for (int i = 0; i < 256; i++) {
        COLOR_t c;
        if (i < 64) {
            c.red   = (uint8_t)(i * 4);
            c.green = 0;
            c.blue  = 0;
        } else if (i < 128) {
            c.red   = 255;
            c.green = (uint8_t)((i - 64) * 4);
            c.blue  = 0;
        } else if (i < 192) {
            c.red   = 255;
            c.green = 255;
            c.blue  = (uint8_t)((i - 128) * 4);
        } else {
            c.red   = 255;
            c.green = 255;
            c.blue  = 255;
        }
        COL_SetIterationColor(COL, i, &c);
    }
    color_set_common(COL, 255, 255, 255, 255, 0, 0, 0, 255, 255);
}

// ------------------------------------------------------------------
//  8 - Jet: blue -> cyan -> green -> yellow -> red (MATLAB colormap)
// ------------------------------------------------------------------
void color_scheme_jet(COL_Data *COL) {
    for (int i = 0; i < 256; i++) {
        uint8_t r, g, b;
        if (i < 32) {
            r = 0; g = 0; b = (uint8_t)(128 + i * 4);
        } else if (i < 96) {
            r = 0; g = (uint8_t)((i - 32) * 4); b = 255;
        } else if (i < 160) {
            r = (uint8_t)((i - 96) * 4); g = 255; b = (uint8_t)(255 - (i - 96) * 4);
        } else if (i < 224) {
            r = 255; g = (uint8_t)(255 - (i - 160) * 4); b = 0;
        } else {
            r = (uint8_t)(255 - (i - 224) * 2); g = 0; b = 0;
        }
        COLOR_t c;
        c.red = r; c.green = g; c.blue = b;
        COL_SetIterationColor(COL, i, &c);
    }
    color_set_common(COL, 255, 255, 255, 0, 255, 0, 255, 0, 255);
}

// ------------------------------------------------------------------
//  9 - Hot: black -> dark red -> red -> orange -> yellow -> white
// ------------------------------------------------------------------
void color_scheme_hot(COL_Data *COL) {
    for (int i = 0; i < 256; i++) {
        COLOR_t c;
        if (i < 51) {
            c.red   = (uint8_t)(i * 3);
            c.green = 0;
            c.blue  = 0;
        } else if (i < 102) {
            c.red   = 153 + (uint8_t)((i - 51) * 2);
            c.green = 0;
            c.blue  = 0;
        } else if (i < 153) {
            c.red   = 255;
            c.green = (uint8_t)((i - 102) * 5);
            c.blue  = 0;
        } else if (i < 204) {
            c.red   = 255;
            c.green = 255;
            c.blue  = (uint8_t)((i - 153) * 5);
        } else {
            c.red   = 255;
            c.green = 255;
            c.blue  = (uint8_t)(((i - 204) * 5 > 255) ? 255 : (i - 204) * 5);
        }
        COL_SetIterationColor(COL, i, &c);
    }
    color_set_common(COL, 255, 255, 255, 255, 0, 0, 0, 255, 255);
}
