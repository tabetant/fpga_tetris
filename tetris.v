`default_nettype none

// Top-level: PS/2 keys -> clean pulses -> gamelogic -> painter.
// Clearing pass is disabled on reset to avoid the blank-screen issue for M2.

module tetris(
    SW, KEY, CLOCK_50, LEDR, PS2_CLK, PS2_DAT,
    VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
    input wire [9:0] SW;
    input  wire [3:0] KEY;
    input       wire CLOCK_50;
    output wire [9:0] LEDR;

    output wire [7:0]  VGA_R, VGA_G, VGA_B;
    output wire        VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    // active–high resetn (KEY[3] not pressed = 1)
    wire resetn = KEY[3];

    // =========================================================
    // Ticks
    // =========================================================
    wire [4:0] score;
    wire       tick_input, tick_gravity;

    tick_i in (
        .CLOCK_50  (CLOCK_50),
        .resetn    (resetn),
        .tick_input(tick_input)
    );

    // assuming tick_g: (CLOCK_50, resetn, tick_gravity, blink, score)
    wire blink_unused;
    tick_g gravity (
        .CLOCK_50    (CLOCK_50),
        .resetn      (resetn),
        .tick_gravity(tick_gravity),
        .blink       (blink_unused),
        .score       (score)
    );

    // =========================================================
    // PS/2 keyboard controller and key decode
    // =========================================================
	 input wire PS2_CLK;
	input wire PS2_DAT;
    wire [7:0] ps2_key_data;
    wire       ps2_key_pressed;

    PS2_Interface PS2 (
    .CLOCK_50       (CLOCK_50),
    .resetn         (resetn),
    .PS2_CLK        (PS2_CLK),
    .PS2_DAT        (PS2_DAT),
    .scan_code      (ps2_key_data),
    .scan_code_valid(ps2_key_pressed)
);
 
    // Decode PS/2 make codes into 1-cycle pulses
    //   'A' (0x1C) -> left
    //   'D' (0x23) -> right
    //   'W' (0x1D) -> rotate
    reg left_ps2_pulse, right_ps2_pulse, rot_ps2_pulse;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            left_ps2_pulse  <= 1'b0;
            right_ps2_pulse <= 1'b0;
            rot_ps2_pulse   <= 1'b0;
        end
        else begin
            // default: no PS/2 pulses this cycle
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

    // =========================================================
    // Final move pulses (PS/2 ONLY, no buttons)
    // =========================================================
    wire left_final, right_final, rot_final;

    // These are already 1-cycle pulses, so we only rate-limit them with pending_event.
    pending_event p_left (
        .edge_1clk  (left_ps2_pulse),
        .tick_input      (tick_input),
        .resetn    (resetn),
        .clock  (CLOCK_50),
        .button (left_final)
    );

    pending_event p_right (
        .edge_1clk  (right_ps2_pulse),
        .tick_input      (tick_input),
        .resetn    (resetn),
        .clock  (CLOCK_50),
        .button (right_final)
    );

    pending_event p_rot (
        .edge_1clk  (rot_ps2_pulse),
        .tick_input      (tick_input),
        .resetn    (resetn),
        .clock  (CLOCK_50),
        .button (rot_final)
    );

    // NOTE: KEY[0], KEY[1], KEY[2] are now unused.
    // Only KEY[3] is used as reset.

    // =========================================================
    // Board wires (not used for M2; RAM can be added later)
    // =========================================================
    wire        board_we;
    wire [3:0]  board_wx, board_rx;
    wire [4:0]  board_wy, board_ry;
    wire        board_wdata, board_rdata;

    assign board_rdata = 1'b0;
    // board10x20 BOARD (...);

    // =========================================================
    // Core game
    // =========================================================
    wire [3:0] cur_x;
    wire [4:0] cur_y;
    wire       move_accept;

    gamelogic GAME(
        .LEDR        (LEDR),
        .CLOCK_50    (CLOCK_50),
        .resetn      (resetn),
        .left_final  (left_final),
        .right_final (right_final),
        .rot_final   (rot_final),
        .tick_gravity(tick_gravity),
        .board_rdata (board_rdata),
        .board_rx    (board_rx),
        .board_ry    (board_ry),
        .board_we    (board_we),
        .board_wx    (board_wx),
        .board_wy    (board_wy),
        .board_wdata (board_wdata),
        .score       (score),
        .cur_x       (cur_x),
        .cur_y       (cur_y),
        .move_accept      (move_accept)
    );

    // =========================================================
    // Painter handshake and cell→pixel mapping
    // =========================================================
    reg        kick;
    wire       done, busy;
    reg [9:0]  x0;
    reg [8:0]  y0;
    reg [8:0]  paint_color;

    wire [8:0] piece_color = 9'b111_000_111; // magenta
    wire [8:0] bg_color    = 9'b111_111_111; // white erase

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

    // clearing disabled at reset
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

            clr_x <= 4'd0;
            clr_y <= 5'd0;
        end
        else begin
            prev_accept <= move_accept;
            prev_tick   <= tick_gravity;

            kick <= 1'b0;

            if (clearing) begin
                // (kept for later – not used because clearing=0 on reset)
                if (~busy && ~kick) begin
                    // 24x24 mapping: x = col*64, y = row*24
                    x0          <= {clr_x, 6'b0};
                    y0          <= {clr_y, 4'b0} + {clr_y, 3'b0};
                    paint_color <= bg_color;
                    kick        <= 1'b1;
                end
                else if (done) begin
                    if (clr_x == 4'd9) begin
                        clr_x <= 4'd0;
                        if (clr_y == 5'd19) begin
                            clr_y     <= 5'd0;
                            clearing  <= 1'b0;
                            first_draw<= 1'b1;
                            prev_x    <= cur_x;
                            prev_y    <= cur_y;
                        end
                        else begin
                            clr_y <= clr_y + 5'd1;
                        end
                    end
                    else begin
                        clr_x <= clr_x + 4'd1;
                    end
                end
            end
            else begin
                if (first_draw && ~busy && ~kick) begin
                    x0          <= {cur_x, 6'b0};
                    y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                    paint_color <= piece_color;
                    kick        <= 1'b1;
                    first_draw  <= 1'b0;
                end
                else begin
                    case (draw_seq)
                        2'd0: begin
                            if (need_redraw && ~busy && ~kick) begin
                                x0          <= {prev_x, 6'b0};
                                y0          <= {prev_y, 4'b0} + {prev_y, 3'b0};
                                paint_color <= bg_color;   // erase old
                                kick        <= 1'b1;
                                draw_seq    <= 2'd1;
                            end
                        end
                        2'd1: begin
                            if (done && ~busy && ~kick) begin
                                x0          <= {cur_x, 6'b0};
                                y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                                paint_color <= piece_color; // draw new
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

endmodule
