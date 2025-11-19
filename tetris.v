// Top-level: buttons -> clean pulses -> gamelogic -> painter.
// Clearing pass is disabled on reset to avoid the blank-screen issue for M2.

module tetris(
    SW, KEY, CLOCK_50, LEDR,
    VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
    input  [9:0] SW;
    input  [3:0] KEY;
    input        CLOCK_50;
    output [9:0] LEDR;

    output wire [7:0]  VGA_R, VGA_G, VGA_B;
    output wire        VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    wire resetn = KEY[3];

    // ticks
    wire [4:0] score;
    wire tick_input, tick_gravity;
    tick_i in      (CLOCK_50, resetn, tick_input);
    tick_g gravity (CLOCK_50, resetn, score, tick_gravity, /*blink*/);

    // buttons (active-low on board)
    wire left_raw   = ~KEY[2];
    wire right_raw  = ~KEY[1];
    wire rotate_raw = ~KEY[0];

    // debounced, one-shot, tick-limited
    wire left_sync,  left_level,  left_pulse,  left_final;
    wire right_sync, right_level, right_pulse, right_final;
    wire rot_sync,   rot_level,   rot_pulse,   rot_final;

    synchronizer s_left   (CLOCK_50, left_raw,   resetn, left_sync);
    debouncer   d_left    (CLOCK_50, resetn, left_sync,  left_level);
    edgedetect  e_left    (CLOCK_50, resetn, left_level, left_pulse);
    pending_event p_left  (left_pulse,  tick_input, resetn, CLOCK_50, left_final);

    synchronizer s_right  (CLOCK_50, right_raw,  resetn, right_sync);
    debouncer   d_right   (CLOCK_50, resetn, right_sync, right_level);
    edgedetect  e_right   (CLOCK_50, resetn, right_level, right_pulse);
    pending_event p_right (right_pulse, tick_input, resetn, CLOCK_50, right_final);

    synchronizer s_rot    (CLOCK_50, rotate_raw, resetn, rot_sync);
    debouncer   d_rot     (CLOCK_50, resetn, rot_sync,   rot_level);
    edgedetect  e_rot     (CLOCK_50, resetn, rot_level,  rot_pulse);
    pending_event p_rot   (rot_pulse,  tick_input, resetn, CLOCK_50, rot_final);

    // board wires (not used for M2; left unconnected to RAM)
    wire        board_we;
    wire [3:0]  board_wx, board_rx;
    wire [4:0]  board_wy, board_ry;
    wire        board_wdata, board_rdata;

    // current cell from game
    wire [3:0] cur_x;
    wire [4:0] cur_y;
    wire       move_accept;

    // core game (no board logic yet)
    gamelogic GAME(
        LEDR, CLOCK_50, resetn,
        left_final, right_final, rot_final,
        tick_gravity,
        board_rdata, board_rx, board_ry,
        board_we, board_wx, board_wy, board_wdata,
        score, cur_x, cur_y, move_accept
    );

    // painter handshake
    reg        kick;
    wire       done, busy;
    reg [9:0]  x0;
    reg [8:0]  y0;
    reg [8:0]  paint_color;

    wire [8:0] piece_color = 9'b111_000_111; // magenta
    wire [8:0] bg_color    = 9'b111111111;

    // remember last cell
    reg [3:0] prev_x;
    reg [4:0] prev_y;

    // draw FSM
    reg [1:0] draw_seq;

    // trigger redraws
    reg  prev_accept, prev_tick;
    wire new_accept  = move_accept  & ~prev_accept;
    wire new_tick    = tick_gravity & ~prev_tick;
    wire need_redraw = new_accept | new_tick;

    // clearing disabled at reset (per your “works when clearing=0” observation)
    reg clearing, first_draw;
    reg [3:0] clr_x;
    reg [4:0] clr_y;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            prev_accept <= 1'b0;
            prev_tick   <= 1'b0;

            kick        <= 1'b0;
            draw_seq    <= 2'd0;

            prev_x      <= 4'd0;
            prev_y      <= 5'd0;

            x0          <= 10'd0;
            y0          <= 9'd0;
            paint_color <= 9'd0;

            // IMPORTANT: no full-screen clear on reset
            clearing    <= 1'b0;
            first_draw  <= 1'b1;  // force one immediate draw of current cell

            clr_x <= 4'd0; clr_y <= 5'd0;
        end else begin
            prev_accept <= move_accept;
            prev_tick   <= tick_gravity;

            kick <= 1'b0;

            if (clearing) begin
                // (kept for later – not used because clearing=0 on reset)
                if (~busy && ~kick) begin
                    x0          <= {clr_x, 6'b0};
                    y0          <= {clr_y, 4'b0} + {clr_y, 3'b0};
                    paint_color <= bg_color;
                    kick        <= 1'b1;
                end else if (done) begin
                    if (clr_x == 4'd9) begin
                        clr_x <= 4'd0;
                        if (clr_y == 5'd19) begin
                            clr_y <= 5'd0;
                            clearing   <= 1'b0;
                            first_draw <= 1'b1;
                            prev_x <= cur_x; prev_y <= cur_y;
                        end else begin
                            clr_y <= clr_y + 5'd1;
                        end
                    end else begin
                        clr_x <= clr_x + 4'd1;
                    end
                end
            end else begin
                if (first_draw && ~busy && ~kick) begin
                    x0          <= {cur_x, 6'b0};
                    y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                    paint_color <= piece_color;
                    kick        <= 1'b1;
                    first_draw  <= 1'b0;
                end else begin
                    case (draw_seq)
                        2'd0: begin
                            if (need_redraw && ~busy && ~kick) begin
                                x0          <= {prev_x, 6'b0};
                                y0          <= {prev_y, 4'b0} + {prev_y, 3'b0};
                                paint_color <= bg_color;
                                kick        <= 1'b1;
                                draw_seq    <= 2'd1;
                            end
                        end
                        2'd1: begin
                            if (done && ~busy && ~kick) begin
                                x0          <= {cur_x, 6'b0};
                                y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                                paint_color <= piece_color;
                                kick        <= 1'b1;
                                draw_seq    <= 2'd2;
                            end
                        end
                        2'd2: begin
                            if (done && ~busy) begin
                                prev_x   <= cur_x;
                                prev_y   <= cur_y;
                                draw_seq <= 2'd0;
                            end
                        end
                        default: draw_seq <= 2'd0;
                    endcase
                end
            end
        end
    end

    // painter
    render_box20 RENDER (
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

endmodule
