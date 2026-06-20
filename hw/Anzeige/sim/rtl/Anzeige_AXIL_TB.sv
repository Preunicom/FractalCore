////////////////////////////////////////////////////////
//
// author: Markus Remy
// Used template of the CSA course of Mr. Münch
//
////////////////////////////////////////////////////////

`timescale 1ns / 1ps
 
import axi_vip_pkg::*;
import VIP_AXIL_Anzeige_TB_axi_vip_0_0_pkg::*; // check instance name in block design <blockdesign-name>_<vip-inst-name>_0_pkg)

module Anzeige_TB();

  //CONSTANT DEFINITIONS
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12;
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32;
    
  //REGISTER DEFINITIONS
  parameter COL_ITER_BASE_ADDR      = 9'h000; // - 0x3FC
  parameter COL_CONV_ADDR           = 9'h400;
  parameter COL_TARGET_MASK         = 9'h404;
  parameter COL_PIXEL_MASK          = 9'h408;
  parameter COL_MASK                = 32'h00FFFFFF;
  
  //BUFFER DEFINITIONS (not used so far)

  //FURTHER DEFINITIONS
  VIP_AXIL_Anzeige_TB_axi_vip_0_0_mst_t mst_ctrl_agent; // check instance name in block design (<blockdesign-name>_<vip-inst-name>_0_mst_t)
  //clock frequency definition

  parameter real CLK_PERIOD = 2;
  parameter real VGA_CLK_PERIOD = 3;
  parameter real AXI_CLK_PERIOD = 1;
  bit error_found = 0;

  //--------------------------------------------------------------------------------------
  //SYSTEM DEFINITION (system instances and signals)
  //CLK

  logic i_vga_clk = 0;
  initial begin: VGA_CLK_GEN
    forever begin
      i_vga_clk = #(VGA_CLK_PERIOD/2) ~i_vga_clk;
    end
  end

  logic i_axi_clk = 0;
  initial begin: AXI_CLK_GEN
    forever begin
      i_axi_clk = #(AXI_CLK_PERIOD/2) ~i_axi_clk;
    end
  end

  //RESET
  logic i_vga_rstn = 0;
  initial begin: VGA_RST_GWN
    vga_rst_n_sequence(16);
  end

  logic i_axi_rst_n = 0;
  initial begin: AXI_RST_GEN
    axi_rst_n_sequence(16);
  end

  //SYSTEM DESIGN WRAPPER instance
  logic [7:0] i_cycles_until_divergent_0 = 0;
  logic i_is_convergent_0 = 0;
  logic i_valid_0 = 0;
  logic [1:0] i_video_frame_idx_0 = 0;
  logic [9:0] i_video_pix_col_0 = 0;
  logic [8:0] i_video_pix_row_0 = 0;
  logic o_ready_0;
  logic o_vga_blank_0;
  logic [7:0] o_vga_red_0;
  logic [7:0] o_vga_green_0;
  logic [7:0] o_vga_blue_0;
  logic o_vga_h_sync_0;
  logic o_vga_v_sync_0;
  logic [38:0] i_highlight_ch0_0 = {
      1'b1,
      9'd0,
      8'd0,
      9'd10,
      8'd10
  };
  logic [38:0] i_highlight_ch1_0 = {
      1'b0,
      9'd0,
      8'd0,
      9'd0,
      8'd0
  };
  logic [38:0] i_highlight_ch2_0 = {
      1'b1,
      9'd331,
      8'd190,
      9'd639,
      8'd400
  };
  logic [38:0] i_highlight_ch3_0 = {
      1'b0,
      9'd0,
      8'd0,
      9'd0,
      8'd0
  };

  //check instance name in block design -> <blockdesign_name>_wrapper 
  VIP_AXIL_Anzeige_TB_wrapper DUT(
    .i_axi_clk(i_axi_clk),
    .i_axi_rst_n(i_axi_rst_n),
    .i_cycles_until_divergent_0(i_cycles_until_divergent_0),
    .i_highlight_ch0_0(i_highlight_ch0_0),
    .i_highlight_ch1_0(i_highlight_ch1_0),
    .i_highlight_ch2_0(i_highlight_ch2_0),
    .i_highlight_ch3_0(i_highlight_ch3_0),
    .i_is_convergent_0(i_is_convergent_0),
    .i_valid_0(i_valid_0),
    .i_vga_clk_0(i_vga_clk),
    .i_vga_rstn(i_vga_rstn),
    .i_video_frame_idx_0(i_video_frame_idx_0),
    .i_video_pix_col_0(i_video_pix_col_0),
    .i_video_pix_row_0(i_video_pix_row_0),
    .o_ready_0(o_ready_0),
    .o_vga_blank_0(o_vga_blank_0),
    .o_vga_red_0(o_vga_red_0),
    .o_vga_green_0(o_vga_green_0),
    .o_vga_blue_0(o_vga_blue_0),
    .o_vga_h_sync_0(o_vga_h_sync_0),
    .o_vga_v_sync_0(o_vga_v_sync_0)
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
  
  task automatic vga_rst_n_sequence(input integer unsigned width = 20);
    @(posedge i_vga_clk);
    #1ns;
    i_vga_rstn = 0;
    repeat (width) @(posedge i_vga_clk);
    #1ns;
    i_vga_rstn = 1;
  endtask

  task automatic axi_rst_n_sequence(input integer unsigned width = 20);
    @(posedge i_axi_clk);
    #1ns;
    i_axi_rst_n = 0;
    repeat (width) @(posedge i_axi_clk);
    #1ns;
    i_axi_rst_n = 1;
  endtask

  task automatic start_vips();
    $display("//////////////////////////////////////////////////////////////");
    $display("Start Axi Control Master");    
    mst_ctrl_agent = new("master_ctrl_agent", DUT.VIP_AXIL_Anzeige_TB_i.axi_vip_0.inst.IF); // check instance name in block design DUT.<blockdesign-name>_<vip-inst-name>.inst.IF
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
    bit [31:0] current_addr = 0;
    bit [31:0] expectedval = 32'h00000000;
    bit tmp_error_found = 0;
    
    error_found = 0;    
    $display("%t : Checking scalar registers", $time);

    for (int i = 0; i <= 255; i++) begin
      current_addr = COL_ITER_BASE_ADDR + (i * 4);
      check_32bitregister_value_with_gaps(current_addr, 32'hffffffff, 32'h00000000, tmp_error_found); // All writable but only lower 24 bit have impact
      error_found |= tmp_error_found;
    end

    check_32bitregister_value_with_gaps (COL_CONV_ADDR, 32'hffffffff, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (COL_PIXEL_MASK, 32'hffffffff, 32'h00000000, tmp_error_found);
    error_found |= tmp_error_found;
    check_32bitregister_value_with_gaps (COL_TARGET_MASK, 32'hffffffff, 32'h00000000, tmp_error_found);
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

  task automatic SET_COLORS;
    bit [31:0] current_addr = 0;
    $display("---------------------------------------------------------------");
    $display(" Setting Colors...");
    $display("---------------------------------------------------------------");
    for (int i = 0; i < 50; i++) begin
      current_addr = COL_ITER_BASE_ADDR + (i * 4);
      blocking_write_register(current_addr, 32'h000000FF); // Red
    end
    for (int i = 50; i <= 255; i++) begin
      current_addr = COL_ITER_BASE_ADDR + (i * 4);
      blocking_write_register(current_addr, 32'h0000FF00); // Green
    end
    blocking_write_register(COL_CONV_ADDR, 32'h0000FFFF); // Yellow
    blocking_write_register(COL_PIXEL_MASK, 32'h00FF0000); // Blue
    blocking_write_register(COL_TARGET_MASK, 32'h00FF0000); // Blue
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
    #10
    SET_COLORS();
    #10

    for(int i = 0; i < 5; i++) begin
      @(posedge o_vga_v_sync_0); // Wait until 5 frames were sent
    end
  
    $finish();      
  end 

  task automatic wait_for_handshake();
    begin
      do begin
        @(posedge i_axi_clk);
      end while (!(i_valid_0 && o_ready_0));
    end
  endtask

  integer stimuli_counter;

  initial begin : STIMULI
    stimuli_counter = 0;
    // wait for reset release
    wait (i_axi_rst_n == 1);
    // Send data too early --> Should never show as it will be bypassed and then overridden
    for (int x = 0; x < 640; x++) begin
      i_valid_0                 = 1;
      i_video_pix_col_0         = x;
      i_video_pix_row_0         = 0;
      i_video_frame_idx_0       = 1;  // too early data
      i_cycles_until_divergent_0 = '1;
      i_is_convergent_0         = 0;
      wait_for_handshake();
    end
    for (int idx = 0; idx < 5; idx++) begin
      for (int y = 0; y < 480; y++) begin
        for (int x = 0; x < 640; x++) begin
          i_valid_0                  = 1;
          i_video_pix_col_0          = x;
          i_video_pix_row_0          = y;
          i_video_frame_idx_0        = idx % 4;
          i_cycles_until_divergent_0 = stimuli_counter[7:0];
          if (stimuli_counter == 101)
            i_is_convergent_0 = 1;
          else
            i_is_convergent_0 = 0;
          wait_for_handshake();
          stimuli_counter++;
          if (stimuli_counter == 102)
            stimuli_counter = 0;
        end
        stimuli_counter = idx + (y % 91);
      end
      stimuli_counter = idx;
    end
    i_valid_0 = 0;
  end

endmodule