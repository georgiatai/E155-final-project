// Julia Gong
// 11/8/2025
// This module preforms complex multiply of numbers

module #(parameter BIT_WIDTH = 16)
    (input logic [BIT_WIDTH - 1:0] real_a, img_a, 
     input logic [BIT_WIDTH - 1:0] real_b, img_b, 
     output logic [BIT_WIDTH -1:0] real_cmplx_prod, img_cmplx_prod);

    logic [BIT_WIDTH - 1:0] ra_rb, ra_ib, ia_rb, ia_ib; // variables for multiplication outputs

    // complex multiplication
    multiply #(BIT_WIDTH) mult1(real_a, real_b, ra_rb); // real
    multiply #(BIT_WIDTH) mult2(real_a, img_b, ra_ib); // img
    multiply #(BIT_WIDTH) mult3(img_a, real_b, ia_rb); // img
    multiply #(BIT_WIDTH) mult4(img_a, img_b, ia_ib); // real

    assign real_cmplx_prod = ra_rb - ia_ib;
    assign img_cmplx_prod = ra_ib + ia_ib;


endmodule