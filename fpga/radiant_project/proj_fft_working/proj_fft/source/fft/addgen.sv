// Julia Gong
// 11/1/25
// This module is the address generation unit that:
// 1. creates addresses for reading and writing data in RAM
// 2. gets twiddle factors from RAM? (have separate module that calculates twiddle factors)
// 3. generate write signals for data RAM

module addgen #(parameter BIT_WIDTH = 16, level = 9, FFT_SIZE = 512) // level = log2(512)
              (input logic clk, reset,
			   input logic fft_load,
			   input logic fft_start,
			   input logic bf_enable,
			   input logic [level-1:0] add_rd,
               output logic [level - 1:0]add_a,
               output logic [level - 1:0]add_b,
               output logic [level - 2:0]add_tw_2cyc, // only need 0 - 255
			   output logic [level - 2:0]add_tw, // only need 0 - 255
               output logic mem_write0_out, // write enable for RAM0
               output logic mem_write1_out, // write enable for RAM1
               output logic read_sel, // select rd
               output logic fft_done,
			   output logic bf_upd_enable, bf_cal_enable,
			   output fft_start_posedge
);

// logic for levels and butterflies
logic [level - 1:0] fft_level; // indicies for total of 5 levels
logic [level - 1:0] fft_bf; // indicies for total of 256 butterflies per level
logic [7:0] total_bf; 

// logic for a, b, tw agu
logic [level - 1:0] a, b, tw;
logic [BIT_WIDTH - 1:0] tw_mask;
logic [level - 1:0] add_tw_1cyc;

logic fft_start_d;

// set limit for butterfly index loop 0-255
assign total_bf = 8'b1111_1111;

always_ff @ (posedge clk) begin
	if (~reset) begin
		fft_start_d <= 0;
	end
	else begin
		fft_start_d <= fft_start;
	end
end

assign fft_start_posedge = fft_start & ~fft_start_d;


logic delay_q;
logic delay_w;

always_ff @(posedge clk) begin
    if (~reset) begin
        delay_q <= 1'b0;
		 delay_w <= 1'b1;
    end 
	else if (fft_start_posedge) begin
        delay_q <= 1'b1;
		 delay_w <= 1'b0;
    end 
	else begin
        delay_q <= ~delay_q;
		delay_w <= ~delay_w;
    end
end

assign bf_upd_enable = delay_q;
assign bf_cal_enable = delay_w;


// loops through each of the levels and butterflies
always_ff @(posedge clk) begin
	if (~reset | (add_rd == 9'h1ff && fft_load)) begin
		fft_level <= 0;
		fft_bf <= 0;
	end
	else if (bf_enable & ~fft_done) begin // begin fft
		if (bf_upd_enable) begin 
			if (fft_bf < total_bf) begin // increment butterfly element every 2 cycles
				fft_bf <= fft_bf + 1'b1;
			end
			else begin // reaches end of the level
				fft_bf <= 0; // reset butterfly index to 0
				fft_level <= fft_level + 1'b1; // increment level
			end
		end
	end
end

// address generation logic for A, B, and TW
// address generation unit for {m, n} pair, m is address of A factor and n is address of B factor
// where m = Rotate_N(2j, i) and n = Rotate_N(2j+1, i)
    always_comb begin
        a = fft_bf << 1'b1; // multiply bf index by 2
        b = a + 1'b1; 

        // rotate by fft_level
        add_a = (a << fft_level) | (a >> (level - fft_level)); 
        add_b = (b << fft_level) | (b >> (level - fft_level));

        // generate tw add by masking out (N - 1 - fft_level) least significant bits of bf index
        tw_mask = {8'hff, 8'b0} >>> fft_level; // shift dependent on level
        // this masking ensures that at level 0, tw = 1_0000_0000 and add_tw = 0000_0000
        // add_tw corresponds to address on twiddleLUT.sv
        tw = tw_mask & fft_bf; // masking with butterfly index to generate tw address
        add_tw = tw[level - 2: 0];
    end

// needs to finish level - 1 (8 in our case), then increment to next level after completion
assign fft_done = (fft_level == level) & ~fft_load; 

// assign register/mem_write
// switches between RAM0 and RAM1 every level, starts with selecting RAM0
assign read_sel = fft_load ? 1'b1: fft_level[0]; // fix read/write issue
// only write when fft agu is occurring

logic mem_write0, mem_write1;
assign mem_write0 = (fft_level[0] & bf_enable); 
assign mem_write1 = (~fft_level[0] & bf_enable);
 
 
logic memwrite0_1cyc, memwrite0_2cyc;
logic memwrite1_1cyc, memwrite1_2cyc;


always_ff @(posedge clk) begin
	if (~reset) begin
		memwrite0_1cyc <= 0;
		memwrite0_2cyc <= 0;
		memwrite1_1cyc <= 0;
		memwrite1_2cyc <= 0;
		add_tw_1cyc <= 0;
		add_tw_2cyc <= 0;
	end else if (bf_enable) begin
		memwrite0_1cyc <= mem_write0;
		memwrite0_2cyc <= memwrite0_1cyc;
		memwrite1_1cyc <= mem_write1;
		memwrite1_2cyc <= memwrite1_1cyc;
		add_tw_1cyc <= add_tw;
		add_tw_2cyc <= add_tw_1cyc;
	end
	else begin
		memwrite0_1cyc <= 0;
		memwrite0_2cyc <= 0;
		memwrite1_1cyc <= 0;
		memwrite1_2cyc <= 0;
		add_tw_1cyc <= 0;
		add_tw_2cyc <= 0;
	end
end

assign mem_write0_out = (bf_enable) ? memwrite0_2cyc : mem_write0;
assign mem_write1_out = (bf_enable) ? memwrite1_2cyc : mem_write1;

endmodule