module tetris_piece_offsets (
    input  wire [2:0] shape_id,  // O=0, I=1, J=2, L=3, S=4, T=5, Z=6
    input  wire [1:0] rot,       // 0,90,180,270 (clockwise)

    output reg  signed [3:0] dx0, dy0,
    output reg  signed [3:0] dx1, dy1,
    output reg  signed [3:0] dx2, dy2,
    output reg  signed [3:0] dx3, dy3
);
  always @* begin
    // defaults
    dx0 = 4'sd0; dy0 = 4'sd0;
    dx1 = 4'sd0; dy1 = 4'sd0;
    dx2 = 4'sd0; dy2 = 4'sd0;
    dx3 = 4'sd0; dy3 = 4'sd0;

    // O (no visible rotation)
    if (shape_id == 3'd0) begin
      dx0 = 4'sd1; dy0 = 4'sd1;
      dx1 = 4'sd2; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd2;
      dx3 = 4'sd2; dy3 = 4'sd2;

    // I
    end else if (shape_id == 3'd1 && (rot == 2'd0 || rot == 2'd2)) begin
      // vertical
      dx0 = 4'sd0; dy0 = 4'sd0;
      dx1 = 4'sd0; dy1 = 4'sd1;
      dx2 = 4'sd0; dy2 = 4'sd2;
      dx3 = 4'sd0; dy3 = 4'sd3;
    end else if (shape_id == 3'd1 && (rot == 2'd1 || rot == 2'd3)) begin
      // horizontal
      dx0 = 4'sd0; dy0 = 4'sd0;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd2; dy2 = 4'sd0;
      dx3 = 4'sd3; dy3 = 4'sd0;

    // J
    end else if (shape_id == 3'd2 && rot == 2'd0) begin
      dx0 = 4'sd0; dy0 = 4'sd0;
      dx1 = 4'sd0; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd1;
    end else if (shape_id == 3'd2 && rot == 2'd1) begin
      dx0 = 4'sd2; dy0 = 4'sd0;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd2;
    end else if (shape_id == 3'd2 && rot == 2'd2) begin
      dx0 = 4'sd0; dy0 = 4'sd1;
      dx1 = 4'sd1; dy1 = 4'sd1;
      dx2 = 4'sd2; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd2;
    end else if (shape_id == 3'd2 && rot == 2'd3) begin
      dx0 = 4'sd0; dy0 = 4'sd2;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd2;

    // L
    end else if (shape_id == 3'd3 && rot == 2'd0) begin
      dx0 = 4'sd2; dy0 = 4'sd0;
      dx1 = 4'sd0; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd1;
    end else if (shape_id == 3'd3 && rot == 2'd1) begin
      dx0 = 4'sd2; dy0 = 4'sd2;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd2;
    end else if (shape_id == 3'd3 && rot == 2'd2) begin
      dx0 = 4'sd0; dy0 = 4'sd1;
      dx1 = 4'sd1; dy1 = 4'sd1;
      dx2 = 4'sd2; dy2 = 4'sd1;
      dx3 = 4'sd0; dy3 = 4'sd2;
    end else if (shape_id == 3'd3 && rot == 2'd3) begin
      dx0 = 4'sd0; dy0 = 4'sd0;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd2;

    // S
    end else if (shape_id == 3'd4 && rot == 2'd0) begin
      dx0 = 4'sd2; dy0 = 4'sd0;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd0; dy3 = 4'sd1;
    end else if (shape_id == 3'd4 && rot == 2'd1) begin
      dx0 = 4'sd2; dy0 = 4'sd2;
      dx1 = 4'sd2; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd0;
    end else if (shape_id == 3'd4 && rot == 2'd2) begin
      dx0 = 4'sd0; dy0 = 4'sd2;
      dx1 = 4'sd1; dy1 = 4'sd2;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd1;
    end else if (shape_id == 3'd4 && rot == 2'd3) begin
      dx0 = 4'sd0; dy0 = 4'sd0;
      dx1 = 4'sd0; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd2;

    // T
    end else if (shape_id == 3'd5 && rot == 2'd0) begin
      dx0 = 4'sd2; dy0 = 4'sd1;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd0; dy3 = 4'sd1;
    end else if (shape_id == 3'd5 && rot == 2'd1) begin
      dx0 = 4'sd1; dy0 = 4'sd2;
      dx1 = 4'sd2; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd0;
    end else if (shape_id == 3'd5 && rot == 2'd2) begin
      dx0 = 4'sd0; dy0 = 4'sd1;
      dx1 = 4'sd1; dy1 = 4'sd2;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd1;
    end else if (shape_id == 3'd5 && rot == 2'd3) begin
      dx0 = 4'sd1; dy0 = 4'sd0;
      dx1 = 4'sd0; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd1; dy3 = 4'sd2;

    // Z
    end else if (shape_id == 3'd6 && rot == 2'd0) begin
      dx0 = 4'sd2; dy0 = 4'sd1;
      dx1 = 4'sd1; dy1 = 4'sd0;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd0; dy3 = 4'sd0;
    end else if (shape_id == 3'd6 && rot == 2'd1) begin
      dx0 = 4'sd1; dy0 = 4'sd2;
      dx1 = 4'sd2; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd0;
    end else if (shape_id == 3'd6 && rot == 2'd2) begin
      dx0 = 4'sd0; dy0 = 4'sd1;
      dx1 = 4'sd1; dy1 = 4'sd2;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd2; dy3 = 4'sd2;
    end else if (shape_id == 3'd6 && rot == 2'd3) begin
      dx0 = 4'sd1; dy0 = 4'sd0;
      dx1 = 4'sd0; dy1 = 4'sd1;
      dx2 = 4'sd1; dy2 = 4'sd1;
      dx3 = 4'sd0; dy3 = 4'sd2;
    end
  end
endmodule
