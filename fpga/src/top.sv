// Julia Gong
// 11/11/2025
// top level module that connects all fpga modules
// currently just includes fft, spi

module top #(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512)
            (input logic clk, reset,
             input logic sclk, cs, mosi, // SPI inputs
             output logic miso // SPI output
             );

// fft control logic
logic fft_load, fft_start, fft_done; 
logic [BIT_WIDTH - 1: 0] fft_in;
logic [2*BIT_WIDTH - 1:0] fft_out;
logic [N - 1:0] add_rd;

// spi lgic
logic received_wd;
logic [BIT_WIDTH - 1:0] sample_in;

// RAM buffer logic
logic [BIT_WIDTH - 1:0] fft_in_A, fft_in_B;
logic [N - 1:0] write_idx, read_idx;
logic buff_sel; // 0 for A and 1 for B
logic buffer_full_A, buffer_full_B;
logic write_enable_A, write_enable_B;


ram1p #(.BIT_WIDTH(BIT_WIDTH), .N(N))
    buffer_A(.clk(clk),
             .we(write_enable_A),
             .add(write_idx),
             .din(sample_in),
             .dout(fft_in_A));

ram1p #(.BIT_WIDTH(BIT_WIDTH), .N(N))
    buffer_B(.clk(clk),
             .we(write_enable_B),
             .add(write_idx),
             .din(sample_in),
             .dout(fft_in_B));


// buffer logic to store continuous data
always_ff @(posedge clk, reset) begin
    if (~reset) begin
        buff_sel <= 0;
        write_idx <= 0;
        buffer_full_A <= 0;
        buffer_full_B <= 0;
        write_enable_A <= 0;
        write_enable_B <=0;
    end
    else begin
    write_enable_A <= 0;
    write_enable_B <= 0;
        if (received_wd) begin
            if (~buff_sel & ~buffer_full_A) begin // choose buffer A
                write_enable_A <= 1'b1;
                write_idx <= write_idx + 1'b1;
                    if (write_idx == FFT_SIZE - 1) begin
                        buffer_full_A <= 1'b1;
                        write_idx <= 0;
                        buff_sel <= 1'b1; // switch to buffer B
                    end
                end
            end
            else if (buff_sel & ~buffer_full_B) begin // choose buffer B
                write_enable_B <= 1'b1;
                write_idx <= write_idx + 1'b1;
                    if (write_idx == FFT_SIZE - 1) begin
                            buffer_full_B <= 1'b1;
                            write_idx <= 0;
                            buff_sel <= 0;
                    end
            end
        end
    end


// loading logic into fft
// next state logic
typedef enum logic [3:0] {WAIT, LOAD, DONE} statetype
statetype state, nextstate;
 
always_ff @posedge(clk, reset) begin
    if (~reset) state <= WAIT;
    else state <= nextstate;
end

always_comb begin
    fft_load = 0;
    fft_start = 0;
    read_idx = 0;
        case (state)
            WAIT:
            begin
                if ((buffer_full_A & buff_sel) | (buffer_full_B & ~buff_sel)) begin // choose buffer that is not being written
                    read_idx = 0;
                    nextstate = LOAD;
                end
            end
            LOAD: 
            begin
                fft_load = 1'b1;
                if (read_idx == FFT_SIZE - 1) begin
                    read_idx = 0;
                    fft_load = 1'b0;
                    fft_start = 1'b1;
                    nextstate = DONE;
                end
                else begin
                    read_idx = read_idx + 1'b1;
                end
            end
            DONE:
            begin
                fft_start <= 0;
                if (fft_done) begin
                    if (buff_sel) begin
                        buffer_full_A = 0; // reset buffer A since it was used
                    end
                    else begin // reset buffer B
                        buffer_full_B = 0;
                    end
                nextstate = WAIT;
                end
            end
        endcase
end

assign fft_in = buff_sel ? fft_in_A : fft_in_B; // choose buffer than is not being written to
assign add_rd = read_idx; 

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
    (.sclk(sclk), // divide HOSC for SPI clk
     .cs(cs),
     .mosi(mosi),
     .play_back(play_back),
     .note(note), // needs to be determined in module post fft
     .duration(duration), // needs to be determined in module post ffr
     .miso(miso),
     .received_wd(received_wd),
     .sample_in(sample_in));


endmodule