`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA  
//           (SoC Design & Verification Engineer)
// Create Date: 28.07.2025 12:44:19
// Design Name: NRZI_ENCODER
// Module Name: nrzi_encoder
// Project Name: USB2.0
// Target Devices:FPGA based Embedded systems 
// Tool Versions:Vivado 2019.2 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module nrzi_encoder(
    input        clk,            // Clock (USB clk, e.g., 48MHz)
    input        rst,            // Synchronous reset
    input        data_valid,     // Valid signal for input bit
    input        data_in,        // Single-bit data to be encoded
    output reg   data_out,       // NRZI encoded bit
    output reg   data_ready      // High when data_out is valid
);

 always@(posedge clk)begin
     if(!rst)begin
        data_out <= 1; //start at J state  
        data_ready <= 0;
     end
     else begin
        data_ready <= 0;
        if(data_valid)begin
            if(data_in == 0)begin
                data_out <= ~data_out;
                data_ready <= 1;
            end
            else begin
                data_out <= data_out;
                data_ready <= 1;
            end
        end
     end
 end   
endmodule