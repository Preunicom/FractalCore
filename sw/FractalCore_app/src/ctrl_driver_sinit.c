
/****************** Include Files ********************/
//#include "xparameters.h"

#include "ctrl_driver.h"

/************************** Constant Definitions ***************************/


/**************************** Type Definitions *****************************/
extern CTRL_Config CTRL_ConfigTable[XPAR_CTRL_NUM_INSTANCES];

/************************** Variable Definitions ***************************/


/************************** Function Definitions ***************************/

CTRL_Config *CTRL_LookupConfig(UINTPTR BaseAddress)
{
	extern CTRL_Config CTRL_ConfigTable[];
	CTRL_Config *CfgPtr = NULL;
	u32 Index;

	for (Index = 0; CTRL_ConfigTable[Index].Name != NULL; Index++) {
		/*
		 * If BaseAddress is 0, return Configuration for 0th instance of
		 * device.
		 * As instance base address varies based on designs,
		 * driver examples can pass base address as 0, to use avilable
		 * instance.
		 */
		if ((CTRL_ConfigTable[Index].BaseAddress == BaseAddress) ||
		    !BaseAddress)  {
			CfgPtr = &CTRL_ConfigTable[Index];
			break;
		}
	}

	return CfgPtr;
}