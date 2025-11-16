`default_nettype none

module PS2_Interface (
    // Inputs
    input  wire       CLOCK_50,
    input  wire       resetn,          // active-low reset (1 = run, 0 = reset)

    // PS/2 lines
    inout  wire       PS2_CLK,
    inout  wire       PS2_DAT,

    // Outputs to your design
    output reg  [7:0] scan_code,       // last scan code received
    output reg        scan_code_valid  // 1-cycle pulse when new code arrives
);

    // Wires from PS2_Controller
    wire [7:0] ps2_key_data;
    wire       ps2_key_pressed;

    // Instantiate the PS/2 controller (same as before)
    PS2_Controller PS2 (
        .CLOCK_50         (CLOCK_50),
        .reset            (~resetn),       // controller expects active-high reset
        .PS2_CLK          (PS2_CLK),
        .PS2_DAT          (PS2_DAT),
        .received_data    (ps2_key_data),
        .received_data_en (ps2_key_pressed)
    );

    // Latch the last scan code and generate a 1-cycle "valid" strobe
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            scan_code       <= 8'h00;
            scan_code_valid <= 1'b0;
        end else begin
            // default: no new code this cycle
            scan_code_valid <= 1'b0;

            // when the controller says "I have a new byte"
            if (ps2_key_pressed) begin
                scan_code       <= ps2_key_data;
                scan_code_valid <= 1'b1;   // pulse for one clock
            end
        end
    end

endmodule
