// Julia Gong
// 11/11/2025
// top level module that connects all fpga modules
// currently just includes fft, spi

module top #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512)
            (input logic clk, reset,
             input logic sclk, cs, mosi, // SPI inputs
             output logic mosi // SPI output
             );

// logic for initial load
logic fft_load, fft_start, received_wd, buff_ready;
logic [N - 1:0] add_rd;
logic [BIT_WIDTH - 1:0] sample_in; // input from SPI
logic [BIT_WIDTH - 1:0] fft_in;

// fft logic
logic [2*BIT_WIDTH - 1:0] fft_out;

// buffers to store continuous 16 bit inputs from SPI 
logic buff_en, buffa_en, buffb_en; // selects buffer, 0 - A and 1 - B
logic [N - 1:0] buff_idx; // buffer index
ram1p #(.BIT_WIDTH(BIT_WIDTH), .N(N))
    buffer_A(.clk(clk),
             .we(buffa_en),
             .add(buff_idx),
             .din(sample_in),
             .dout(fft_in_A));

ram1p #(.BIT_WIDTH(BIT_WIDTH), .N(N))
    buffer_B(.clk(clk),
             .we(buffb_en),
             .add(buff_idx),
             .din(sample_in),
             .dout(fft_in_B));


assign buff_en = 0; // starts to choose buffer_A
// buffer logic to store continuous data
always_ff @(posedge clk, reset)
    if (~reset) begin
        buff_en <= 0;
        buff_idx <= 0;
        buff_ready <= 0;
    end
    else if (received_wd) begin
        if (~buff_en & ~fft_done) begin
            buffa_en <= 1'b1;
        end
        else if (buff_en & ~fft_done) begin
            buffb_en <= 1'b1
        end
        if (buff_idx == FFT_SIZE - 1) begin
            buff_en <= ~buff_en;
            buff_idx <= 0;
            buff_ready <= 1'b1;
        end
        else begin
            buff_idx <= buff_idx + 1'b1; // increment index
            buff_ready <= 0;
        end
    end
// busy when ~fft_done
// load data when fft is ~ busy

// loading logic into fft
always_ff @(posedge clk, reset) 
    if (~reset) begin
        fft_load <= 0;
        fft_start <= 0;
        add_rd <= 0;
    end
    else if (buff_ready) begin// buffer full so start loading
        fft_load <= 1'b1;
        add_rd <= add_rd + 1'b1;
    else if (add_rd == 10'b10_0000_0000) // 512
        fft_load <= 0;
        fft_start <= 1'b1;
        add_rd <= 0; // reset index count to get ready for next fft
    end

assign fft_in = buff_en ? fft_in_B : fft_in_A;

fft #(.BIT_WIDTH(BIT_WIDTH), .N(N))
     (.clk(clk),
      .reset(reset),
      .fft_start(fft_start),
      .fft_load(fft_load),
      .add_rd(add_rd), // index of input sample, determined by SPI transaction
      .din(fft_in),
      .dout(fft_out),
      .fft_done(fft_done));

// load fft output data into buffer to process

spi #(.BIT_WIDTH(BIT_WIDTH))
    (.(sclk), // divide HOSC for SPI clk
     .cs(cs),
     .mosi(mosi),
     .play_back(play_back),
     .note(note), // needs to be determined in module post fft
     .duration(duration), // needs to be determined in module post ffr
     .miso(miso),
     .received_wd(received_wd),
     .sample_in(sample_in));


endmodule