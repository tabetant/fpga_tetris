`timescale 1ns/1ps

module tb_gamelogic_m2;

  // ===== Declarations (must come before procedural statements) =====
  // 50 MHz clock (20 ns period)
  reg CLOCK_50 = 0;

  // Active-high reset inside gamelogic is 'resetn' (sync to posedge)
  reg resetn = 0;

  // Control inputs (already debounced/one-shot at the GAME level)
  reg left_final  = 0;
  reg right_final = 0;
  reg rot_final   = 0;

  // Gravity tick (single-cycle pulse)
  reg tick_gravity = 0;

  // Board interface (unused for M2; tie rdata low)
  wire        board_rdata;
  wire [3:0]  board_rx;
  wire [4:0]  board_ry;
  wire        board_we;
  wire [3:0]  board_wx;
  wire [4:0]  board_wy;
  wire        board_wdata;

  assign board_rdata = 1'b0; // no blocks on board in M2 test

  // Outputs to watch
  wire [9:0] LEDR;
  wire [4:0] score;
  wire [3:0] cur_x;
  wire [4:0] cur_y;
  wire       move_accept;

  // Utility for “drop to floor” loop
  integer max_ticks;

  // ===== Clock =====
  always #10 CLOCK_50 = ~CLOCK_50;  // 50 MHz

  // ===== DUT =====
  gamelogic DUT (
    .LEDR(LEDR),
    .CLOCK_50(CLOCK_50),
    .resetn(resetn),
    .left_final(left_final),
    .right_final(right_final),
    .rot_final(rot_final),
    .tick_gravity(tick_gravity),
    .board_rdata(board_rdata),
    .board_rx(board_rx),
    .board_ry(board_ry),
    .board_we(board_we),
    .board_wx(board_wx),
    .board_wy(board_wy),
    .board_wdata(board_wdata),
    .score(score),
    .cur_x(cur_x),
    .cur_y(cur_y),
    .move_accept(move_accept)
  );

  // -------- Helper tasks --------
  task pulse_left;
  begin
    left_final = 1'b1;
    @(posedge CLOCK_50);
    left_final = 1'b0;
    repeat (3) @(posedge CLOCK_50);
  end
  endtask

  task pulse_right;
  begin
    right_final = 1'b1;
    @(posedge CLOCK_50);
    right_final = 1'b0;
    repeat (3) @(posedge CLOCK_50);
  end
  endtask

  task pulse_rot;  // clockwise rotate
  begin
    rot_final = 1'b1;
    @(posedge CLOCK_50);
    rot_final = 1'b0;
    repeat (3) @(posedge CLOCK_50);
  end
  endtask

  task tick_g;     // one gravity tick
  begin
    tick_gravity = 1'b1;
    @(posedge CLOCK_50);
    tick_gravity = 1'b0;
    repeat (2) @(posedge CLOCK_50);
  end
  endtask

  // Pretty state/rot decode from LEDR for ModelSim transcript
  function [79:0] state_name;
    input [2:0] s;
    begin
      case (s)
        3'd0: state_name = "S_IDLE ";
        3'd1: state_name = "S_SPAWN";
        3'd2: state_name = "S_FALL ";
        3'd3: state_name = "S_LOCK ";
        3'd4: state_name = "S_CLEAR";
        default: state_name = "UNKNOWN";
      endcase
    end
  endfunction

  // Live monitor (fires on any change)
  initial begin
    $display(" time    | state   rot  | move_accept | cur(x,y) | notes");
    forever begin
      @(LEDR or cur_x or cur_y or move_accept);
      $display("%8t | %s  %0d    |     %0b       |  (%0d,%0d) |",
               $time,
               state_name(LEDR[7:5]),
               {LEDR[4],LEDR[3]}, // rot bits as 2-bit value
               move_accept, cur_x, cur_y);
    end
  end

  // Scenario
  initial begin
    // Optional VCD (ModelSim can write VCD; if you prefer WLF, comment these)
    $dumpfile("gamelogic_m2.vcd");
    $dumpvars(0, tb_gamelogic_m2);

    // Reset sequence
    resetn = 0;
    repeat (10) @(posedge CLOCK_50);
    resetn = 1;
    repeat (10) @(posedge CLOCK_50);

    // 1) Rotate once (should advance rot 00->01)
    $display("=== Rotate once ===");
    pulse_rot;

    // 2) Move left 3 times
    $display("=== Move left 3x ===");
    pulse_left;
    pulse_left;
    pulse_left;

    // 3) Move right 2 times
    $display("=== Move right 2x ===");
    pulse_right;
    pulse_right;

    // 4) Apply a few gravity ticks
    $display("=== Gravity 5 ticks ===");
    repeat (5) tick_g;

    // 5) “Drop to floor”: tick until S_LOCK then let it settle
    $display("=== Drop to floor (wait for S_LOCK->S_SPAWN) ===");
    max_ticks = 40;
    while ( (LEDR[7:5] != 3'd3) && max_ticks > 0 ) begin // wait until S_LOCK
      tick_g;
      max_ticks = max_ticks - 1;
    end
    // a few extra cycles to see transition
    repeat (6) @(posedge CLOCK_50);

    // 6) Quick sanity after respawn
    $display("=== Post-respawn sanity ===");
    repeat (5) @(posedge CLOCK_50);

    $display("=== TEST DONE ===");
    repeat (30) @(posedge CLOCK_50);
    $finish;
  end

endmodule
