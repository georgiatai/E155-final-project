// Julia Gong
// 11/8/2025
// main module for fft computation

module fft #(BIT_WIDTH = 16, N = 9)
            (input logic clk, reset,
             input logic fft_start, // start fft once data finishes loading
             input logic fft_load, 
             input logic [N - 1:0] add_rd, // register address
             input logic [2*BIT_WIDTH - 1:0] din, // complex number
             output logic [2*BIT_WIDTH - 1:0] dout, // complex number
             output logic fft_done
             );

// RAM
logic read_sel; // select to read from RAM0 or RAM1
logic mem_write0, mem_write1; // mem write enable
logic [N - 1:0] r0_add_a, r0_add_b, r1_add_a, r1_add_b; // A and B ports addresses for RAM0 and RAM1
logic [2*BIT_WIDTH - 1:0] r0_out_a, r0_out_b, r1_out_a, r1_out_b;
logic [2*BIT_WIDTH - 1:0] r0_a, r0_b, r1_a, r1_b; // A and B port values for RAM0 and RAM1

// A and B complex/real
logic [2*BIT_WIDTH - 1:0] write_a, write_b, out_a, out_b;
logic [BIT_WIDTH - 1:0] real_write_a, img_write_a, real_write_b, img_write_b;
logic [BIT_WIDTH - 1:0] real_out_a, img_out_a, real_out_b, img_out_b;

// bufferfly real/img
logic [2*BIT_WIDTH - 1:0] a, b;
logic [BIT_WIDTH - 1:0] real_a, img_a, real_b, img_b, real_ap, img_ap, real_bp, img_bp,

// twiddle
logic [N - 2:0] add_tw; // twiddle address
logic [BIT_WIDTH - 1:0] real_tw, img_tw;

// load initial data, otherwise take outputs from RAM
assign write_a = fft_load ? din : out_a;
assign write_b = fft_load ? din : out_b;
// split into real and imaginary components
assign real_write_a = write_a

// two port RAM0 and RAM1
ram2p (BIT_WIDTH, N) ram0(.clk(clk), .we(mem_write0), .add_a(r0_add_a), .add_b(r0_add_b), .real_din_a(real_write_a), .img_din_a(img_write_a), .real_din_b(real_write_b), img_din_b(img_write_b), .dout_a(r0_out_a), .dout_b(r0_out_b));
ram2p (BIT_WIDTH, N) ram1(.clk(clk), .we(mem_write1), .add_a(r1_add_a), .add_b(r1_add_b), .real_din_a(real_out_a), .img_din_a(img_out_a), .real_din_b(real_out_b), img_din_b(img_out_b), .dout_a(r1_out_a), .dout_b(r1_out_b));


// twiddle LUT
twiddleLUT (.clk(clk), .reset(reset), .tw_add(add_tw), .real_tw(real_tw), .img_tw(img_tw));

// fft control unit

// butterfly unit
assign real_a = out_a[BIT_WIDTH - 1: ];
assign img_a = out_a[BIT_WIDTH - :0];
assign real_b = out_a[BIT_WIDTH - 1: ];
assign img_b = out_a[BIT_WIDTH - :0];
butterfly (BIT_WIDTH) butterfly(.clk(clk), .reset(reset), .real_a(real_a), .real_b(real_b), .img_a(img_a), .img_b(img_b), .real_tw(real_tw), .img_tw(img_tw), .real_ap(real_ap), .real_bp(real_bp), .img_ap(img_ap), .img_bp(img_bp));

endmodule