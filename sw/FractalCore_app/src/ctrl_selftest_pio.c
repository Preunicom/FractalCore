
// @author: Markus Remy

/***************************** Include Files *******************************/
#include "ctrl_driver.h"
#include "ctrl_selftest_pio.h"

/************************** Constant Definitions ***************************/

XStatus CTRL_TestRegister(CTRL_Data *InstancePtr, uint32_t AddrOffset, uint32_t ExpectedReadRegValWriteFF, uint32_t ExpectedReadRegValWrite00)
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


XStatus CTRL_TestRegisters(CTRL_Data *InstancePtr)
{
  XStatus Status=XST_SUCCESS, Statustmp=XST_SUCCESS;
  uint32_t expectedval;

  xil_printf("******************************\n\r");
	xil_printf("*CTRL_TESTREGISTERS\n\r");
	xil_printf("******************************\n\r");

  // Reserved Register
  Statustmp=CTRL_TestRegister(InstancePtr, GSCR_ADDR_OFFSET, 0x00000000, 0x00000000);
  Status |= Statustmp;
  Statustmp=CTRL_TestRegister(InstancePtr, GIER_ADDR_OFFSET, 0x00000000, 0x00000000);
  Status |= Statustmp;
  Statustmp=CTRL_TestRegister(InstancePtr, IPIER_ADDR_OFFSET, 0x00000000, 0x00000000);
  Status |= Statustmp;
  Statustmp=CTRL_TestRegister(InstancePtr, IPISR_ADDR_OFFSET, 0x00000000, 0x00000000);
  Status |= Statustmp;
  // ID/VERR
  Statustmp=CTRL_TestRegister(InstancePtr, IDR_ADDR_OFFSET, 0x0000FEED, 0x0000FEED);
  Status |= Statustmp;
  Statustmp=CTRL_TestRegister(InstancePtr, VERR_ADDR_OFFSET, 0x00000001, 0x00000001);
  Status |= Statustmp;
  // Control
  expectedval=SETCR_MODE_MASK | SETCR_MME_MASK; // LD reads always 0
  Statustmp=CTRL_TestRegister(InstancePtr, SETCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=SPECR_DP_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, SPECR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=CSWCR_SW_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, CSWCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=XMRCR_XR_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, XMRCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=XMICR_XI_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, XMICR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=LSRCR_SR_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, LSRCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=LSICR_SI_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, LSICR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=DWCR_DW_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, DWCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=DHCR_DH_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, DHCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  expectedval=ZOMCR_DS_MASK;
  Statustmp=CTRL_TestRegister(InstancePtr, ZOMCR_ADDR_OFFSET, expectedval, 0x00000000);
  Status |= Statustmp;
  
  if (Status==XST_SUCCESS){
    xil_printf("CTRL_TESTREGISTERS was successful\n\r");
  }else {
    xil_printf("CTRL_TESTREGISTERS failed\n\r");
  }
  return Status;
}