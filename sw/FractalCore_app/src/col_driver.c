// @author: Markus Remy

/***************************** Include Files *******************************/
#include "col_driver.h"
#include "driver_l.h"

/************************** Constant Definitions ***************************/


/**************************** Type Definitions *****************************/


/************************** Variable Definitions ***************************/


/************************** Function Prototypes ****************************/
static void COL_StubAppHandler(void *CallBackRef);


/************************** Function Definitions ***************************/
static void COL_StubAppHandler(void *CallBackRef)
{
	Xil_AssertVoid(CallBackRef != NULL);
	//Dummy handler 
  //just do nothing 
}


XStatus COL_Init(COL_Data *InstancePtr, uint32_t BaseAddress)
{
  XStatus Status = XST_SUCCESS;
  COL_Config *ConfigPtr;

  Xil_AssertNonvoid(InstancePtr != NULL);

  //Get core configuration (file _g mechanism) 
	ConfigPtr = COL_LookupConfig(BaseAddress);
    if (!ConfigPtr) {
		Status = XST_DEVICE_NOT_FOUND;
    return Status;
	}

  COL_InitCfg(InstancePtr, BaseAddress, ConfigPtr);
  
  Status = COL_InitHw(InstancePtr);

  return Status; 
}   


void COL_InitCfg(COL_Data *InstancePtr, uint32_t BaseAddress, COL_Config *ConfigPtr)
{
  Xil_AssertVoid(InstancePtr != NULL);
  Xil_AssertVoid(BaseAddress != 0x0);
  Xil_AssertVoid(ConfigPtr != NULL);
  
  InstancePtr->Config = *ConfigPtr;
    
  InstancePtr->BaseAddress = BaseAddress;

  InstancePtr->AppHandler = COL_StubAppHandler; //set dummy handler, should be overwritten later
  InstancePtr->CallBackRef = InstancePtr;
}


XStatus COL_InitHw(COL_Data *InstancePtr)
{
  XStatus Status = XST_SUCCESS;
   
    ///Immediate HW Initilaization
    //Put in here things which have to be done immediately after start

    //In this case nothing is required

    return Status;
}

uint32_t COL_ConvertColor2Int(COLOR_t* color) {
  return (color->blue << 16) | (color->green << 8) | color->red;
}

void COL_ConvertFromInt2Color(uint32_t color, COLOR_t* color_result) {
  color_result->red = color & 0xFF;
  color_result->green = (color >> 8) & 0xFF;
  color_result->blue = (color >> 16) & 0xFF;
}

void COL_SetIterationColor(COL_Data *InstancePtr, uint8_t iteration, COLOR_t* color) {
  uint32_t address_offset = COL_ITER_BASE_ADDR_OFFSET_START + ((uint32_t)iteration << 2);
  uint32_t data = COL_ConvertColor2Int(color);
  mWriteReg(InstancePtr->BaseAddress, address_offset, data);
}

void COL_SetConvergentColor(COL_Data *InstancePtr, COLOR_t* color) {
  uint32_t data = COL_ConvertColor2Int(color);
  mWriteReg(InstancePtr->BaseAddress, COL_CONV_ADDR_OFFSET, data);
}

void COL_SetTargetMinimapColor(COL_Data *InstancePtr, COLOR_t* color) {
  uint32_t data = COL_ConvertColor2Int(color);
  mWriteReg(InstancePtr->BaseAddress, COL_MINIMAP_TARGET_ADDR_OFFSET, data);
}

void COL_SetCurrentMinimapColor(COL_Data *InstancePtr, COLOR_t* color) {
  uint32_t data = COL_ConvertColor2Int(color);
  mWriteReg(InstancePtr->BaseAddress, COL_MINIMAP_PIXEL_ADDR_OFFSET, data);
}

void COL_GetIterationColor(COL_Data *InstancePtr, uint8_t iteration, COLOR_t* color_result) {
  uint32_t address_offset = COL_ITER_BASE_ADDR_OFFSET_START + ((uint32_t)iteration << 2);
  uint32_t color = mReadReg(InstancePtr->BaseAddress, address_offset);
  COL_ConvertFromInt2Color(color, color_result);
}

void COL_GetConvergentColor(COL_Data *InstancePtr, COLOR_t* color_result) {
  uint32_t color = mReadReg(InstancePtr->BaseAddress, COL_CONV_ADDR_OFFSET);
  COL_ConvertFromInt2Color(color, color_result);
}

void COL_GetTargetMinimapColor(COL_Data *InstancePtr, COLOR_t* color_result) {
  uint32_t color = mReadReg(InstancePtr->BaseAddress, COL_MINIMAP_TARGET_ADDR_OFFSET);
  COL_ConvertFromInt2Color(color, color_result);
}

void COL_GetCurrentMinimapColor(COL_Data *InstancePtr, COLOR_t* color_result) {
  uint32_t color = mReadReg(InstancePtr->BaseAddress, COL_MINIMAP_PIXEL_ADDR_OFFSET);
  COL_ConvertFromInt2Color(color, color_result);
}
