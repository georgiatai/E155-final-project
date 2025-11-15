// Julia Gong
// 11/14/2025
// module that does the full calculation
// takes sampled inputs into fft module
// determines frequency from maximum magnitude of fft outputs
// decodes the note from frequency

module fftfull #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 48000)
                (input logic clk, reset,
                 input logic fft_start, 
                 input logic fft_load,
                 input logic [N - 1:0] add_rd,
                 input logic [BIT_WIDTH - 1:0] din,
                 output logic [9:0] note);

// fft logic
logic [2*BIT_WIDTH - 1:0] dout;
logic fft_done;

// fftdec logic
logic [BIT_WIDTH:0] frequency;
logic note_dec;

fft #(.BIT_WIDTH(BIT_WIDTH), .N(N))
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
           .fft_done(fft_done),
           .fft_result(dout),
           .frequency(frequency),
           .note_dec(note_dec));

freqLUT #(.BIT_WIDTH(BIT_WIDTH))
    freqLUT(.frequency(frequency),
            .note(note));

endmodule
