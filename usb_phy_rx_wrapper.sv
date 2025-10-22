`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2025 14:54:03
// Design Name: 
// Module Name: usb_phy_rx_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module usb_phy_rx_wrapper #(
    parameter REF_CLK_FREQ   = 48_000_000,   // Reference clock frequency in Hz
    parameter USB_BIT_RATE   = 12_000_000   // Target USB bit rate (FS = 12 Mbps)
    )(
    input wire clk,
    input wire rst_n,
    input wire usb_dp,
    input wire usb_dn,
    output wire data_out,
    output wire data_valid,
    output wire sync_detected,
    output wire eop_detected,
    output wire phase_locked,
    output wire data_error
);
    wire [1:0]line_state_w;
    wire [1:0]line_sync_w;
    wire strobe_valid_w;
    wire phase_lock_w;
    wire nrzi_out_valid_w;
    wire nrzi_out_data_w;
    wire unstuff_valid_w;
    wire unstuff_data_w;
    
    //***Line state detector***//
    line_state_detector u_line_state (
        .clk(clk),
        .rst(rst_n),
        .usb_dp_i(usb_dp),
        .usb_dn_i(usb_dn),
        .line_state_valid(),
        .SE0_detected(),
        .line_state(line_state_w)
    );
    
    
    //***Bit Clock Recovery Module***//
    bit_clock_recovery #(
        .REF_CLK_FREQ(REF_CLK_FREQ),
        .USB_BIT_RATE(USB_BIT_RATE)
        )u_BCR(
        .clk(clk),
        .rst_n(rst_n),
        .line_state(line_state_w),
        .bit_strobe(strobe_valid_w),
        .locked(phase_lock_w),
        .line_state_sync(line_sync_w)
   );
   
  
   //***END OF POINT(EOP) Detector module***//
   eop_detector u_eop_detector (
        .clk(clk),
        .rst_n(rst_n),
        .line_state_in(line_sync_w),
        .line_state_valid(strobe_valid_w),
        .phase_lock(phase_lock_w),
        .eop_detected(eop_detected)
   );
   

   //***NRZI Decoder module***//
   nrzi_decoder u_nrzi_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .data_valid(strobe_valid_w),
        .phase_lock(phase_lock_w),
        .data_in(line_sync_w),
        .data_out(nrzi_out_data_w),
        .data_ready(nrzi_out_valid_w)
   );
   
   
   //***BIT Unstuffer Module***//
   bit_unstuffer  u_bit_unstuffer (
        .clk(clk),
        .rst(rst_n),
        .data_valid(nrzi_out_valid_w),
        .data_in(nrzi_out_data_w),
        .unstuffed_data_out(unstuff_data_w),
        .data_ready(unstuff_valid_w),
        .bit_stuff_error(data_error)
   ); 
   
   
 
   //***SYNC Detector Module***//
   sync_detector u_sync_detect (
        .clk(clk),
        .rst(rst_n),
        .data_valid(unstuff_valid_w),
        .data_in(unstuff_data_w),
        .sync_detected(sync_detected)
   );
   
   // Final output mapping
    assign data_out     = unstuff_data_w;
    assign data_valid   = unstuff_valid_w;
    assign phase_locked = phase_lock_w;
endmodule
