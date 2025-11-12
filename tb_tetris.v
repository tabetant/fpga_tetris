`timescale 1ns/1ps
module tb_tetris;
  reg        CLOCK_50 = 0;
  reg  [3:0] KEY      = 4'b1111;   // idle high (like board)
  reg  [9:0] SW       = 10'b0;
  wire [9:0] LEDR;

  // DUT
  tetris DUT(.SW(SW), .KEY(KEY), .CLOCK_50(CLOCK_50), .LEDR(LEDR));

  // 50 MHz clock
  always #10 CLOCK_50 = ~CLOCK_50;  // 20 ns period

  initial begin
    // run for a little
    repeat (50) @(posedge CLOCK_50);

    // press LEFT (KEY[1] active-low) for ~10 clocks, then release
    KEY[1] = 1'b0;  repeat (10) @(posedge CLOCK_50);
    KEY[1] = 1'b1;  repeat (2000) @(posedge CLOCK_50);

    $finish;
  end
endmodule
