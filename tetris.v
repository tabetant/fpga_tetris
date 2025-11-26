`default_nettype none

module tetris(
    SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, PS2_CLK, PS2_DAT,
    VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
    input  wire [9:0] SW;
    input  wire [3:0] KEY;
    input  wire       CLOCK_50;
    output wire [9:0] LEDR;

    output wire [7:0] VGA_R, VGA_G, VGA_B;
    output wire       VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
    output wire [6:0] HEX0, HEX1; // score display

    // active–high resetn (KEY[3] not pressed = 1)
    wire resetn = KEY[3];
    
    // =========================================================
    // Ticks
    // =========================================================
    wire [4:0] score;
    wire       tick_input, tick_gravity;

    tick_i in (
        .CLOCK_50   (CLOCK_50),
        .resetn     (resetn),
        .tick_input (tick_input)
    );
    wire blink_unused;
    tick_g gravity (
        .CLOCK_50     (CLOCK_50),
        .resetn       (resetn),
        .score        (score),
        .tick_gravity (tick_gravity),
        .blink        (blink_unused)
    );

    // =========================================================
    // PS/2 keyboard controller and key decode
    // =========================================================
    input  wire PS2_CLK;
    input  wire PS2_DAT;
    wire  [7:0] ps2_key_data;
    wire        ps2_key_pressed;
    PS2_Interface PS2 (
        .CLOCK_50        (CLOCK_50),
        .resetn          (resetn),
        .PS2_CLK         (PS2_CLK),
        .PS2_DAT         (PS2_DAT),
        .scan_code       (ps2_key_data),
        .scan_code_valid (ps2_key_pressed)
    );
    
    reg left_ps2_pulse, right_ps2_pulse, rot_ps2_pulse;
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            left_ps2_pulse  <= 1'b0;
            right_ps2_pulse <= 1'b0;
            rot_ps2_pulse   <= 1'b0;
        end else begin
            left_ps2_pulse  <= 1'b0;
            right_ps2_pulse <= 1'b0;
            rot_ps2_pulse   <= 1'b0;

            if (ps2_key_pressed) begin
                case (ps2_key_data)
                    8'h1C: left_ps2_pulse  <= 1'b1; // 'A'
                    8'h23: right_ps2_pulse <= 1'b1; // 'D'
                    8'h1D: rot_ps2_pulse   <= 1'b1; // 'W'
                    default: ;
                endcase
            end
        end
    end

    wire left_final, right_final, rot_final;
    pending_event p_left (
        .edge_1clk   (left_ps2_pulse),
        .tick_input  (tick_input),
        .resetn      (resetn),
        .clock       (CLOCK_50),
        .button      (left_final)
    );
    pending_event p_right (
        .edge_1clk   (right_ps2_pulse),
        .tick_input  (tick_input),
        .resetn      (resetn),
        .clock       (CLOCK_50),
        .button      (right_final)
    );
    pending_event p_rot (
        .edge_1clk   (rot_ps2_pulse),
        .tick_input  (tick_input),
        .resetn      (resetn),
        .clock       (CLOCK_50),
        .button      (rot_final)
    );

    // =========================================================
    // Core game
    // =========================================================
    wire [3:0] cur_x;
    wire [4:0] cur_y;
    wire       move_accept;
    wire [2:0] cur_shape_id; 
    wire [1:0] cur_rot;      
    wire signed [3:0] dx0_c, dy0_c, dx1_c, dy1_c, dx2_c, dy2_c, dx3_c, dy3_c; 
    wire       game_over; 

    wire        board_we;
    wire [3:0]  board_wx;
    wire [4:0]  board_wy;
    wire        board_wdata;

    wire [3:0]  rx0, rx1, rx2, rx3;
    wire [4:0]  ry0, ry1, ry2, ry3;
    wire        r0, r1, r2, r3;

    // NEW: Randomizer wire
    wire [2:0] next_random_shape;

    // NEW: Randomizer Instance
    // Pass ~resetn because randomiser expects active high reset
    randomiser u_rand (
        .reset (~resetn),
        .clock (CLOCK_50),
        .shape_id (next_random_shape)
    );

    // Game core
    gamelogic GAME(
        .LEDR       (LEDR),
        .CLOCK_50   (CLOCK_50),
        .resetn     (resetn),
        .left_final (left_final),
        .right_final(right_final),
        .rot_final  (rot_final),
        .tick_gravity(tick_gravity),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3),
        .rx0(rx0), .ry0(ry0),
        .rx1(rx1), .ry1(ry1),
        .rx2(rx2), .ry2(ry2),
        .rx3(rx3), .ry3(ry3),
        .board_we   (board_we),
        .board_wx   (board_wx),
        .board_wy   (board_wy),
        .board_wdata(board_wdata),
        .score      (score),
        .cur_x      (cur_x),
        .cur_y      (cur_y),
        .move_accept(move_accept),
        .cur_shape_id (cur_shape_id), 
        .cur_rot      (cur_rot),      
        .dx0_c(dx0_c), .dy0_c(dy0_c),
        .dx1_c(dx1_c), .dy1_c(dy1_c),
        .dx2_c(dx2_c), .dy2_c(dy2_c),
        .dx3_c(dx3_c), .dy3_c(dy3_c),
        .game_over    (game_over),
        .random_shape (next_random_shape) // Connect the wire
    );

    // Board instance
    board10x20_4r BOARD(
        .clk    (CLOCK_50),
        .resetn (resetn),
        .we     (board_we),
        .wx     (board_wx),
        .wy     (board_wy),
        .wdata  (board_wdata),
        .rx0(rx0), .ry0(ry0), .r0(r0),
        .rx1(rx1), .ry1(ry1), .r1(r1),
        .rx2(rx2), .ry2(ry2), .r2(r2),
        .rx3(rx3), .ry3(ry3), .r3(r3)
    );

    // =========================================================
    // Painter and cell→pixel mapping
    // =========================================================
    reg        kick;
    wire       done, busy;
    reg [9:0]  x0;
    reg [8:0]  y0;
    reg [8:0]  paint_color;

    wire [8:0] piece_color = 9'b111_000_111; // magenta
    wire [8:0] bg_color    = game_over ? 9'b111_000_000 : 9'b000_000_000; 

    // remember last cell (for live piece trail erase)
    reg [3:0] prev_x;
    reg [4:0] prev_y;
    reg       have_prev;
    reg [1:0] draw_seq;
    reg [1:0] draw_index; 

    // trigger redraws
    reg  prev_accept, prev_tick;
    wire new_accept  = move_accept  & ~prev_accept;
    wire new_tick    = tick_gravity & ~prev_tick;
    wire need_redraw = new_accept | new_tick;
    
    // clearing disabled at reset
    reg clearing, first_draw;
    reg [3:0] clr_x;
    reg [4:0] clr_y;
    reg game_over_latched; 

    // ------------------------------
    // Lock-draw queue to ensure locked blocks are always painted
    // ------------------------------
    reg        locking;
    reg  [1:0] lock_wr_ptr, lock_rd_ptr;
    reg  [3:0] lock_qx [0:3];
    reg  [4:0] lock_qy [0:3];
    wire       lock_q_empty = (lock_wr_ptr == lock_rd_ptr);

    // painter
    render_box24 RENDER (
        .CLOCK_50    (CLOCK_50),
        .resetn      (resetn),
        .start       (kick),
        .x0          (x0),
        .y0          (y0),
        .color       (paint_color),
        .done        (done),
        .busy        (busy),
        .VGA_R       (VGA_R),
        .VGA_G       (VGA_G),
        .VGA_B       (VGA_B),
        .VGA_HS      (VGA_HS),
        .VGA_VS      (VGA_VS),
        .VGA_BLANK_N (VGA_BLANK_N),
        .VGA_SYNC_N  (VGA_SYNC_N),
        .VGA_CLK     (VGA_CLK)
    );

    wire signed [3:0] current_dx, current_dy;
    assign current_dx = (draw_index == 2'd0) ? dx0_c :
                        (draw_index == 2'd1) ? dx1_c :
                        (draw_index == 2'd2) ? dx2_c : dx3_c;
    assign current_dy = (draw_index == 2'd0) ? dy0_c :
                        (draw_index == 2'd1) ? dy1_c :
                        (draw_index == 2'd2) ? dy2_c : dy3_c;

    // ------------------------------
    // Painter control
    // ------------------------------

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            prev_accept     <= 1'b0;
            prev_tick       <= 1'b0;
            locking         <= 1'b0;
            lock_wr_ptr     <= 2'd0;
            lock_rd_ptr     <= 2'd0;
            have_prev       <= 1'b0;
            draw_seq        <= 2'd0;
            draw_index      <= 2'd0; 
            kick            <= 1'b0;
            x0              <= 10'd0;
            y0              <= 9'd0;
            paint_color     <= 9'd0;
            prev_x          <= 4'd0;
            prev_y          <= 5'd0;
            clearing        <= 1'b0;
            first_draw      <= 1'b1;  
            clr_x           <= 4'd0;
            clr_y           <= 5'd0;
            game_over_latched <= 1'b0;
        end else begin
            prev_accept   <= move_accept;
            prev_tick     <= tick_gravity;

            kick <= 1'b0; 

            if (game_over && !game_over_latched) begin
                clearing          <= 1'b1;
                game_over_latched <= 1'b1;
                clr_x             <= 4'd0;
                clr_y             <= 5'd0;
            end

            if (board_we && board_wdata) begin
                lock_qx[lock_wr_ptr] <= board_wx;
                lock_qy[lock_wr_ptr] <= board_wy;
                lock_wr_ptr          <= lock_wr_ptr + 2'd1;
                locking              <= 1'b1;
            end

            if (clearing) begin
                if (~busy && ~kick) begin
                    x0          <= {clr_x, 6'b0};
                    y0          <= {clr_y, 4'b0} + {clr_y, 3'b0};
                    paint_color <= bg_color;
                    kick        <= 1'b1;
                end else if (done) begin
                    if (clr_x == 4'd9) begin
                        clr_x <= 4'd0;
                        if (clr_y == 5'd19) begin
                            clr_y     <= 5'd0;
                            clearing  <= 1'b0;
                            first_draw<= 1'b1;
                            prev_x    <= cur_x;
                            prev_y    <= cur_y;
                        end else begin
                            clr_y <= clr_y + 5'd1;
                        end
                    end else begin
                        clr_x <= clr_x + 4'd1;
                    end
                end
            end else if (!game_over) begin
                if (~busy && ~kick && ~lock_q_empty) begin
                    x0          <= {lock_qx[lock_rd_ptr], 6'b0};
                    y0          <= {lock_qy[lock_rd_ptr], 4'b0} + {lock_qy[lock_rd_ptr], 3'b0};
                    paint_color <= piece_color; 
                    kick        <= 1'b1;
                    lock_rd_ptr <= lock_rd_ptr + 2'd1;
                end
                else if (locking && lock_q_empty && done && ~busy && ~kick) begin
                    locking    <= 1'b0;
                    have_prev  <= 1'b0; 
                    first_draw <= 1'b1; 
                    prev_x     <= cur_x;
                    prev_y     <= cur_y;
                end else if (first_draw && ~busy && ~kick) begin
                    x0          <= {prev_x + dx0_c, 6'b0}; 
                    y0          <= {prev_y + dy0_c, 4'b0} + {prev_y + dy0_c, 3'b0};
                    paint_color <= bg_color;
                    kick        <= 1'b1;
                    first_draw  <= 1'b0;
                    draw_seq    <= 2'd1; 
                    draw_index  <= 2'd0; 
                end else begin
                    case (draw_seq)
                        2'd0: begin 
                            if (need_redraw && ~busy && ~kick) begin
                                if (~locking && have_prev && lock_q_empty) begin
                                    x0          <= {prev_x + dx0_c, 6'b0};
                                    y0          <= {prev_y + dy0_c, 4'b0} + {prev_y + dy0_c, 3'b0};
                                    paint_color <= bg_color;
                                    kick        <= 1'b1;
                                    draw_seq    <= 2'd1; 
                                    draw_index  <= 2'd0;
                                end else begin
                                    x0          <= {cur_x + dx0_c, 6'b0};
                                    y0          <= {cur_y + dy0_c, 4'b0} + {cur_y + dy0_c, 3'b0};
                                    paint_color <= piece_color;
                                    kick        <= 1'b1;
                                    draw_seq    <= 2'd2; 
                                    draw_index  <= 2'd0;
                                end
                            end
                        end
                        2'd1: begin 
                            if (done && ~busy && ~kick) begin
                                if (draw_index == 2'd3) begin
                                    x0          <= {cur_x + dx0_c, 6'b0};
                                    y0          <= {cur_y + dy0_c, 4'b0} + {cur_y + dy0_c, 3'b0};
                                    paint_color <= piece_color;
                                    kick        <= 1'b1;
                                    draw_seq    <= 2'd2; 
                                    draw_index  <= 2'd0;
                                end else begin
                                    case (draw_index)
                                        2'd0: begin x0 <= {prev_x + dx1_c, 6'b0}; y0 <= {prev_y + dy1_c, 4'b0} + {prev_y + dy1_c, 3'b0}; end
                                        2'd1: begin x0 <= {prev_x + dx2_c, 6'b0}; y0 <= {prev_y + dy2_c, 4'b0} + {prev_y + dy2_c, 3'b0}; end
                                        2'd2: begin x0 <= {prev_x + dx3_c, 6'b0}; y0 <= {prev_y + dy3_c, 4'b0} + {prev_y + dy3_c, 3'b0}; end
                                        default: ;
                                    endcase
                                    paint_color <= bg_color;
                                    kick        <= 1'b1;
                                    draw_index  <= draw_index + 2'd1;
                                end
                            end
                        end
                        2'd2: begin 
                            if (done && ~busy && ~kick) begin
                                if (draw_index == 2'd3) begin
                                    draw_seq    <= 2'd3; 
                                    draw_index  <= 2'd0;
                                end else begin
                                    case (draw_index)
                                        2'd0: begin x0 <= {cur_x + dx1_c, 6'b0}; y0 <= {cur_y + dy1_c, 4'b0} + {cur_y + dy1_c, 3'b0}; end
                                        2'd1: begin x0 <= {cur_x + dx2_c, 6'b0}; y0 <= {cur_y + dy2_c, 4'b0} + {cur_y + dy2_c, 3'b0}; end
                                        2'd2: begin x0 <= {cur_x + dx3_c, 6'b0}; y0 <= {cur_y + dy3_c, 4'b0} + {cur_y + dy3_c, 3'b0}; end
                                        default: ;
                                    endcase
                                    paint_color <= piece_color;
                                    kick        <= 1'b1;
                                    draw_index  <= draw_index + 2'd1;
                                end
                            end
                        end
                        2'd3: begin 
                             prev_x      <= cur_x;
                             prev_y      <= cur_y;
                             have_prev   <= 1'b1;
                             draw_seq    <= 2'd0;
                             draw_index  <= 2'd0;
                        end
                        default: draw_seq <= 2'd0;
                    endcase
                end
            end
        end
    end

    wire [6:0] h_tens, h_units;
    SevSegDecoder_5bit s(score, h_tens, h_units);
    assign HEX0 = ~h_units;
    assign HEX1 = ~h_tens;

endmodule
