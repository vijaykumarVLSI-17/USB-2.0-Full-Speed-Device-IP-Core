`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA  
//           (SoC Design & Verification Engineer)
// Create Date: 28.07.2025 12:44:19
// Design Name: BIT_STUFFER
// Module Name: bit_stuffer
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


module bit_stuffer(
    input clk,
    input rst,
    input data_valid,
    input data_in,
    output reg stuffed_data_out,
    output reg data_ready
);
 
 reg [2:0]bit_counter = 0;
 
 always@(posedge clk)begin
    if(!rst)begin
        bit_counter <= 0;
        stuffed_data_out <= 0;
        data_ready <= 0;
    end
    else begin
        if(data_valid)begin
            if(data_in == 1)begin
                bit_counter <= bit_counter + 1;
                if(bit_counter >= 6)begin
                    stuffed_data_out <= ~data_in;
                    bit_counter <= 0;
                    data_ready <= 1;
                end
                else begin
                    stuffed_data_out <= data_in;
                    data_ready <= 1;
                end
            end
            else begin
                bit_counter <= 0;
                stuffed_data_out <= data_in;
                data_ready <= 1;
            end
        end
        else 
            data_ready <= 0;
    end
 end
endmodule
// typedef enum logic [1:0]{IDLE, BIT_STUFF}bit_stuff_state_t;
// bit_stuff_state_t state;
 
// always @(posedge clk)begin
//    if(!rst)begin
//        bit_counter <= 0;
//        stuffed_data_out <= 'bx;
//        data_ready <= 0;
//        state <= IDLE;
//    end
//    else begin
//        case(state)
//            IDLE:begin
//                data_ready <= 0;
//                if(data_valid) state <= BIT_STUFF;
//                else state <= IDLE;    
//            end
//            BIT_STUFF:begin
//                data_ready <= 1;
//                if(data_in == 1)begin
//                    bit_counter <= bit_counter + 1;
//                    if(bit_counter == 6)begin
//                        stuffed_data_out <= 0;
//                        bit_counter <= 0;
//                    end
//                    else stuffed_data_out <= data_in;
//                    state <= IDLE;
//                end
//                else begin
//                    bit_counter <= 0;
//                    stuffed_data_out <= data_in;
//                    state <= IDLE;
//                end 
//            end
//        endcase
//    end
// end        
//endmodule
