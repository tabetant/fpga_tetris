// board size: 10 cols (0 <= x <= 9) * 20 rows (0 <= y <= 19)
// origin: top-left cell (ORIGIN_X = 0, ORIGIN_Y = 0)
// y increases downward: gravity = y + 1
// screen 160x120 (0 <= px_x <= 159, 0 <= px_y <= 119)
// CELL_W = 160 / 10 = 16 px
// CELL_H = 120 / 20 = 6 px
// px_left = ORIGIN_X + x * CELL_W
// px_top = ORIGIN_Y + y * CELL_H
// ORIGIN (x = 0, y = 0) maps to pixels [0:15]x[0:5]
// BOTTOM RIGHT (x = 9, y = 19) maps to pixels [144:159]x[114:119]
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
// if tx < 0 | tx > 9 | ty > 19 => collide = 1 (illegal)
// if read_cell(tx, ty) == 1, collide == 1
// 3 - if all conditions keep collide = 0 , accept the move:
// piece_x += dX, piece_y += dY, rot = new_rot

module gamelogic(CLOCK_50, resetn, left_final, right_final, rot_final, tick_gravity, board_rdata, board_rx, board_ry, board_we, board_wx, board_wy, board_wdata);
    input CLOCK_50, resetn;

    // input debounced clean pulses
    input left_final, right_final, rot_final;

    input tick_gravity; // gravity timer

    // board reading
    input board_rdata; // 1 if (board_rx, board_ry) is occupied
    output reg [3:0] board_rx;
    output reg [4:0] board_ry;

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
 
    // accepting move logic
    reg move_accept; // set in "fall", checked before accepting move at clock cycle
    reg want_left, want_right, want_rot, want_grav;
    reg [1:0] dRot;
    reg have_action;

    reg [3:0] tx; // target x
    reg [4:0] ty; // target y 
    reg collide; // for violations
    reg [1:0] new_rot; // target rot (rot+dRot) % 4

    always@*
    begin
        case(state)
            S_IDLE: next_state = S_SPAWN;
            S_SPAWN: 
                if (collision)
                    next_state = S_GAME_OVER; // to be implemented later;
                else 
                begin
                    next_state = S_FALL;
                end
            S_FALL: if (left_final) 
                begin
                    dRot = 0;
                    want_left = 1;
                    dX = -1;
                    new_rot = (rot + dRot) & 2'b11;
                    
                    // compute offsets dy, dx
                    tx = piece_x + dX + dx[i]; // will need 4 of these, one for each block of our tetrominos
                    ty = piece_y + dy[i];
                    if (piece_x == 0 || x > 4'd9 || ty > 5'd19) collide = 1'b1;
                    else collide = 0;
                end
                else if (right_final)
                begin
                    dRot = 0;
                    want_right = 1;
                    dX = 1;
                    new_rot = (rot + dRot) & 2'b11;
                    // compute offsets dy, dx
                    tx = piece_x + dX + dx[i];
                    ty = piece_y + dy[i];
                    if (piece_x == 4'd9 || tx > 4'd9 || ty > 5'd19) collide = 1'b1;
                    else collide = 0;
                end
                else if (rot_final)
                begin
                    want_rot = 1;
                    dRot = 1;
                    new_rot = (rot + dRot) & 2'b11;
                    // compute offsets dy, dx
                    tx = piece_x + dx[i];
                    ty = piece_y + dy[i];
                    if (tx > 4'd9 || ty > 5'd19) collide = 1'b1;
                    else collide = 0;
                end
                if(tick_gravity)
                begin
                    want_gravity = 1;
                    dY = 1;
                    new_rot = (rot + dRot) & 2'b11;
                    // compute offsets dy, dx
                    tx = piece_x + dx[i];
                    ty = piece_y + dY + dy[i];
                    if (tx > 4'd9 || ty > 5'd19) collide = 1'b1;
                    else collide = 0;
                end
                have_action = want_left|want_right|want_rot|want_grav;
            S_LOCK: // write the 4 blocks of active piece into board memory

            S_CLEAR: next_state = S_SPAWN; // will change for next milestone
            default: next_state = S_IDLE;
        endcase
    end

    always@(posedge CLOCK_50)
    begin
        if(!resetn | state == S_IDLE)
        begin
            state <= S_IDLE;
            piece_x <= 0;
            piece_y <= 0;
            rot <= 0;
            shape_id <= 0;
            lock_i <= 0;
            board_we <= 0;
            board_wdata <= 0;
            board_wx <= 0;
            board_wy <= 0;
            board_rx <= 0;
            board_ry <= 0;
            move_accept <= 0;
            tx <= 0;
            ty <= 0;
            collide <= 0;
            new_rot <= 0;
            lock_i <= 0;
            piece_x <= 0;
            piece_y <= 0;
            rot <= 0;
            shape_id <= 0;
        end
        else
        begin
            state <= next_state;
            if (move_accept)
                begin
                    if(state == S_SPAWN)
                    begin
                        shape_id <= 0;
                        rot <= 0;
                        piece_x <= spawn_x;
                        piece_y <= spawn_y;
                    end
                    else    
                    begin
                        piece_x <= tx;
                        piece_y <= ty;
                        rot <= new_rot;
                    end
                end   
        end
    end
endmodule

