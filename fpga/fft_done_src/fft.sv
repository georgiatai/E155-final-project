// Julia Gong
// 11/8/2025
// main module for fft computation

module fft #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512)
            (input logic clk, reset,
             input logic fft_start, // start fft once data finishes loading
             input logic fft_load, 
             input logic [N - 1:0] add_rd, // index of input sample
             input logic [7:0] din, // 16 bit real number
             output logic [2*BIT_WIDTH - 1:0] dout, // complex number
             output logic fft_done);

// RAM
logic read_sel; // select to read from RAM0 or RAM1
logic mem_write0, mem_write1; // mem write enable
logic [N - 1:0] r0_add_a, r0_add_b, r1_add_a, r1_add_b; // A and B ports addresses for RAM0 and RAM1
logic [2*BIT_WIDTH - 1:0] r0_out_a, r0_out_b, r1_out_a, r1_out_b;
logic [2*BIT_WIDTH - 1:0] r0_out_a_new, r0_out_b_new, r1_out_a_new, r1_out_b_new;
logic [2*BIT_WIDTH - 1:0] r0_out_a_hold, r0_out_b_hold, r1_out_a_hold, r1_out_b_hold;

// A and B complex/real
logic [2*BIT_WIDTH - 1:0] write_a, write_b, out_a, out_b, din_cmplx;
logic [BIT_WIDTH - 1:0] real_write_a, img_write_a, real_write_b, img_write_b;

// bufferfly real/img
logic [2*BIT_WIDTH - 1:0] a, b;
logic [BIT_WIDTH - 1:0] real_a, img_a, real_b, img_b; // butterfly inputs
logic [BIT_WIDTH - 1:0] real_ap, img_ap, real_bp, img_bp; // butterfly outputs

// twiddle
logic [N - 2:0] add_tw; // twiddle address
logic [BIT_WIDTH - 1:0] real_tw, img_tw;

// load initial data, otherwise take outputs from RAM
assign din_cmplx = {8'b0, din, 16'b0};
assign write_a = fft_load ? din_cmplx : out_a;
assign write_b = fft_load ? din_cmplx : out_b;
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

logic delay, delay_1cyc, delay_2cyc;
always_ff @(posedge clk) begin
	if (~reset) begin
		delay_1cyc <= 0;
		delay_2cyc <= 0;
	end
	else begin
		delay_1cyc <= read_sel;
		delay_2cyc <= delay_1cyc;
	end
end

assign delay = delay_2cyc;

logic bf_enable;
logic [N - 1:0] bf_count;
logic [N - 2:0] add_tw_2cyc;


always_ff @(posedge clk) begin
	if (~reset | fft_load) begin
		bf_enable <= 0;
		bf_count <= 0;
	end
	else if (fft_start) begin
		bf_count <= bf_count + 1'b1;
		if (bf_count >= 9'b1) begin
			bf_enable <= 1'b1;
		end
	end
end

logic [N - 1:0] r0_add_a_d1, r0_add_b_d1, r1_add_a_d1, r1_add_b_d1;
logic [N - 1:0] r0_add_a_d2, r0_add_b_d2, r1_add_a_d2, r1_add_b_d2;
logic [N - 1:0] r0_add_a_wr, r0_add_b_wr, r1_add_a_wr, r1_add_b_wr;
logic [N - 1:0] r0_add_a_rd, r1_add_a_rd;


always_ff @(posedge clk) begin
	if (~reset) begin
		r0_add_a_d1 <= 0;
		r0_add_b_d1 <= 0;
		r1_add_a_d1 <= 0;
		r1_add_b_d1 <= 0;
		r0_add_a_d2 <= 0;
		r0_add_b_d2 <= 0;
		r1_add_a_d2 <= 0;
		r1_add_b_d2 <= 0;
	end else if (bf_enable) begin
		r0_add_a_d1 <= r0_add_a;
		r0_add_b_d1 <= r0_add_b;
		r1_add_a_d1 <= r1_add_a;
		r1_add_b_d1 <= r1_add_b;
		r0_add_a_d2 <= r0_add_a_d1;
		r0_add_b_d2 <= r0_add_b_d1;
		r1_add_a_d2 <= r1_add_a_d1;
		r1_add_b_d2 <= r1_add_b_d1;
	end
end

logic bf_upd_enable, bf_cal_enable;

assign r0_add_a_wr = (fft_load) ? r0_add_a : r0_add_a_d2;
assign r0_add_b_wr = (fft_load) ? r0_add_b : r0_add_b_d2;
assign r1_add_a_wr = (fft_load) ? r1_add_a : r1_add_a_d2;
assign r1_add_b_wr = (fft_load) ? r1_add_b : r1_add_b_d2;

assign r0_add_a_rd = (bf_upd_enable) ? r0_add_a : ((fft_done) ? r0_add_a : r0_add_b);
assign r1_add_a_rd = (bf_upd_enable) ? r1_add_a : ((fft_done) ? r1_add_a : r1_add_b);

assign r0_out_a_new = (add_tw_2cyc >= 9'h80) ? r0_out_b : r0_out_a;
assign r0_out_b_new = (add_tw_2cyc >= 9'h80) ? r0_out_b : r0_out_a;
assign r1_out_a_new = (add_tw_2cyc >= 9'h80) ? r1_out_b : r1_out_a;
assign r1_out_b_new = (add_tw_2cyc >= 9'h80) ? r1_out_b : r1_out_a;

always_ff @(posedge clk) begin
	if (~reset) begin
		r0_out_a_hold <= 0;
		r1_out_a_hold <= 0;
	end
	else if (bf_cal_enable) begin
		r0_out_a_hold <= r0_out_a_new;
		r1_out_a_hold <= r1_out_a_new;
	end
end

assign a = (delay_2cyc ? r1_out_a_hold : r0_out_a_hold);
assign b = (delay_2cyc ? r1_out_b_new : r0_out_b_new);
assign real_a = a[2*BIT_WIDTH - 1:BIT_WIDTH];
assign img_a = a[BIT_WIDTH - 1:0];
assign real_b = b[2*BIT_WIDTH - 1:BIT_WIDTH];
assign img_b = b[BIT_WIDTH - 1:0];

	

// RAM0 and RAM1 FOR BF INPUT A
ramdualpt ram0_a_bfa(.wr_clk_i(clk), 
				.rd_clk_i(clk), 
				.rst_i(~reset), 
				.wr_clk_en_i(reset), 
				.rd_en_i(~read_sel), 
				.rd_clk_en_i(reset), 
				.wr_en_i((mem_write0)), 
				.wr_data_i({real_write_a, img_write_a}), 
				.wr_addr_i(r0_add_a_wr), 
				.rd_addr_i(r0_add_a_rd), 
				.rd_data_o(r0_out_a));

ramdualpt ram0_b_bfa(.wr_clk_i(clk), 
				.rd_clk_i(clk), 
				.rst_i(~reset), 
				.wr_clk_en_i(reset), 
				.rd_en_i(~read_sel), 
				.rd_clk_en_i(reset), 
				.wr_en_i((mem_write0)), 
				.wr_data_i({real_write_b, img_write_b}), 
				.wr_addr_i(r0_add_b_wr), 
				.rd_addr_i(r0_add_a_rd), 
				.rd_data_o(r0_out_b));

ramdualpt ram1_a_bfa(.wr_clk_i(clk), 
				.rd_clk_i(clk), 
				.rst_i(~reset), 
				.wr_clk_en_i(reset), 
				.rd_en_i(read_sel), 
				.rd_clk_en_i(reset), 
				.wr_en_i((mem_write1)), 
				.wr_data_i({real_write_a, img_write_a}), 
				.wr_addr_i(r1_add_a_wr), 
				.rd_addr_i(r1_add_a_rd), 
				.rd_data_o(r1_out_a));

ramdualpt ram1_b_bfa(.wr_clk_i(clk), 
				.rd_clk_i(clk), 
				.rst_i(~reset), 
				.wr_clk_en_i(reset), 
				.rd_en_i(read_sel), 
				.rd_clk_en_i(reset), 
				.wr_en_i((mem_write1)), 
				.wr_data_i({real_write_b, img_write_b}), 
				.wr_addr_i(r1_add_b_wr), 
				.rd_addr_i(r1_add_a_rd), 
				.rd_data_o(r1_out_b));


// twiddle LUT
twiddleLUT twiddle_lut (
    .tw_add(add_tw_2cyc),
    .real_tw(real_tw),
    .img_tw(img_tw));


// fft control unit
addctrl #(.BIT_WIDTH(BIT_WIDTH),.N(N), .FFT_SIZE(FFT_SIZE)) 
addctrl_inst (
    .clk(clk),
    .reset(reset),
    .fft_start(fft_start),
    .fft_load(fft_load),
	.bf_enable(bf_enable),
    .add_rd(add_rd),
    .r0_add_a(r0_add_a),
    .r0_add_b(r0_add_b),
    .r1_add_a(r1_add_a),
    .r1_add_b(r1_add_b),
	.add_tw_2cyc(add_tw_2cyc),
    .add_tw(add_tw),
    .mem_write0(mem_write0),
    .mem_write1(mem_write1),
    .read_sel(read_sel),
    .fft_done(fft_done),
    .bf_upd_enable(bf_upd_enable),
    .bf_cal_enable(bf_cal_enable));

// butterfly unit
butterfly #(.BIT_WIDTH(BIT_WIDTH)) 
butterfly_inst (
    .clk(clk),
    .reset(reset),
	.bf_enable(bf_enable),
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
// assign dout = (fft_done) ? ((N % 2) ? r1_out_aa : r0_out_aa) : 32'b0;
assign dout = (fft_done) ? ((r1_add_a <= 9'd255) ? r1_out_a : r1_out_b): 32'b0;


endmodule