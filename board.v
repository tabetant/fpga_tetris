module board10x20_4r (
  input        clk,
  input        resetn,
  // write port
  input        we,
  input  [3:0] wx,
  input  [4:0] wy,
  input        wdata,
  // 4 read taps (combinational)
  input  [3:0] rx0, rx1, rx2, rx3,
  input  [4:0] ry0, ry1, ry2, ry3,
  output       r0,  r1,  r2,  r3
);
  reg [9:0] row0,  row1,  row2,  row3,  row4,
            row5,  row6,  row7,  row8,  row9,
            row10, row11, row12, row13, row14,
            row15, row16, row17, row18, row19;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      row0<=0; row1<=0; row2<=0; row3<=0; row4<=0;
      row5<=0; row6<=0; row7<=0; row8<=0; row9<=0;
      row10<=0; row11<=0; row12<=0; row13<=0; row14<=0;
      row15<=0; row16<=0; row17<=0; row18<=0; row19<=0;
    end else if (we) begin
      case (wy)
        5'd0:  row0 [wx] <= wdata;  5'd1:  row1 [wx] <= wdata;
        5'd2:  row2 [wx] <= wdata;  5'd3:  row3 [wx] <= wdata;
        5'd4:  row4 [wx] <= wdata;  5'd5:  row5 [wx] <= wdata;
        5'd6:  row6 [wx] <= wdata;  5'd7:  row7 [wx] <= wdata;
        5'd8:  row8 [wx] <= wdata;  5'd9:  row9 [wx] <= wdata;
        5'd10: row10[wx] <= wdata;  5'd11: row11[wx] <= wdata;
        5'd12: row12[wx] <= wdata;  5'd13: row13[wx] <= wdata;
        5'd14: row14[wx] <= wdata;  5'd15: row15[wx] <= wdata;
        5'd16: row16[wx] <= wdata;  5'd17: row17[wx] <= wdata;
        5'd18: row18[wx] <= wdata;  5'd19: row19[wx] <= wdata;
        default: ;
      endcase
    end
  end

  function [9:0] selrow(input [4:0] y);
    case (y)
      5'd0: selrow=row0;  5'd1: selrow=row1;  5'd2: selrow=row2;  5'd3: selrow=row3;  5'd4: selrow=row4;
      5'd5: selrow=row5;  5'd6: selrow=row6;  5'd7: selrow=row7;  5'd8: selrow=row8;  5'd9: selrow=row9;
      5'd10: selrow=row10;5'd11: selrow=row11;5'd12: selrow=row12;5'd13: selrow=row13;5'd14: selrow=row14;
      5'd15: selrow=row15;5'd16: selrow=row16;5'd17: selrow=row17;5'd18: selrow=row18;5'd19: selrow=row19;
      default: selrow=10'b0;
    endcase
  endfunction

  assign r0 = selrow(ry0)[rx0];
  assign r1 = selrow(ry1)[rx1];
  assign r2 = selrow(ry2)[rx2];
  assign r3 = selrow(ry3)[rx3];
endmodule
