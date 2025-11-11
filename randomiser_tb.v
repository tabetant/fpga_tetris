`timescale 1ns/1ps
`default_nettype none

module tb_randomiser;

    // DUT inputs
    reg        clock;
    reg        reset;

    // DUT output
    wire [2:0] shape_id;

    // Instantiate DUT
    randomiser #(
        .INITIAL_SEED(16'hABCD)
    ) dut (
        .reset   (reset),
        .clock   (clock),
        .shape_id(shape_id)
    );

    // Clock gen: 50 MHz equivalent (20 ns period)
    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;
    end

    // Stimulus
    initial begin
        // Start in reset
        reset = 1'b1;
        #50;             // hold reset for a bit
        reset = 1'b0;

        // Let it run for a while
        // 200 cycles is plenty to eyeball behavior
        repeat (200) @(posedge clock);

        $display("Test completed without fatal errors.");
        $finish;
    end

    // Monitor + check: ensure shape_id is never 7
    always @(posedge clock) begin
        if (!reset) begin
            // Peek at internal seed via hierarchy for debugging (optional)
            // Remove this line if your simulator complains.
            $display("t=%0t ns  seed=%h  shape_id=%0d",
                     $time, dut.seed, shape_id);

            if (shape_id == 3'd7) begin
                $display("**ERROR** shape_id == 7 at t=%0t ns", $time);
                $stop;
            end
        end
    end

endmodule
