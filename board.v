`default_nettype none
module board10x20_4r (
  input        clk,
  input        resetn,
  input        we,
  input  [3:0] wx,
  input  [4:0] wy,
  input        wdata,
  input  [3:0] rx0, input [4:0] ry0, output r0,
  input  [3:0] rx1, input [4:0] ry1, output r1,
  input  [3:0] rx2, input [4:0] ry2, output r2,
  input  [3:0] rx3, input [4:0] ry3, output r3
);

  reg [9:0] row0,  row1,  row2,  row3,  row4,
            row5,  row6,  row7,  row8,  row9,
            row10, row11, row12, row13, row14,
            row15, row16, row17, row18, row19;

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
        default: ;
      endcase
    end
  end

  reg [9:0] rrow0, rrow1, rrow2, rrow3;

  always @* begin
    case (ry0)
      5'd0:  rrow0 = row0;  5'd1:  rrow0 = row1;  5'd2:  rrow0 = row2;  5'd3:  rrow0 = row3;
      5'd4:  rrow0 = row4;  5'd5:  rrow0 = row5;  5'd6:  rrow0 = row6;  5'd7:  rrow0 = row7;
      5'd8:  rrow0 = row8;  5'd9:  rrow0 = row9;  5'd10: rrow0 = row10; 5'd11: rrow0 = row11;
      5'd12: rrow0 = row12; 5'd13: rrow0 = row13; 5'd14: rrow0 = row14; 5'd15: rrow0 = row15;
      5'd16: rrow0 = row16; 5'd17: rrow0 = row17; 5'd18: rrow0 = row18; 5'd19: rrow0 = row19;
      default: rrow0 = 10'b0;
    endcase
  end

  always @* begin
    case (ry1)
      5'd0:  rrow1 = row0;  5'd1:  rrow1 = row1;  5'd2:  rrow1 = row2;  5'd3:  rrow1 = row3;
      5'd4:  rrow1 = row4;  5'd5:  rrow1 = row5;  5'd6:  rrow1 = row6;  5'd7:  rrow1 = row7;
      5'd8:  rrow1 = row8;  5'd9:  rrow1 = row9;  5'd10: rrow1 = row10; 5'd11: rrow1 = row11;
      5'd12: rrow1 = row12; 5'd13: rrow1 = row13; 5'd14: rrow1 = row14; 5'd15: rrow1 = row15;
      5'd16: rrow1 = row16; 5'd17: rrow1 = row17; 5'd18: rrow1 = row18; 5'd19: rrow1 = row19;
      default: rrow1 = 10'b0;
    endcase
  end

  always @* begin
    case (ry2)
      5'd0:  rrow2 = row0;  5'd1:  rrow2 = row1;  5'd2:  rrow2 = row2;  5'd3:  rrow2 = row3;
      5'd4:  rrow2 = row4;  5'd5:  rrow2 = row5;  5'd6:  rrow2 = row6;  5'd7:  rrow2 = row7;
      5'd8:  rrow2 = row8;  5'd9:  rrow2 = row9;  5'd10: rrow2 = row10; 5'd11: rrow2 = row11;
      5'd12: rrow2 = row12; 5'd13: rrow2 = row13; 5'd14: rrow2 = row14; 5'd15: rrow2 = row15;
      5'd16: rrow2 = row16; 5'd17: rrow2 = row17; 5'd18: rrow2 = row18; 5'd19: rrow2 = row19;
      default: rrow2 = 10'b0;
    endcase
  end

  always @* begin
    case (ry3)
      5'd0:  rrow3 = row0;  5'd1:  rrow3 = row1;  5'd2:  rrow3 = row2;  5'd3:  rrow3 = row3;
      5'd4:  rrow3 = row4;  5'd5:  rrow3 = row5;  5'd6:  rrow3 = row6;  5'd7:  rrow3 = row7;
      5'd8:  rrow3 = row8;  5'd9:  rrow3 = row9;  5'd10: rrow3 = row10; 5'd11: rrow3 = row11;
      5'd12: rrow3 = row12; 5'd13: rrow3 = row13; 5'd14: rrow3 = row14; 5'd15: rrow3 = row15;
      5'd16: rrow3 = row16; 5'd17: rrow3 = row17; 5'd18: rrow3 = row18; 5'd19: rrow3 = row19;
      default: rrow3 = 10'b0;
    endcase
  end

  assign r0 = (rx0 <= 4'd9) ? rrow0[rx0] : 1'b0;
  assign r1 = (rx1 <= 4'd9) ? rrow1[rx1] : 1'b0;
  assign r2 = (rx2 <= 4'd9) ? rrow2[rx2] : 1'b0;
  assign r3 = (rx3 <= 4'd9) ? rrow3[rx3] : 1'b0;

endmodule
