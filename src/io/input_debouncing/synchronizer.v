/* purpose: safely bring an async button signal
into the 50 MHz domain (limit metastability)
using 2 flipflops */

// metastability = when a signal is read as its changing 
// if the button signal is read on its rising edge
// it might cause undefined behavior
// -> delay signal with 2 flipflops for safe reading

module synchronizer(clock, D, resetn, key_sync);
    input clock, D, resetn;
    output key_sync; // synchronized output

    // 2-stage FF reduces risk if signal is sampled on rising edge
    wire Q;
    flipflop f1(clock, D, resetn, Q);
    flipflop f2(clock, Q, resetn, key_sync);
endmodule
