// Julia Gong
// 11/8/2025
// main module for fft computation

module fft #(parameter BIT_WIDTH = 16, N = 9)
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

// A and B complex/real
logic [2*BIT_WIDTH - 1:0] write_a, write_b, out_a, out_b;
logic [BIT_WIDTH - 1:0] real_write_a, img_write_a, real_write_b, img_write_b;

// bufferfly real/img
logic [BIT_WIDTH - 1:0] real_a, img_a, real_b, img_b; // butterfly inputs
logic [BIT_WIDTH - 1:0] real_ap, img_ap, real_bp, img_bp; // butterfly outputs

// twiddle
logic [N - 2:0] add_tw; // twiddle address
logic [BIT_WIDTH - 1:0] real_tw, img_tw;

// load initial data, otherwise take outputs from RAM
assign write_a = fft_load ? din : out_a;
assign write_b = fft_load ? din : out_b;
// split into real and imaginary components
assign real_write_a = write_a[2*BIT_WIDTH - 1: BIT_WIDTH]; // bits 31-16
assign img_write_a = write_a[BIT_WIDTH - 1:0]; // bits 15-0
assign real_write_b = write_b[2*BIT_WIDTH - 1: BIT_WIDTH]; // bits 31-16
assign img_write_b = write_b[BIT_WIDTH - 1:0]; // bits 15-0


// BFU memory ping pong logic
// read_sel is dependent on LSB of fft level, so at level 0, read_sel = 0
// at level 0, will be writing to RAM1 and reading from RAM0
// so read from RAM0 when read_sel = 0 and RAM1 when read_sel = 1
// imaginary and real values
assign real_a = (read_sel ? r1_out_a : r0_out_a)[2*BIT_WIDTH - 1 : BIT_WIDTH];
assign img_a  = (read_sel ? r1_out_a : r0_out_a)[BIT_WIDTH - 1 : 0];
assign real_b = (read_sel ? r1_out_b : r0_out_b)[2*BIT_WIDTH - 1 : BIT_WIDTH];
assign img_b  = (read_sel ? r1_out_b : r0_out_b)[BIT_WIDTH - 1 : 0];



// two port RAM0 and RAM1
ram2p #(.BIT_WIDTH(BIT_WIDTH),.N(N)) 
ram0 (.clk(clk),
      .we(mem_write0),
      .add_a(r0_add_a),
      .add_b(r0_add_b),
      .real_din_a(real_write_a),
      .img_din_a(img_write_a),
      .real_din_b(real_write_b),
      .img_din_b(img_write_b),
      .dout_a(r0_out_a),
      .dout_b(r0_out_b));

ram2p #(.BIT_WIDTH(BIT_WIDTH),.N(N)) 
ram1 (.clk(clk),
      .we(mem_write1),
      .add_a(r1_add_a),
      .add_b(r1_add_b),
      .real_din_a(real_ap),
      .img_din_a(img_ap),
      .real_din_b(real_bp),
      .img_din_b(img_bp),
      .dout_a(r1_out_a),
      .dout_b(r1_out_b));

// twiddle LUT
twiddleLUT twiddle_lut (
    .clk(clk),
    .reset(reset),
    .tw_add(add_tw),
    .real_tw(real_tw),
    .img_tw(img_tw));

// fft control unit
addctrl #(.BIT_WIDTH(BIT_WIDTH),.N(N)) 
addctrl_inst (
    .clk(clk),
    .reset(reset),
    .fft_start(fft_start),
    .fft_load(fft_load),
    .add_rd(add_rd),
    .r0_add_a(r0_add_a),
    .r0_add_b(r0_add_b),
    .r1_add_a(r1_add_a),
    .r1_add_b(r1_add_b),
    .add_tw(add_tw),
    .mem_write0(mem_write0),
    .mem_write1(mem_write1),
    .read_sel(read_sel),
    .fft_done(fft_done));

// butterfly unit
butterfly #(.BIT_WIDTH(BIT_WIDTH)) 
butterfly_inst (
    .clk(clk),
    .reset(reset),
    .real_a(real_a),
    .real_b(real_b),
    .img_a(img_a),
    .img_b(img_b),
    .real_tw(real_tw),
    .img_tw(img_tw),
    .real_ap(real_ap),
    .real_bp(real_bp),
    .img_ap(img_ap),
    .img_bp(img_bp));

// BIT_WIDTH*2 bit butterfly outputs
assign out_a = {real_ap, img_ap}; 
assign out_b = {real_bp, img_bp};

// output ping pong logic for where data is stored in RAM0 or RAM1, dependent on number of levels N
// if N levels are odd, then data in RAM1 since starts writing to RAM1 at level 0
// if N levels are even, data in RAM0
assign dout = (N % 2) ? r1_out_a : r0_out_a;

endmodule