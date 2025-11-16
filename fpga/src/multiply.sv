// Julia Gong
// 11/8/2025
// this module is the multiply unit and takes 2 N-bit numbers and truncates to produce an N-bit product 
// since multiplication doubles bit length

module multiply #(parameter BIT_WIDTH = 16) // 16 bit multiplication
    (input logic [BIT_WIDTH-1:0] a, b, 
    output logic [BIT_WIDTH-1:0] prod_trunc);

    logic [2*BIT_WIDTH - 1: 0] prod_full; 

    assign prod_full = a * b;
    assign prod_trunc = prod_full[2*BIT_WIDTH - 2: BIT_WIDTH - 1] + prod_full[BIT_WIDTH - 2:0];
    // 2*BIT_WIDTH - 2 takes away sign
    // truncates product by taking 16 MSB + 1 bit for rounding 

endmodule
