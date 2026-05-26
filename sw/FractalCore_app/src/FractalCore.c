// @author: Markus Remy

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "ctrl_driver.h"
#include "col_driver.h"
#include "ctrl_selftest_pio.h"
#include "col_selftest_pio.h"
#include "menu.h"

XStatus test_system(CTRL_Data *ctrl, COL_Data *col);

int main()
{
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

    if (test_system(CTRL_InstPtr, COL_InstPtr) != XST_SUCCESS) {
        xil_printf("WARNING: Self-test FAILED. Menu will start anyway.\n\r");
    }

    menu_run(CTRL_InstPtr, COL_InstPtr);

    xil_printf("Menu closed. Cleanup...\n\r");

    cleanup_platform();
    return 0;
}

// Run CTRL and COL register self-tests. Returns XST_SUCCESS on success, XST_FAILURE if any fail.
XStatus test_system(CTRL_Data *ctrl, COL_Data *col) {
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