// Julia Gong
// 11/14/2025
// module that does the full calculation
// takes sampled inputs into fft module
// determines frequency from maximum magnitude of fft outputs
// decodes the note from frequency

module fftfull #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 48000)
                (input logic clk, reset,
				 input logic fft_load, fft_start,
				 input logic [7:0] din,
                 input logic [N - 1:0] add_rd,
                 output logic [7:0] note,
				  output logic fft_done, 
				  output note_dec, 
				  output note_dec_pre,
				  output [N-1:0] note_count);
				 
// fft logic
logic [2*BIT_WIDTH - 1:0] dout;

// fftdec logic
logic [BIT_WIDTH:0] frequency;

fft #(.BIT_WIDTH(BIT_WIDTH), .N(N), .FFT_SIZE(FFT_SIZE))
    fft(.clk(clk),
        .reset(reset),
        .fft_start(fft_start),
        .fft_load(fft_load),
        .add_rd(add_rd),
        .din(din),
        .dout(dout),
        .fft_done(fft_done));

fftdec #(.BIT_WIDTH(BIT_WIDTH), .N(N), .FFT_SIZE(FFT_SIZE), .FS(FS))
    fftdec(.clk(clk),
           .reset(reset),
           .dout(dout),
           .fft_result(dout),
		   .fft_done(fft_done),
           .frequency(frequency),
           .note_dec(note_dec),
		   .note_dec_pre(note_dec_pre));

freqLUT #(.BIT_WIDTH(BIT_WIDTH))
    freqLUT(.frequency(frequency),
            .note(note));

logic [7:0] prev_note;
logic [N - 1:0] note_cnt;

always_ff @(posedge clk) begin
	if (~reset) begin
		note_cnt <= 0;
		prev_note <= 0;
	end
	else if (note_dec) begin
		prev_note <= note;
	end
	else if (note == prev_note) begin
		note_cnt <= note_cnt + 1'b1;
	end
	else if (note != prev_note) begin
		note_cnt <= 0;
	end
end

assign note_count = note_cnt;
endmodule