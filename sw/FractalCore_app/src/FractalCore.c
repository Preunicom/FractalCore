// @author: Markus Remy

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "ctrl_driver.h"
#include "col_driver.h"
#include "ctrl_selftest_pio.h"
#include "col_selftest_pio.h"
#include "menu.h"

XStatus testSystem(CTRL_Data *ctrl, COL_Data *col);
void loadDefaultColors(COL_Data *col);
void loadDefaultSettings(CTRL_Data *ctrl);

int main() {
    CTRL_Data CTRL_Inst;
    CTRL_Data *CTRL_InstPtr = &CTRL_Inst;
    COL_Data COL_Inst;
    COL_Data *COL_InstPtr = &COL_Inst;
    XStatus Status;

    init_platform();

    xil_printf("Platform initialized!\n\r");

    Status=CTRL_Init(CTRL_InstPtr, CTRL_BASEADDRESS);
    if (Status != XST_SUCCESS){
      xil_printf("Error during CTRL_Init(). Check/Debug manually.\n\r");
    }
    Status=COL_Init(COL_InstPtr, COL_BASEADDRESS);
    if (Status != XST_SUCCESS){
      xil_printf("Error during COL_Init(). Check/Debug manually.\n\r");
    }

    if (testSystem(CTRL_InstPtr, COL_InstPtr) != XST_SUCCESS) {
        xil_printf("WARNING: Self-test FAILED. Menu will start anyway.\n\r");
    }

    loadDefaultSettings(CTRL_InstPtr);
    loadDefaultColors(COL_InstPtr);

    menu_run(CTRL_InstPtr, COL_InstPtr);

    xil_printf("Menu closed. Cleanup...\n\r");

    cleanup_platform();
    return 0;
}

// Run CTRL and COL register self-tests. Returns XST_SUCCESS on success, XST_FAILURE if any fail.
XStatus testSystem(CTRL_Data *ctrl, COL_Data *col) {
    int failed = 0;
    xil_printf("\n\r");
    xil_printf("=== Self-test ===\n\r");
    if (CTRL_TestRegisters(ctrl) != XST_SUCCESS) {
        xil_printf("  CTRL-Test FAILED!\n\r");
        failed = 1;
    }
    if (COL_TestRegisters(col) != XST_SUCCESS) {
        xil_printf("  COL-Test FAILED!\n\r");
        failed = 1;
    }
    if (!failed) {
        xil_printf("  Self-test PASSED.\n\r");
    }
    xil_printf("==================\n\r\n\r");
    return failed ? XST_FAILURE : XST_SUCCESS;
}

void loadDefaultSettings(CTRL_Data *ctrl) {
    CTRL_SetJuliaDiamondMode(ctrl);
    CTRL_SetPixelDistance(ctrl, (uint32_t)50);
    CTRL_SetDiamondHeight(ctrl, (uint32_t)32512);
    CTRL_SetDiamondWidth(ctrl, (uint32_t)32512);
    CTRL_SetAnimationSpeed(ctrl, (uint32_t)2); // 30 fps animation
    CTRL_SetStepWidth(ctrl, (uint32_t)100);
    CTRL_SetSeedLfsrRe(ctrl, (uint32_t)1);
    CTRL_SetSeedLfsrIm(ctrl, (uint32_t)100);
    CTRL_LoadLfsrSeeds(ctrl);
    CTRL_SetXorMaskLfsrRe(ctrl, 26624);
    CTRL_SetXorMaskLfsrIm(ctrl, 26624);
    CTRL_SetMinimapEnable(ctrl, (uint8_t)1);
}

void loadDefaultColors(COL_Data *col) {
    COLOR_t color;
    color.red = 0;
    color.green = 0;
    color.blue = 0;
    COL_SetConvergentColor(col, &color);
    for (uint16_t i = 0; i <= 255; i++) {
        color.red = 255 - i;
        COL_SetIterationColor(col, (uint8_t)i, &color);
    }
    color.red = 0;
    color.blue = 255;
    COL_SetCurrentMinimapColor(col, &color);
    color.green = 255;
    COL_SetTargetMinimapColor(col, &color);
}