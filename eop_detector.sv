`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2025 21:08:45
// Design Name: 
// Module Name: eop_detector
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


module eop_detector(
    input clk,      //reference clk 48MHz
    input rst_n,    //Active low reset synchronous reset
    input [1:0]line_state_in,   //coming from the line state detector through BCR module
    input line_state_valid,     //bit strobe valid coming from the BCR module
    input phase_lock,
    output reg eop_detected     // end of detected when SE0>=2 bit strobes + j state
);
    reg [1:0]count;
    
    always@(posedge clk)begin
        if(!rst_n)begin
            eop_detected <= 0;
            count <= 0;
        end
        else begin
            eop_detected <= 0;
            if(line_state_valid)begin
                if(line_state_in == 2'b00)
                    count <= count + 1;
                else if(line_state_in == 2'b01)begin
                    if(count >= 2)begin
                        eop_detected <= 1;
                        count <= 0;
                    end
                end
                else count <= 0;
            end
        end
    end
endmodule
