module 7segDecoder(S, H);
    input [3:0] S;
    output [6:0] H;
    assign H[0] = S[1] | S[3] | (S[0]&S[2]) | (~S[2]&~S[0]);
    assign H[1] = (S[3]&S[1]) | ~S[2] | (S[1]&S[0]) | (~S[1]&~S[0]);
    assign H[2] = ~S[1] | S[0] | S[3] | S[2];
    assign H[3] = (~S[2]&S[1]) | (~S[2]&~S[0]) | (S[2]&~S[1]&S[0]) | (S[1]&~S[0]);
    assign H[4] = ~S[0] & (S[1] | S[2]);
    assign H[5] = S[3]| (S[2]&~S[0]) | (~S[1]&~S[3]&S[2]) | (~S[1]&~S[0]&S[3]);
    assign H[6] = S[3] | (S[2]&~S[1]) | (~S[2]&S[1]) | (S[1]&~S[0]);
endmodule
