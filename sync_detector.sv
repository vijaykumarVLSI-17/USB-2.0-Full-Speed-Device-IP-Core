`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2025 16:08:59
// Design Name: 
// Module Name: sync_detector
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


module sync_detector (
    input  wire clk,
    input  wire rst,
    input  wire data_valid,     // unstuffed data valid
    input  wire data_in,        // unstuffed bit-stream (1 bit at a time)
    output reg  sync_detected   // high for 1 clk cycle on SYNC match
);

    logic [7:0] sync_shift_reg;
    
    always @(posedge clk) begin
      if (!rst) begin
        sync_shift_reg <= 8'b0;
        sync_detected <= 0;
      end else if (data_valid) begin
        sync_shift_reg <= {data_in, sync_shift_reg[7:1]};
        if (sync_shift_reg == 8'b10000000)
          sync_detected <= 1;
        else
          sync_detected <= 0;
      end
    end
endmodule

