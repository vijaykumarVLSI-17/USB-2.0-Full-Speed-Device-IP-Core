`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.07.2025 12:55:42
// Design Name: 
// Module Name: bit_unstuffer
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

module bit_unstuffer(
    input clk,
    input rst,
    input data_valid,
    input data_in,
    output reg unstuffed_data_out,
    output reg data_ready,
    output reg bit_stuff_error
 );
 
  reg [2:0]counter;
  
  always@(posedge clk)begin
    if(!rst)begin
        counter <= 0;
        data_ready <= 0;
        bit_stuff_error <= 0;
        unstuffed_data_out <= 0;
    end
    else begin
        if(data_valid)begin
            if(data_in == 1)begin
                counter <= counter + 1;
                if(counter >= 6)begin
                    bit_stuff_error <= 1;
                    data_ready <= 0;
                    counter <= 0;
                end
                else begin
                    unstuffed_data_out <= data_in;
                    data_ready <= 1;
                    bit_stuff_error <= 0;
                end
            end
            else begin
                if(counter >= 6)begin
                    unstuffed_data_out <= ~data_in;
                    data_ready <= 1;
                    counter <= 0;
                end
                else begin
                    unstuffed_data_out <= data_in;
                    data_ready <= 1;
                    counter <= 0;
                end
            end
        end
        else data_ready <= 0;
    end
  end
endmodule
  
  
  
  
  
//  typedef enum logic [1:0]{IDLE, BIT_UNSTUFF}bit_unstuff_state_t;
//  bit_unstuff_state_t state;
  
//  always@(posedge clk)begin
//    if(!rst) counter <= 0;
//    else begin
//        if(data_valid) 
//            counter <= (data_in) ? counter + 1 : 0;
//    end
//  end
  
//  always @(posedge clk) begin
//    if (!rst) begin
//        counter <= 0;
//        data_ready <= 0;
//        bit_stuff_error <= 0;
//        unstuffed_data_out <= 0;
//        state <= IDLE;
//    end 
//    else begin
//        case(state)
//            IDLE: begin
//                bit_stuff_error <= 0;
//                if (data_valid) begin
//                    unstuffed_data_out <= data_in;
//                    data_ready <= 1;
//                    counter <= (data_in) ? 1 : 0;  // start counting consecutive 1s if data_in=1 else 0
//                    state <= BIT_UNSTUFF;
//                end 
//                else begin
//                    data_ready <= 0;
//                end
//            end
//            BIT_UNSTUFF: begin
//                if (data_valid) begin
//                    if (counter == 6 && data_in) begin
//                        bit_stuff_error <= 1;
//                        data_ready <= 0;
//                        counter <= 0;
//                        $display("****----------Ignore the packet(7'consecutive 1's)-------------*****");
//                        state <= IDLE;
//                    end
//                    else if (counter == 6 && !data_in) begin
//                        data_ready <= 0;
//                        // Either hold last value or output 0 instead of 'bx' to avoid undefined
//                        unstuffed_data_out <= 0;
//                        counter <= 0;
//                        state <= IDLE;
//                        $display("***-----stuffed bit detected and IGNORED it by deasserting data_ready------***");
//                    end
//                    else begin
//                        unstuffed_data_out <= data_in;
//                        data_ready <= 1;
//                        counter <= (data_in) ? counter + 1 : 0;
//                    end
//                end 
//                else begin
//                    data_ready <= 0;  // no valid data, no output ready
//                end
//            end
//       endcase
//    end
//  end
//endmodule 


  
