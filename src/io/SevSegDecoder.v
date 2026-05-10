module SevSegDecoder_5bit(S, H_Tens, H_Units);   

    // Input: 5 bits (Range: 0 to 31)
    input [4:0] S;

    // Outputs: Two 7-segment signals (Active High)
    output [6:0] H_Tens;
    output [6:0] H_Units;

    // --- Logic for the UNITS digit (The right display) ---
    // This maps the number to its last digit (0-9)
    assign H_Units = 
    // Numbers ending in 0 (0, 10, 20, 30) -> Display '0'
    ((S == 5'b00000) || (S == 5'b01010) || (S == 5'b10100) || (S == 5'b11110)) ? 7'b0111111 :
    
    // Numbers ending in 1 (1, 11, 21, 31) -> Display '1'
    ((S == 5'b00001) || (S == 5'b01011) || (S == 5'b10101) || (S == 5'b11111)) ? 7'b0000110 :
    
    // Numbers ending in 2 (2, 12, 22) -> Display '2'
    ((S == 5'b00010) || (S == 5'b01100) || (S == 5'b10110)) ? 7'b1011011 :
    
    // Numbers ending in 3 (3, 13, 23) -> Display '3'
    ((S == 5'b00011) || (S == 5'b01101) || (S == 5'b10111)) ? 7'b1001111 :

    // Numbers ending in 4 (4, 14, 24) -> Display '4'
    ((S == 5'b00100) || (S == 5'b01110) || (S == 5'b11000)) ? 7'b1100110 :

    // Numbers ending in 5 (5, 15, 25) -> Display '5'
    ((S == 5'b00101) || (S == 5'b01111) || (S == 5'b11001)) ? 7'b1101101 :

    // Numbers ending in 6 (6, 16, 26) -> Display '6'
    ((S == 5'b00110) || (S == 5'b10000) || (S == 5'b11010)) ? 7'b1111101 :

    // Numbers ending in 7 (7, 17, 27) -> Display '7'
    ((S == 5'b00111) || (S == 5'b10001) || (S == 5'b11011)) ? 7'b0000111 :

    // Numbers ending in 8 (8, 18, 28) -> Display '8'
    ((S == 5'b01000) || (S == 5'b10010) || (S == 5'b11100)) ? 7'b1111111 :
    
    // Numbers ending in 9 (9, 19, 29) -> Display '9'
    7'b1101111; 


    // --- Logic for the TENS digit (The left display) ---
    // This maps the magnitude to 0, 1, 2, or 3
    assign H_Tens = 
    // Range 0-9 -> Display '0'
    (S < 5'b01010) ? 7'b0111111 :
    
    // Range 10-19 -> Display '1'
    (S < 5'b10100) ? 7'b0000110 :
    
    // Range 20-29 -> Display '2'
    (S < 5'b11110) ? 7'b1011011 :
    
    // Range 30-31 -> Display '3'
    7'b1001111;

endmodule
