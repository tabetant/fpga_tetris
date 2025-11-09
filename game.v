// top-level wiring for inputs
// Purpose: convert physical button presses into clean, one-shot, frame-rate-limited pulses for the game FSM
// one-shot = the signal goes high for exactly one rising edge of clock, then goes low on the next
// per control: KEY -> invert -> synchronizer -> debouncer (5 ms) -> edge detector (rising edge, 1 clk)
// -> pending_event (re-timed to tick_input; max 1 action per frame)
// outputs from the top will be used by FSM: left_final, right_final, rot_final
module game(SW, KEY, CLOCK_50);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;

    // sync active low reset
    wire resetn;
    assign resetn = ~KEY[3];

    // frame rate for inputs (100 Hz)
    wire tick_input;
    tick_i in(CLOCK_50, resetn, tick_input); // from ticks.v file
    
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
endmodule
