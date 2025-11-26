`default_nettype none

// Module: randomiser
// Purpose: Generates a pseudo-random 3-bit number (0-6) to select Tetris shapes.
// Mechanism: Uses a 16-bit Linear Feedback Shift Register (LFSR) tapped at specific bits.
//            The output is derived from slicing the seed to ensure even distribution.

module randomiser #(
    parameter INITIAL_SEED = 16'hABCD  // Non-zero seed to ensure LFSR starts correctly
)(
    input  wire       reset,  
    input  wire       clock,
    output wire [2:0] shape_id 
);
    reg  [15:0] seed;
    wire        next_bit;

    // LFSR Feedback Polynomial: Taps at 15, 13, 12, 10
    // XORing these creates the next bit for the shift register.
    assign next_bit = seed[15] ^ seed[13] ^ seed[12] ^ seed[10];

    // Slice the 16-bit seed into 3-bit chunks to get a number between 0-7.
    wire [2:0] s0 = seed[2:0];
    wire [2:0] s1 = seed[5:3];
    wire [2:0] s2 = seed[8:6];
    wire [2:0] s3 = seed[11:9];
    wire [2:0] s4 = seed[14:12];

    // Priority Encoder to select a valid shape ID (0-6).
    // If a slice is 7 (3'b111), we skip it because valid shapes are only 0-6.
    assign shape_id =
        (s0 != 3'd7) ? s0 :
        (s1 != 3'd7) ? s1 :
        (s2 != 3'd7) ? s2 :
        (s3 != 3'd7) ? s3 :
        (s4 != 3'd7) ? s4 :
                       3'd0; // Default fallback if all slices happen to be 7 (rare)

    always @(posedge clock) begin
        if (reset) begin
            // Initialize with a non-zero value on reset
            seed <= (INITIAL_SEED != 16'd0) ? INITIAL_SEED : 16'h0001;
        end else begin
            // Shift left and insert the new XOR'd bit at the LSB
            seed <= {seed[14:0], next_bit};
        end
    end

endmodule
