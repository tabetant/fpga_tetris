`timescale 1ns/1ps

// Testbench for the top-level tetris module.
// - 50 MHz clock
// - KEY[3] used as reset (active-high resetn inside tetris)
// - PS2 lines held idle (no keypresses)
// - SW unused => tied low

module tetris_tb;

    // Top-level inputs
    reg  [9:0] SW;
    reg  [3:0] KEY;
    reg        CLOCK_50;
    reg        PS2_CLK;
    reg        PS2_DAT;

    // Top-level outputs
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
        forever #10 CLOCK_50 = ~CLOCK_50; // 20 ns
    end

    // Drive inputs
    initial begin
        // Initial conditions
        SW      = 10'd0;      // all switches low
        KEY     = 4'b0000;    // KEY[3] = 0 -> resetn = 0 inside tetris
        PS2_CLK = 1'b1;       // PS/2 idle high
        PS2_DAT = 1'b1;       // PS/2 idle high

        // Hold reset for a bit (several clock cycles)
        #200;                 // 200 ns
        KEY[3] = 1'b1;        // release reset (resetn = 1)

        // After this we just let the design run.
        // tick_input/tick_gravity are generated internally.
        // If you want to inject PS/2 keypresses later,
        // you can add a PS2 stimulus process here.
    end

endmodule
