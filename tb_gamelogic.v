`timescale 1ns/1ps

// Unit testbench for gamelogic only.
// Drives *_final pulses and tick_gravity directly.
// Asserts basic behavior: SPAWN -> FALL, left/right/rot/gravity updates.

module tb_gamelogic;

  // 50 MHz clock
  reg CLOCK_50 = 1'b0;
  always #10 CLOCK_50 = ~CLOCK_50;  // 20 ns period

  // Inputs to DUT
  reg  resetn = 1'b0;
  reg  left_final  = 1'b0;
  reg  right_final = 1'b0;
  reg  rot_final   = 1'b0;
  reg  tick_gravity = 1'b0;

  // DUT outputs
  wire [9:0] LEDR;   // just for sanity; you don’t need to inspect it

  // DUT
  gamelogic DUT (
    .LEDR(LEDR),
    .CLOCK_50(CLOCK_50),
    .resetn(resetn),
    .left_final(left_final),
    .right_final(right_final),
    .rot_final(rot_final),
    .tick_gravity(tick_gravity)
  );

  // --- Helper tasks ---------------------------------------------------------
  task press_left; begin
    @(posedge CLOCK_50);
    left_final <= 1'b1;
    @(posedge CLOCK_50);
    left_final <= 1'b0;
  end endtask

  task press_right; begin
    @(posedge CLOCK_50);
    right_final <= 1'b1;
    @(posedge CLOCK_50);
    right_final <= 1'b0;
  end endtask

  task press_rot; begin
    @(posedge CLOCK_50);
    rot_final <= 1'b1;
    @(posedge CLOCK_50);
    rot_final <= 1'b0;
  end endtask

  task grav_tick; begin
    @(posedge CLOCK_50);
    tick_gravity <= 1'b1;
    @(posedge CLOCK_50);
    tick_gravity <= 1'b0;
  end endtask

  task wait_clocks(input integer n); integer i; begin
    for (i = 0; i < n; i = i + 1) @(posedge CLOCK_50);
  end endtask
  // --------------------------------------------------------------------------

  // Numeric mirrors of the DUT’s localparams (by value) for readable checks.
  // Your gamelogic has: S_IDLE=0, S_SPAWN=1, S_FALL=2
  localparam S_IDLE  = 3'd0;
  localparam S_SPAWN = 3'd1;
  localparam S_FALL  = 3'd2;

  initial begin
    // RESET pulse
    resetn = 1'b0;
    wait_clocks(8);
    resetn = 1'b1;      // release reset

    // Allow a couple cycles for S_IDLE -> S_SPAWN -> S_FALL
    wait_clocks(4);

    // === Basic state check ===
    if (DUT.state !== S_FALL) begin
      $display("[%0t] ERROR: expected state=S_FALL (2), got %0d", $time, DUT.state);
      $fatal;
    end else
      $display("[%0t] OK: state=S_FALL", $time);

    // === Spawn position check ===
    // Your RTL sets spawn_x=4, spawn_y=0 on reset, then loads into piece_x/y in S_SPAWN
    if (DUT.piece_x !== 4'd4 || DUT.piece_y !== 5'd0) begin
      $display("[%0t] ERROR: expected (x,y)=(4,0), got (%0d,%0d)", $time, DUT.piece_x, DUT.piece_y);
      $fatal;
    end else
      $display("[%0t] OK: spawn at (4,0)", $time);

    // === LEFT press: expect x = 3 ===
    press_left();
    wait_clocks(1);   // let the registered update happen
    if (DUT.piece_x !== 4'd3) begin
      $display("[%0t] ERROR: after LEFT, expected x=3, got %0d", $time, DUT.piece_x);
      $fatal;
    end else
      $display("[%0t] OK: LEFT -> x=3", $time);

    // === RIGHT press twice: expect x = 5 ===
    press_right();
    wait_clocks(1);
    press_right();
    wait_clocks(1);
    if (DUT.piece_x !== 4'd5) begin
      $display("[%0t] ERROR: after RIGHTx2, expected x=5, got %0d", $time, DUT.piece_x);
      $fatal;
    end else
      $display("[%0t] OK: RIGHTx2 -> x=5", $time);

    // === ROTATE once: expect rot = 1 ===
    press_rot();
    wait_clocks(1);
    if (DUT.rot !== 2'd1) begin
      $display("[%0t] ERROR: after ROT, expected rot=1, got %0d", $time, DUT.rot);
      $fatal;
    end else
      $display("[%0t] OK: ROT -> rot=1", $time);

    // === Gravity 3 ticks: expect y = 3 ===
    grav_tick(); wait_clocks(1);
    grav_tick(); wait_clocks(1);
    grav_tick(); wait_clocks(1);
    if (DUT.piece_y !== 5'd3) begin
      $display("[%0t] ERROR: after 3 gravity ticks, expected y=3, got %0d", $time, DUT.piece_y);
      $fatal;
    end else
      $display("[%0t] OK: gravity x3 -> y=3", $time);

    // === Wall test: push to right edge and one more ===
    // Move until x=9
    while (DUT.piece_x < 4'd9) begin
      press_right();
      wait_clocks(1);
    end
    // One extra RIGHT should not move (collide=1 blocks move_accept)
    press_right();
    wait_clocks(1);
    if (DUT.piece_x !== 4'd9) begin
      $display("[%0t] ERROR: at wall, x changed unexpectedly to %0d", $time, DUT.piece_x);
      $fatal;
    end else
      $display("[%0t] OK: wall collision blocks movement at x=9", $time);

    $display("[%0t] ALL CHECKS PASSED.", $time);
    // Leave sim open (the .do uses -onfinish stop)
  end

endmodule
