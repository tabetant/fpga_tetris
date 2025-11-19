`timescale 1ns/1ps
`default_nettype none

module tetris_tb;

    // ==============================
    // DUT top-level I/O
    // ==============================
    reg  [9:0] SW;
    reg  [3:0] KEY;
    reg        CLOCK_50;
    reg        PS2_CLK;
    reg        PS2_DAT;

    wire [9:0] LEDR;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire       VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    // ==============================
    // DUT instance
    // ==============================
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

    // ==============================
    // 50 MHz clock: 20 ns period
    // ==============================
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // ==============================
    // Stimulus
    // ==============================
    initial begin
        // Safe initial values
        SW      = 10'd0;
        KEY     = 4'b0000;     // KEY[3] = 0 -> resetn = 0 inside tetris
        PS2_CLK = 1'b1;        // PS/2 idle
        PS2_DAT = 1'b1;

        // Hold reset for a bit
        #200;                  // 200 ns
        KEY[3] = 1'b1;         // release reset (resetn = KEY[3])

        // After this we just let it run.
        // Gravity tick comes from your tick_g module.
        // PS/2 is idle (no moves) so you see pure gravity behavior.
    end

endmodule

`default_nettype wire
