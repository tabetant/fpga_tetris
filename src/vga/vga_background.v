`default_nettype none

module vga_background(
    input  wire       CLOCK_50,
    input  wire [3:0] KEY,
    output wire [9:0] LEDR,
    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK
);

    localparam nX = 10;
    localparam nY = 9;

    wire [8:0]    color = 9'd0;
    wire [nX-1:0] X     = {nX{1'b0}};
    wire [nY-1:0] Y     = {nY{1'b0}};
    wire          write = 1'b0;

    vga_adapter VGA (
        .resetn   (KEY[0]),
        .clock    (CLOCK_50),
        .color    (color),
        .x        (X),
        .y        (Y),
        .write    (write),
        .VGA_R    (VGA_R),
        .VGA_G    (VGA_G),
        .VGA_B    (VGA_B),
        .VGA_HS   (VGA_HS),
        .VGA_VS   (VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N (VGA_SYNC_N),
        .VGA_CLK    (VGA_CLK)
    );
    defparam VGA.RESOLUTION       = "640x480";
    defparam VGA.COLOR_DEPTH      = 9;
    defparam VGA.BACKGROUND_IMAGE = "./MIF/bmp_640_9.mif";

endmodule
