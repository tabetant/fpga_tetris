`timescale 1ns/1ps

module gamelogic_tb;

    // =============== DUT ports ===============

    // Inputs
    reg CLOCK_50;
    reg resetn;
    reg left_final, right_final, rot_final;
    reg tick_gravity;
    reg board_rdata;

    // Outputs
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

    // =============== DUT instance ===============
    // Ports taken *directly* from your real gamelogic.v
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

    // =============== 50 MHz clock ===============
    // Period = 20 ns
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // =============== “Always empty” board ===============
    // For M2 you can treat the board as empty (no collisions from board_rdata).
    initial begin
        board_rdata = 1'b0;
    end

    // =============== Reset + stimulus ===============
    initial begin
        // Start in reset with all inputs low
        resetn      = 1'b0;
        left_final  = 1'b0;
        right_final = 1'b0;
        rot_final   = 1'b0;
        tick_gravity= 1'b0;

        // Hold reset for a few cycles so all regs get initialized
        #200;              // 200 ns → at least 10 clock edges
        resetn = 1'b1;     // release reset

        // Give the FSM a bit of time before we poke it
        #100_000;          // 100 µs

        // A few manual moves (1-clock pulses)

        // Move left
        left_final = 1'b1; #20; left_final = 1'b0;
        #200_000; // 200 µs gap

        // Move right
        right_final = 1'b1; #20; right_final = 1'b0;
        #200_000;

        // Rotate
        rot_final = 1'b1; #20; rot_final = 1'b0;

        // Now just let gravity do the work.
        // One tick every 20 ms => plenty of motion over 2 seconds.
        repeat (100) begin
            #20_000_000;         // 20 ms
            tick_gravity = 1'b1; // 1-clock pulse
            #20;
            tick_gravity = 1'b0;
        end

        // After this, the .do file controls total runtime.
    end

endmodule
