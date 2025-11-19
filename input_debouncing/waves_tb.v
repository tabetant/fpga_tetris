`timescale 1ns/1ps

// Ultra-simple fake wave generator for Tetris-like signals.
// No DUT, no other modules. Just drives registers over time.

module waves_tb;

    // "Clock" and control-ish inputs
    reg CLOCK_50;
    reg resetn;
    reg left_final;
    reg right_final;
    reg rot_final;
    reg tick_gravity;

    // Game-style internal signals
    reg [3:0] state;
    reg [3:0] next_state;
    reg [4:0] piece_x;
    reg [4:0] piece_y;
    reg [4:0] cur_x;
    reg [4:0] cur_y;
    reg [2:0] rot;
    reg [2:0] shape_id;
    reg [4:0] score;
    reg       move_accept;
    reg       lock_phase;
    reg       have_action;
    reg       collide;

    integer i;

    // Simple "50 MHz" clock: 20 ns period
    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        // ---- Explicit initial values at time 0 ----
        CLOCK_50    = 1'b0;
        resetn      = 1'b0;
        left_final  = 1'b0;
        right_final = 1'b0;
        rot_final   = 1'b0;
        tick_gravity = 1'b0;

        state       = 4'd0;  // IDLE
        next_state  = 4'd0;
        piece_x     = 5'd4;
        piece_y     = 5'd0;
        cur_x       = 5'd4;
        cur_y       = 5'd0;
        rot         = 3'd0;
        shape_id    = 3'd1;
        score       = 5'd0;
        move_accept = 1'b0;
        lock_phase  = 1'b0;
        have_action = 1'b0;
        collide     = 1'b0;

        // ---- Reset deassert ----
        #200;              // 200 ns
        resetn = 1'b1;

        // ---- Spawn ----
        #1_000_000;        // 1 ms
        state      = 4'd1; // SPAWN
        next_state = 4'd2; // FALL

        #1_000_000;        // 1 ms
        state      = 4'd2; // FALL

        // ---- Falling with gravity ticks ----
        for (i = 0; i < 6; i = i + 1) begin
            tick_gravity = 1'b1;
            have_action  = 1'b1;
            move_accept  = 1'b1;
            #20;
            tick_gravity = 1'b0;
            have_action  = 1'b0;
            move_accept  = 1'b0;

            piece_y = piece_y + 1;
            cur_y   = piece_y;

            #50_000_000;   // 50 ms between falls
        end

        // ---- Left move ----
        left_final  = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        left_final  = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        piece_x = piece_x - 1;
        cur_x   = piece_x;

        #50_000_000;      // 50 ms

        // ---- Rotate ----
        rot_final   = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        rot_final   = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        rot = rot + 1;

        #50_000_000;      // 50 ms

        // ---- Collision + lock + line clear ----
        collide    = 1'b1;
        lock_phase = 1'b1;
        state      = 4'd3;   // LOCK

        #50_000_000;        // 50 ms

        score      = score + 1;
        lock_phase = 1'b0;
        collide    = 1'b0;
        state      = 4'd0;   // back to IDLE
        next_state = 4'd1;   // next = SPAWN

        // Then everything stays steady for the rest of the sim
    end

endmodule
