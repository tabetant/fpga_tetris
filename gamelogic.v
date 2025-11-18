// Minimal Milestone-2 gamelogic: movement + bounds-only collision, no board usage.

module gamelogic(
    LEDR, CLOCK_50, resetn,
    left_final, right_final, rot_final,
    tick_gravity,
    // board interface kept for compatibility but unused here
    board_rdata, board_rx, board_ry,
    board_we, board_wx, board_wy, board_wdata,
    score, cur_x, cur_y, move_accept
);
    input CLOCK_50, resetn;
    output [9:0] LEDR;

    input left_final, right_final, rot_final;
    input tick_gravity;

    // board (unused for M2)
    input        board_rdata;
    output reg [3:0] board_rx;
    output reg [4:0] board_ry;
    output reg       board_we;
    output reg [3:0] board_wx;
    output reg [4:0] board_wy;
    output reg       board_wdata;

    output reg [4:0] score;

    // visible cell for painter
    output reg [3:0] cur_x;  // 0..9
    output reg [4:0] cur_y;  // 0..19

    output move_accept;

    // FSM
    localparam S_IDLE=3'd0, S_SPAWN=3'd1, S_FALL=3'd2, S_LOCK=3'd3, S_CLEAR=3'd4;
    reg [2:0] state, next_state;

    // piece state
    reg  [1:0] rot;
    reg  [2:0] shape_id;
    reg  [3:0] piece_x;        // 0..9
    reg  [4:0] piece_y;        // 0..19
    reg  [3:0] spawn_x;
    reg  [4:0] spawn_y;

    // intent
    reg signed [2:0] dX, dY;
    reg        want_left, want_right, want_rot, want_grav;
    reg  [1:0] dRot;
    reg  [1:0] new_rot;
    reg        have_action;

    // move commit pipeline
    reg signed [2:0] dX_lat, dY_lat;
    reg        want_rot_lat;
    reg  [1:0] new_rot_lat;
    reg        move_commit;
    wire       will_move;

    // offsets module (provided elsewhere)
    wire signed [3:0] dx0_c, dy0_c, dx1_c, dy1_c, dx2_c, dy2_c, dx3_c, dy3_c;
    wire signed [3:0] dx0_t, dy0_t, dx1_t, dy1_t, dx2_t, dy2_t, dx3_t, dy3_t;

    tetris_piece_offsets OFF_CUR(
        .shape_id(shape_id), .rot(rot),
        .dx0(dx0_c), .dy0(dy0_c),
        .dx1(dx1_c), .dy1(dy1_c),
        .dx2(dx2_c), .dy2(dy2_c),
        .dx3(dx3_c), .dy3(dy3_c)
    );

    tetris_piece_offsets OFF_TRY(
        .shape_id(shape_id), .rot(new_rot),
        .dx0(dx0_t), .dy0(dy0_t),
        .dx1(dx1_t), .dy1(dy1_t),
        .dx2(dx2_t), .dy2(dy2_t),
        .dx3(dx3_t), .dy3(dy3_t)
    );

    // display one block of the active tetromino (block #1 here)
    wire [4:0] disp_x5 = {1'b0,piece_x} + {{1{dx1_c[3]}}, dx1_c};
    wire [5:0] disp_y6 = {1'b0,piece_y} + {{2{dy1_c[3]}}, dy1_c};
    wire [3:0] disp_x  = (disp_x5 > 5'd9 ) ? 4'd9  : disp_x5[3:0];
    wire [4:0] disp_y  = (disp_y6 > 6'd19) ? 5'd19 : disp_y6[4:0];

    // bounds-only collision (no board)
    wire signed [5:0] piece_x_s = $signed({1'b0, piece_x});
    wire signed [6:0] piece_y_s = $signed({2'b00, piece_y});
    wire signed [5:0] dX_s = $signed({{3{dX[2]}}, dX});
    wire signed [6:0] dY_s = $signed({{4{dY[2]}}, dY});

    wire signed [5:0] tx0_s = piece_x_s + dX_s + $signed({{2{dx0_t[3]}}, dx0_t});
    wire signed [5:0] tx1_s = piece_x_s + dX_s + $signed({{2{dx1_t[3]}}, dx1_t});
    wire signed [5:0] tx2_s = piece_x_s + dX_s + $signed({{2{dx2_t[3]}}, dx2_t});
    wire signed [5:0] tx3_s = piece_x_s + dX_s + $signed({{2{dx3_t[3]}}, dx3_t});
    wire signed [6:0] ty0_s = piece_y_s + dY_s + $signed({{3{dy0_t[3]}}, dy0_t});
    wire signed [6:0] ty1_s = piece_y_s + dY_s + $signed({{3{dy1_t[3]}}, dy1_t});
    wire signed [6:0] ty2_s = piece_y_s + dY_s + $signed({{3{dy2_t[3]}}, dy2_t});
    wire signed [6:0] ty3_s = piece_y_s + dY_s + $signed({{3{dy3_t[3]}}, dy3_t});

    reg collide_bounds;
    always @* begin
        collide_bounds = 1'b0;
        if (tx0_s < 0 || tx0_s > 9  || ty0_s > 19) collide_bounds = 1'b1;
        if (tx1_s < 0 || tx1_s > 9  || ty1_s > 19) collide_bounds = 1'b1;
        if (tx2_s < 0 || tx2_s > 9  || ty2_s > 19) collide_bounds = 1'b1;
        if (tx3_s < 0 || tx3_s > 9  || ty3_s > 19) collide_bounds = 1'b1;
    end

    // Next-state / intent
    reg collide;
    always @* begin
        // unused board lines
        board_we    = 1'b0;
        board_wdata = 1'b0;
        board_wx    = 4'd0;
        board_wy    = 5'd0;
        board_rx    = piece_x;
        board_ry    = piece_y;

        dX = 0; dY = 0; dRot = 0;
        want_left = 0; want_right = 0; want_rot = 0; want_grav = 0;
        new_rot   = rot;
        collide   = 1'b0;
        have_action = 1'b0;
        next_state  = state;

        case (state)
            S_IDLE:  next_state = S_SPAWN;

            S_SPAWN: begin
                next_state = S_FALL;
            end

            S_FALL: begin
                if (left_final)   begin want_left = 1; dX = -1; end
                else if (right_final) begin want_right = 1; dX = 1; end
                else if (rot_final)   begin want_rot = 1; dRot = 1; end
                else if (tick_gravity)begin want_grav = 1; dY = 1; end

                new_rot     = (rot + dRot) & 2'b11;
                have_action = (want_left || want_right || want_rot || want_grav);
                collide     = collide_bounds; // no board yet

                if (have_action) begin
                    if (collide) begin
                        if (want_grav) next_state = S_LOCK; // hit floor/wall on gravity
                        else           next_state = S_FALL; // ignore side/rotate collide
                    end
                end
            end

            S_LOCK: begin
                // No board yet: just respawn for M2 visual
                next_state = S_SPAWN;
            end

            default: next_state = S_IDLE;
        endcase
    end

    assign will_move   = have_action & ~collide;
    assign move_accept = move_commit;

    // register updates
    always @(posedge CLOCK_50) begin
        if (!resetn) begin
            state <= S_IDLE;

            piece_x <= 4'd4;
            piece_y <= 5'd0;
            spawn_x <= 4'd4;
            spawn_y <= 5'd0;

            rot      <= 2'd0;
            shape_id <= 3'd1;   // I-piece by default (works well for M2 visuals)

            cur_x <= 0; cur_y <= 0;

            dX_lat <= 0; dY_lat <= 0;
            want_rot_lat <= 1'b0; new_rot_lat <= 2'd0;
            move_commit <= 1'b0;

            score <= 5'd0;
        end else begin
            move_commit <= 1'b0;
            state <= next_state;

            // drive painter coordinates (clamped)
            cur_x <= disp_x;
            cur_y <= disp_y;

            // capture accepted action at FALL
            if (state == S_FALL && will_move) begin
                move_commit  <= 1'b1;
                dX_lat       <= dX;
                dY_lat       <= dY;
                want_rot_lat <= want_rot;
                new_rot_lat  <= new_rot;
            end

            // commit position/rotation
            if (move_commit) begin
                piece_x <= piece_x + dX_lat;
                piece_y <= piece_y + dY_lat;
                if (want_rot_lat) rot <= new_rot_lat;
            end

            // spawn
            if (state == S_SPAWN) begin
                shape_id <= shape_id; // keep same for M2 (or change if you want randomizer later)
                rot      <= 2'd0;
                piece_x  <= spawn_x;
                piece_y  <= spawn_y;
            end
        end
    end

    // LEDs (optional debug)
    assign LEDR[7:5] = state;
    assign LEDR[0]   = move_accept;
    assign LEDR[1]   = have_action & collide;
    assign LEDR[2]   = tick_gravity;
    assign LEDR[8]   = rot_final;
    assign LEDR[4:3] = rot;

endmodule
