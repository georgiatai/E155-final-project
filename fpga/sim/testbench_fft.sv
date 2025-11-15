`timescale 1ns/1ps

module fft_testbench
  #(parameter width = 16, N = 9)();
   
   logic clk;
   logic start, load, done, reset;
   logic signed [width-1:0] expected_re, expected_im, wd_re, wd_im;
   logic [width-1:0]        rd;
   logic [2*width-1:wd];
   logic [2*width-1:0]        idx, out_idx, expected;

   logic [N-1:0]            rd_adr;
   assign rd_adr = idx[M-1:0];
   
   logic [2*width-1:0]          input_data [0:2**N-1];
   logic [2*width-1:0]        expected_out [0:2**N-1];

   integer             f; // file pointer

   fft #(width, N) dut(clk, reset, start, load, rd_adr, rd, wd, done);
   
   // clk
   always
     begin
	clk = 1; #5; clk=0; #5;
     end
   
   // start of test: load `input_data`, `expected_out`, open output file, reset fft module.
   initial
     begin
	$readmemh("fft_input.txt", input_data);
	$readmemh("fft_expected.txt", expected_out);
        f = $fopen("text_out.txt", "w"); // write computed values.
	idx=0; reset=1; #40; reset=0;
     end	

   // increment testbench counter and derive load/start signals
   always @(posedge clk)
     if (~reset) idx <= idx + 1;
     else idx <= idx;
   assign load =  idx < 2**N;
   assign start = idx === 2**N;

   // increment output address if done, reset if restarting FFT
   always @(posedge clk)
     if (load) out_idx <= 0;
     else if (done) out_idx <= out_idx + 1;
   
   // load/start logic
   assign rd = load ? input_data[idx[N-1:0]] : 0;  // read in test data by addressing `input_data` with `idx`.
   assign expected = expected_out[out_idx[N-1:0]]; // get test output by addressing `expected_out` with `idx`.
   assign expected_re = expected[2*width-1:width];   // get real      part of `expected` (gt output)
   assign expected_im = expected[width-1:0];         // get imaginary part of `expected` (gt output)
   assign wd_re = wd[2*width-1:width];               // get real      part of `wd` (computed output)
   assign wd_im = wd[width-1:0];                     // get imaginary part of `wd` (computed output)

   // if FFT is done, compare gt to computed output, and write computed output to file.
   always @(posedge clk)
     if (done) begin
	if (out_idx <= (2**N-1)) begin
           $fwrite(f, "%h\n", wd);
	   if (wd !== expected) begin
	      $display("Error @ out_idx %d: expected %b (got %b)    expected: %d+j%d, got %d+j%d", 
                       out_idx, expected, wd, expected_re, expected_im, wd_re, wd_im);
	   end
	end else begin
	   $display("FFT test complete.");
           $fclose(f);
           $stop;
	end
     end
endmodule // fft_testbench