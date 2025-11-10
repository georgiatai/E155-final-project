// Julia Gong
// 11/8/2025
// this module controls the input data writes and output data reads from RAM0 and RAM1

module addctrl #(parameter BIT_WIDTH = 16, N = 9)
                (input logic clk, reset,
                 input logic fft_start,
                 input logic fft_load,
                 input logic [N - 1: 0] add_rd, // register address
                 output logic [N - 1:0]r0_add_a, r0_add_b, // RAM0 A and B ports
                 output logic [N - 1:0]r1_add_a, r1_add_b, // RAM1 A and B ports
                 output logic [N - 2:0]add_tw, // only need 0 - 255
                 output logic mem_write0, // write enable for RAM0
                 output logic mem_write1, // write enable for RAM1
                 output logic read_sel, // register sel
                 output logic fft_done);

logic fft_enable;
logic add_a, add_b; // addresses for A and B
logic agu_mem_write0; // write enable bit from agu
logic [N-1] add_bitrev; // bit reversed address
logic [N-1] fft_idx; 

// enable signal for start of fft
always_ff@(posedge clk, reset) begin
        if (reset) fft_enable <= 0;
        else if (fft_start) fft_enable <= 1'b1;
        else if (fft_done) fft_enable <= 0;
    end

// address generation
addgen #(BIT_WIDTH, N) addgen(.clk(clk), .reset(reset), .fft_enable(fft_enable), .add_a(add_a), .add_b(add_b), .add_tw(add_tw), .mem_write0(agu_mem_write0), .mem_write1(mem_write_1), .read_sel(read_sel), .fft_done(fft_done));

// bit reverse
bitrev #(N) bitrev(.bit_norm(add_rd), .bit_rev(add_bitrev));

// fft_done signal which will be used to determine index of fft calculated
always_ff @(posedge clk, reset) begin
    if (reset) fft_idx <= 0;
    else if (fft_done) fft_idx <= fft_idx + 1'b1;
end

// logic for reading and writing out of memory
// write to RAM0 when initially loading input data OR RAM0 enabled from fft_agu
assign mem_write0 = load | agu_mem_write0; 
// RAM0: output counter during DONE, use bit reversed addresses during LOAD, and addresses from AGU otherwise
assign r0_add_a = fft_done ? fft_idx : (fft_load ? add_bitrev : add_a);
assign r0_add_b = fft_load ? add_bitrev : add_b;
// RAM1: use output counter during DONE, and addresses from AGU otherwise
assign r1_add_a = fft_done ? fft_idx : add_a;
assign r1_add_b = add_b;

endmodule