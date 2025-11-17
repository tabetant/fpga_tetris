// board size: 10 cols (0 <= x <= 9) * 20 rows (0 <= y <= 19)
// origin: top-left cell (ORIGIN_X = 0, ORIGIN_Y = 0)
// y increases downward: gravity = y + 1
// screen 640 x 480 (0 <= px_x <= 639, 0 <= px_y <= 479)
// CELL_W = 640 / 10 = 64 px
// CELL_H = 480 / 20 = 24 px
// px_left = ORIGIN_X + x * CELL_W
// px_top = ORIGIN_Y + y * CELL_H
// ORIGIN (x = 0, y = 0) maps to pixels [0:63]x[0:23]
// BOTTOM RIGHT (x = 9, y = 19) maps to pixels [576:639]x[456:479]
// proposed moves: (dX, dY, dRot)
// left (-1,0,0) ; right (+1,0,0); rotate(0,0, 1 mod 4); gravity (0, +1, 0)
// need a lookup table for the shapes: offsets[shape_id][rot][0:3] = (dx, dy)
// for each shape, have 4 diff rotations (1 at 0 deg (default), at 90, at 180, then back to 0 (hence the mod 4))
// CLOCKWISE ROTATION
// for rotation: 1 mod 4 means we go to the next rotation state, then wrap around at 4 (4 rotation states)
// before making a move: (for 0 <= i <= 3)
// 1 - compute target cell: 
// new_rot = (rot + dRot) mod 4
// (dx[i], dy[i]) = offsets[shape_id][new_rot][i]
// tx[i] = piece_x + dX + dx[i]
// ty[i] = piece_y + dY + dy[i]
// 2 - bounds check
// if tx < 0 | tx > 63 | ty > 23 => collide = 1 (illegal)
// if read_cell(tx, ty) == 1, collide == 1
// 3 - if all conditions keep collide = 0 , accept the move:
// piece_x += dX, piece_y += dY, rot = new_rot

module gamelogic(LEDR, CLOCK_50, resetn, left_final, right_final, rot_final, tick_gravity, board_rdata, board_rx, board_ry, board_we, board_wx, board_wy, board_wdata, score, cur_x, cur_y, move_accept);
    input CLOCK_50, resetn;

    // testing + sanity check
    output [9:0] LEDR;
	
    // input debounced clean pulses
    input left_final, right_final, rot_final;

    input tick_gravity; // gravity timer

    // board reading
	 
    input board_rdata; // 1 if (board_rx, board_ry) is occupied
    output reg [3:0] board_rx;
    output reg [4:0] board_ry;
    output reg [4:0] score;

    // board writing
    output reg board_we; // 1-cycle write enable
    output reg [3:0] board_wx; // writing X address
    output reg [4:0] board_wy; // writing Y address
    output reg board_wdata; // 1 to set cell occupied
	 

    // FSM states
    parameter S_IDLE = 3'd0, S_SPAWN = 3'd1, S_FALL = 3'd2, S_LOCK = 3'd3, S_CLEAR = 3'd4;
    reg [2:0] state, next_state;

    // tetromino shape and rotation 
    reg [1:0] rot;
    reg [2:0] shape_id;

    // coordinate logic
    reg [3:0] spawn_x;
    reg [4:0] spawn_y;
    reg [3:0] piece_x; // 0 to 9
    reg [4:0] piece_y; // 0 to 19

    // lock state
    reg [1:0] lock_i;
 
    // move logic
    output reg move_accept; // set in "fall", checked before accepting move at clock cycle
    reg want_left, want_right, want_rot, want_grav;
    reg [1:0] dRot;
    reg have_action;
    reg signed [2:0] dX, dY;

    reg collide; // for violations
    reg [1:0] new_rot; // target rot (rot+dRot) % 4

    // VGA

    output reg [3:0] cur_x;
    output reg [4:0] cur_y;
	
    // current rotation (for LOCK writes)
    wire signed [3:0] dx0_c, dy0_c, dx1_c, dy1_c, dx2_c, dy2_c, dx3_c, dy3_c;

    // trial rotation (for collision test of this move)
    wire signed [3:0] dx0_t, dy0_t, dx1_t, dy1_t, dx2_t, dy2_t, dx3_t, dy3_t;

    tetris_piece_offsets OFF_CUR (
        .shape_id (shape_id),
        .rot      (rot),  
        .dx0(dx0_c), .dy0(dy0_c),
        .dx1(dx1_c), .dy1(dy1_c),
        .dx2(dx2_c), .dy2(dy2_c),
        .dx3(dx3_c), .dy3(dy3_c)
    );
    
    // trial rotation (for collision checks)
    tetris_piece_offsets OFF_TRY (
        .shape_id (shape_id),
        .rot      (new_rot),  
        .dx0(dx0_t), .dy0(dy0_t),
        .dx1(dx1_t), .dy1(dy1_t),
        .dx2(dx2_t), .dy2(dy2_t),
        .dx3(dx3_t), .dy3(dy3_t)
    );


    // for S_LOCK
    reg [1:0] lock_phase;   // 0..3
    reg [3:0] wx_hold [0:3];
    reg [4:0] wy_hold [0:3];

    // compute target piece and check collision

    reg collide_bounds;

    wire [4:0] base_x = {1'b0, piece_x};
    wire [5:0] base_y = {1'b0, piece_y};

    wire [4:0] bx0 = base_x + {{1{dx0_t[3]}}, dx0_t};
    wire [4:0] bx1 = base_x + {{1{dx1_t[3]}}, dx1_t};
    wire [4:0] bx2 = base_x + {{1{dx2_t[3]}}, dx2_t};
    wire [4:0] bx3 = base_x + {{1{dx3_t[3]}}, dx3_t};

    wire [5:0] by0 = base_y + {{2{dy0_t[3]}}, dy0_t};
    wire [5:0] by1 = base_y + {{2{dy1_t[3]}}, dy1_t};
    wire [5:0] by2 = base_y + {{2{dy2_t[3]}}, dy2_t};
    wire [5:0] by3 = base_y + {{2{dy3_t[3]}}, dy3_t};

    wire under0 = want_left && (bx0 == 5'd0);
    wire under1 = want_left && (bx1 == 5'd0);
    wire under2 = want_left && (bx2 == 5'd0);
    wire under3 = want_left && (bx3 == 5'd0);

    wire [4:0] tx0 = bx0 + (want_right ? 5'd1 : 5'd0) - (want_left ? 5'd1 : 5'd0);
    wire [4:0] tx1 = bx1 + (want_right ? 5'd1 : 5'd0) - (want_left ? 5'd1 : 5'd0);
    wire [4:0] tx2 = bx2 + (want_right ? 5'd1 : 5'd0) - (want_left ? 5'd1 : 5'd0);
    wire [4:0] tx3 = bx3 + (want_right ? 5'd1 : 5'd0) - (want_left ? 5'd1 : 5'd0);
    
    wire [5:0] ty0 = by0 + (want_grav ? 6'd1 : 6'd0);
    wire [5:0] ty1 = by1 + (want_grav ? 6'd1 : 6'd0);
    wire [5:0] ty2 = by2 + (want_grav ? 6'd1 : 6'd0);
    wire [5:0] ty3 = by3 + (want_grav ? 6'd1 : 6'd0);   
    
    always@*
    begin
        collide_bounds = 1'b0;
        if (under0 || tx0 > 5'd9 || ty0 > 6'd19) collide_bounds = 1'b1;
        if (under1 || tx1 > 5'd9 || ty1 > 6'd19) collide_bounds = 1'b1;
        if (under2 || tx2 > 5'd9 || ty2 > 6'd19) collide_bounds = 1'b1;
        if (under3 || tx3 > 5'd9 || ty3 > 6'd19) collide_bounds = 1'b1;
    end

    always@*
    begin
        dX = 0;
        dY = 0;
        next_state = state;
        want_left = 0;
        want_right = 0;
        want_rot = 0;
        want_grav = 0;
        dRot = 0;
        move_accept = 0;
        collide = 0;
        new_rot = rot;
        board_rx = piece_x;
        board_ry = piece_y;
        board_we = 1'b0;
        board_wdata = 1'b0;
        board_wx = 4'd0;
        board_wy = 5'd0; 
        case(state)
            S_IDLE: next_state = S_SPAWN;
            S_SPAWN: 
				begin
                board_we = 1'b0;
                if (collide)
                    next_state = S_FALL; // next_state = S_GAME_OVER : to be implemented later;
                else 
                begin
                    next_state = S_FALL;
                end
				end
            S_FALL: 
			begin
                if (left_final) 
                begin
                    dRot = 0;
                    want_left = 1;
                    dX = -1;
                end
                else if (right_final)
                begin
                    dRot = 0;
                    want_right = 1;
                    dX = 1;
                end
                else if (rot_final)
                begin
                    want_rot = 1;
                    dRot = 1;
                end
                else if(tick_gravity)
                begin
                    want_grav = 1;
                    dY = 1;
                end
                new_rot = (rot + dRot) & 2'b11;
                have_action = (want_left || want_right || want_rot || want_grav);
                collide = collide_bounds;
                move_accept = have_action & ~collide;
                if (have_action) 
                begin
                    if (collide)
                        next_state = S_LOCK; 
                    else 
                        move_accept = 1'b1; // normal move
                end
            end
            S_LOCK: // write the 4 blocks of active piece into board memory
            begin
                // write one cell per cycle
                board_we = 1'b1;
                board_wdata = 1'b1;
                case (lock_phase)
                    2'd0: begin board_wx = wx_hold[0]; board_wy = wy_hold[0]; end
                    2'd1: begin board_wx = wx_hold[1]; board_wy = wy_hold[1]; end
                    2'd2: begin board_wx = wx_hold[2]; board_wy = wy_hold[2]; end
                    2'd3: begin board_wx = wx_hold[3]; board_wy = wy_hold[3]; end
                endcase
    
                next_state = (lock_phase == 2'd3) ? S_SPAWN : S_LOCK;
            end

            S_CLEAR: next_state = S_SPAWN; // will change for next milestone
            default: begin 
                next_state = S_IDLE;
                board_we = 1'b0;
            end
        endcase
    end

	reg move_commit;   // 1-cycle pulse aligned to state update
	wire will_move = have_action & ~collide;
	
    always@(posedge CLOCK_50)
    begin
        if(!resetn)
        begin
			move_commit <= 1'b0;
            lock_phase <= 0;
            state <= S_IDLE;
            piece_x <= 0;
            piece_y <= 0;
            rot <= 0;
            shape_id <= 0;
            lock_i <= 0;
				/*
            board_we <= 0;
            board_wdata <= 0;
            board_wx <= 0;
            board_wy <= 0;
            board_rx <= 0;
            board_ry <= 0;
				*/
            spawn_x <= 4'd4;
            spawn_y <= 5'd0;
            score <= 0;
        end
        else
        begin
			move_commit <= 1'b0;
            cur_x <= piece_x;
            cur_y <= piece_y;
            state <= next_state;
			if (state == S_FALL && will_move) begin
      			move_commit <= 1'b1;       // fire the commit pulse
    		end
			if (move_commit) begin
      			piece_x <= piece_x + dX;
      			piece_y <= piece_y + dY;
      			if (want_rot) rot <= new_rot;
    		end
                if(state == S_SPAWN)
                begin
                    shape_id <= 0;
                    rot <= 0;
                    piece_x <= spawn_x;
                    piece_y <= spawn_y;
                end
                else if(move_accept)   
                begin
                    piece_x <= piece_x + dX;
                    piece_y <= piece_y + dY;
                    if(want_rot) 
                        rot <= new_rot;
                end
                if(state == S_FALL && next_state == S_LOCK)
                begin
                    // prepare write list for LOCK (using current rot)
                    wx_hold[0] <= piece_x + dx0_c;
                    wy_hold[0] <= piece_y + dy0_c;
                    wx_hold[1] <= piece_x + dx1_c;
                    wy_hold[1] <= piece_y + dy1_c;
                    wx_hold[2] <= piece_x + dx2_c;
                    wy_hold[2] <= piece_y + dy2_c;
                    wx_hold[3] <= piece_x + dx3_c;
                    wy_hold[3] <= piece_y + dy3_c;
                    lock_phase <= 2'd0;
                end
                if (state == S_LOCK)
                begin
                    if (lock_phase == 2'd3) 
					begin
                        lock_phase <= 2'd0;
                        if (score != 5'd31) 
                            score <= score + 5'd1;
                        else
                            score <= score;  // hold at max
					end
                    else 
                        lock_phase <= lock_phase + 2'd1; 
                end   
        end
end
    end
    assign LEDR[7:5] = state;
    assign LEDR[0]   = move_accept;
    assign LEDR[1]   = collide;
    assign LEDR[2]   = tick_gravity;
endmodule
