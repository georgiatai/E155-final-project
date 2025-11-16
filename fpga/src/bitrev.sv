// Julia Gong
// 11/8/2025
// this module reverses the bit indicies such that the inputs can be ordered properly into butterfly operations

module bitrev #(parameter N = 9) // M = 9 since log2(512) = 9
        (input logic [N-1:0] bit_norm,
         output logic [N-1:0] bit_rev);

    genvar b; // generating variable b to increment through each bit of the input

    generate for (b = 0; b < N; b = b + 1) begin: bit_reversed //creates block bit_reversed that connects input bit to output bit
        assign bit_rev[b] = bit_norm[N - 1 - b]; // bit reversing logic
    end
    endgenerate

endmodule
