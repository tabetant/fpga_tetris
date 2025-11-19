`timescale 1ns/1ps

// Standalone fake wave generator.
// No DUT, just signals that look like your gamelogic.

module gamelogic_tb;

    // "Clock" and inputs
    reg CLOCK_50   = 1'b0;
    reg resetn     = 1'b0;

    reg left_final  = 1'b0;
    reg right_final = 1'b0;
    reg rot_final   = 1'b0;
    reg tick_gravity = 1'b0;

    // "Internal" game signals you care about
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

    // 50 MHz "clock"
    always #10 CLOCK_50 = ~CLOCK_50;   // 20 ns period

    initial begin
        // Initial reset low
        resetn     = 1'b0;
        state      = 4'd0;  // S_IDLE
        next_state = 4'd0;
        piece_x    = 5'd4;
        piece_y    = 5'd0;
        cur_x      = 5'd4;
        cur_y      = 5'd0;
        score      = 5'd0;
        rot        = 3'd0;
        shape_id   = 3'd1;

        // Hold reset a bit
        #200;
        resetn = 1'b1;

        // -----------------------------
        // Spawn a piece
        // -----------------------------
        #1_000_000;        // 1 ms
        state      = 4'd1; // S_SPAWN
        next_state = 4'd2; // S_FALL

        #1_000_000;
        state      = 4'd2; // S_FALL

        // -----------------------------
        // Piece falling with gravity
        // -----------------------------
        for (i = 0; i < 8; i = i + 1) begin
            // gravity tick + accepted move
            tick_gravity = 1'b1;
            have_action  = 1'b1;
            move_accept  = 1'b1;
            #20;
            tick_gravity = 1'b0;
            have_action  = 1'b0;
            move_accept  = 1'b0;

            // piece moves down
            piece_y = piece_y + 1;
            cur_y   = piece_y;

            #10_000_000;  // 10 ms between falls
        end

        // -----------------------------
        // Simulate a left move
        // -----------------------------
        left_final  = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        left_final  = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        piece_x = piece_x - 1;
        cur_x   = piece_x;

        #10_000_000;

        // -----------------------------
        // Simulate a rotate
        // -----------------------------
        rot_final  = 1'b1;
        have_action = 1'b1;
        move_accept = 1'b1;
        #20;
        rot_final   = 1'b0;
        have_action = 1'b0;
        move_accept = 1'b0;

        rot = rot + 1;

        #10_000_000;

        // -----------------------------
        // Simulate collision + lock + line clear
        // -----------------------------
        collide    = 1'b1;
        lock_phase = 1'b1;
        state      = 4'd3;   // S_LOCK
        #10_000_000;

        score      = score + 1; // line cleared
        lock_phase = 1'b0;
        collide    = 1'b0;
        state      = 4'd0;      // back to S_IDLE
        next_state = 4'd1;      // would spawn again

        // After this, things stay steady; sim can keep running
    end

endmodule
