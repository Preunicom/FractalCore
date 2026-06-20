// @author: Markus Remy

#ifndef CTRL_MENU_H
#define CTRL_MENU_H

#include "ctrl_driver.h"

void menu_fractal_mode(CTRL_Data *ctrl);
void menu_animation_speed(CTRL_Data *ctrl);
void menu_stepwidth(CTRL_Data *ctrl);
void menu_zoom(CTRL_Data *ctrl);
void menu_lfsr(CTRL_Data *ctrl);
void menu_diamond(CTRL_Data *ctrl);
void menu_system_info(CTRL_Data *ctrl);
void menu_status(CTRL_Data *ctrl);

#endif