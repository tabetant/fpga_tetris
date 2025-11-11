`timescale 1ns/1ps
`default_nettype none

module tb_vga_demo_160x120;

    // Inputs to DUT
    reg        CLOCK_50;
    reg [3:0]  KEY;

    // Outputs from DUT
    wire [9:0] LEDR;
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire       VGA_HS;
    wire       VGA_VS;
    wire       VGA_BLANK_N;
    wire       VGA_SYNC_N;
    wire       VGA_CLK;

    // Instantiate DUT
    vga_demo dut (
        .CLOCK_50   (CLOCK_50),
        .KEY        (KEY),
        .LEDR       (LEDR),
        .VGA_R      (VGA_R),
        .VGA_G      (VGA_G),
        .VGA_B      (VGA_B),
        .VGA_HS     (VGA_HS),
        .VGA_VS     (VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N (VGA_SYNC_N),
        .VGA_CLK    (VGA_CLK)
    );

    // 50 MHz clock (20 ns period)
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        // Initial KEY: KEY[0] is resetn for VGA, others unused here
        KEY = 4'b0000;      // hold reset low
        #200;               // 200 ns in reset

        KEY[0] = 1'b1;      // release reset
        #100000;            // run for 100 us

        $display("TB finished.");
        $finish;
    end

    // Simple monitor: show some sync + clock activity
    integer hs_count = 0;
    integer vs_count = 0;

    always @(posedge VGA_HS)
        hs_count = hs_count + 1;

    always @(posedge VGA_VS)
        vs_count = vs_count + 1;

    // Periodically report status
    always @(posedge CLOCK_50) begin
        if (KEY[0]) begin
            if ($time % 20000 == 0) begin
                $display("t=%0t ns : VGA_CLK=%b HS=%b VS=%b BLANK=%b HS_cnt=%0d VS_cnt=%0d",
                         $time, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, hs_count, vs_count);
            end
        end
    end

endmodule
