`timescale 1ns/1ps

module fftdec_tb;

    // Parameters
    parameter BIT_WIDTH = 16;
    parameter N = 9;
    parameter FFT_SIZE = 512;
    parameter FS = 48000;

    // Clock and reset
    logic clk, reset;

    // Inputs to fftdec
    logic fft_done;
    logic [2*BIT_WIDTH-1:0] fft_result;

    // Outputs from fftdec
    logic [BIT_WIDTH:0] frequency;
    logic note_dec;

    // Internal
    integer i;
    integer input_file;
    integer ret;
    logic [2*BIT_WIDTH-1:0] fft_data [0:FFT_SIZE-1];

    // Instantiate fftdec
    fftdec #(.BIT_WIDTH(BIT_WIDTH), .N(N), .FFT_SIZE(FFT_SIZE), .FS(FS))
        dut (.clk(clk),
             .reset(reset),
             .fft_done(fft_done),
             .fft_result(fft_result),
             .frequency(frequency),
             .note_dec(note_dec));

    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end

    // Read FFT expected file
    initial begin
        input_file = $fopen("fft_expected.txt", "r");
        if (input_file == 0) begin
            $display("ERROR: Could not open fft_expected.txt");
            $finish;
        end

        i = 0;
        while (!$feof(input_file) && i < FFT_SIZE) begin
            ret = $fscanf(input_file, "%h\n", fft_data[i]);
            i = i + 1;
        end
        $fclose(input_file);
        $display("Read %0d FFT samples.", i);
    end

    // Stimulus
    initial begin
        reset = 1;
        fft_done = 0;
        fft_result = 0;
        #20;

        reset = 0;
        #20;

        // Feed FFT results one by one
        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            fft_result = fft_data[i];
            fft_done = 1;
            @(posedge clk);
        end

        // Tell module FFT is done to finalize calculation
        fft_done = 1;
        @(posedge clk);

        // Wait for note_dec to assert
        wait(note_dec == 1);
        #10;
        $display("Dominant frequency detected: %0d Hz", frequency);

        $stop;
    end

endmodule
