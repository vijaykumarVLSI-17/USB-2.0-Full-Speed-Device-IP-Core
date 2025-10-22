`timescale 1ns / 1ps

module nrzi_decoder (
    input        clk,          // System clock
    input        rst_n,        // Active-low synchronous reset
    input        data_valid,   // High when input bit is valid (from BCR bit_strobe)
    input        phase_lock,   // High when BCR is locked
    input  [1:0] data_in,      // 2-bit line state (J/K)
    output reg   data_out,     // Decoded bit
    output reg   data_ready    // High when data_out is valid
);

    // Map line_state to a 1-bit J/K representation
    wire jk_bit;
    assign jk_bit = (data_in == 2'b01) ? 1'b1 :    // J ? 1
                    (data_in == 2'b10) ? 1'b0 :    // K ? 0
                     1'bx;                         // SE0/SE1 ? invalid

    reg prev_jk;

    always @(posedge clk) begin
        if (!rst_n) begin
            prev_jk    <= 1'b1;   // USB idle = J ? initialize as '1'
            data_out   <= 1'b0;
            data_ready <= 1'b0;
        end else begin
            data_ready <= 1'b0; // default

            // Decode only when phase is locked and line state is valid
            if (data_valid && (data_in == 2'b01 || data_in == 2'b10)) begin
                // NRZI decoding: transition = 0, no transition = 1
                data_out   <= (jk_bit == prev_jk) ? 1'b1 : 1'b0;
                data_ready <= 1'b1;
                prev_jk    <= jk_bit;
            end
        end
    end

endmodule
