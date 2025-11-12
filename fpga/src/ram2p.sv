// Julia Gong
// 11/8/2025
// two port RAM for storing bf addresses

module ram2p #(parameter BIT_WIDTH = 16, N = 9)
            (input logic clk,
             input logic we,
             input logic [N - 1:0] add_a, add_b,
             input logic [BIT_WIDTH - 1:0] real_din_a, img_din_a,
             input logic [BIT_WIDTH - 1:0] real_din_b, img_din_b,
             output logic [2*BIT_WIDTH - 1:0] dout_a, dout_b);

// depth of 2^(N-1) x width of [2*BIT_WIDTH - 1:0]
logic [2*BIT_WIDTH - 1:0] mem[2**N-1:0];

always_ff @(posedge clk)
    if (we) begin
        mem[add_a] <= {real_din_a, img_din_a};
        mem[add_b] <= {real_din_b, img_din_b};
    end

assign dout_a = mem[adr_a];
assign dout_b = mem[adr_b];

endmodule