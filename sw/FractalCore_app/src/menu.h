// @author: Markus Remy

#ifndef MENU_H
#define MENU_H

#include "ctrl_driver.h"
#include "col_driver.h"

// Main entry point: prints banner, runs the menu loop, returns when user exits.
void menu_run(CTRL_Data *ctrl, COL_Data *col);

// Read a single character from UART
char menu_getkey(void);

#endif
