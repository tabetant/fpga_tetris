`timescale 1ns/1ps

module tb_gamelogic_m2;

  // ===== Top-level declarations (Verilog-2001: no in-block decls) =====
  // Clock/reset
  reg CLOCK_50 = 1'b0;
  reg resetn   = 1'b0;

  // Control pulses (already debounced at DUT level)
  reg left_final  = 1'b0;
  reg right_final = 1'b0;
  reg rot_final   = 1'b0;

  // Gravity tick
  reg tick_gravity = 1'b0;

  // Board interface (unused for M2: tie reads low)
  wire        board_rdata;
  wire [3:0]  board_rx;
  wire [4:0]  board_ry;
  wire        board_we;
  wire [3:0]  board_wx;
  wire [4:0]  board_wy;
  wire        board_wdata;

  assign board_rdata = 1'b0;

  // DUT observable outputs
  wire [9:0] LEDR;
  wire [4:0] score;
  wire [3:0] cur_x;
  wire [4:0] cur_y;
  wire       move_accept;

  // Utilities
  integer k;        // loop counter
  integer max_ticks;

  // 50 MHz clock
  always #10 CLOCK_50 = ~CLOCK_50;

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

  // ===== Simple helper “tasks” done as inline procedures to avoid decl issues =====
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

  task pulse_rot;
    begin
      rot_final = 1'b1;
      @(posedge CLOCK_50);
      rot_final = 1'b0;
      repeat (3) @(posedge CLOCK_50);
    end
  endtask

  task one_gravity_tick;
    begin
      tick_gravity = 1'b1;
      @(posedge CLOCK_50);
      tick_gravity = 1'b0;
      repeat (2) @(posedge CLOCK_50);
    end
  endtask

  // ===== Monitoring =====
  initial begin
    $display(" time     | state rot | move | (x,y) | score");
    $monitor("%8t |  %0d    %0d  |  %0b   | (%0d,%0d) | %0d",
             $time, LEDR[7:5], {LEDR[4],LEDR[3]}, move_accept, cur_x, cur_y, score);
  end

  // ===== Scenario =====
  initial begin
    // Reset
    resetn = 1'b0;
    repeat (10) @(posedge CLOCK_50);
    resetn = 1'b1;
    repeat (10) @(posedge CLOCK_50);

    // 1) Rotate once (should update rot bits)
    pulse_rot;

    // 2) Move left 3x
    pulse_left; pulse_left; pulse_left;

    // 3) Move right 2x
    pulse_right; pulse_right;

    // 4) Gravity 5 ticks
    for (k = 0; k < 5; k = k + 1) begin
      one_gravity_tick();
    end

    // 5) Drop to floor: tick until S_LOCK (state==3) or timeout
    max_ticks = 60;
    while ((LEDR[7:5] != 3) && (max_ticks > 0)) begin
      one_gravity_tick();
      max_ticks = max_ticks - 1;
    end

    // settle a bit
    repeat (10) @(posedge CLOCK_50);

    $display("=== TEST DONE ===");
    repeat (20) @(posedge CLOCK_50);
    $finish;
  end

endmodule
