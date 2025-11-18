module board10x20 (
  input        clk,
  input        resetn,
  // write port
  input        we,
  input  [3:0] wx,          // 0..9
  input  [4:0] wy,          // 0..19
  input        wdata,       // 1 = occupied, 0 = empty
  // read port (combinational)
  input  [3:0] rx,          // 0..9
  input  [4:0] ry,          // 0..19
  output       rdata
);
  // 20 rows of 10 bits each (bit=column)
  reg [9:0] row0,  row1,  row2,  row3,  row4,
            row5,  row6,  row7,  row8,  row9,
            row10, row11, row12, row13, row14,
            row15, row16, row17, row18, row19;

  // synchronous clear + write
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      row0  <= 10'b0; row1  <= 10'b0; row2  <= 10'b0; row3  <= 10'b0; row4  <= 10'b0;
      row5  <= 10'b0; row6  <= 10'b0; row7  <= 10'b0; row8  <= 10'b0; row9  <= 10'b0;
      row10 <= 10'b0; row11 <= 10'b0; row12 <= 10'b0; row13 <= 10'b0; row14 <= 10'b0;
      row15 <= 10'b0; row16 <= 10'b0; row17 <= 10'b0; row18 <= 10'b0; row19 <= 10'b0;
    end else if (we) begin
      case (wy)
        5'd0:  row0 [wx] <= wdata;
        5'd1:  row1 [wx] <= wdata;
        5'd2:  row2 [wx] <= wdata;
        5'd3:  row3 [wx] <= wdata;
        5'd4:  row4 [wx] <= wdata;
        5'd5:  row5 [wx] <= wdata;
        5'd6:  row6 [wx] <= wdata;
        5'd7:  row7 [wx] <= wdata;
        5'd8:  row8 [wx] <= wdata;
        5'd9:  row9 [wx] <= wdata;
        5'd10: row10[wx] <= wdata;
        5'd11: row11[wx] <= wdata;
        5'd12: row12[wx] <= wdata;
        5'd13: row13[wx] <= wdata;
        5'd14: row14[wx] <= wdata;
        5'd15: row15[wx] <= wdata;
        5'd16: row16[wx] <= wdata;
        5'd17: row17[wx] <= wdata;
        5'd18: row18[wx] <= wdata;
        5'd19: row19[wx] <= wdata;
        default: ; // ignore out-of-range
      endcase
    end
  end

  // combinational read
  reg [9:0] rrow;
  always @* begin
    case (ry)
      5'd0:  rrow = row0;
      5'd1:  rrow = row1;
      5'd2:  rrow = row2;
      5'd3:  rrow = row3;
      5'd4:  rrow = row4;
      5'd5:  rrow = row5;
      5'd6:  rrow = row6;
      5'd7:  rrow = row7;
      5'd8:  rrow = row8;
      5'd9:  rrow = row9;
      5'd10: rrow = row10;
      5'd11: rrow = row11;
      5'd12: rrow = row12;
      5'd13: rrow = row13;
      5'd14: rrow = row14;
      5'd15: rrow = row15;
      5'd16: rrow = row16;
      5'd17: rrow = row17;
      5'd18: rrow = row18;
      5'd19: rrow = row19;
      default: rrow = 10'b0;
    endcase
  end

  assign rdata = rrow[rx];

endmodule
