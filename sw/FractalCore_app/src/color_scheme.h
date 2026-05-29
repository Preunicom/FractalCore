// @author: Markus Remy
//
// Predefined colour palettes (color schemes) for FractalCore.
// Each scheme writes all 256 iteration colors, the convergent colour,
// and both minimap colours in one action.

#ifndef COLOR_SCHEME_H
#define COLOR_SCHEME_H

#include "col_driver.h"

void color_scheme_grayscale(COL_Data *COL);
void color_scheme_red(COL_Data *COL);
void color_scheme_green(COL_Data *COL);
void color_scheme_blue(COL_Data *COL);
void color_scheme_plasma(COL_Data *COL);
void color_scheme_rainbow(COL_Data *COL);
void color_scheme_fire(COL_Data *COL);
void color_scheme_jet(COL_Data *COL);
void color_scheme_hot(COL_Data *COL);

#endif
