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
    // proper reset pulse (your RTL uses: resetn = KEY[3]; active when KEY[3]=0)
    repeat (2) @(posedge CLOCK_50);
    KEY[3] = 1'b0;              // assert reset
    repeat (8) @(posedge CLOCK_50);
    KEY[3] = 1'b1;              // deassert reset

    // wait a bit, then tap LEFT (KEY[1] active-low)
    repeat (50) @(posedge CLOCK_50);
    KEY[1] = 1'b0;              // press
    repeat (10) @(posedge CLOCK_50);
    KEY[1] = 1'b1;              // release

    // let it run so you see tick-input alignment
    repeat (10000) @(posedge CLOCK_50);
    // no $finish / $stop needed; .do uses -onfinish stop
  end
endmodule
