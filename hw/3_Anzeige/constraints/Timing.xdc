# CDC Constraints in Framebuffer_Manager --> Top level 
set_property ASYNC_REG TRUE [get_cells { VGA_CTRL/FRAME_BUF_MANAGER/r_cdc_is_lower_half_of_frame_reg }];
set_property ASYNC_REG TRUE [get_cells { VGA_CTRL/FRAME_BUF_MANAGER/r_stable_is_lower_half_of_frame_reg }];
set_property ASYNC_REG TRUE [get_cells { VGA_CTRL/FRAME_BUF_MANAGER/r_cdc_frame_idx_grey_code_reg }];
set_property ASYNC_REG TRUE [get_cells { VGA_CTRL/FRAME_BUF_MANAGER/r_stable_frame_idx_grey_code_reg }];
