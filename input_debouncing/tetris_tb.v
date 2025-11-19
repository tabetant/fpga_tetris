`timescale 1ns/1ps

module tetris_tb;

    // Top-level inputs
    reg  [9:0] SW;
    reg  [3:0] KEY;
    reg        CLOCK_50;
    reg        PS2_CLK, PS2_DAT;

    // Top-level outputs (we won't really use them in the waves)
    wire [9:0] LEDR;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire       VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    // DUT
    tetris dut (
        .SW       (SW),
        .KEY      (KEY),
        .CLOCK_50 (CLOCK_50),
        .LEDR     (LEDR),
        .PS2_CLK  (PS2_CLK),
        .PS2_DAT  (PS2_DAT),
        .VGA_R    (VGA_R),
        .VGA_G    (VGA_G),
        .VGA_B    (VGA_B),
        .VGA_HS   (VGA_HS),
        .VGA_VS   (VGA_VS),
        .VGA_BLANK_N (VGA_BLANK_N),
        .VGA_SYNC_N  (VGA_SYNC_N),
        .VGA_CLK     (VGA_CLK)
    );

    // 50 MHz clock: 20 ns period
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50; // 20 ns period
    end

    // Stimulus
    initial begin
        // Initial values
        SW      = 10'd0;
        KEY     = 4'b0000;   // KEY[3] = 0 -> resetn = 0 (in reset)
        PS2_CLK = 1'b1;      // idle PS/2
        PS2_DAT = 1'b1;

        // Hold reset for a bit
        #200;
        KEY[3] = 1'b1;       // release reset (resetn = KEY[3] = 1)

        // You can add more fancy stuff later if you want
        // (e.g., tap reset again, change SW, etc.)

        // Let the design run; ModelSim .do script will decide how long
    end

endmodule
