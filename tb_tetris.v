`timescale 1ns/1ps
module tb_tetris;
  reg        CLOCK_50 = 0;
  reg  [3:0] KEY      = 4'b1111;  // idle high like the board
  reg  [9:0] SW       = 10'b0;
  wire [9:0] LEDR;

  // DUT
  tetris DUT(.SW(SW), .KEY(KEY), .CLOCK_50(CLOCK_50), .LEDR(LEDR));

  // 50 MHz
  always #10 CLOCK_50 = ~CLOCK_50;

  initial begin
  // proper reset
  KEY = 4'b1111;                 // idle high (board-like)
  repeat (2)  @(posedge CLOCK_50);
  KEY[3] = 1'b0;                 // assert reset (resetn = KEY[3])
  repeat (8)  @(posedge CLOCK_50);
  KEY[3] = 1'b1;                 // release reset
  repeat (50) @(posedge CLOCK_50);

  // HOLD LEFT long enough to pass debounce (~5 ms = 250k clocks @ 50 MHz)
  KEY[1] = 1'b0;                 // press LEFT (active-low)
  repeat (300000) @(posedge CLOCK_50); // ~6 ms
  KEY[1] = 1'b1;                 // release
  repeat (300000) @(posedge CLOCK_50); // let it settle

  // leave sim running (your .do uses -onfinish stop)
end

endmodule
