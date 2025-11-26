`default_nettype none

module randomiser #(
    parameter INITIAL_SEED = 16'hABCD 
)(
    input  wire       reset,  
    input  wire       clock,
    output wire [2:0] shape_id 
);
    reg  [15:0] seed;
    wire        next_bit;

    assign next_bit = seed[15] ^ seed[13] ^ seed[12] ^ seed[10];

    // FIX: Defined the slices that were missing in the original code
    wire [2:0] s0 = seed[2:0];
    wire [2:0] s1 = seed[5:3];
    wire [2:0] s2 = seed[8:6];
    wire [2:0] s3 = seed[11:9];
    wire [2:0] s4 = seed[14:12];

    // Select the first slice that isn't 7 (since valid shapes are 0-6)
    assign shape_id =
        (s0 != 3'd7) ? s0 :
        (s1 != 3'd7) ? s1 :
        (s2 != 3'd7) ? s2 :
        (s3 != 3'd7) ? s3 :
        (s4 != 3'd7) ? s4 :
                       3'd0;

    always @(posedge clock) begin
        if (reset) begin
            seed <= (INITIAL_SEED != 16'd0) ? INITIAL_SEED : 16'h0001;
        end else begin
            seed <= {seed[14:0], next_bit};
        end
    end

endmodule
