/*
-- Company: 
-- Engineer: 
-- 
-- Create Date:
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

#include "color_config_driver.h"

void ColorConfig_SetScheme(uintptr_t baseaddr, uint32_t scheme)
{
    Xil_Out32(baseaddr + COLOR_CONFIG_REG0_OFFSET,
              scheme & COLOR_CONFIG_SCHEME_MASK);
}

uint32_t ColorConfig_GetScheme(uintptr_t baseaddr)
{
    return Xil_In32(baseaddr + COLOR_CONFIG_REG0_OFFSET)
           & COLOR_CONFIG_SCHEME_MASK;
}

const char* ColorConfig_GetSchemeName(uint32_t scheme)
{
    switch (scheme & COLOR_CONFIG_SCHEME_MASK)
    {
        case COLOR_SCHEME_GRAY:
            return "Graustufen";
        case COLOR_SCHEME_COLOR:
            return "Blau-Gruen-Gelb-Rot";
        case COLOR_SCHEME_BW:
            return "Schwarz/Weiss";
        case COLOR_SCHEME_FIRE:
            return "Fire-Style";
        default:
            return "Unbekannt";
    }
}