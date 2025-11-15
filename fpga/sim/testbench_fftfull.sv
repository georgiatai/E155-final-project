`timescale 1ns/1ps

module testbench_fftfull();

    // Parameters
    parameter BIT_WIDTH = 16;
    parameter N = 9;
    parameter FFT_SIZE = 512;

    // Clock and reset
    logic clk, reset;

    // FFT inputs
    logic fft_start, fft_load;
    logic [N-1:0] add_rd;
    logic [BIT_WIDTH-1:0] din;

    // Output
    logic [9:0] note;

    // Internal
    integer i;
    integer input_file;
    integer ret;
    logic [BIT_WIDTH-1:0] input_data [0:FFT_SIZE-1];

    // Instantiate fftfull
    fftfull #(.BIT_WIDTH(BIT_WIDTH), .N(N), .FFT_SIZE(FFT_SIZE))
        dut (.clk(clk),
             .reset(reset),
             .fft_start(fft_start),
             .fft_load(fft_load),
             .add_rd(add_rd),
             .din(din),
             .note(note));

    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end

    // Read input file
    initial begin
        input_file = $fopen("fft_input.txt", "r");
        if (input_file == 0) begin
            $display("ERROR: Could not open fft_input.txt");
            $finish;
        end

        i = 0;
        while (!$feof(input_file) && i < FFT_SIZE) begin
            ret = $fscanf(input_file, "%h\n", input_data[i]);
            i = i + 1;
        end
        $fclose(input_file);
        $display("Read %0d input samples.", i);
    end

    // Stimulus
    initial begin
        reset = 1;
        fft_start = 0;
        fft_load = 0;
        add_rd = 0;
        din = 0;
        #20;

        reset = 0;
        #20;

        // Begin loading FFT input
        fft_load = 1;
        fft_start = 1;

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 0;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.fftdec.note_dec == 1);
        #10;
        $display("Detected note: %0d", note);

        $stop;
    end

endmodule
