// simple d-flipflop with sync active low reset

module flipflop(clock, D, resetn, Q);
    input clock, D;
    output reg Q;
    always@(posedge clock)
    begin
    if (!resetn)
        Q <= 1'b0;
    else
        Q <= D;
    end
endmodule
