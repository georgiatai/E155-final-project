// Julia Gong
// 11/12/2025
// module for one port RAM for storing data

module ram1p #(parameter BIT_WIDTH = 16, N = 9)
              (input logic clk, 
               input logic we,
               input logic [N - 1:0] add,
               input logic [2*BIT_WIDTH - 1:0] din,
               output logic [2*BIT_WIDTH - 1:0] dout);

logic [BIT_WIDTH - 1:0] mem[2**N - 1:0];

always_ff @(posedge clk)
    if (we) begin
        mem[add] <= din;
    end
assign dout = mem[add];

endmodule
