// top-level wiring for inputs
// Purpose: convert physical button presses into clean, one-shot, frame-rate-limited pulses for the game FSM
// one-shot = the signal goes high for exactly one rising edge of clock, then goes low on the next
// per control: KEY -> invert -> synchronizer -> debouncer (5 ms) -> edge detector (rising edge, 1 clk)
// -> pending_event (re-timed to tick_input; max 1 action per frame)
// outputs from the top will be used by FSM: left_final, right_final, rot_final

module tetris(
    SW, KEY, CLOCK_50, LEDR,
    VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
    input  [9:0] SW;
    input  [3:0] KEY;
    input        CLOCK_50;
    output [9:0] LEDR;

    output wire [7:0]  VGA_R;
    output wire [7:0]  VGA_G;
    output wire [7:0]  VGA_B;
    output wire        VGA_HS;
    output wire        VGA_VS;
    output wire        VGA_BLANK_N;
    output wire        VGA_SYNC_N;
    output wire        VGA_CLK;

    // sync active-low reset
    wire resetn = KEY[3];

    wire blink;
    wire [4:0] score;

    // frame rates
    wire tick_input, tick_gravity;
    tick_i in      (CLOCK_50, resetn, tick_input);               // 100 Hz input tick
    tick_g gravity (CLOCK_50, resetn, score, tick_gravity, blink);

    // raw buttons (active low on DE1/DE2 style boards)
    wire left_raw   = ~KEY[1];
    wire right_raw  = ~KEY[2];
    wire rotate_raw = ~KEY[0];

    // --- Debounced, one-shot pulses, limited to tick_input ---
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

    // --- Board RAM wires (stub for now) ---
    wire        board_we;
    wire [3:0]  board_wx, board_rx;
    wire [4:0]  board_wy, board_ry;
    wire        board_wdata;
    wire        board_rdata;

    // Current active piece position from gamelogic
    wire [3:0] cur_x;
    wire [4:0] cur_y;
    wire       move_accept;

    // Game core
    gamelogic GAME(
        LEDR, CLOCK_50, resetn,
        left_final, right_final, rot_final,
        tick_gravity,
        board_rdata, board_rx, board_ry,
        board_we, board_wx, board_wy, board_wdata,
        score, cur_x, cur_y, move_accept
    );

    // --- Painter handshake ---
    // render_box20 draws a 64x24 box at (x0,y0) with a given color when .start is pulsed for 1 cycle.
    // It asserts .busy while working and raises .done for 1 cycle when finished.

    reg        kick;           // 1-cycle pulse to start a draw
    wire       done, busy;     // from painter

    reg [9:0]  x0;             // pixel x  (multiple of 64)
    reg [8:0]  y0;             // pixel y  (multiple of 24)
    reg [8:0]  paint_color;    // 3:3:3 RGB

    wire [8:0] piece_color = 9'b111_000_111; // magenta
    wire [8:0] bg_color    = 9'd0;           // black

    // Remember last drawn cell to erase it first
    reg [3:0] prev_x;
    reg [4:0] prev_y;

    // Simple 3-step draw FSM: 0=idle, 1=erase old, 2=draw new
    reg [1:0] draw_seq;

    // Edge-detect move_accept and tick_gravity to trigger redraws
    reg prev_accept, prev_tick;
    wire new_accept  = move_accept  & ~prev_accept;
    wire new_tick    = tick_gravity & ~prev_tick;
    wire need_redraw = new_accept | new_tick;

    // On-boot clear of whole screen (10x20 boxes), then one forced first draw
    reg        clearing;
    reg [3:0]  clr_x;     // 0..9
    reg [4:0]  clr_y;     // 0..19
    reg        first_draw;

    // Painter / display sequencer
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            // reset painter state
            clearing     <= 1'b1;    // DO clear after reset
            first_draw   <= 1'b0;
            clr_x        <= 4'd0;
            clr_y        <= 5'd0;

            prev_accept  <= 1'b0;
            prev_tick    <= 1'b0;

            kick         <= 1'b0;
            draw_seq     <= 2'd0;

            prev_x       <= 4'd0;
            prev_y       <= 5'd0;

            // IMPORTANT: give painter known coords & color at reset so first start is valid
            x0           <= 10'd0;
            y0           <= 9'd0;
            paint_color  <= 9'd0;
        end else begin
            // edge capture for move/gravity
            prev_accept <= move_accept;
            prev_tick   <= tick_gravity;

            // default: no painter start unless we set it
            kick <= 1'b0;

            if (clearing) begin
                // Clear one cell when painter is idle
                if (~busy && ~kick) begin
                    x0          <= {clr_x, 6'b0};                 // clr_x * 64
                    y0          <= {clr_y, 4'b0} + {clr_y, 3'b0}; // clr_y * 24
                    paint_color <= bg_color;
                    kick        <= 1'b1;                          // start this box
                end else if (done) begin
                    // advance the scanning cursor
                    if (clr_x == 4'd9) begin
                        clr_x <= 4'd0;
                        if (clr_y == 5'd19) begin
                            // finished full clear
                            clr_y      <= 5'd0;
                            clearing   <= 1'b0;
                            first_draw <= 1'b1;      // force one draw after clearing
                            // sync previous cell to current
                            prev_x <= cur_x;
                            prev_y <= cur_y;
                        end else begin
                            clr_y <= clr_y + 5'd1;
                        end
                    end else begin
                        clr_x <= clr_x + 4'd1;
                    end
                end
            end else begin
                // One-time draw immediately after the clear finishes
                if (first_draw && ~busy && ~kick) begin
                    x0          <= {cur_x, 6'b0};
                    y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                    paint_color <= piece_color;
                    kick        <= 1'b1;
                    first_draw  <= 1'b0;
                end else begin
                    // Normal erase->draw sequence
                    case (draw_seq)
                        2'd0: begin
                            // if a move/gravity happened, erase the old cell
                            if (need_redraw && ~busy && ~kick) begin
                                x0          <= {prev_x, 6'b0};
                                y0          <= {prev_y, 4'b0} + {prev_y, 3'b0};
                                paint_color <= bg_color;
                                kick        <= 1'b1;
                                draw_seq    <= 2'd1;
                            end
                        end

                        2'd1: begin
                            // after erase finishes, draw the new cell
                            if (done && ~busy && ~kick) begin
                                x0          <= {cur_x, 6'b0};
                                y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                                paint_color <= piece_color;
                                kick        <= 1'b1;
                                draw_seq    <= 2'd2;
                            end
                        end

                        2'd2: begin
                            // after draw finishes, commit prev_* and go idle
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

    // Painter (64x24 box renderer)
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
