module gamelogic(
    LEDR, CLOCK_50, resetn,
    left_final, right_final, rot_final,
    tick_gravity,
    r0, r1, r2, r3,
    rx0, ry0, rx1, ry1, rx2, ry2, rx3, ry3,
    board_we, board_wx, board_wy, board_wdata,
    score, cur_x, cur_y, move_accept,
     cur_shape_id,
     cur_rot,
    dx0_c, dy0_c, dx1_c, dy1_c, dx2_c, dy2_c, dx3_c, dy3_c,
     game_over,
     random_shape // NEW INPUT
);
    output wire [2:0] cur_shape_id;
    output wire [1:0] cur_rot;
    output wire signed [3:0] dx0_c, dy0_c, dx1_c, dy1_c, dx2_c, dy2_c, dx3_c, dy3_c;
    output wire game_over;
    input wire [2:0] random_shape; // Input from the randomiser module

    input  CLOCK_50, resetn;
    output [9:0] LEDR;
    input  left_final, right_final, rot_final;
    input  tick_gravity;

    // gamelogic port deltas
    input  r0, r1, r2, r3;
    output [3:0] rx0, rx1, rx2, rx3;
    output [4:0] ry0, ry1, ry2, ry3;
    output reg       board_we;
    output reg [3:0] board_wx;
    output reg [4:0] board_wy;
    output reg       board_wdata;

    reg       next_board_we;
    reg [3:0] next_board_wx;
    reg [4:0] next_board_wy;
    reg       next_board_wdata;

    output reg [4:0] score;
    
    // FSM states
    parameter S_IDLE = 3'd0, S_SPAWN = 3'd1, S_FALL = 3'd2, S_LOCK = 3'd3, S_CLEAR = 3'd4, S_GAME_OVER = 3'd5, S_CHECK_SPAWN = 3'd6; 
    reg [2:0] state, next_state;
    
    assign game_over = (state == S_GAME_OVER);

    reg [1:0] rot;
    reg [2:0] shape_id;
    assign cur_shape_id = shape_id;
    assign cur_rot = rot;

    reg [3:0] spawn_x;
    reg [4:0] spawn_y;
    reg [3:0] piece_x;
    reg [4:0] piece_y;

    reg  signed [2:0] dX_lat, dY_lat;
    reg               want_rot_lat;
    reg        [1:0]  new_rot_lat;
    output            move_accept;
    
    reg               want_left, want_right, want_rot, want_grav;
    reg        [1:0]  dRot;
    reg               have_action;
    reg  signed [2:0] dX, dY;

    reg               collide;
    reg        [1:0]  new_rot;

    output reg [3:0] cur_x;
    output reg [4:0] cur_y;
    
    // Offsets
    wire signed [3:0] dx0_t, dy0_t, dx1_t, dy1_t, dx2_t, dy2_t, dx3_t, dy3_t;
    
    tetris_piece_offsets OFF_CUR (
        .shape_id (shape_id),
        .rot      (rot),  
        .dx0(dx0_c), .dy0(dy0_c),
        .dx1(dx1_c), .dy1(dy1_c),
        .dx2(dx2_c), .dy2(dy2_c),
        .dx3(dx3_c), .dy3(dy3_c)
    );

    tetris_piece_offsets OFF_TRY (
        .shape_id (shape_id),
        .rot      (new_rot),  
        .dx0(dx0_t), .dy0(dy0_t),
        .dx1(dx1_t), .dy1(dy1_t),
        .dx2(dx2_t), .dy2(dy2_t),
        .dx3(dx3_t), .dy3(dy3_t)
    );

    reg [1:0] lock_phase;
    reg [3:0] wx_hold [0:3];
    reg [4:0] wy_hold [0:3];

    reg collide_bounds;
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

    wire [3:0] tx0_clamp = (tx0_s < 0) ? 4'd0 : (tx0_s > 9) ? 4'd9 : tx0_s[3:0];
    wire [3:0] tx1_clamp = (tx1_s < 0) ? 4'd0 : (tx1_s > 9) ? 4'd9 : tx1_s[3:0];
    wire [3:0] tx2_clamp = (tx2_s < 0) ? 4'd0 : (tx2_s > 9) ? 4'd9 : tx2_s[3:0];
    wire [3:0] tx3_clamp = (tx3_s < 0) ? 4'd0 : (tx3_s > 9) ? 4'd9 : tx3_s[3:0];

    wire [4:0] ty0_clamp = (ty0_s < 0) ? 5'd0 : (ty0_s > 19) ? 5'd19 : ty0_s[4:0];
    wire [4:0] ty1_clamp = (ty1_s < 0) ? 5'd0 : (ty1_s > 19) ? 5'd19 : ty1_s[4:0];
    wire [4:0] ty2_clamp = (ty2_s < 0) ? 5'd0 : (ty2_s > 19) ? 5'd19 : ty2_s[4:0];
    wire [4:0] ty3_clamp = (ty3_s < 0) ? 5'd0 : (ty3_s > 19) ? 5'd19 : ty3_s[4:0];

    assign rx0 = tx0_clamp; assign ry0 = ty0_clamp;
    assign rx1 = tx1_clamp; assign ry1 = ty1_clamp;
    assign rx2 = tx2_clamp; assign ry2 = ty2_clamp;
    assign rx3 = tx3_clamp; assign ry3 = ty3_clamp;

    always @* begin
        collide_bounds = 1'b0;
        if (tx0_s < 0 || tx0_s > 9 || ty0_s < 0 || ty0_s > 19) collide_bounds = 1'b1;
        if (tx1_s < 0 || tx1_s > 9 || ty1_s < 0 || ty1_s > 19) collide_bounds = 1'b1;
        if (tx2_s < 0 || tx2_s > 9 || ty2_s < 0 || ty2_s > 19) collide_bounds = 1'b1;
        if (tx3_s < 0 || tx3_s > 9 || ty3_s < 0 || ty3_s > 19) collide_bounds = 1'b1;
    end

    always @* begin
        dX = 0;
        dY = 0;
        next_state = state;
        want_left = 0;
        want_right = 0;
        want_rot = 0;
        want_grav = 0;
        dRot = 0;
        collide = 0;
        new_rot = rot;
        next_board_we    = 1'b0;
        next_board_wdata = 1'b0;
        next_board_wx    = 4'd0;
        next_board_wy    = 5'd0;

        case (state)
            S_IDLE: begin
                next_state = S_SPAWN;
            end
            S_SPAWN: begin
                next_state = S_CHECK_SPAWN; 
            end
            S_CHECK_SPAWN: begin
                if (collide) next_state = S_GAME_OVER;
                else next_state = S_FALL;
            end
            S_FALL: begin
                if (left_final) begin
                    dRot = 0; want_left = 1; dX = -1;
                end
                else if (right_final) begin
                    dRot = 0; want_right = 1; dX = 1;
                end
                else if (rot_final) begin
                    want_rot = 1; dRot = 1;
                end
                else if (tick_gravity) begin
                    want_grav = 1; dY = 1;
                end
                new_rot = (rot + dRot) & 2'b11;
                have_action = (want_left || want_right || want_rot || want_grav);
                collide = collide_bounds | (r0 | r1 | r2 | r3);
                if (have_action) begin
                    if (collide) begin
                        if (want_grav) next_state = S_LOCK;
                        else next_state = S_FALL;
                    end
                end
            end
            S_LOCK: begin
                next_board_we    = 1'b1;
                next_board_wdata = 1'b1;
                case (lock_phase)
                    2'd0: begin next_board_wx = wx_hold[0]; next_board_wy = wy_hold[0]; end
                    2'd1: begin next_board_wx = wx_hold[1]; next_board_wy = wy_hold[1]; end
                    2'd2: begin next_board_wx = wx_hold[2]; next_board_wy = wy_hold[2]; end
                    2'd3: begin next_board_wx = wx_hold[3]; next_board_wy = wy_hold[3]; end
                endcase
                next_state = (lock_phase == 2'd3) ? S_SPAWN : S_LOCK;
            end
            S_GAME_OVER: begin
                 next_state = S_GAME_OVER;
            end
            S_CLEAR: begin
                next_state = S_SPAWN;
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    reg move_commit;
    wire will_move = have_action & ~collide;
    wire signed [5:0] piece_x_next_s = $signed({1'b0, piece_x}) + $signed({{2{dX_lat[2]}}, dX_lat});
    wire signed [6:0] piece_y_next_s = $signed({2'b0, piece_y}) + $signed({{3{dY_lat[2]}}, dY_lat});

    // Removed internal rand_cnt, using external input

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            dX_lat        <= 3'sd0;
            dY_lat        <= 3'sd0;
            want_rot_lat  <= 1'b0;
            new_rot_lat   <= 2'd0;
            move_commit   <= 1'b0;
            lock_phase    <= 2'd0;
            state         <= S_IDLE;
            piece_x       <= 4'd0;
            piece_y       <= 5'd0;
            rot           <= 2'd0;
            shape_id      <= 3'd0;
            board_we      <= 1'b0;
            board_wdata   <= 1'b0;
            board_wx      <= 4'd0;
            board_wy      <= 5'd0;
            spawn_x       <= 4'd4;
            spawn_y       <= 5'd0;
            score         <= 5'd0;
        end
        else begin
            move_commit <= 1'b0;
            state <= next_state;
            cur_x <= piece_x;
            cur_y <= piece_y;

            if (state == S_FALL && will_move) begin
                move_commit   <= 1'b1;
                dX_lat        <= dX;
                dY_lat        <= dY;
                want_rot_lat  <= want_rot;
                new_rot_lat   <= new_rot;
            end

            if (move_commit) begin
                piece_x <= piece_x_next_s[3:0];
                piece_y <= piece_y_next_s[4:0];
                if (want_rot_lat) rot <= new_rot_lat;
            end

            if (state == S_SPAWN) begin
                shape_id <= random_shape; // FIX: Use external random shape
                rot      <= 2'd0;
                piece_x  <= spawn_x;
                piece_y  <= spawn_y;
            end

            if (state == S_FALL && next_state == S_LOCK) begin
                wx_hold[0] <= piece_x + dx0_c;
                wy_hold[0] <= piece_y + dy0_c;
                wx_hold[1] <= piece_x + dx1_c;  wy_hold[1] <= piece_y + dy1_c;
                wx_hold[2] <= piece_x + dx2_c;
                wy_hold[2] <= piece_y + dy2_c;
                wx_hold[3] <= piece_x + dx3_c;  wy_hold[3] <= piece_y + dy3_c;
                lock_phase <= 2'd0;
            end

            board_we    <= next_board_we;
            board_wdata <= next_board_wdata;
            board_wx    <= next_board_wx;
            board_wy    <= next_board_wy;

            if (state == S_LOCK) begin
                if (lock_phase == 2'd3) begin
                    lock_phase <= 2'd0;
                    if (score != 5'd31) score <= score + 5'd1;
                end
                else begin
                    lock_phase <= lock_phase + 2'd1;
                end
            end
        end
    end

    assign move_accept = move_commit;
    assign LEDR[7:5] = state;
    assign LEDR[0]   = move_accept;
    assign LEDR[1]   = have_action & collide;
    assign LEDR[2]   = tick_gravity;
endmodule
