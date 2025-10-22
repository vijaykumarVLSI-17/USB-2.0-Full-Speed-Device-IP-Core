`timescale 1ns / 1ps

module bit_clock_recovery #(
    // Parameters for portability
    parameter REF_CLK_FREQ   = 48_000_000,   // Reference clock frequency in Hz
    parameter USB_BIT_RATE   = 12_000_000,   // Target USB bit rate (FS = 12 Mbps)
    parameter LOCK_COUNT_MAX = 3,            // # of good strobes before declaring lock
    parameter UNLOCK_COUNT_MAX = 4           // # of misses before losing lock
)(
    input  wire clk,             // Reference clock (e.g., 48 MHz)
    input  wire rst_n,           // Active-low synchronous reset
    input  wire [1:0] line_state,// From line_state_detector (J/K states)
    output reg  bit_strobe,      // Sample enable pulse (1 clk wide)
    output wire locked,          // Lock status
    output reg  [1:0] line_state_sync // Synchronized line state (safe for downstream use)
);

    // Derived parameter
    localparam BIT_PERIOD_TICKS = REF_CLK_FREQ / USB_BIT_RATE; // e.g., 48/12 = 4

    // ----------------------------------------------------
    // Synchronizer for line_state (avoid metastability)
    // ----------------------------------------------------
    reg [1:0] line_sync_0, line_sync_1;

    always @(posedge clk) begin
        if (!rst_n) begin
            line_sync_0 <= 2'b00;
            line_sync_1 <= 2'b00;
        end else begin
            line_sync_0 <= line_state;
            line_sync_1 <= line_sync_0;
        end
    end

    assign line_state_sync = line_sync_1;

    // ----------------------------------------------------
    // Bit timing and strobe generation
    // ----------------------------------------------------
    reg [2:0] bit_timer; // Enough bits to count up to 4

    always @(posedge clk) begin
        if (!rst_n) begin
            bit_timer  <= 3'd0;
            bit_strobe <= 1'b0;
        end else begin
            bit_strobe <= 1'b0; // Default low each cycle

            // Transition detected -> reset timer
            if (line_sync_0 != line_state_sync) begin
                bit_timer <= 3'd0;
            end
            // Mid-bit strobe
            else if (bit_timer == (BIT_PERIOD_TICKS/2 - 1)) begin
                bit_strobe <= 1'b1;
                bit_timer  <= bit_timer + 3'd1;
            end
            // End of bit period -> wrap
            else if (bit_timer == (BIT_PERIOD_TICKS - 1)) begin
                bit_timer <= 3'd0;
            end
            // Keep counting
            else begin
                bit_timer <= bit_timer + 3'd1;
            end
        end
    end

    // ----------------------------------------------------
    // Lock / Unlock logic
    // ----------------------------------------------------
//    reg [3:0] lock_count;
//    reg [2:0] unlock_count;
//    reg       locked_reg;

//    assign locked = locked_reg;

//    always @(posedge clk) begin
//        if (!rst_n) begin
//            lock_count   <= 0;
//            unlock_count <= 0;
//            locked_reg   <= 1'b0;
//        end else begin
//            if (bit_strobe) begin
//                // Good strobe event
//                if (!locked_reg) begin
//                    if (lock_count < LOCK_COUNT_MAX)
//                        lock_count <= lock_count + 1;
//                    if (lock_count == LOCK_COUNT_MAX - 1)
//                        locked_reg <= 1'b1; // Declare lock
//                end else begin
//                    // Already locked -> keep saturated
//                    lock_count   <= LOCK_COUNT_MAX;
//                    unlock_count <= 0;
//                end
//            end else begin
//                // No strobe -> potential unlock
//                if (locked_reg) begin
//                    if (unlock_count < UNLOCK_COUNT_MAX)
//                        unlock_count <= unlock_count + 1;
//                    if (unlock_count == UNLOCK_COUNT_MAX - 1)
//                        locked_reg <= 1'b0; // Lose lock
//                end
//            end
//        end
//    end

endmodule
