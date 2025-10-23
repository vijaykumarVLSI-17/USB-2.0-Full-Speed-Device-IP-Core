`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2025 16:14:02
// Design Name: BYTE_BUFFER
// Module Name: byte_buffer
// Project Name: USB 2.0 full speed device IP core
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////*
//****I'm Creating this byte_buffer module to buffer the data synchronously in a byte format which is coming 'bit-by-bit' 
//from the PHY Interface Layer by storing the incoming bits in a 8-bit width(a byte) buffer then it transmit
// the data 'byte-by-byte' to PACKET_PARSER module(Protocol Layer).
//////////////////////////////////////////////////////////////////////////////////


module byte_buffer #(
    parameter buffer_width = 8, 
    parameter buffer_depth = 16)(
    input wire clk,
    input wire rst_n,
    input wire data_in,
    input wire data_valid,
    input wire ready_to_accept,
    output reg [buffer_width -1:0]buffer_data,    
    output reg buffer_valid,
    output reg full,
    output reg empty
);
  reg [buffer_width -1:0]buffer[buffer_depth -1:0];
  reg [$clog2(buffer_depth) - 1:0]wr_ptr, rd_ptr;
  reg [7:0]bit_accumalator;
  reg [2:0]bit_count;
  wire nxt_wr_ptr ;
  assign nxt_wr_ptr = wr_ptr + 1;
  assign buffer_valid = (ready_to_accept && !empty) ? 1 : 0 ;
  always@(posedge clk)begin
    if(!rst_n)begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        bit_accumalator <= 0;
        bit_count <= 0;
    end
    else if(data_valid)begin
        if(bit_count == 3'd7 && !full)begin
            buffer[wr_ptr] <= {bit_accumalator[6:0], data_in};
            wr_ptr <= nxt_wr_ptr ;
            bit_count <= 0;
        end
        else begin
            bit_accumalator <= {bit_accumalator[6:0], data_in};
            bit_count <= bit_count + 1;
        end
     end
     
     else if(ready_to_accept && !empty)begin
            buffer_data <= buffer[rd_ptr];
//            buffer_valid <= 1;
            rd_ptr <= rd_ptr + 1;
     end
     
     full <= (wr_ptr == buffer_depth - 1) && (nxt_wr_ptr == rd_ptr);
     empty <= (wr_ptr == rd_ptr);
  
  end    
    
endmodule
