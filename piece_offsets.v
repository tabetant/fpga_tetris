module tetris_piece_offsets (
    input  wire [2:0]shape_id,  // O = 0 I = 1 ( for now to limit scope )
    input  wire [1:0] rot,       // 0..3 = {0°, 90°, 180°, 270°}, clockwise

    output reg  signed [1:0] dx0, dy0,
    output reg  signed [1:0] dx1, dy1,
    output reg signed  [1:0] dx2, dy2,
    output reg  signed [1:0] dx3, dy3
);

 always @* begin
        // default safe values
        dx0 = 0; dy0 = 0;
        dx1 = 0; dy1 = 0;
        dx2 = 0; dy2 = 0;
        dx3 = 0; dy3 = 0;
        // O
        if (shape_id == 3'd0) begin
            dx0 = 2'd1; dy0 = 2'd1;
            dx1 = 2'd2; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd2;
            dx3 = 2'd2; dy3 = 2'd2;
        end
        // I
        else if (shape_id == 3'd1 && (rot ==2'd0 || rot == 2'd2)) begin // rotating 0 and 2 times will result in same pos
            dx0 = 2'd0; dy0 = 2'd0;
            dx1 = 2'd0; dy1 = 2'd1;
            dx2 = 2'd0; dy2 = 2'd2;
            dx3 = 2'd0; dy3 = 2'd3;
        end

        else if (shape_id == 3'd1 && (rot ==2'd1 || rot == 2'd3)) begin // rotating 1 and 3 times will result in same pos
            dx0 = 2'd0; dy0 = 2'd0;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd2; dy2 = 2'd0;
            dx3 = 2'd3; dy3 = 2'd0;
        end

            // J
        else if (shape_id == 3'd2 && (rot ==2'd0)) begin // rotating 0
            dx0 = 2'd0; dy0 = 2'd0;
            dx1 = 2'd0; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd1;
        end

        else if (shape_id == 3'd2 && (rot ==2'd1)) begin // rotating 1
            dx0 = 2'd2; dy0 = 2'd0;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd2;
        end

        else if (shape_id == 3'd2 && (rot ==2'd2)) begin // rotating 2
            dx0 = 2'd0; dy0 = 2'd1;
            dx1 = 2'd1; dy1 = 2'd1;
            dx2 = 2'd2; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd2;
        end

        else if (shape_id == 3'd2 && (rot ==2'd3)) begin // rotating 3
            dx0 = 2'd0; dy0 = 2'd2;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd2;
        end

            // L
        else if (shape_id == 3'd3 && (rot ==2'd0)) begin // rotating 0
            dx0 = 2'd2; dy0 = 2'd0;
            dx1 = 2'd0; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd1;
        end

        else if (shape_id == 3'd3 && (rot ==2'd1)) begin // rotating 1
            dx0 = 2'd2; dy0 = 2'd2;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd2;
        end

        else if (shape_id == 3'd3 && (rot ==2'd2)) begin // rotating 2
            dx0 = 2'd0; dy0 = 2'd1;
            dx1 = 2'd1; dy1 = 2'd1;
            dx2 = 2'd2; dy2 = 2'd1;
            dx3 = 2'd0; dy3 = 2'd2;
        end

        else if (shape_id == 3'd3 && (rot ==2'd3)) begin // rotating 3
            dx0 = 2'd0; dy0 = 2'd0;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd2;
        end

                // S
        else if (shape_id == 3'd4 && (rot ==2'd0)) begin // rotating 0
            dx0 = 2'd2; dy0 = 2'd0;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd0; dy3 = 2'd1;
        end

        else if (shape_id == 3'd4 && (rot ==2'd1)) begin // rotating 1
            dx0 = 2'd2; dy0 = 2'd2;
            dx1 = 2'd2; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd0;
        end

        else if (shape_id == 3'd4 && (rot ==2'd2)) begin // rotating 2
            dx0 = 2'd0; dy0 = 2'd2;
            dx1 = 2'd1; dy1 = 2'd2;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd1;
        end

        else if (shape_id == 3'd4 && (rot ==2'd3)) begin // rotating 3
            dx0 = 2'd0; dy0 = 2'd0;
            dx1 = 2'd0; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd2;
        end

                // T
        else if (shape_id == 3'd5 && (rot ==2'd0)) begin // rotating 0
            dx0 = 2'd2; dy0 = 2'd1;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd0; dy3 = 2'd1;
        end

        else if (shape_id == 3'd5 && (rot ==2'd1)) begin // rotating 1
            dx0 = 2'd1; dy0 = 2'd2;
            dx1 = 2'd2; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd0;
        end

        else if (shape_id == 3'd5 && (rot ==2'd2)) begin // rotating 2
            dx0 = 2'd0; dy0 = 2'd1;
            dx1 = 2'd1; dy1 = 2'd2;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd1;
        end

        else if (shape_id == 3'd5 && (rot ==2'd3)) begin // rotating 3
            dx0 = 2'd1; dy0 = 2'd0;
            dx1 = 2'd0; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd1; dy3 = 2'd2;
        end

                // Z
        else if (shape_id == 3'd6 && (rot ==2'd0)) begin // rotating 0
            dx0 = 2'd2; dy0 = 2'd1;
            dx1 = 2'd1; dy1 = 2'd0;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd0; dy3 = 2'd0;
        end

        else if (shape_id == 3'd6 && (rot ==2'd1)) begin // rotating 1
            dx0 = 2'd1; dy0 = 2'd2;
            dx1 = 2'd2; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd0;
        end

        else if (shape_id == 3'd6 && (rot ==2'd2)) begin // rotating 2
            dx0 = 2'd0; dy0 = 2'd1;
            dx1 = 2'd1; dy1 = 2'd2;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd2; dy3 = 2'd2;
        end

        else if (shape_id == 3'd6 && (rot ==2'd3)) begin // rotating 3
            dx0 = 2'd1; dy0 = 2'd0;
            dx1 = 2'd0; dy1 = 2'd1;
            dx2 = 2'd1; dy2 = 2'd1;
            dx3 = 2'd0; dy3 = 2'd2;
        end
        
        
    end
endmodule
