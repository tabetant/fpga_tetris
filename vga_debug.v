reg prev_accept, prev_tick;
reg kick;  // 1-cycle pulse to painter

wire new_accept = move_accept & ~prev_accept;
wire new_tick   = tick_gravity & ~prev_tick;
wire need_redraw = new_accept | new_tick;

always @(posedge CLOCK_50 or negedge resetn) begin
    if (!resetn) begin
        prev_accept <= 1'b0;
        prev_tick   <= 1'b0;
        kick        <= 1'b0;
        draw_seq    <= 2'd0;
        prev_x      <= 4'd0;
        prev_y      <= 5'd0;
        clearing <= 1'b1;
        clr_x    <= 4'd0;
        clr_y    <= 5'd0;
    end else begin
        // edge-capture
        prev_accept <= move_accept;
        prev_tick   <= tick_gravity;

        // default: no start
        kick <= 1'b0;

        case (draw_seq)
            2'd0: begin
                // idle: if a move/gravity happened and painter is free, erase old cell
                if (need_redraw && ~busy) begin
                    x0          <= {prev_x, 6'b0};                       // prev_x * 64
                    y0          <= {prev_y, 4'b0} + {prev_y, 3'b0};      // prev_y * 24
                    paint_color <= bg_color;                              // erase
                    kick        <= 1'b1;
                    draw_seq    <= 2'd1;
                end
            end
            if (clearing) begin
            // only launch when painter is idle
            if (~busy && ~kick) begin
                x0          <= {clr_x, 6'b0};
                y0          <= {clr_y, 4'b0} + {clr_y, 3'b0};
                paint_color <= bg_color;
                kick        <= 1'b1;  // one box per start
            end else if (done) begin
                // advance to next cell
                if (clr_x == 4'd9) begin
                    clr_x <= 4'd0;
                    if (clr_y == 5'd19) begin
                        clr_y   <= 5'd0;
                        clearing <= 1'b0;   // finished clearing
                        // also sync prev to current so first move erases the right cell
                        prev_x <= cur_x;
                        prev_y <= cur_y;
                    end else begin
                        clr_y <= clr_y + 5'd1;
                    end
                end else begin
                    clr_x <= clr_x + 4'd1;
                end
            end

            2'd1: begin
                // after erase finishes, draw the new cell
                if (done && ~busy) begin
                    x0          <= {cur_x, 6'b0};
                    y0          <= {cur_y, 4'b0} + {cur_y, 3'b0};
                    paint_color <= piece_color;
                    kick        <= 1'b1;
                    draw_seq    <= 2'd2;
                end
            end

            2'd2: begin
                // after draw finishes, update prev_* and go idle
                if (done && ~busy) begin
                    prev_x   <= cur_x;
                    prev_y   <= cur_y;
                    draw_seq <= 2'd0;
                end
            end

            default: draw_seq <= 2'd0;
        endcase
    end
end
