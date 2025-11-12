module tick_i(CLOCK_50, resetn, tick_input);
    input CLOCK_50, resetn;
    output reg tick_input;
    reg [19:0] count;
    always@(posedge CLOCK_50)
    begin
        if (!resetn)
        begin
            tick_input <= 0;
            count <= 0;
        end
		else if (count == 20'd499_999)
        begin
            tick_input <= 1'b1;
            count <= 0;
        end
        else
        begin
            tick_input <= 0;
            count <= count + 1;
        end
    end
endmodule

module tick_g(CLOCK_50, resetn, tick_gravity, blink);
    input CLOCK_50, resetn;
    output reg tick_gravity, blink;
    reg [25:0] count;
    always@(posedge CLOCK_50)
    begin
        if (!resetn)
        begin
            tick_gravity <= 0;
            count <= 0;
				blink <= 0;
        end
		else if (count == 26'd24_999_999)
        begin
            tick_gravity <= 1'b1;
            count <= 0;
				blink <= ~blink;
        end
        else
        begin
            tick_gravity <= 0;
            count <= count + 1;
        end
    end
endmodule
