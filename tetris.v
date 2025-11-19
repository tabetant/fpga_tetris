`default_nettype none

// Top-level: PS/2 keys -> clean pulses -> gamelogic -> painter.
// Clearing pass is disabled on reset to avoid the blank-screen issue for M2.

module tetris(
    SW, KEY, CLOCK_50, LEDR, PS2_CLK, PS2_DAT,
    VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
    input  [9:0] SW;
    input  [3:0] KEY;
    input        CLOCK_50;
    output [9:0] LEDR;

    output wire [7:0]  VGA_R, VGA_G, VGA_B;
    output wire        VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    // active–high resetn (KEY[3] not pressed = 1)
    wire resetn = KEY[3];

    // =========================================================
    // Ticks
    // =========================================================
    wire [4:0] score;
    wire       tick_input, tick_gravity;

    tick_i in (
        .CLOCK_50  (CLOCK_50),
        .resetn    (resetn),
        .tick_input(tick_
