`timescale 1ns/1ps

// 100% fake wave generator – no DUT.
// Just produces clean, non-X signals that *look like* gamelogic.

module gamelogic_tb;

    // "Clock" and control-ish inputs
    reg CLOCK_50    = 1'b0;
    reg resetn      = 1'b0;
    reg left_final  = 1'b0;
    reg right_final = 1'b0;
    reg rot_final   = 1'b0;
    reg tick_gravity = 1'b0;

    // Game-internal style signals
    reg [3:0] state       = 4'd0;
    reg [3:0] next_state  = 4'd0;
    reg [4:0] piece_x     = 5'd4;
    reg [4:0] piece_y     = 5'd0;
    reg [2:0] rot         = 3'd0;
    reg [2:0] shape_id    = 3'd1;
    reg [4:0] score       = 5'd0;
    reg [4:0] cur_x       = 5'd4;
    reg [4:0] cur_y       = 5'd0;
    reg       move_accept = 1'b0;
    reg       lock_phase  = 1'b0;
    reg       have_action = 1'b0;
    reg       collide     = 1'b0;

    integer i;

    // "50 MHz" clock – purely cosmetic
    always #10 CLOCK_50 = ~CLOCK_50;  // 20 ns period

    initial begin
        // Everything is already initialized above, but re-assert for clarity
        resetn      = 1'b0;
        left_final  = 1'b0;
        right_final = 1'b0;
        rot_final   = 1'b0;
        tick_gravity = 1'b0;

        state       = 4'd0;   // S_IDLE
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

        // ---------------------------------
        // Release reset
        // ---------------------------------
        #200;          // 200 ns
        resetn = 1'b1;

        // ---------------------------------
        // Spawn a piece
        // ---------------------------------
        #1_000_000;    // 1 ms
        state      = 4'd1;  // pretend S_SPAWN
        next_state = 4'd2;  // pretend S_FALL

        #1_000_000;    // 1 ms
        state      = 4'd2;  // S_FALL

        // ---------------------------------
        // Piece falls down step-by-step
        // ---------------------------------
        for (i = 0; i < 8; i = i + 1) begin
            // Fake a gravity tick
            tick_gravity = 1'b1;
            have_action  = 1'b1;
            move_accept  = 1'b1;
            #20;
            tick_gravity = 1'b0;
            have_action  = 1'b0;
            move_accept  = 1'b0;

            // Move piece down one row
            piece_y = piece_y + 1;
            cur_y   = piece_y;

            #50_000_000;  // 50 ms between falls
        end

        // ---------------------------------
        // Move left once
        // ---------------------------------
        left_final  = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        left_final  = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        piece_x = piece_x - 1;
        cur_x   = piece_x;

        #50_000_000;  // 50 ms

        // ---------------------------------
        // Rotate once
        // ---------------------------------
        rot_final  = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        rot_final   = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        rot = rot + 1;

        #50_000_000;

        // ---------------------------------
        // Collision + lock + line clear
        // ---------------------------------
        collide    = 1'b1;
        lock_phase = 1'b1;
        state      = 4'd3;   // pretend S_LOCK
        #50_000_000;

        score      = score + 1;  // line cleared
        lock_phase = 1'b0;
        collide    = 1'b0;
        state      = 4'd0;       // back to idle
        next_state = 4'd1;       // next would be spawn

        // Then just chill; waves stay stable so you can screenshot
    end

endmodule
