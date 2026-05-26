/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

 // @author: Markus Remy

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "ctrl_driver.h"
#include "col_driver.h"
#include "ctrl_selftest_pio.h"
#include "col_selftest_pio.h"

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

    test_system(CTRL_InstPtr, COL_InstPtr);

    xil_printf("End of tests reached. Cleaning up...\n\r");

    cleanup_platform();
    return 0;
}

void test_system(CTRL_Data* ctrl, COL_Data* col) {
    CTRL_TestRegisters(ctrl);
    COL_TestRegisters(col);
}