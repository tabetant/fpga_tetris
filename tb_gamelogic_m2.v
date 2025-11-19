`timescale 1ns/1ps
// Simple, deterministic TB for Milestone 2 (no board memory)

module tb_gamelogic_m2;

  // 50 MHz clock
  reg CLOCK_50 = 1'b0;
  always #10 CLOCK_50 = ~CLOCK_50;  // 20 ns period

  // Active-low reset
  reg resetn;

  // Debounced one-shot inputs (what GAME expects)
  reg left_final;
  reg right_final;
  reg rot_final;

  // Gravity tick
  reg tick_gravity;

  // Stub out board read (no board for M2)
  // GAME will drive board_rx/board_ry; we must return a value.
  wire        board_rdata;
  wire [3:0]  board_rx;
  wire [4:0]  board_ry;

  // Tie board_rdata LOW so no collisions are seen from board
  assign board_rdata = 1'b0;

  // Unused write port from GAME (OK to leave unconnected in TB)
  wire        board_we;
  wire [3:0]  board_wx;
  wire [4:0]  board_wy;
  wire        board_wdata;

  // Outputs to observe
  wire [9:0] LEDR;
  wire [4:0] score;
  wire [3:0] cur_x;
  wire [4:0] cur_y;
  wire       move_accept;

  // DUT
  gamelogic DUT(
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

  // Helper: generate a 1-clock pulse on a given reg
  task pulse(input integer cycles, output reg sig);
    integer i;
    begin
      sig = 1'b1;
      for (i = 0; i < cycles; i = i + 1) @(posedge CLOCK_50);
      sig = 1'b0;
    end
  endtask

  // Gravity tick at a slow interval (purely for sim)
  // We'll just pulse it explicitly in the stimulus instead of a free-running gen.

  // Stimulus
  initial begin
    // Default all inputs to 0 to avoid Z/X propagation
    resetn       = 1'b0;
    left_final   = 1'b0;
    right_final  = 1'b0;
    rot_final    = 1'b0;
    tick_gravity = 1'b0;

    // Hold reset low for a few cycles, then release
    repeat (10) @(posedge CLOCK_50);
    resetn = 1'b1;

    // Wait one frame worth of cycles to let FSM go to SPAWN->FALL
    repeat (20) @(posedge CLOCK_50);

    // Rotate once (1-cycle pulse)
    pulse(1, rot_final);
    repeat (10) @(posedge CLOCK_50);

    // Move right twice
    pulse(1, right_final);
    repeat (5) @(posedge CLOCK_50);
    pulse(1, right_final);
    repeat (10) @(posedge CLOCK_50);

    // Gravity: drop the piece a few steps
    pulse(1, tick_gravity);
    repeat (10) @(posedge CLOCK_50);
    pulse(1, tick_gravity);
    repeat (10) @(posedge CLOCK_50);
    pulse(1, tick_gravity);

    // Move left once
    repeat (10) @(posedge CLOCK_50);
    pulse(1, left_final);

    // More gravity
    repeat (10) @(posedge CLOCK_50);
    pulse(1, tick_gravity);

    // Run a bit longer
    repeat (1000) @(posedge CLOCK_50);

    $finish;
  end

endmodule
