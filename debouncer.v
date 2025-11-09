// Purpose: convert bouncy button level into a stable out_level
// accepts a new input level only if it remains unchanged for 5ms
// output stays high the entire time the button is held

module debouncer(clock, resetn, in_sync, out_level);
    input clock, resetn;
    input in_sync; // synchronized button
    output reg out_level; // debounced stable button
    reg stable_state; // last accepted stable level
    reg [19:0] count; // ~5ms => 250k clock cycles

    always @(posedge clock)
    begin
        if(!resetn)
        begin
            out_level <= 1'b0;
            stable_state <= 1'b0;
            count <= 0;
        end
        else if (in_sync == stable_state)
            // if input matches stable state, no change + reset timer
            count <= 0;
        else if (count == 20'd249_999)
        begin
            // input has remained different for long enough -> accept the change
            count <= 0;
            stable_state <= in_sync;
            out_level <= in_sync;
        end
        else
            count <= count + 1;
    end
endmodule