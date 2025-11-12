`timescale 1ns/1ps

module tb_input_pipeline;
  // 50 MHz board clock
  reg CLOCK_50 = 0;
  always #10 CLOCK_50 = ~CLOCK_50; // 20 ns period = 50 MHz

  // reset (active-low)
  reg resetn = 0;

  // raw, asynchronous button (simulated) — this will "bounce"
  reg btn_raw = 0;

  // input pacing tick (your tick_i output). Here we just make a slow periodic tick.
  reg tick_input = 0;

  // Wires through the chain
  wire btn_sync;
  wire btn_level;     // debounced level
  wire btn_edge;      // 1-clock edge
  wire btn_final;     // 1-tick-aligned pulse from pending_event

  // DUTs (use your modules’ exact names/ports)
  synchronizer u_sync( .clock(CLOCK_50), .D(btn_raw), .resetn(resetn), .key_sync(btn_sync) );

  debouncer   u_deb ( .clock(CLOCK_50), .resetn(resetn), .in_sync(btn_sync), .out_level(btn_level) );

  edgedetect  u_edge( .clock(CLOCK_50), .resetn(resetn), .key_clean(btn_level), .key_pulse(btn_edge) );

  pending_event u_pend(
    .edge_1clk(btn_edge),
    .tick_input(tick_input),
    .resetn(resetn),
    .clock(CLOCK_50),
    .button(btn_final)
  );

  // Slow input tick: 1 pulse every ~2 us here (adjust as you like)
  initial begin
    forever begin
      tick_input = 0;
      repeat (99) @(posedge CLOCK_50); // idle ~100 cycles
      tick_input = 1; @(posedge CLOCK_50);
      tick_input = 0;
    end
  end

  // Simple monitor
  initial begin
    $display("time   raw  sync  lvl  edge  final  tick");
    $monitor("%t  %0d    %0d    %0d    %0d     %0d      %0d",
             $time, btn_raw, btn_sync, btn_level, btn_edge, btn_final, tick_input);
  end

  // Bounce generator: a single "press" that toggles quickly
  task press_with_bounce;
    begin
      // simulate a few rapid toggles within a few clock cycles
      btn_raw = 1; repeat (2) @(posedge CLOCK_50);
      btn_raw = 0; repeat (1) @(posedge CLOCK_50);
      btn_raw = 1; repeat (3) @(posedge CLOCK_50);
      btn_raw = 0; repeat (1) @(posedge CLOCK_50);
      btn_raw = 1; repeat (50) @(posedge CLOCK_50); // settle high for a while
      btn_raw = 0; repeat (50) @(posedge CLOCK_50); // release
    end
  endtask

  initial begin
    // reset
    resetn = 0;
    repeat (5) @(posedge CLOCK_50);
    resetn = 1;

    // Wait a bit, then do a single bouncy press
    repeat (50) @(posedge CLOCK_50);
    press_with_bounce();

    // Another press later
    repeat (300) @(posedge CLOCK_50);
    press_with_bounce();

    // Finish
    repeat (2000) @(posedge CLOCK_50);
    $finish;
  end

endmodule
Get Outlook for Mac