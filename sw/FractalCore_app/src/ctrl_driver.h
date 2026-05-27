
// @author: Markus Remy

#ifndef CTRL_DRIVER_H
#define CTRL_DRIVER_H

/****************** Include Files ********************/
#include <stdint.h>
#include "xil_types.h"
#include "xstatus.h"
#include "xil_printf.h"
#include "xparameters.h"

#include "driver_l.h" 

/************************** Constant Definitions ***************************/

///Register definitions and mask values
//Define base address
#define CTRL_BASEADDRESS XPAR_INITIALWERTERZEUGUNG_0_BASEADDR

//REGISTER DEFINITIONS
#define GSCR_ADDR_OFFSET    			0x000
#define GIER_ADDR_OFFSET    			0x004
#define IPIER_ADDR_OFFSET   			0x008
#define IPISR_ADDR_OFFSET   			0x00C
#define IDR_ADDR_OFFSET     			0x010
#define VERR_ADDR_OFFSET    			0x014
#define SETCR_ADDR_OFFSET   			0x018
#define SETCR_JULIA_DIAMOND_MODE_MASK	0x00000000
#define SETCR_JULIA_LFSR_MODE_MASK 		0x00000001
#define SETCR_MANDELBROT_MODE_MASK		0x00000002
#define SETCR_MODE_MASK					0x00000003
#define SETCR_LD_MASK  					0x00000100
#define SETCR_MME_MASK 					0x00010000
#define SPECR_ADDR_OFFSET   			0x01C
#define SPECR_DP_MASK  					0x0000FFFF
#define CSWCR_ADDR_OFFSET   			0x020
#define CSWCR_SW_MASK  					0x0001FFFF
#define XMRCR_ADDR_OFFSET   			0x024
#define XMRCR_XR_MASK  					0x0001FFFF
#define XMICR_ADDR_OFFSET   			0x028
#define XMICR_XI_MASK  					0x0001FFFF
#define LSRCR_ADDR_OFFSET   			0x02C
#define LSRCR_SR_MASK  					0x0003FFFF
#define LSICR_ADDR_OFFSET   			0x030
#define LSICR_SI_MASK  					0x0003FFFF
#define DWCR_ADDR_OFFSET    			0x034
#define DWCR_DW_MASK   					0x0001FFFF
#define DHCR_ADDR_OFFSET    			0x038
#define DHCR_DH_MASK   					0x0001FFFF
#define ZOMCR_ADDR_OFFSET   			0x03C
#define ZOMCR_DS_MASK  					0x000000FF


///Required for _g-file config mechanism (ctrl_driver_g.c and ctrl_driver_sinit.c)
#ifndef XPAR_CTRL_NUM_INSTANCES
#define XPAR_CTRL_NUM_INSTANCES	1
#endif

/**************************** Type Definitions *****************************/
typedef struct { 
  char *Name;
  UINTPTR BaseAddress;	/**< Register base address */
	u32 SysClockFreqHz;	/**< The AXI bus clock frequency */
  u32 IntrId;
	UINTPTR IntrParent;	/** Bit[0] Interrupt parent type Bit[64/32:1] Parent base address */
} CTRL_Config; //core config data using the _g-file mechanism (do not insert further data here)


typedef void (*CTRL_AppHandlerFpType) (void *CallBackRef);

typedef struct {
	CTRL_Config Config; //core config using the _g-file mechanism
 	UINTPTR BaseAddress;	 /**< Base address of registers */ //already in CTRL_Config, however replicate/buffer it here to avoid costly indirect access in the follwing
	CTRL_AppHandlerFpType AppHandler; /**< Callback function */ 
	void *CallBackRef;	 /**< Callback reference for handler  (AT_Data* instanceptr)*/
} CTRL_Data; //config data; insert additional required (config) data in this struct


/************************** Function Prototypes ****************************/

XStatus CTRL_Init(CTRL_Data *InstancePtr, uint32_t BaseAddress); //UNINTPTR BaseAddr

void CTRL_InitCfg(CTRL_Data *InstancePtr, uint32_t BaseAddress, CTRL_Config *ConfigPtr); //UNINTPTR BaseAddr

XStatus CTRL_InitHw(CTRL_Data *InstancePtr);

void _CTRL_SetValue(CTRL_Data *InstancePtr, uint32_t register_offset, uint32_t value);

void CTRL_LoadLfsrSeeds(CTRL_Data *InstancePtr);

void CTRL_SetJuliaDiamondMode(CTRL_Data *InstancePtr);

void CTRL_SetJuliaLfsrMode(CTRL_Data *InstancePtr);

void CTRL_SetMandelbrotMode(CTRL_Data *InstancePtr);

void CTRL_SetMinimapEnable(CTRL_Data *InstancePtr, uint8_t state);

uint32_t _CTRL_GetValue(CTRL_Data *InstancePtr, uint32_t register_offset);

/************************** Function Definitions ***************************/

// ========== SETER ==========
#define CTRL_SetAnimationSpeed(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), SPECR_ADDR_OFFSET, ((value) & SPECR_DP_MASK))

#define CTRL_SetStepWidth(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), CSWCR_ADDR_OFFSET, ((value) & CSWCR_SW_MASK))

#define CTRL_SetXorMaskLfsrRe(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), XMRCR_ADDR_OFFSET, ((value) & XMRCR_XR_MASK))

#define CTRL_SetXorMaskLfsrIm(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), XMICR_ADDR_OFFSET, ((value) & XMICR_XI_MASK))

#define CTRL_SetSeedLfsrRe(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), LSRCR_ADDR_OFFSET, ((value) & LSRCR_SR_MASK))

#define CTRL_SetSeedLfsrIm(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), LSICR_ADDR_OFFSET, ((value) & LSICR_SI_MASK))

#define CTRL_SetDiamondWidth(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), DWCR_ADDR_OFFSET, ((value) & DWCR_DW_MASK))

#define CTRL_SetDiamondHeight(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), DHCR_ADDR_OFFSET, ((value) & DHCR_DH_MASK))

#define CTRL_SetPixelDistance(InstancePtr, value) \
	_CTRL_SetValue((InstancePtr), ZOMCR_ADDR_OFFSET, ((value) & ZOMCR_DS_MASK))

// ========== GETER ==========
#define CTRL_GetId(InstancePtr) \
	_CTRL_GetValue((InstancePtr), IDR_ADDR_OFFSET)

#define CTRL_GetVersion(InstancePtr) \
	_CTRL_GetValue((InstancePtr), VERR_ADDR_OFFSET)

#define CTRL_GetMode(InstancePtr) \
	(_CTRL_GetValue((InstancePtr), SETCR_ADDR_OFFSET) & SETCR_MODE_MASK)

#define CTRL_GetMinimapState(InstancePtr) \
	(_CTRL_GetValue((InstancePtr), SETCR_ADDR_OFFSET) & SETCR_MME_MASK)

#define CTRL_GetAnimationSpeed(InstancePtr) \
	_CTRL_GetValue((InstancePtr), SPECR_ADDR_OFFSET)

#define CTRL_GetStepWidth(InstancePtr) \
	_CTRL_GetValue((InstancePtr), CSWCR_ADDR_OFFSET)

#define CTRL_GetXorMaskLfsrRe(InstancePtr) \
	_CTRL_GetValue((InstancePtr), XMRCR_ADDR_OFFSET)

#define CTRL_GetXorMaskLfsrIm(InstancePtr) \
	_CTRL_GetValue((InstancePtr), XMICR_ADDR_OFFSET)

#define CTRL_GetSeedLfsrRe(InstancePtr) \
	_CTRL_GetValue((InstancePtr), LSRCR_ADDR_OFFSET)

#define CTRL_GetSeedLfsrIm(InstancePtr) \
	_CTRL_GetValue((InstancePtr), LSICR_ADDR_OFFSET)

#define CTRL_GetDiamondWidth(InstancePtr) \
	_CTRL_GetValue((InstancePtr), DWCR_ADDR_OFFSET)

#define CTRL_GetDiamondHeight(InstancePtr) \
	_CTRL_GetValue((InstancePtr), DHCR_ADDR_OFFSET)

#define CTRL_GetPixelDistance(InstancePtr) \
	_CTRL_GetValue((InstancePtr), ZOMCR_ADDR_OFFSET)

#endif // CTRL_DRIVER_H
