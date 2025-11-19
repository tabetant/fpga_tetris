`timescale 1ns/1ps

// Simple testbench for the gamelogic module only.
// - Drives a 50 MHz clock
// - Applies a reset
// - Generates some gravity ticks
// - Gives a few left/right/rotate pulses
// Board is assumed empty (board_rdata = 0).

module gamelogic_tb;

    // Clock + reset
    reg CLOCK_50;
    reg resetn;

    // Clean input pulses (these are the debounced / rate-limited signals)
    reg left_final;
    reg right_final;
    reg rot_final;
    reg tick_gravity;

    // Board interface (for M2, board is effectively empty)
    reg        board_rdata;
    wire [3:0] board_rx;
    wire [4:0] board_ry;
    wire       board_we;
    wire [3:0] board_wx;
    wire [4:0] board_wy;
    wire       board_wdata;

    // Outputs we care about
    wire [9:0] LEDR;      // for sanity / debugging, but we won't add it to waves
    wire [4:0] score;
    wire [3:0] cur_x;
    wire [4:0] cur_y;
    wire       move_accept;

    // DUT: your gamelogic module
    gamelogic dut (
        .LEDR        (LEDR),
        .CLOCK_50    (CLOCK_50),
        .resetn      (resetn),
        .left_final  (left_final),
        .right_final (right_final),
        .rot_final   (rot_final),
        .tick_gravity(tick_gravity),

        .board_rdata (board_rdata),
        .board_rx    (board_rx),
        .board_ry    (board_ry),
        .board_we    (board_we),
        .board_wx    (board_wx),
        .board_wy    (board_wy),
        .board_wdata (board_wdata),

        .score       (score),
        .cur_x       (cur_x),
        .cur_y       (cur_y),
        .move_accept (move_accept)
    );

    // 50 MHz clock: 20 ns period
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;   // 20 ns
    end

    // Simple "always empty" board
    initial begin
        board_rdata = 1'b0;
    end

    // Reset + stimulus
    initial begin
        // Initial values
        resetn      = 1'b0;
        left_final  = 1'b0;
        right_final = 1'b0;
        rot_final   = 1'b0;
        tick_gravity= 1'b0;

        // Hold reset for a few cycles
        #200;            // 200 ns
        resetn = 1'b1;   // release reset

        // Small delay after reset before we start poking it
        #100_000;        // 100 us

        // A few manual moves (1-clock pulses)
        // Left
        left_final = 1'b1;  #20; left_final = 1'b0;   // 1 clock
        #200_000; // 200 us

        // Right
        right_final = 1'b1; #20; right_final = 1'b0;  // 1 clock
        #200_000; // 200 us

        // Rotate
        rot_final = 1'b1;   #20; rot_final = 1'b0;    // 1 clock

        // Now generate a bunch of gravity ticks so we can watch the piece fall.
        // One gravity tick every 2 ms.
        repeat (200) begin
            #2_000_000;           // 2 ms between ticks (with `timescale 1ns`)
            tick_gravity = 1'b1;  // 1 clock-wide pulse
            #20;
            tick_gravity = 1'b0;
        end

        // After this, simulation can keep running; .do file controls total time.
    end

endmodule
