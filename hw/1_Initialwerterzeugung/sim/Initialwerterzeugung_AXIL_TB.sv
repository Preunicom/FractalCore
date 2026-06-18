////////////////////////////////////////////////////////
//
// author: Markus Remy
// Used template of the CSA course of Mr. Münch
//
////////////////////////////////////////////////////////

`timescale 1ns / 1ps
 
import axi_vip_pkg::*;
import VIP_AXIL_Initialwerterzeugung_TB_axi_vip_0_0_pkg::*; // check instance name in block design <blockdesign-name>_<vip-inst-name>_0_pkg)

module Initialwerterzeugung_TB();

  //CONSTANT DEFINITIONS
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12;
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32;
    
  //REGISTER DEFINITIONS
  //GSCR General/Global Control and Status Register slv_reg00 0x00 
  parameter GSCR_ADDR               = 6'h000;
  //GIER slv_reg01 0x04  
  parameter GIER_ADDR               = 6'h004;
  //IPIER slv_reg02 0x08  
  parameter IPIER_ADDR              = 6'h008;
  //IPISR slv_reg03 0x0C  
  parameter IPISR_ADDR              = 6'h00C;
  //IDR ID Register slv_reg04 0x10  --const axi r ip rw (part3)
  parameter IDR_ADDR                = 6'h010;
  //VERR Version Register slv_reg05 0x14 --const axi r ip rw (part3)
  parameter VERR_ADDR               = 6'h014;
  //SETCR Setup Control Register slv_reg06 0x18 
  parameter SETCR_ADDR              = 6'h018;
  parameter SETCR_MODE_MASK         = 32'h00000003;
  parameter SETCR_LD_MASK           = 32'h00000100;
  parameter SETCR_MME_MASK          = 32'h00010000;
  //SPECR Speed Control Register slv_reg07 0x1C 
  parameter SPECR_ADDR              = 6'h01C;
  parameter SPECR_DP_MASK           = 32'h0000FFFF;
  //CSWCR C Step Width Control Register slv_reg08 0x20 
  parameter CSWCR_ADDR              = 6'h020;
  parameter CSWCR_SW_MASK           = 32'h0001FFFF;
  //XMRCR XOR Mask RE Control Register slv_reg09 0x24
  parameter XMRCR_ADDR              = 6'h024;
  parameter XMRCR_XR_MASK           = 32'h0000FFFF;
  //XMICR XOR Mask IM Control Register slv_reg10 0x28
  parameter XMICR_ADDR              = 6'h028;
  parameter XMICR_XI_MASK           = 32'h0000FFFF;
  //LSRCR LFSR Seed RE Control Register slv_reg11 0x2C
  parameter LSRCR_ADDR              = 6'h02C;
  parameter LSRCR_SR_MASK           = 32'h0001FFFF;
  //LSICR LFSR Seed IM Control Register slv_reg12 0x30
  parameter LSICR_ADDR              = 6'h030;
  parameter LSICR_SI_MASK           = 32'h0001FFFF;
  //DWCR Diamond Width Control Register slv_reg13 0x34
  parameter DWCR_ADDR              = 6'h034;
  parameter DWCR_DW_MASK           = 32'h0000FFFF;
  //DHCR Diamond Height Control Register slv_reg14 0x38
  parameter DHCR_ADDR              = 6'h038;
  parameter DHCR_DH_MASK           = 32'h0000FFFF;
  //ZOMCR Zoom Control Register slv_reg15 0x3C
  parameter ZOMCR_ADDR              = 6'h03C;
  parameter ZOMCR_DH_MASK           = 32'h000000FF;
  
  //BUFFER DEFINITIONS (not used so far)

  //FURTHER DEFINITIONS
  VIP_AXIL_Initialwerterzeugung_TB_axi_vip_0_0_mst_t mst_ctrl_agent; // check instance name in block design (<blockdesign-name>_<vip-inst-name>_0_mst_t)
  //clock frequency definition
  parameter real CLK_PERIOD = 1; // for ease of use in the waveform diagram the clock period is selected as 1ns
  bit error_found = 0;


  //--------------------------------------------------------------------------------------
  //SYSTEM DEFINITION (system instances and signals)
  //CLK
  logic i_aclk_0 = 0;
  initial begin: AP_CLK
    forever begin
      i_aclk_0 = #(CLK_PERIOD/2) ~i_aclk_0;
    end
  end

  //RESET
  logic i_aresetn_0 = 0;
  initial begin: AP_RST
    ap_rst_n_sequence(16);
  end

  //SYSTEM DESIGN WRAPPER instance
  logic i_ready_0 = 1;
  logic o_valid_0;
  logic [9:0] o_video_pix_col_0;
  logic [8:0] o_video_pix_row_0;
  logic [1:0] o_video_frame_idx_0;
  logic [17:0] o_z0_real_0;
  logic [17:0] o_z0_img_0;
  logic [17:0] o_c_real_0;
  logic [17:0] o_c_img_0;
  logic [38:0] o_highlight_ch0_0;
  logic [38:0] o_highlight_ch1_0;
  logic [38:0] o_highlight_ch2_0;
  logic [38:0] o_highlight_ch3_0;

  //check instance name in block design -> <blockdesign_name>_wrapper 
  VIP_AXIL_Initialwerterzeugung_TB_wrapper DUT( // TODO: Check signals!
    .i_aclk_0(i_aclk_0),
    .i_aresetn_0(i_aresetn_0),
    .i_ready_0(i_ready_0),
    .o_valid_0(o_valid_0),
    .o_video_pix_col_0(o_video_pix_col_0),
    .o_video_pix_row_0(o_video_pix_row_0),
    .o_video_frame_idx_0(o_video_frame_idx_0),
    .o_z0_real_0(o_z0_real_0),
    .o_z0_img_0(o_z0_img_0),
    .o_c_real_0(o_c_real_0),
    .o_c_img_0(o_c_img_0),
    .o_highlight_ch0_0(o_highlight_ch0_0),
    .o_highlight_ch1_0(o_highlight_ch1_0),
    .o_highlight_ch2_0(o_highlight_ch2_0),
    .o_highlight_ch3_0(o_highlight_ch3_0)
  );
 
  //-------------------------------------------------------------------------------------
  //FUNCTIONS AND TASKS
  /////////////////////////////////////////////////////////////
  // Reusing and adapting AXI VIP functions out of Xilinx Tutorial
  //
  //https://github.com/Xilinx/Vitis-Tutorials/blob/2023.2/Hardware_Acceleration/Feature_Tutorials/01-rtl_kernel_workflow/reference-files/src/testbench/Vadd_A_B_tb.sv   
  //
  ////////////////////////////////////////////////////////////  
  
  //`include "vis_tb.vh"
  
  //FUNCTIONS AND TASKS
  task automatic ap_rst_n_sequence(input integer unsigned width = 20);
    @(posedge i_aclk_0);
    #1ns;
    i_aresetn_0 = 0;
    repeat (width) @(posedge i_aclk_0);
    #1ns;
    i_aresetn_0 = 1;
  endtask

  task automatic start_vips();
    $display("//////////////////////////////////////////////////////////////");
    $display("Start Axi Control Master");    
    mst_ctrl_agent = new("master_ctrl_agent", DUT.VIP_AXIL_Initialwerterzeugung_TB_i.axi_vip_0.inst.IF); // check instance name in block design DUT.<blockdesign-name>_<vip-inst-name>.inst.IF
    mst_ctrl_agent.start_master();
  endtask

  /////////////////////////////////////////////////////////////////////////////////////////////////
  // Control interface blocking write
  // The task will return when the BRESP has been returned from the kernel.
  task automatic blocking_write_register (input bit [31:0] addr_in, input bit [31:0] data);
    axi_transaction   wr_xfer;
    axi_transaction   wr_rsp;
    wr_xfer = mst_ctrl_agent.wr_driver.create_transaction("wr_xfer");
    wr_xfer.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
    assert(wr_xfer.randomize() with {addr == addr_in;});
    wr_xfer.set_data_beat(0, data);
    mst_ctrl_agent.wr_driver.send(wr_xfer);
    mst_ctrl_agent.wr_driver.wait_rsp(wr_rsp);
  endtask

  /////////////////////////////////////////////////////////////////////////////////////////////////
  // Control interface blocking read
  // The task will return when the BRESP has been returned from the kernel.
  task automatic read_register (input bit [31:0] addr, output bit [31:0] rddata);
    axi_transaction   rd_xfer;
    axi_transaction   rd_rsp;
    bit [31:0] rd_value;
    rd_xfer = mst_ctrl_agent.rd_driver.create_transaction("rd_xfer");
    rd_xfer.set_addr(addr);
    rd_xfer.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
    mst_ctrl_agent.rd_driver.send(rd_xfer);
    mst_ctrl_agent.rd_driver.wait_rsp(rd_rsp);
    rd_value = rd_rsp.get_data_beat(0);
    rddata = rd_value;
  endtask

  /////////////////////////////////////////////////////////////////////////////////////////////////
  //check if only the implemented bit can be written and read back 
  //(unimplemented reserved bits should ignore writes and return zeros if read)
  task automatic check_32bitregister_value_with_gaps(input bit [31:0] addr_in, input bit [31:0] expectedreadregvalwriteff, input bit [31:0] expectedreadregvalwrite00, output bit error_found);
    bit [31:0] rddata;
    error_found = 0;

    blocking_write_register(addr_in, 32'hffffffff);
    read_register(addr_in, rddata);
    if (rddata != expectedreadregvalwriteff) begin
      $error("Value mismatch expectedreadregvalwriteff: A:0x%0x : Expected 0x%x -> Got 0x%x", addr_in, expectedreadregvalwriteff, rddata);
      error_found = 1;
    end
    blocking_write_register(addr_in, 32'h00000000);
    read_register(addr_in, rddata);
    if (rddata != expectedreadregvalwrite00 ) begin
      $error("Value mismatch expectedreadregvalwrite00: A:0x%0x : Expected 0x%x -> Got 0x%x", addr_in, expectedreadregvalwrite00, rddata);
      error_found = 1;
    end    
  endtask
  
  /////////////////////////////////////////////////////////////////////////////////////////////////
  // For each of the scalar registers, check:
  //  correct number bits set on a write 
  task automatic check_scalar_registers(output bit error_found);
    bit [31:0] expectedval = 32'h00000000;
    bit tmp_error_found = 0;
    
    error_found = 0;    
    $display("%t : Checking scalar registers", $time);

    check_32bitregister_value_with_gaps (GSCR_ADDR, 32'h00000000, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (GIER_ADDR, 32'h00000000, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (IPIER_ADDR, 32'h00000000, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (IPISR_ADDR, 32'h00000000, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (IPISR_ADDR, 32'h00000000, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (IDR_ADDR, 32'h0000FEED, 32'h0000FEED, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (VERR_ADDR, 32'h00000001, 32'h00000001, tmp_error_found);
    error_found |= tmp_error_found;

    expectedval=0;
    expectedval=SETCR_MME_MASK | SETCR_MODE_MASK; // LD reads zero
    check_32bitregister_value_with_gaps (SETCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=SPECR_DP_MASK;
    check_32bitregister_value_with_gaps (SPECR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=CSWCR_SW_MASK;
    check_32bitregister_value_with_gaps (CSWCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=XMRCR_XR_MASK;
    check_32bitregister_value_with_gaps (XMRCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=XMICR_XI_MASK;
    check_32bitregister_value_with_gaps (XMICR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=LSRCR_SR_MASK;
    check_32bitregister_value_with_gaps (LSRCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=LSICR_SI_MASK;
    check_32bitregister_value_with_gaps (LSICR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=DWCR_DW_MASK;
    check_32bitregister_value_with_gaps (DWCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=DHCR_DH_MASK;
    check_32bitregister_value_with_gaps (DHCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    expectedval=0;
    expectedval=ZOMCR_DH_MASK;
    check_32bitregister_value_with_gaps (ZOMCR_ADDR, expectedval, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
  endtask
  
  
  //---------------------------------------------------------------------------------- 
  //TEST TASKS 
  
  task automatic CHECK_REGISTERS;  
    $display("---------------------------------------------------------------");
    $display(" START TEST Check Registers");
    $display("---------------------------------------------------------------"); 
    check_scalar_registers(error_found);
    if(error_found == 1) begin
      $display( "Test Failed at Check Registers!");
      $finish();
    end else begin
      $display( "Test Check Registers ... OK");      
    end 
  endtask

  task automatic TEST_NO_MINIMAP;  
    $display("---------------------------------------------------------------");
    $display(" START TEST NO MINIMAP");
    $display("---------------------------------------------------------------"); 
    blocking_write_register(SETCR_ADDR, 32'h00000000); 
    blocking_write_register(SPECR_ADDR, 32'h00000001); 
    blocking_write_register(CSWCR_ADDR, 32'h00000001); 
    blocking_write_register(DWCR_ADDR, 32'h00000010); 
    blocking_write_register(DHCR_ADDR, 32'h00000010);
    blocking_write_register(ZOMCR_ADDR, 32'h00000001); 
    // Check manually
  endtask

  task automatic TEST_MINIMAP;  
    $display("---------------------------------------------------------------");
    $display(" START TEST MINIMAP");
    $display("---------------------------------------------------------------"); 
    blocking_write_register(SETCR_ADDR, SETCR_MME_MASK);
    blocking_write_register(SPECR_ADDR, 32'h00000001); 
    blocking_write_register(CSWCR_ADDR, 32'h00000001); 
    blocking_write_register(DWCR_ADDR, 32'h00000010); 
    blocking_write_register(DHCR_ADDR, 32'h00000010);
    blocking_write_register(ZOMCR_ADDR, 32'h00000001);
    // Check manually
  endtask
  
  //------------------------------------------------------------------------------------------------------
  //ACTUCAL TEST MAIN  
  initial begin : test_routine 
    //#2000
    //start_vips();
    //#1000
    #10
    start_vips();
    #10

    CHECK_REGISTERS();

    TEST_NO_MINIMAP();
    #1.5ms;
    TEST_MINIMAP();
    #1.5ms;
 
    $finish(); 
            
  end 
  
endmodule