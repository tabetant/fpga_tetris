`timescale 1ns/1ps

module tb_gamelogic;

  // Clock/reset
  reg CLOCK_50 = 0;
  always #10 CLOCK_50 = ~CLOCK_50; // 50 MHz

  reg resetn = 0;

  // Final pulses (already debounced/edge-aligned in your design)
  reg left_final  = 0;
  reg right_final = 0;
  reg rot_final   = 0;

  // Gravity tick
  reg tick_gravity = 0;

  // Unused board read/write (stub for now)
  wire board_rdata = 1'b0;
  wire [3:0] board_rx;
  wire [4:0] board_ry;
  wire       board_we;
  wire [3:0] board_wx;
  wire [4:0] board_wy;
  wire       board_wdata;

  // If your gamelogic has LED/HEX outputs, just wire to dummies:
  wire [9:0] LEDR;
  wire [5:0] HEX;

  // DUT
  gamelogic dut (
    .LEDR(LEDR),
    .HEX(HEX),
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
    .board_wdata(board_wdata)
  );

  // === Helper tasks ===
  task pulse(input reg ref signal);
    begin
      signal = 1;
      @(posedge CLOCK_50);
      signal = 0;
    end
  endtask

  task press_left;  begin pulse(left_final);  end endtask
  task press_right; begin pulse(right_final); end endtask
  task press_rot;   begin pulse(rot_final);   end endtask

  task grav_tick;
    begin
      tick_gravity = 1;
      @(posedge CLOCK_50);
      tick_gravity = 0;
    end
  endtask

  // For convenience, watch internals via hierarchy
  // (These paths assume your internal reg names are state/piece_x/piece_y/rot)
  initial begin
    $display(" time   st   x  y  rot   lf rf rt  grav  move_accept collide");
    forever begin
      @(posedge CLOCK_50);
      $display("%5t   %0d   %0d %0d  %0d     %0d  %0d  %0d    %0d        %0d         %0d",
        $time,
        dut.state,
        dut.piece_x,
        dut.piece_y,
        dut.rot,
        left_final, right_final, rot_final,
        tick_gravity,
        dut.move_accept,
        dut.collide
      );
    end
  end

  initial begin
    // Reset
    resetn = 0;
    repeat (5) @(posedge CLOCK_50);
    resetn = 1;

    // Wait for SPAWN -> FALL
    repeat (10) @(posedge CLOCK_50);

    // === Sanity moves ===
    // Rotate a couple of times (always legal in placeholder)
    press_rot();  repeat (5) @(posedge CLOCK_50);
    press_rot();  repeat (5) @(posedge CLOCK_50);

    // Move left 3 times (assuming spawn_x = 4)
    press_left(); repeat (5) @(posedge CLOCK_50);
    press_left(); repeat (5) @(posedge CLOCK_50);
    press_left(); repeat (5) @(posedge CLOCK_50);

    // Bang left at wall: expect collide=1, move_accept=0 when x==0
    press_left(); repeat (5) @(posedge CLOCK_50);

    // Gravity a few times until near bottom
    repeat (15) begin grav_tick(); repeat (3) @(posedge CLOCK_50); end

    // Bang gravity at bottom: expect collide=1, move_accept=0 when y==19
    repeat (5) begin grav_tick(); repeat (3) @(posedge CLOCK_50); end

    // Move right a few times (should still accept if within bounds)
    press_right(); repeat (5) @(posedge CLOCK_50);
    press_right(); repeat (5) @(posedge CLOCK_50);

    // Done
    repeat (100) @(posedge CLOCK_50);
    $finish;
  end

endmodule
Get Outlook for Mac