// @author: Markus Remy

/***************************** Include Files *******************************/
#include "ctrl_driver.h"
#include "driver_l.h"

/************************** Constant Definitions ***************************/


/**************************** Type Definitions *****************************/


/************************** Variable Definitions ***************************/


/************************** Function Prototypes ****************************/
static void CTRL_StubAppHandler(void *CallBackRef);


/************************** Function Definitions ***************************/
static void CTRL_StubAppHandler(void *CallBackRef)
{
	Xil_AssertVoid(CallBackRef != NULL);
	//Dummy handler 
  //just do nothing 
}


XStatus CTRL_Init(CTRL_Data *InstancePtr, uint32_t BaseAddress)
{
  XStatus Status = XST_SUCCESS;
  CTRL_Config *ConfigPtr;

  Xil_AssertNonvoid(InstancePtr != NULL);

  //Get core configuration (file _g mechanism) 
	ConfigPtr = CTRL_LookupConfig(BaseAddress);
    if (!ConfigPtr) {
		Status = XST_DEVICE_NOT_FOUND;
    return Status;
	}

  CTRL_InitCfg(InstancePtr, BaseAddress, ConfigPtr);
  
  Status = CTRL_InitHw(InstancePtr);

  return Status; 
}   


void CTRL_InitCfg(CTRL_Data *InstancePtr, uint32_t BaseAddress, CTRL_Config *ConfigPtr)
{
  Xil_AssertVoid(InstancePtr != NULL);
  Xil_AssertVoid(BaseAddress != 0x0);
  Xil_AssertVoid(ConfigPtr != NULL);
  
  InstancePtr->Config = *ConfigPtr;
    
  InstancePtr->BaseAddress = BaseAddress;

  InstancePtr->AppHandler = CTRL_StubAppHandler; //set dummy handler, should be overwritten later
  InstancePtr->CallBackRef = InstancePtr;
}


XStatus CTRL_InitHw(CTRL_Data *InstancePtr)
{
  XStatus Status = XST_SUCCESS;
   
    ///Immediate HW Initialization
    //Put in here things which have to be done immediately after start

    //In this case nothing is required

    return Status;
}

void _CTRL_SetValue(CTRL_Data *InstancePtr, uint32_t register_offset, uint32_t value) {
  mWriteReg(InstancePtr->BaseAddress, register_offset, value);
}

void CTRL_LoadLfsrSeeds(CTRL_Data *InstancePtr) {
  uint32_t data = mReadReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET);
  data |= SETCR_LD_MASK;
  mWriteReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET, data);
}

void CTRL_SetJuliaDiamondMode(CTRL_Data *InstancePtr) {
  uint32_t data = mReadReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET);
  data &= ~(SETCR_MODE_MASK);
  data |= SETCR_JULIA_DIAMOND_MODE_MASK;
  mWriteReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET, data);
}

void CTRL_SetJuliaLfsrMode(CTRL_Data *InstancePtr) {
  uint32_t data = mReadReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET);
  data &= ~(SETCR_MODE_MASK);
  data |= SETCR_JULIA_LFSR_MODE_MASK;
  mWriteReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET, data);
}

void CTRL_SetMandelbrotMode(CTRL_Data *InstancePtr) {
  uint32_t data = mReadReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET);
  data &= ~(SETCR_MODE_MASK);
  data |= SETCR_MANDELBROT_MODE_MASK;
  mWriteReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET, data);
}

void CTRL_SetMinimapEnable(CTRL_Data *InstancePtr, uint8_t state) {
  uint32_t data = mReadReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET);
  data &= ~(SETCR_MME_MASK);
  data |= (state << 16) & SETCR_MME_MASK;
  mWriteReg(InstancePtr->BaseAddress, SETCR_ADDR_OFFSET, data);
}

uint32_t _CTRL_GetValue(CTRL_Data *InstancePtr, uint32_t register_offset) {
  return mReadReg(InstancePtr->BaseAddress, register_offset);
}