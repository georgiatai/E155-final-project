// Julia Gong
// 11/14/2025
// decoding frequency for FFT results

module fftdec #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 48000)
               (input logic clk, reset,
                input logic [2*BIT_WIDTH - 1:0] dout, 
                input logic [BIT_WIDTH * 2 - 1:0] fft_result,
				input logic fft_done,
                output logic [BIT_WIDTH:0] frequency,
                output logic note_dec, note_dec_pre);

logic [2*BIT_WIDTH - 1:0] magnitude_sq, magnitude_max;
logic signed [BIT_WIDTH - 1:0] real_v, img;
logic [2*BIT_WIDTH - 1:0] real_sq, img_sq;

// fft output index
logic [N - 1:0] k, k_max, k_delay;

assign real_v = fft_result[2 * BIT_WIDTH - 1:BIT_WIDTH];
assign img = fft_result[BIT_WIDTH - 1:0];

assign real_sq = real_v * real_v;

assign img_sq = img * img;

logic fft_done_d;
always_ff @(posedge clk) begin
	if (~reset) fft_done_d <= 0;
	else        fft_done_d <= fft_done;
end

always_ff @(posedge clk) begin
    if (~reset) begin
        magnitude_sq <= 0;
        magnitude_max <= 0;
        k <= 0;
        k_max <= 0;
		k_delay <= 0;
        frequency <= 0;
        note_dec <= 0;
    end
    else if (fft_done) begin 
		magnitude_sq <= real_sq + img_sq;
        if (magnitude_sq > magnitude_max & k > 9'b1) begin
            magnitude_max <= magnitude_sq;
			k_delay <= k;
            k_max <= k_delay;
			k <= k + 1'b1; 
			note_dec <= 1'b0;
        end
		else if (~fft_done_d) begin
			k <= 1;
			k_max <= k_max;
			k_delay <= 0;
            magnitude_max <= 0;
			magnitude_sq <= 0;
			note_dec <= 1'b0;
			frequency <= frequency;
		end
        else if (k == FFT_SIZE - 1) begin
            frequency <= k_max * FS / FFT_SIZE;
            note_dec <= 1'b1;
            k <= 0;
			k_max <= k_max;
			k_delay <= 0;
            magnitude_max <= 0;
			magnitude_sq <= 0;
        end
		else if (note_dec) begin
			k <= 0;
			k_max <= k_max;
			k_delay <= 0;
            magnitude_max <= 0;
			magnitude_sq <= 0;
			note_dec <= 1'b0;
			frequency <= frequency;
		end
        else begin
			k_delay <= k;
            k <= k + 1'b1;
			note_dec <= 1'b0;
			frequency <= frequency;
        end
    end
    else begin
        note_dec <= 0;
		frequency <= frequency;
    end
end

assign note_dec_pre = fft_done & (k == FFT_SIZE - 1);

endmodule