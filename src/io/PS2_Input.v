`default_nettype none

module PS2_Interface (
    input  wire       CLOCK_50,
    input  wire       resetn,          // active-low reset
    inout  wire       PS2_CLK,
    inout  wire       PS2_DAT,

    output reg  [7:0] scan_code,       // MAKE code only
    output reg        scan_code_valid  // 1-cycle pulse
);

    // ==============================================================
    // Receive raw bytes from PS2_Controller
    // ==============================================================
    wire [7:0] ps2_raw;
    wire       ps2_raw_valid;

    PS2_Controller PS2 (
        .CLOCK_50         (CLOCK_50),
        .reset            (~resetn),       // controller uses active-high
        .PS2_CLK          (PS2_CLK),
        .PS2_DAT          (PS2_DAT),
        .received_data    (ps2_raw),
        .received_data_en (ps2_raw_valid)
    );

    // ==============================================================
    // Decode PS/2 protocol
    // ==============================================================
    reg break_code;
    reg extended_code;

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            scan_code       <= 8'h00;
            scan_code_valid <= 1'b0;
            break_code      <= 1'b0;
            extended_code   <= 1'b0;
        end else begin
            scan_code_valid <= 1'b0;

            if (ps2_raw_valid) begin
                case (ps2_raw)

                    8'hF0: begin
                        break_code <= 1'b1;   // next byte = release
                    end

                    8'hE0: begin
                        extended_code <= 1'b1; // next code is extended
                    end

                    default: begin
                        if (break_code) begin
                            // ignore this byte (ignored release)
                            break_code <= 1'b0;
                        end else begin
                            // MAKE code → valid key press
                            scan_code <= ps2_raw;
                            scan_code_valid <= 1'b1;
                        end

                        // done with extended flag
                        extended_code <= 1'b0;
                    end

                endcase
            end
        end
    end

endmodule
