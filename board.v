// board10x20.v  (no for-loops)
// 20 rows x 10 columns boolean occupancy board
module board10x20 (
    input  wire        CLOCK_50,
    input  wire        resetn,
    // write
    input  wire        we,
    input  wire [3:0]  wx,     // 0..9
    input  wire [4:0]  wy,     // 0..19
    input  wire        wdata,  // 1 = occupied, 0 = empty
    // read (combinational)
    input  wire [3:0]  rx,     // 0..9
    input  wire [4:0]  ry,     // 0..19
    output wire        rdata
);
    // 20 independent rows (bit 0 = x=0, bit 9 = x=9)
    reg [9:0] r0,  r1,  r2,  r3,  r4,
              r5,  r6,  r7,  r8,  r9,
              r10, r11, r12, r13, r14,
              r15, r16, r17, r18, r19;

    // write mask from wx
    wire [9:0] bitmask =
        (wx == 4'd0) ? 10'b0000000001 :
        (wx == 4'd1) ? 10'b0000000010 :
        (wx == 4'd2) ? 10'b0000000100 :
        (wx == 4'd3) ? 10'b0000001000 :
        (wx == 4'd4) ? 10'b0000010000 :
        (wx == 4'd5) ? 10'b0000100000 :
        (wx == 4'd6) ? 10'b0001000000 :
        (wx == 4'd7) ? 10'b0010000000 :
        (wx == 4'd8) ? 10'b0100000000 :
                        10'b1000000000 ; // wx == 9 (or clamped by caller)

    // next-row helper (set/clear one bit)
    function [9:0] set_or_clear;
        input [9:0] row;
        input [9:0] mask;
        input       val;
        begin
            set_or_clear = val ? (row | mask) : (row & ~mask);
        end
    endfunction

    // synchronous reset + write
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            r0  <= 10'b0; r1  <= 10'b0; r2  <= 10'b0; r3  <= 10'b0; r4  <= 10'b0;
            r5  <= 10'b0; r6  <= 10'b0; r7  <= 10'b0; r8  <= 10'b0; r9  <= 10'b0;
            r10 <= 10'b0; r11 <= 10'b0; r12 <= 10'b0; r13 <= 10'b0; r14 <= 10'b0;
            r15 <= 10'b0; r16 <= 10'b0; r17 <= 10'b0; r18 <= 10'b0; r19 <= 10'b0;
        end else if (we) begin
            case (wy)
              5'd0:  r0  <= set_or_clear(r0 , bitmask, wdata);
              5'd1:  r1  <= set_or_clear(r1 , bitmask, wdata);
              5'd2:  r2  <= set_or_clear(r2 , bitmask, wdata);
              5'd3:  r3  <= set_or_clear(r3 , bitmask, wdata);
              5'd4:  r4  <= set_or_clear(r4 , bitmask, wdata);
              5'd5:  r5  <= set_or_clear(r5 , bitmask, wdata);
              5'd6:  r6  <= set_or_clear(r6 , bitmask, wdata);
              5'd7:  r7  <= set_or_clear(r7 , bitmask, wdata);
              5'd8:  r8  <= set_or_clear(r8 , bitmask, wdata);
              5'd9:  r9  <= set_or_clear(r9 , bitmask, wdata);
              5'd10: r10 <= set_or_clear(r10, bitmask, wdata);
              5'd11: r11 <= set_or_clear(r11, bitmask, wdata);
              5'd12: r12 <= set_or_clear(r12, bitmask, wdata);
              5'd13: r13 <= set_or_clear(r13, bitmask, wdata);
              5'd14: r14 <= set_or_clear(r14, bitmask, wdata);
              5'd15: r15 <= set_or_clear(r15, bitmask, wdata);
              5'd16: r16 <= set_or_clear(r16, bitmask, wdata);
              5'd17: r17 <= set_or_clear(r17, bitmask, wdata);
              5'd18: r18 <= set_or_clear(r18, bitmask, wdata);
              5'd19: r19 <= set_or_clear(r19, bitmask, wdata);
              default: ;
            endcase
        end
    end

    // combinational: select row by ry
    wire [9:0] row_sel =
        (ry == 5'd0 ) ? r0  :
        (ry == 5'd1 ) ? r1  :
        (ry == 5'd2 ) ? r2  :
        (ry == 5'd3 ) ? r3  :
        (ry == 5'd4 ) ? r4  :
        (ry == 5'd5 ) ? r5  :
        (ry == 5'd6 ) ? r6  :
        (ry == 5'd7 ) ? r7  :
        (ry == 5'd8 ) ? r8  :
        (ry == 5'd9 ) ? r9  :
        (ry == 5'd10) ? r10 :
        (ry == 5'd11) ? r11 :
        (ry == 5'd12) ? r12 :
        (ry == 5'd13) ? r13 :
        (ry == 5'd14) ? r14 :
        (ry == 5'd15) ? r15 :
        (ry == 5'd16) ? r16 :
        (ry == 5'd17) ? r17 :
        (ry == 5'd18) ? r18 :
                        r19 ;

    // bit pick by rx
    assign rdata = row_sel[rx];

endmodule
