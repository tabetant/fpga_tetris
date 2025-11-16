// top-level wiring for inputs
// Purpose: convert physical button presses into clean, one-shot, frame-rate-limited pulses for the game FSM
// one-shot = the signal goes high for exactly one rising edge of clock, then goes low on the next
// per control: KEY -> invert -> synchronizer -> debouncer (5 ms) -> edge detector (rising edge, 1 clk)
// -> pending_event (re-timed to tick_input; max 1 action per frame)
// outputs from the top will be used by FSM: left_final, right_final, rot_final

module tetris(SW, KEY, CLOCK_50, LEDR, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_V, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
	output [9:0] LEDR;

	output wire [7:0]  VGA_R,
    output wire [7:0]  VGA_G,
    output wire [7:0]  VGA_B,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire        VGA_BLANK_N,
    output wire        VGA_SYNC_N,
    output wire        VGA_CLK
	
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

board10x20 BOARD (CLOCK_50, resetn, board_we, board_wx, board_wy, board_wdata, board_rx, board_ry, board_rdata);
	gamelogic GAME(LEDR, CLOCK_50, resetn, left_final, right_final, rot_final, tick_gravity, board_rdata, board_rx, board_ry, board_we, board_wx, board_wy, board_wdata, score, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_V, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

endmodule
