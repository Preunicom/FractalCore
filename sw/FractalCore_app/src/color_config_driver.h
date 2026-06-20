/* 
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2026 08:31:42 AM
-- Design Name: 
-- Module Name: color_config_driver
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
*/

#ifndef COLOR_CONFIG_DRIVER_H
#define COLOR_CONFIG_DRIVER_H

#include <stdint.h>

#define COLOR_CONFIG_REG0_OFFSET 0x00u
#define COLOR_CONFIG_SCHEME_MASK 0x03u

#define COLOR_SCHEME_GRAY  0u
#define COLOR_SCHEME_COLOR 1u
#define COLOR_SCHEME_BW    2u
#define COLOR_SCHEME_FIRE  3u

void ColorConfig_SetScheme(uintptr_t baseaddr, uint32_t scheme);
uint32_t ColorConfig_GetScheme(uintptr_t baseaddr);
const char* ColorConfig_GetSchemeName(uint32_t scheme);

#endif
