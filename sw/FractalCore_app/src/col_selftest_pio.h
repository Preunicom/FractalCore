// @author: Markus Remy

#ifndef COL_SELFTEST_PIO_H
#define COL_SELFTEST_PIO_H

/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "col_driver.h"

/**************************** Type Definitions *****************************/


/************************** Function Prototypes ****************************/

XStatus COL_TestRegister(COL_Data *InstancePtr, uint32_t AddrOffset, uint32_t ExpectedReadRegValWriteFF, uint32_t ExpectedReadRegValWrite00);

XStatus COL_TestRegisters(COL_Data *InstancePtr);


/************************** Function Definitions ***************************/

#endif // COL_SELFTEST_PIO_H


