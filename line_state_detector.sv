`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2025 14:34:08
// Design Name: 
// Module Name: line_state_detector
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

module line_state_detector(
    input wire clk,
    input wire rst,
    input wire usb_dp_i,
    input wire usb_dn_i,
    output reg line_state_valid,
    output reg SE0_detected,
    output reg [1:0]line_state
);

localparam J_state = 2'b01;
localparam K_state = 2'b10;
localparam SE0_state = 2'b00;
localparam Illegal = 2'b11;

    always@(posedge clk)begin
        if(!rst)begin
            line_state_valid <= 1'b0;
            SE0_detected <= 1'b0;
            line_state <= 2'b11;
        end
        else begin
            if(usb_dp_i == 0 && usb_dn_i == 0)begin
                SE0_detected <= 1;
                line_state_valid <= 1;
                line_state <= SE0_state;
            end
            else if(usb_dp_i == 1 && usb_dn_i == 0)begin
                line_state_valid <= 1;
                line_state <= J_state;
                SE0_detected <= 0;
            end
            else if(usb_dp_i == 0 && usb_dn_i == 1)begin
                line_state_valid <= 1;
                line_state <= K_state;
                SE0_detected <= 0;
            end
            else if(usb_dp_i == 1 && usb_dn_i == 1)begin
                line_state_valid <= 0;
                line_state <= Illegal;
                SE0_detected <= 0;
            end
            else begin
                SE0_detected <= 0;
                line_state_valid <= 0;
                line_state <= Illegal;
            end
        end
    end
    
endmodule
