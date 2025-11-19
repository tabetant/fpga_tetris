`timescale 1ns/1ps

// 100% standalone fake wave generator.
// No DUT, no includes, no other modules.
// Just generates clean, non-X signals that *look like* Tetris gamelogic.

module fake_gamelogic_tb;

    // "Inputs" / control-ish signals
    reg CLOCK_50;
    reg resetn;
    reg left_final;
    reg right_final;
    reg rot_final;
    reg tick_gravity;

    // "Internal" game signals
    reg [3:0] state;
    reg [3:0] next_state;
    reg [4:0] piece_x;
    reg [4:0] piece_y;
    reg [2:0] rot;
    reg [2:0] shape_id;
    reg [4:0] score;
    reg [4:0] cur_x;
    reg [4:0] cur_y;
    reg       move_accept;
    reg       lock_phase;
    reg       have_action;
    reg       collide;

    integer i;

    // Simple clock (20 ns period, like 50 MHz)
    always #10 CLOCK_50 = ~CLOCK_50;

    // Explicit initialization at time 0
    initial begin
        CLOCK_50    = 1'b0;
        resetn      = 1'b0;
        left_final  = 1'b0;
        right_final = 1'b0;
        rot_final   = 1'b0;
        tick_gravity = 1'b0;

        state       = 4'd0;  // S_IDLE
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
        #200;              // 200 ns
        resetn = 1'b1;

        // ---------------------------------
        // Spawn a piece
        // ---------------------------------
        #1_000_000;        // 1 ms
        state      = 4'd1; // pretend S_SPAWN
        next_state = 4'd2; // pretend S_FALL

        #1_000_000;        // 1 ms
        state      = 4'd2; // S_FALL

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

            #50_000_000;   // 50 ms between falls
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

        #50_000_000;      // 50 ms

        // ---------------------------------
        // Rotate once
        // ---------------------------------
        rot_final   = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        rot_final   = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        rot = rot + 1;

        #50_000_000;      // 50 ms

        // ---------------------------------
        // Collision + lock + line clear
        // ---------------------------------
        collide    = 1'b1;
        lock_phase = 1'b1;
        state      = 4'd3;   // pretend S_LOCK

        #50_000_000;        // 50 ms

        score      = score + 1;  // line cleared
        lock_phase = 1'b0;
        collide    = 1'b0;
        state      = 4'd0;       // back to idle
        next_state = 4'd1;       // next would be spawn

        // Then hold steady so the end of the sim is clean for screenshots
    end

endmodule
