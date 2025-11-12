// for modelsim:
`timescale 1ns/1ps

`ifndef SIM
  localparam INPUT_MAX = 20'd499_999;     // ~10 ms @ 50 MHz (100 Hz)
  localparam GRAV_MAX  = 26'd24_999_999;  // ~0.5 s @ 50 MHz
`else
  localparam INPUT_MAX = 20'd999;         // fast in sim (~20 us)
  localparam GRAV_MAX  = 26'd49_999;      // fast in sim (~1 ms)
`endif

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
		else if (count == INPUT_MAX)
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
		else if (count == GRAV_MAX)
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
