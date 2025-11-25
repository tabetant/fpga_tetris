`default_nettype none

// 10 (X) by 20 (Y) single-bit board with 1 write port and 4 async read taps.
module board10x20_4r (
    input  wire       clk,
    input  wire       resetn,

    // single-cell write
    input  wire       we,          // write enable
    input  wire [3:0] wx,          // 0..9  (column)
    input  wire [4:0] wy,          // 0..19 (row)
    input  wire       wdata,       // 1: filled, 0: empty

    // four async read taps
    input  wire [3:0] rx0, input wire [4:0] ry0, output wire r0,
    input  wire [3:0] rx1, input wire [4:0] ry1, output wire r1,
    input  wire [3:0] rx2, input wire [4:0] ry2, output wire r2,
    input  wire [3:0] rx3, input wire [4:0] ry3, output wire r3
);
    // Store as 20 rows of 10 bits: mem[y][x]
    reg [9:0] mem [0:19];

    integer y;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            for (y = 0; y < 20; y = y + 1)
                mem[y] <= 10'b0;
        end else begin
            if (we) begin
                // write exactly ONE cell
                // protect against out-of-range just in case
                if (wy < 20 && wx < 10) begin
                    mem[wy][wx] <= wdata;
                end
            end
        end
    end

    // four combinational reads (safe because gamelogic clamps rx/ry)
    assign r0 = (ry0 < 20 && rx0 < 10) ? mem[ry0][rx0] : 1'b0;
    assign r1 = (ry1 < 20 && rx1 < 10) ? mem[ry1][rx1] : 1'b0;
    assign r2 = (ry2 < 20 && rx2 < 10) ? mem[ry2][rx2] : 1'b0;
    assign r3 = (ry3 < 20 && rx3 < 10) ? mem[ry3][rx3] : 1'b0;
endmodule
