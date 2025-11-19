`default_nettype none

// Minimal but reliable PS/2 device receiver
// - Synchronizes PS2_CLK, PS2_DAT
// - Detects falling edges safely
// - Open-collector I/O is released (high-Z)
// - Samples one bit per falling edge

module PS2_Controller (
    input  wire       CLOCK_50,
    input  wire       reset,            // active-high reset
    inout  wire       PS2_CLK,
    inout  wire       PS2_DAT,
    output reg  [7:0] received_data,
    output reg        received_data_en
);

    // ==============================================================
    // Release PS/2 lines (keyboard drives them)
    // ==============================================================
    assign PS2_CLK = 1'bz;
    assign PS2_DAT = 1'bz;

    // ==============================================================
    // Synchronizers (prevent metastability)
    // ==============================================================
    reg ps2_clk_sync0, ps2_clk_sync1;
    reg ps2_dat_sync0, ps2_dat_sync1;

    always @(posedge CLOCK_50) begin
        ps2_clk_sync0 <= PS2_CLK;
        ps2_clk_sync1 <= ps2_clk_sync0;

        ps2_dat_sync0 <= PS2_DAT;
        ps2_dat_sync1 <= ps2_dat_sync0;
    end

    wire ps2_clk   = ps2_clk_sync1;
    wire ps2_dat   = ps2_dat_sync1;

    // ==============================================================
    // Falling-edge detector
    // ==============================================================
    reg ps2_clk_prev;
    always @(posedge CLOCK_50) begin
        ps2_clk_prev <= ps2_clk;
    end

    wire falling_edge = (ps2_clk_prev == 1'b1 && ps2_clk == 1'b0);

    // ==============================================================
    // Bit reception state
    // ==============================================================
    reg [3:0] bit_count;
    reg [7:0] shift_reg;

    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            bit_count        <= 0;
            received_data    <= 0;
            received_data_en <= 0;
        end
        else begin
            received_data_en <= 0;

            if (falling_edge) begin
                case (bit_count)
                    0: ; // start bit
                    1,2,3,4,5,6,7,8:
                        shift_reg[bit_count-1] <= ps2_dat; // data bits
                    9: ; // parity bit (ignored)
                    10: begin
                        received_data    <= shift_reg;
                        received_data_en <= 1'b1;
                    end
                endcase

                if (bit_count == 10)
                    bit_count <= 0;
                else
                    bit_count <= bit_count + 1'b1;
            end
        end
    end

endmodule
