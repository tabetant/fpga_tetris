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

module tick_g (
    input  wire        CLOCK_50,
    input  wire        resetn,
    input  wire [4:0]  score,
    output reg         tick_gravity,
    output reg         blink
);
    reg [25:0] count;
    reg [25:0] period;

    always @(*) begin
  
        period = 26'd24_999_999;
        if      (score[4]) period = 26'd4_999_999;
        else if (score[3]) period = 26'd9_999_999;
        else if (score[2]) period = 26'd14_999_999;
        else if (score[1]) period = 26'd19_999_999;
        else if (score[0]) period = 26'd24_999_999;
    end

    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            count        <= 26'd0;
            tick_gravity <= 1'b0;
            blink        <= 1'b0;
        end else begin
            if (count == period) begin
                count        <= 26'd0;
                tick_gravity <= 1'b1;   // pulse
                blink        <= ~blink; // toggle
            end else begin
                count        <= count + 1'b1;
                tick_gravity <= 1'b0;   // no tick this cycle
            end
        end
    end

endmodule
