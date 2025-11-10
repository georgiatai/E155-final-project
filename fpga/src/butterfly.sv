// Julia Gong
// 11/1/25
// Module for butterfly operation
// takes in 2 complex 16 bit numbers and performs 4 multiplies and add/subtract operations

module butterfly #(parameter BIT_WIDTH = 16)
                (input logic clk, reset, 
                 input logic [BIT_WIDTH - 1:0] real_a, real_b, // input data A/B real
                 input logic [BIT_WIDTH - 1:0] img_a, img_b,   // input data A/B img
                 input logic [BIT_WIDTH - 1:0] real_tw, img_tw, // input data twiddle real/img
                 output logic [BIT_WIDTH - 1:0] real_ap, real_bp, // output data A'/B' real
                 output logic [BIT_WIDTH - 1:0] img_ap, img_bp    // output data A'/B' img
    );

logic [31:0] real_btw, img_btw; // intemediate B*TW real/img values

// main butterfly computation:
// A' = A + B(TW)
// B' = A - B(TW)

// complex multiplication to calculate B*TW, each uses 2 8 bit multipliers
cmplxmult #(.BIT_WIDTH(BIT_WIDTH)) 
tw_mult(.real_a(real_b), 
        .img_a(img_b), 
        .real_b(real_tw), 
        .img_b(img_tw), 
        .real_cmplx_prod(real_btw), 
        .img_cmplx_prod(img_btw));

// complex adds for A' and B'
// signed integer multiplication procudes redundant signed bits in product, so preserve bits [30;15]
// A'
real_ap = real_a + real_btw;
img_ap = img_a + img_btw;

// B'
real_bp = real_a - real_btw;
img_bp  = img_a - img_btw;

endmodule
