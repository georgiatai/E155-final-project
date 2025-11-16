// Julia Gong
// 11/14/2025
// decoding frequency for FFT results

module fftdec #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 48000)
               (input logic clk, reset,
                input logic fft_done, 
                input logic [BIT_WIDTH * 2 - 1:0] fft_result,
                output logic [BIT_WIDTH:0] frequency,
                output logic note_dec);

logic [BIT_WIDTH - 1:0] magnitude_sq, magnitude_max, real_v, img;
logic [BIT_WIDTH - 1:0] real_sq, img_sq;

// fft output index
logic [N - 1:0] k, k_max;

assign real_v = fft_result[2 * BIT_WIDTH - 1:BIT_WIDTH];
assign img = fft_result[BIT_WIDTH - 1:0];

multiply #(.BIT_WIDTH(BIT_WIDTH))
  mag_real(.a(real_v),
           .b(real_v),
           .prod_trunc(real_sq));

multiply #(.BIT_WIDTH(BIT_WIDTH))
   mag_img(.a(img),
           .b(img),
           .prod_trunc(img_sq));

always_ff @(posedge clk) begin
    if (~reset) begin
        magnitude_sq <= 0;
        magnitude_max <= 0;
        k <= 0;
        k_max <= 0;
        frequency <= 0;
        note_dec <= 0;
    end
    else if (fft_done) begin 
		magnitude_sq <= real_sq + img_sq;
        if (magnitude_sq > magnitude_max) begin
            magnitude_max <= magnitude_sq;
            k_max <= k;
        end
        else if (k == FFT_SIZE - 1) begin
            frequency <= k_max * FS / FFT_SIZE;
            note_dec <= 1'b1;
            k <= 0;
            magnitude_max <= 0;
        end
        else begin
            k <= k + 1'b1;
        end
    end
    else begin
        note_dec <= 0;
    end
end


endmodule
