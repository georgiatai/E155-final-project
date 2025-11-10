// Julia Gong
// 11/8/2025
// This module preforms complex multiply of numbers

module cmplxmult #(parameter BIT_WIDTH = 16)
    (input logic [BIT_WIDTH - 1:0] real_a, img_a, 
     input logic [BIT_WIDTH - 1:0] real_b, img_b, 
     output logic [BIT_WIDTH -1:0] real_cmplx_prod, img_cmplx_prod);

    logic [BIT_WIDTH - 1:0] ra_rb, ra_ib, ia_rb, ia_ib; // variables for multiplication outputs

    // complex multiplication
    multiply #(.BIT_WIDTH(BIT_WIDTH)) mult1(.a(real_a), .b(real_b), .prod_trunc(ra_rb)); // real
    multiply #(.BIT_WIDTH(BIT_WIDTH)) mult2(.a(real_a), .b(img_b), .prod_trunc(ra_ib)); // img
    multiply #(.BIT_WIDTH(BIT_WIDTH)) mult3(.a(img_a), .b(real_b), .prod_trunc(ia_rb)); // img
    multiply #(.BIT_WIDTH(BIT_WIDTH)) mult4(.a(img_a), .b(img_b), .prod_trunc(ia_ib)); // real

    assign real_cmplx_prod = ra_rb - ia_ib;
    assign img_cmplx_prod = ra_ib + ia_ib;


endmodule