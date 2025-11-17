// top-level wiring for inputs
// Purpose: convert physical button presses into clean, one-shot, frame-rate-limited pulses for the game FSM
// one-shot = the signal goes high for exactly one rising edge of clock, then goes low on the next
// per control: KEY -> invert -> synchronizer -> debouncer (5 ms) -> edge detector (rising edge, 1 clk)
// -> pending_event (re-timed to tick_input; max 1 action per frame)
// outputs from the top will be used by FSM: left_final, right_final, rot_final

module tetris(SW, KEY, CLOCK_50, LEDR, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
	output [9:0] LEDR;

	output wire [7:0]  VGA_R;
    output wire [7:0]  VGA_G;
    output wire [7:0]  VGA_B;
    output wire        VGA_HS;
    output wire        VGA_VS;
    output wire        VGA_BLANK_N;
    output wire        VGA_SYNC_N;
    output wire        VGA_CLK;
	
    // sync active low reset
    wire resetn;
    assign resetn = KEY[3];

    wire blink;
    wire [4:0] score;

    // frame rate for inputs (100 Hz)
    wire tick_input, tick_gravity;
    tick_i in(CLOCK_50, resetn, tick_input); // from ticks.v file
    tick_g gravity(CLOCK_50, resetn, score, tick_gravity, blink);
	 
    // move left, move right, rotate clockwise
    wire left, right, rotate;
    assign rotate = ~KEY[0];
    assign left = ~KEY[1];
    assign right = ~KEY[2];

    // LEFT BUTTON KEY[1]
    wire left_sync, left_level, left_pulse, left_final;
    // synchronize to 50 MHz
    synchronizer s_left(CLOCK_50, left, resetn, left_sync);
    // debounce into stable pulse 
    debouncer d_left(CLOCK_50, resetn, left_sync, left_level);
    // make sure 1 clock pulse happen on transition of left_level
    edgedetect e_left(CLOCK_50, resetn, left_level, left_pulse);
    // at most one action per tick_input timeframe
    pending_event p_left(left_pulse, tick_input, resetn, CLOCK_50, left_final);

    // RIGHT BUTTON KEY[2]
    wire right_sync, right_level, right_pulse, right_final;
    synchronizer s_right(CLOCK_50, right, resetn, right_sync);
    debouncer d_right(CLOCK_50, resetn, right_sync, right_level);
    edgedetect e_right(CLOCK_50, resetn, right_level, right_pulse);
    pending_event p_right(right_pulse, tick_input, resetn, CLOCK_50, right_final);

    // ROTATE BUTTON KEY[0]
    wire rot_sync, rot_level, rot_pulse, rot_final;
    synchronizer s_rotate(CLOCK_50, rotate, resetn, rot_sync);
    debouncer d_rotate(CLOCK_50, resetn,rot_sync, rot_level);
    edgedetect e_rotate(CLOCK_50, resetn, rot_level, rot_pulse);
    pending_event p_rot(rot_pulse, tick_input, resetn, CLOCK_50, rot_final);

    // left_final, right_final, rot_final will feed our FSM
	 
     // --- Board RAM wires ---
    wire        board_we;
    wire [3:0]  board_wx, board_rx;
    wire [4:0]  board_wy, board_ry;
    wire        board_wdata;
    wire        board_rdata;

	wire [8:0] piece_color = 9'b111_000_111; // magenta

    wire [3:0] cur_x;
    wire [4:0] cur_y;
    wire move_accept;
//    board10x20 BOARD (CLOCK_50, resetn, board_we, board_wx, board_wy, board_wdata, board_rx, board_ry, board_rdata);    
	gamelogic GAME(LEDR, CLOCK_50, resetn, left_final, right_final, rot_final, tick_gravity, board_rdata, board_rx, board_ry, board_we, board_wx, board_wy, board_wdata, score, cur_x, cur_y, move_accept);

    wire [9:0] px = cur_x * 10'd64; // 0..576
    wire [8:0] py = cur_y * 9'd24;  // 0..456

	reg        kick;           // 1-cycle pulse to start a draw
	wire       done, busy;     // from painter

	reg [9:0] x0;	
	reg [8:0] y0;

	 // REMEMBER LAST DRAWN CELL
	 
	 reg [3:0] prev_x;
	 reg [4:0] prev_y;
	 
	 reg [1:0] draw_seq;
	 
	 reg [8:0] paint_color;
	 
	 wire [8:0] bg_color = 0;
	
	
reg prev_accept, prev_tick;

wire new_accept = move_accept & ~prev_accept;
wire new_tick   = tick_gravity & ~prev_tick;
wire need_redraw = new_accept | new_tick;
reg        clearing;
reg [3:0]  clr_x;     // 0..9
reg [4:0]  clr_y;     // 0..19

always @(posedge CLOCK_50 or negedge resetn) begin
    if (!resetn) begin
        clearing <= 1'b1;
        clr_x    <= 4'd0;
        clr_y    <= 5'd0;
        prev_accept <= 1'b0;
        prev_tick   <= 1'b0;
        kick        <= 1'b0;
        draw_seq    <= 2'd0;
        prev_x      <= 4'd0;
        prev_y      <= 5'd0;
    end else begin
        // edge-capture
        prev_accept <= move_accept;
        prev_tick   <= tick_gravity;

        // default: no start
        kick <= 1'b0;
		  if (clearing) begin
            // only launch when painter is idle
            if (~busy && ~kick) begin
                x0          <= {clr_x, 6'b0};
                y0          <= {clr_y, 4'b0} + {clr_y, 3'b0};
                paint_color <= bg_color;
                kick        <= 1'b1;  // one box per start
            end else if (done) begin
                // advance to next cell
                if (clr_x == 4'd9) begin
                    clr_x <= 4'd0;
                    if (clr_y == 5'd19) begin
                        clr_y   <= 5'd0;
                        clearing <= 1'b0;   // finished clearing
                        // also sync prev to current so first move erases the right cell
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

        case (draw_seq)
            2'd0: begin
                // idle: if a move/gravity happened and painter is free, erase old cell
                if (need_redraw && ~busy) begin
                    x0          <= {prev_x, 6'b0};                       // prev_x * 64
                    y0          <= {prev_y, 4'b0} + {prev_y, 3'b0};      // prev_y * 24
                    paint_color <= bg_color;                              // erase
                    kick        <= 1'b1;
                    draw_seq    <= 2'd1;
                end
            end

            2'd1: begin
                // after erase finishes, draw the new cell
                if (done && ~busy) begin
                    x0          <= {cur_x, 6'b0};
                    y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                    paint_color <= piece_color;
                    kick        <= 1'b1;
                    draw_seq    <= 2'd2;
                end
            end

            2'd2: begin
                // after draw finishes, update prev_* and go idle
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
    	.VGA_CLKz
