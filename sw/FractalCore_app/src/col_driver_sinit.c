// @author: Markus Remy

/****************** Include Files ********************/
//#include "xparameters.h"

#include "col_driver.h"

/************************** Constant Definitions ***************************/


/**************************** Type Definitions *****************************/
extern COL_Config COL_ConfigTable[XPAR_COL_NUM_INSTANCES];

/************************** Variable Definitions ***************************/


/************************** Function Definitions ***************************/

COL_Config *COL_LookupConfig(UINTPTR BaseAddress)
{
	extern COL_Config COL_ConfigTable[];
	COL_Config *CfgPtr = NULL;
	u32 Index;

	for (Index = 0; COL_ConfigTable[Index].Name != NULL; Index++) {
		/*
		 * If BaseAddress is 0, return Configuration for 0th instance of
		 * device.
		 * As instance base address varies based on designs,
		 * driver examples can pass base address as 0, to use avilable
		 * instance.
		 */
		if ((COL_ConfigTable[Index].BaseAddress == BaseAddress) ||
		    !BaseAddress)  {
			CfgPtr = &COL_ConfigTable[Index];
			break;
		}
	}

	return CfgPtr;
}