`timescale 1ns/1ps

module testbench_fftfull();

    // Parameters
    parameter BIT_WIDTH = 16;
    parameter N = 9;
    parameter FFT_SIZE = 512;

    // Clock and reset
    logic clk, reset;

    // FFT inputs
    logic fft_start, fft_load, fft_done;
    logic [N-1:0] add_rd;
    logic [BIT_WIDTH-1:0] din;

    // Output
	logic [7:0] note;

    // Internal
    integer i;
    integer input_file;
    integer ret;
    logic [FFT_SIZE - 1:0][BIT_WIDTH-1:0] input_data ;
	logic note_dec, note_dec_pre;
	logic [N-1:0] note_cnt;

    // Instantiate fftfull
    fftfull #(.BIT_WIDTH(BIT_WIDTH), .N(N), .FFT_SIZE(FFT_SIZE), .FS(5000))
        dut (.clk(clk),
             .reset(reset),
			 .fft_start(fft_start),
             .fft_load(fft_load),
             .add_rd(add_rd),
             .din(din),
             .note(note),
			  .fft_done(fft_done),
			  .note_dec(note_dec),
			  .note_dec_pre(note_dec_pre),
			  .note_count(note_cnt));

    // Clock generation
    always begin
        clk = 1; #5; clk = 0; #5;
    end

    // Read input file
    initial begin
        input_file = $fopen("fft_inputsharp.txt", "r");
        if (input_file == 0) begin
            $display("ERROR: Could not open fft_input.txt");
            $finish;
        end

        i = 0;
        while (!$feof(input_file) && i < FFT_SIZE) begin
            ret = $fscanf(input_file, "%b\n", input_data[i]);
            i = i + 1;
        end
        $fclose(input_file);
        $display("Read %0d input samples.", i);
    end

    // Stimulus
    initial begin
        reset = 0;
        fft_load = 0;
        add_rd = 0;
        din = 0;
        #10;

        reset = 1;
        #10;

        // Begin loading FFT input
        fft_load = 1;
        fft_start = 0;

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0);
        #10;
        //$display("Detected note: %0d", dut.note);
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		
        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
		
		// Begin loading FFT input
        fft_load = 1;
        fft_start = 0;
		

        for (i = 0; i < FFT_SIZE; i = i + 1) begin
            add_rd = i[N-1:0];
            din = input_data[i];
		$display("input data %h", input_data[i]);
            @(posedge clk);
        end

        fft_load = 0;
        fft_start = 1;

        $display("All input samples loaded, waiting for FFT + decoding to complete...");

        // Wait for note_dec to assert in the FFT decoding stage
        wait(dut.note != 0 && dut.note_dec == 1);
        #10;
        //$display("Detected note: %0d", dut.note);
        $stop;
    end

endmodule