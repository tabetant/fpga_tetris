`timescale 1ns/1ps
`default_nettype none  // catch missing declarations in TB

module gamelogic_tb;

    // =====================
    // DUT ports (inputs)
    // =====================
    reg CLOCK_50   = 1'b0;
    reg resetn     = 1'b0;

    reg left_final  = 1'b0;
    reg right_final = 1'b0;
    reg rot_final   = 1'b0;

    reg tick_gravity = 1'b0;

    reg board_rdata = 1'b0; // treat board as empty for now

    // =====================
    // DUT ports (outputs)
    // =====================
    wire [9:0] LEDR;

    wire [3:0] board_rx;
    wire [4:0] board_ry;

    wire [4:0] score;

    wire       board_we;
    wire [3:0] board_wx;
    wire [4:0] board_wy;
    wire       board_wdata;

    wire       move_accept;
    wire [3:0] cur_x;
    wire [4:0] cur_y;

    // =====================
    // DUT instance
    // =====================
    gamelogic dut (
        .LEDR        (LEDR),
        .CLOCK_50    (CLOCK_50),
        .resetn      (resetn),

        .left_final  (left_final),
        .right_final (right_final),
        .rot_final   (rot_final),

        .tick_gravity(tick_gravity),

        .board_rdata (board_rdata),
        .board_rx    (board_rx),
        .board_ry    (board_ry),

        .score       (score),

        .board_we    (board_we),
        .board_wx    (board_wx),
        .board_wy    (board_wy),
        .board_wdata (board_wdata),

        .move_accept (move_accept),
        .cur_x       (cur_x),
        .cur_y       (cur_y)
    );

    // =====================
    // 50 MHz clock
    // =====================
    always #10 CLOCK_50 = ~CLOCK_50;  // 20 ns period

    // =====================
    // Reset & stimulus
    // =====================
    initial begin
        // At time 0 everything is already 0 (see reg initializations above)

        // Hold reset low for 10 clock edges
        repeat (10) @(posedge CLOCK_50);
        resetn <= 1'b1;   // release reset

        // Wait a bit after reset
        repeat (1000) @(posedge CLOCK_50);  // 1000 cycles ~ 20 us

        // --- Simple manual moves: 1-cycle pulses ---
        // Left pulse
        left_final <= 1'b1;
        @(posedge CLOCK_50);
        left_final <= 1'b0;

        // wait some cycles
        repeat (5000) @(posedge CLOCK_50);  // 5000 cycles ~ 100 us

        // Right pulse
        right_final <= 1'b1;
        @(posedge CLOCK_50);
        right_final <= 1'b0;

        repeat (5000) @(posedge CLOCK_50);

        // Rotate pulse
        rot_final <= 1'b1;
        @(posedge CLOCK_50);
        rot_final <= 1'b0;

        // --- Gravity pulses ---
        // One gravity tick every 20 ms (1e6 clock cycles at 50 MHz)
        // Over 2 s we’ll get ~100 ticks.
        repeat (100) begin
            // wait 20 ms
            repeat (1_000_000) @(posedge CLOCK_50);
            // 1-clock gravity pulse
            tick_gravity <= 1'b1;
            @(posedge CLOCK_50);
            tick_gravity <= 1'b0;
        end

        // After this, ModelSim .do file will end the sim (run 2 s)
    end

endmodule

`default_nettype wire
