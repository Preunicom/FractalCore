// @author: Markus Remy

#ifndef CTRL_SELFTEST_PIO_H
#define CTRL_SELFTEST_PIO_H

/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "ctrl_driver.h"

/**************************** Type Definitions *****************************/


/************************** Function Prototypes ****************************/

XStatus CTRL_TestRegister(CTRL_Data *InstancePtr, uint32_t AddrOffset, uint32_t ExpectedReadRegValWriteFF, uint32_t ExpectedReadRegValWrite00);

XStatus CTRL_TestRegisters(CTRL_Data *InstancePtr);


/************************** Function Definitions ***************************/

#endif // CTRL_SELFTEST_PIO_H


