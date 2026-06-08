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
static uint8_t scale_color(uint8_t val);
static void color_set_common(COL_Data *COL,
    uint8_t cr, uint8_t cg, uint8_t cb,
    uint8_t mr, uint8_t mg, uint8_t mb,
    uint8_t tr, uint8_t tg, uint8_t tb);

// ================================================================
//  COLOR SCHEME HELPERS
// ================================================================

// ------------------------------------------------------------------
//  Helper: fill all used iteration colors with a linear gradient
// ------------------------------------------------------------------
static void color_linear_gradient(COL_Data *COL,
    uint8_t r0, uint8_t g0, uint8_t b0,
    uint8_t r1, uint8_t g1, uint8_t b1)
{
    for (uint16_t i = 0; i <= MAX_USED_ITERATION_REGISTER; i++) {
        COLOR_t c;
        c.red   = (uint8_t)(r0 + ((int)(r1 - r0) * i / MAX_USED_ITERATION_REGISTER));
        c.green = (uint8_t)(g0 + ((int)(g1 - g0) * i / MAX_USED_ITERATION_REGISTER));
        c.blue  = (uint8_t)(b0 + ((int)(b1 - b0) * i / MAX_USED_ITERATION_REGISTER));
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

// ------------------------------------------------------------------
//  Helper: scale an 8-bit color value (0-255) to USED_COLOR_BITS
// ------------------------------------------------------------------
static uint8_t scale_color(uint8_t val) {
    return (uint8_t)((uint32_t)val * MAX_COLOR_VALUE / 255);
}

// ================================================================
//  COLOR SCHEME GENERATORS
// ================================================================

// ------------------------------------------------------------------
//  1 - Grayscale: black -> white
// ------------------------------------------------------------------
void color_scheme_grayscale(COL_Data *COL) {
    color_linear_gradient(COL, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0, 0, 0);
    color_set_common(COL, 0, 0, 0, MAX_COLOR_VALUE, 0, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0);
}

// ------------------------------------------------------------------
//  2 - Red: dark red -> bright red
// ------------------------------------------------------------------
void color_scheme_red(COL_Data *COL) {
    color_linear_gradient(COL, MAX_COLOR_VALUE, 0, 0, scale_color(10), 0, 0);
    color_set_common(COL, 0, 0, 0, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0);
}

// ------------------------------------------------------------------
//  3 - Green: dark green -> bright green
// ------------------------------------------------------------------
void color_scheme_green(COL_Data *COL) {
    color_linear_gradient(COL, 0, MAX_COLOR_VALUE, 0, 0, scale_color(10), 0);
    color_set_common(COL, 0, 0, 0, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0);
}

// ------------------------------------------------------------------
//  4 - Blue: dark blue -> bright blue
// ------------------------------------------------------------------
void color_scheme_blue(COL_Data *COL) {
    color_linear_gradient(COL, 0, 0, MAX_COLOR_VALUE, 0, 0, scale_color(10));
    color_set_common(COL, 0, 0, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE, 0, 0);
}

// ------------------------------------------------------------------
//  5 - Plasma: purple -> cyan
// ------------------------------------------------------------------
void color_scheme_plasma(COL_Data *COL) {
    color_linear_gradient(COL, 0, MAX_COLOR_VALUE, scale_color(200), scale_color(80), 0, scale_color(128));
    color_set_common(COL, 0, 0, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE);
}

// ------------------------------------------------------------------
//  6 - Rainbow: HSV hue sweep (full saturation and value)
// ------------------------------------------------------------------
void color_scheme_rainbow(COL_Data *COL) {
    uint16_t maxIter = MAX_USED_ITERATION_REGISTER;
    uint16_t hueSteps = MAX_COLOR_VALUE + 1;
    uint16_t regionSize = hueSteps / 6;
    for (uint16_t i = 0; i <= maxIter; i++) {
        int h = (int)i * MAX_COLOR_VALUE / (int)maxIter;   // hue 0..MAX_COLOR_VALUE
        int s = MAX_COLOR_VALUE;                            // full saturation
        int v = MAX_COLOR_VALUE;                            // full value
        int region = h / (int)regionSize;
        int f = (h - region * (int)regionSize) * 6;
        int p = (v * (MAX_COLOR_VALUE - s)) >> USED_COLOR_BITS;
        int q = (v * (MAX_COLOR_VALUE - ((s * f) >> USED_COLOR_BITS))) >> USED_COLOR_BITS;
        int t = (v * (MAX_COLOR_VALUE - ((s * (MAX_COLOR_VALUE - f)) >> USED_COLOR_BITS))) >> USED_COLOR_BITS;
        COLOR_t c;
        switch (region) {
            case 0: c.red = v; c.green = t; c.blue = p; break;
            case 1: c.red = q; c.green = v; c.blue = p; break;
            case 2: c.red = p; c.green = v; c.blue = t; break;
            case 3: c.red = p; c.green = q; c.blue = v; break;
            case 4: c.red = t; c.green = p; c.blue = v; break;
            default: c.red = v; c.green = p; c.blue = q; break;
        }
        COL_SetIterationColor(COL, (uint8_t)i, &c);
    }
    color_set_common(COL, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0, 0, 0, 0, 0, MAX_COLOR_VALUE);
}

// ------------------------------------------------------------------
//  7 - Fire: black -> red -> yellow -> white
// ------------------------------------------------------------------
void color_scheme_fire(COL_Data *COL) {
    uint16_t t1 = (MAX_USED_ITERATION_REGISTER + 1) / 4;
    uint16_t t2 = (MAX_USED_ITERATION_REGISTER + 1) / 2;
    uint16_t t3 = (MAX_USED_ITERATION_REGISTER + 1) * 3 / 4;
    for (uint16_t i = 0; i <= MAX_USED_ITERATION_REGISTER; i++) {
        COLOR_t c;
        if (i < t1) {
            c.red   = (uint8_t)((uint32_t)i * MAX_COLOR_VALUE / t1);
            c.green = 0;
            c.blue  = 0;
        } else if (i < t2) {
            c.red   = MAX_COLOR_VALUE;
            c.green = (uint8_t)((uint32_t)(i - t1) * MAX_COLOR_VALUE / (t2 - t1));
            c.blue  = 0;
        } else if (i < t3) {
            c.red   = MAX_COLOR_VALUE;
            c.green = MAX_COLOR_VALUE;
            c.blue  = (uint8_t)((uint32_t)(i - t2) * MAX_COLOR_VALUE / (t3 - t2));
        } else {
            c.red   = MAX_COLOR_VALUE;
            c.green = MAX_COLOR_VALUE;
            c.blue  = MAX_COLOR_VALUE;
        }
        COL_SetIterationColor(COL, (uint8_t)i, &c);
    }
    color_set_common(COL, MAX_COLOR_VALUE, 0, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE);
}

// ------------------------------------------------------------------
//  8 - Jet: blue -> cyan -> green -> yellow -> red (MATLAB colormap)
// ------------------------------------------------------------------
void color_scheme_jet(COL_Data *COL) {
    uint16_t maxIter = MAX_USED_ITERATION_REGISTER;
    uint16_t t1 = (maxIter + 1) / 8;
    uint16_t t2 = (maxIter + 1) * 3 / 8;
    uint16_t t3 = (maxIter + 1) * 5 / 8;
    uint16_t t4 = (maxIter + 1) * 7 / 8;
    uint16_t mid = (MAX_COLOR_VALUE + 1) / 2;
    for (uint16_t i = 0; i <= maxIter; i++) {
        uint8_t r, g, b;
        if (i < t1) {
            r = 0; g = 0; b = (uint8_t)(mid + (uint32_t)i * (MAX_COLOR_VALUE - mid) / t1);
        } else if (i < t2) {
            r = 0; g = (uint8_t)((uint32_t)(i - t1) * MAX_COLOR_VALUE / (t2 - t1)); b = MAX_COLOR_VALUE;
        } else if (i < t3) {
            r = (uint8_t)((uint32_t)(i - t2) * MAX_COLOR_VALUE / (t3 - t2)); g = MAX_COLOR_VALUE; b = (uint8_t)(MAX_COLOR_VALUE - (uint32_t)(i - t2) * MAX_COLOR_VALUE / (t3 - t2));
        } else if (i < t4) {
            r = MAX_COLOR_VALUE; g = (uint8_t)(MAX_COLOR_VALUE - (uint32_t)(i - t3) * MAX_COLOR_VALUE / (t4 - t3)); b = 0;
        } else {
            r = (uint8_t)(MAX_COLOR_VALUE - (uint32_t)(i - t4) * MAX_COLOR_VALUE / (maxIter - t4)); g = 0; b = 0;
        }
        COLOR_t c;
        c.red = r; c.green = g; c.blue = b;
        COL_SetIterationColor(COL, (uint8_t)i, &c);
    }
    color_set_common(COL, 0, 0, 0, 0, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE);
}

// ------------------------------------------------------------------
//  9 - Hot: black -> dark red -> red -> orange -> yellow -> white
// ------------------------------------------------------------------
void color_scheme_hot(COL_Data *COL) {
    uint16_t maxIter = MAX_USED_ITERATION_REGISTER;
    uint16_t t1 = (maxIter + 1) / 5;
    uint16_t t2 = (maxIter + 1) * 2 / 5;
    uint16_t t3 = (maxIter + 1) * 3 / 5;
    uint16_t t4 = (maxIter + 1) * 4 / 5;
    uint8_t r153 = scale_color(153);
    for (uint16_t i = 0; i <= maxIter; i++) {
        COLOR_t c;
        if (i < t1) {
            c.red   = (uint8_t)((uint32_t)i * MAX_COLOR_VALUE / t1);
            c.green = 0;
            c.blue  = 0;
        } else if (i < t2) {
            c.red   = (uint8_t)((uint32_t)(i - t1) * (MAX_COLOR_VALUE - r153) / (t2 - t1) + r153);
            c.green = 0;
            c.blue  = 0;
        } else if (i < t3) {
            c.red   = MAX_COLOR_VALUE;
            c.green = (uint8_t)((uint32_t)(i - t2) * MAX_COLOR_VALUE / (t3 - t2));
            c.blue  = 0;
        } else if (i < t4) {
            c.red   = MAX_COLOR_VALUE;
            c.green = MAX_COLOR_VALUE;
            c.blue  = (uint8_t)((uint32_t)(i - t3) * MAX_COLOR_VALUE / (t4 - t3));
        } else {
            c.red   = MAX_COLOR_VALUE;
            c.green = MAX_COLOR_VALUE;
            c.blue  = MAX_COLOR_VALUE;
        }
        COL_SetIterationColor(COL, (uint8_t)i, &c);
    }
    color_set_common(COL, MAX_COLOR_VALUE, MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0, 0, MAX_COLOR_VALUE, 0, MAX_COLOR_VALUE, MAX_COLOR_VALUE);
}
