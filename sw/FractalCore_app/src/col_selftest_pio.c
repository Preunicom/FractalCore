// @author: Markus Remy

/***************************** Include Files *******************************/
#include "col_driver.h"
#include "col_selftest_pio.h"

/************************** Constant Definitions ***************************/

XStatus COL_TestRegister(COL_Data *InstancePtr, uint32_t AddrOffset, uint32_t ExpectedReadRegValWriteFF, uint32_t ExpectedReadRegValWrite00)
{
  XStatus Status=XST_SUCCESS;
  uint32_t val;

  mWriteReg(InstancePtr->BaseAddress, AddrOffset, 0xffffffff);
  val=mReadReg(InstancePtr->BaseAddress, AddrOffset);
  if (val != ExpectedReadRegValWriteFF) 
  {  
    xil_printf("Value mismatch: A:0x%0x : Expected 0x%x -> Got 0x%x\n\r", AddrOffset, ExpectedReadRegValWriteFF, val);
    Status = XST_FAILURE;
  }

  mWriteReg(InstancePtr->BaseAddress, AddrOffset, 0x00000000);
  val=mReadReg(InstancePtr->BaseAddress, AddrOffset); 
  if (val != ExpectedReadRegValWrite00) 
  {  
    xil_printf("Value mismatch: A:0x%0x : Expected 0x%x -> Got 0x%x\n\r", AddrOffset, ExpectedReadRegValWrite00, val);
    Status = XST_FAILURE;
  }

  return Status;
}


XStatus COL_TestRegisters(COL_Data *InstancePtr)
{
  XStatus Status=XST_SUCCESS, Statustmp=XST_SUCCESS;

  xil_printf("******************************\n\r");
	xil_printf("*COL_TESTREGISTERS\n\r");
	xil_printf("******************************\n\r");

  for(uint16_t i = 0; i <= 255; i++) {
    Statustmp=COL_TestRegister(InstancePtr, COL_ITER_BASE_ADDR_OFFSET_START + (4*i), 0xFFFFFFFF, 0x00000000);
    Status |= Statustmp;
  }
  Statustmp=COL_TestRegister(InstancePtr, COL_CONV_ADDR_OFFSET, 0xFFFFFFFF, 0x00000000);
  Status |= Statustmp;
  Statustmp=COL_TestRegister(InstancePtr, COL_MINIMAP_TARGET_ADDR_OFFSET, 0xFFFFFFFF, 0x00000000);
  Status |= Statustmp;
  Statustmp=COL_TestRegister(InstancePtr, COL_MINIMAP_PIXEL_ADDR_OFFSET, 0xFFFFFFFF, 0x00000000);
  Status |= Statustmp;
  
  if (Status==XST_SUCCESS){
    xil_printf("COL_TESTREGISTERS was successful\n\r");
  }else {
    xil_printf("COL_TESTREGISTERS failed\n\r");
  }
  return Status;
}