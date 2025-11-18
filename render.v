`default_nettype none

module render_box20 (
    input  wire        CLOCK_50,
    input  wire        resetn,      // active-low: 1 = running, 0 = reset
    input  wire        start,       // pulse/high to draw the box once
    input  wire [9:0]  x0,          // top-left X of box
    input  wire [8:0]  y0,          // top-left Y of box
    input  wire [8:0]  color,       // 9-bit color: RRR_GGG_BBB

    output wire [7:0]  VGA_R,
    output wire [7:0]  VGA_G,
    output wire [7:0]  VGA_B,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire        VGA_BLANK_N,
    output wire        VGA_SYNC_N,
    output wire        VGA_CLK,
    output reg         done,
    output reg         busy
);
    // VGA geometry for 640x480 via given vga_adapter
    localparam nX = 10;
    localparam nY = 9;

    // Cell size for Tetris
    localparam [nX-1:0] BOX_W = 10'd64;
    localparam [nY-1:0] BOX_H = 9'd24;

    // Offsets within the box
    wire [nX-1:0] xc;
    wire [nY-1:0] yc;

    // Control for the counters + write signal
    reg        write;
    reg        L_xc, L_yc;
    reg        E_xc, E_yc;
    reg [1:0]  state, next_state;

    // Simple 2-bit FSM states
    localparam S_IDLE  = 2'b00;
    localparam S_DRAWX = 2'b01;
    localparam S_NEXTY = 2'b10;
    localparam S_DONE  = 2'b11;

    // Up counters for scanning the 20x20 area
    Up_count #(.n(nX)) u_xc (
        .R      ({nX{1'b0}}),
        .Clock  (CLOCK_50),
        .Resetn (resetn),
        .L      (L_xc),
        .E      (E_xc),
        .Q      (xc)
    );

    Up_count #(.n(nY)) u_yc (
        .R      ({nY{1'b0}}),
        .Clock  (CLOCK_50),
        .Resetn (resetn),
        .L      (L_yc),
        .E      (E_yc),
        .Q      (yc)
    );

    always @(*) begin    
        case (state)
            S_IDLE:   next_state = start ? S_DRAWX : S_IDLE;
            S_DRAWX:  next_state = (xc < BOX_W-1) ? S_DRAWX : S_NEXTY;
            S_NEXTY:  next_state = (yc < BOX_H-1) ? S_DRAWX : S_DONE;
            S_DONE:   next_state = S_IDLE;
            default:  next_state = S_IDLE;
        endcase
    end

    always @(*) 
    begin
    // defaults
    write = 1'b0; L_xc = 1'b0; L_yc = 1'b0; E_xc = 1'b0; E_yc = 1'b0;
    done  = 1'b0; busy = 1'b0;

    case (state)
        S_IDLE: begin
            if (start) begin L_xc = 1'b1; L_yc = 1'b1; end
        end
        S_DRAWX: begin
            write = 1'b1; E_xc = 1'b1; busy = 1'b1;
        end
        S_NEXTY: begin
            L_xc = 1'b1; E_yc = 1'b1; busy = 1'b1;
        end
        S_DONE: begin
            done = 1'b1; // 1-cycle pulse
        end
    endcase
    end

    // FSM state register
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Compute absolute pixel coordinates: top-left (x0, y0) + offsets
    wire [nX-1:0] pixel_x = x0 + xc;
    wire [nY-1:0] pixel_y = y0 + yc;

    // Connect to VGA adapter
    vga_adapter VGA (
        .resetn      (resetn),
        .clock       (CLOCK_50),
        .color       (color),
        .x           (pixel_x),
        .y           (pixel_y),
        .write       (write),
        .VGA_R       (VGA_R),
        .VGA_G       (VGA_G),
        .VGA_B       (VGA_B),
        .VGA_HS      (VGA_HS),
        .VGA_VS      (VGA_VS),
        .VGA_BLANK_N (VGA_BLANK_N),
        .VGA_SYNC_N  (VGA_SYNC_N),
        .VGA_CLK     (VGA_CLK)
    );
    defparam VGA.RESOLUTION       = "640x480";
    defparam VGA.COLOR_DEPTH      = 9;
    // Adjust or override this in your top if you want:
    defparam VGA.BACKGROUND_IMAGE = "./frame3.mif";

endmodule

// ===== Helpers (same as before) =====

module Up_count #(parameter n = 8)(
    input  wire [n-1:0] R,
    input  wire         Clock,
    input  wire         Resetn,
    input  wire         L,
    input  wire         E,
    output reg  [n-1:0] Q
);
    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            Q <= {n{1'b0}};
        else if (L)
            Q <= R;
        else if (E)
            Q <= Q + 1'b1;
    end
endmodule
