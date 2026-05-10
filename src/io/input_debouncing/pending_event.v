// Purpose: rate-limit the 1-clock edge pulses to input frame
// collects any edges that occur between tick_input pulses
// on tick_input, emits exactly one 1-clock button pulse if an event is pending or is just arriving
// then clears the pending flag
// guarantee max 1 action per input frame

module pending_event(edge_1clk, tick_input, resetn, clock, button);
    input edge_1clk; // 1-clock pulse from edgedetect
    input tick_input; // frame enable pulse 
    input resetn, clock;
    output reg button; // frame-aligned output
    reg pending; // remembers if an edge occurred between frames

    // precompute "pending if we include this cycle's new edge"
    wire pending_next = pending | edge_1clk;

    // fire when the frame ticks and something is pending or arriving now
    wire fire = tick_input & pending_next;
    always@(posedge clock)
    begin
        if (!resetn)
        begin
            pending <= 0;
            button <= 0;
        end
        else if (edge_1clk)
            pending <= 1'b1;
        else 
        begin
            // emit only one pulse when frame ticks and event is pending
            button <= fire; 
            // update pending when edge arrives, clear if we fired this frame
            pending <= pending_next & ~fire;
        end
    end
endmodule
