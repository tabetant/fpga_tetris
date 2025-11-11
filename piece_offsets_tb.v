module tb_tetris_piece_offsets;
    reg        shape_id;
    reg  [1:0] rot;
    wire [1:0] dx0,dy0,dx1,dy1,dx2,dy2,dx3,dy3;

    tetris_piece_offsets dut(
        .shape_id(shape_id),
        .rot(rot),
        .dx0(dx0), .dy0(dy0),
        .dx1(dx1), .dy1(dy1),
        .dx2(dx2), .dy2(dy2),
        .dx3(dx3), .dy3(dy3)
    );

    initial begin
        // O piece
        shape_id = 0;
        for (rot = 0; rot < 4; rot = rot + 1) begin
            #1;
            $display("O rot=%0d: (%0d,%0d) (%0d,%0d) (%0d,%0d) (%0d,%0d)",
                     rot, dx0,dy0, dx1,dy1, dx2,dy2, dx3,dy3);
        end

        // I piece
        shape_id = 1;
        for (rot = 0; rot < 4; rot = rot + 1) begin
            #1;
            $display("I rot=%0d: (%0d,%0d) (%0d,%0d) (%0d,%0d) (%0d,%0d)",
                     rot, dx0,dy0, dx1,dy1, dx2,dy2, dx3,dy3);
        end

        $finish;
    end
endmodule
