`timescale 1ns/1ps
`default_nettype none

module tb_render_box20;

    // DUT inputs
    reg        CLOCK_50;
    reg        resetn;      // active-high
    reg        start;
    reg [9:0]  x0;
    reg [8:0]  y0;
    reg [8:0]  color;

    // DUT outputs (VGA signals)
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire       VGA_HS;
    wire       VGA_VS;
    wire       VGA_BLANK_N;
    wire       VGA_SYNC_N;
    wire       VGA_CLK;

    // Instantiate DUT
    render_box20 dut (
        .CLOCK_50   (CLOCK_50),
        .resetn     (resetn),
        .start      (start),
        .x0         (x0),
        .y0         (y0),
        .color      (color),
        .VGA_R      (VGA_R),
        .VGA_G      (VGA_G),
        .VGA_B      (VGA_B),
        .VGA_HS     (VGA_HS),
        .VGA_VS     (VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N (VGA_SYNC_N),
        .VGA_CLK    (VGA_CLK)
    );

    // 50 MHz clock: period = 20 ns
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        // Init
        resetn = 1'b0;
        start  = 1'b0;
        x0     = 10'd50;              // box top-left X
        y0     = 9'd40;               // box top-left Y
        color  = 9'b111_000_000;      // red box

        // Hold reset low for a bit
        #100;
        resetn = 1'b1;

        // Wait a few cycles after reset
        #100;

        // Pulse start for one clock to trigger draw
