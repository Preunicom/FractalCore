// @author: Markus Remy

#ifndef COL_DRIVER_H
#define COL_DRIVER_H

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
#define COL_BASEADDRESS XPAR_ANZEIGE_0_BASEADDR

#define COL_ITER_BASE_ADDR_OFFSET_START 0x000
#define COL_ITER_BASE_ADDR_OFFSET_END 	0x3FC
#define COL_CONV_ADDR_OFFSET      		0x400
#define COL_MINIMAP_PIXEL_ADDR_OFFSET   0x404
#define COL_MINIMAP_TARGET_ADDR_OFFSET  0x408
#define COL_MASK           				0x00FFFFFF
#define COL_RED_MASK       				0x000000FF
#define COL_GREEN_MASK     				0x0000FF00
#define COL_BLUE_MASK      				0x00FF0000

#define USED_COLOR_BITS 8
#define MAX_COLOR_VALUE ((1 << USED_COLOR_BITS) - 1)

#define MAX_USED_ITERATION_REGISTER 100

///Required for _g-file config mechanism (col_driver_g.c and col_driver_sinit.c)
#ifndef XPAR_COL_NUM_INSTANCES
#define XPAR_COL_NUM_INSTANCES	1
#endif

/**************************** Type Definitions *****************************/
typedef struct { 
  char *Name;
  UINTPTR BaseAddress;	/**< Register base address */
	u32 SysClockFreqHz;	/**< The AXI bus clock frequency */
  u32 IntrId;
	UINTPTR IntrParent;	/** Bit[0] Interrupt parent type Bit[64/32:1] Parent base address */
} COL_Config; //core config data using the _g-file mechanism (do not insert further data here)


typedef void (*COL_AppHandlerFpType) (void *CallBackRef);

typedef struct {
	COL_Config Config; //core config using the _g-file mechanism
 	UINTPTR BaseAddress;	 /**< Base address of registers */ //already in COL_Config, however replicate/buffer it here to avoid costly indirect access in the following
	COL_AppHandlerFpType AppHandler; /**< Callback function */ 
	void *CallBackRef;	 /**< Callback reference for handler  (COL_Data* instanceptr)*/
} COL_Data; //config data; insert additional required (config) data in this struct


typedef struct {
	uint8_t red;
	uint8_t green;
	uint8_t blue;
} COLOR_t;

/************************** Function Prototypes ****************************/

XStatus COL_Init(COL_Data *InstancePtr, uint32_t BaseAddress); //UNINTPTR BaseAddr

void COL_InitCfg(COL_Data *InstancePtr, uint32_t BaseAddress, COL_Config *ConfigPtr); //UNINTPTR BaseAddr

XStatus COL_InitHw(COL_Data *InstancePtr);

void COL_SetIterationColor(COL_Data *InstancePtr, uint8_t iteration, COLOR_t* color);

void COL_SetConvergentColor(COL_Data *InstancePtr, COLOR_t* color);

void COL_SetTargetMinimapColor(COL_Data *InstancePtr, COLOR_t* color);

void COL_SetCurrentMinimapColor(COL_Data *InstancePtr, COLOR_t* color);

void COL_GetIterationColor(COL_Data *InstancePtr, uint8_t iteration, COLOR_t* color_result);

void COL_GetConvergentColor(COL_Data *InstancePtr, COLOR_t* color_result);

void COL_GetTargetMinimapColor(COL_Data *InstancePtr, COLOR_t* color_result);

void COL_GetCurrentMinimapColor(COL_Data *InstancePtr, COLOR_t* color_result);

/************************** Function Definitions ***************************/

#endif // COL_DRIVER_H
