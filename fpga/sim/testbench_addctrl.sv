// Julia Gong
// 11/15/2025
// testbench to see behavior of addctrl unit

`timescale 1ns/1ps

module addctrl #(parameter BIT_WIDTH = 16, N = 9)

logic clk, reset, fft_start, fft_load;
logic [N - 1:0] add_rd;
logic [N-1:0] r0_add_a, r0_add_b;
logic [N-1:0] r1_add_a, r1_add_b;
logic [N-2:0] add_tw;
logic mem_write0, mem_write1;
logic read_sel;
logic fft_done;

addctrl #(.BIT_WIDTH(BIT_WIDTH), .N(N)) 
addctrl(.clk(clk),
        .reset(reset),
        .fft_start(fft_start),
        .fft_load(fft_load),
        .add_rd(add_rd),
        .r0_add_a(r0_add_a),
        .r0_add_b(r0_add_b),
        .r1_add_a(r1_add_a),
        .r1_add_b(r1_add_b),
        .add_tw(add_tw),
        .mem_write0(mem_write0),
        .mem_write1(mem_write1),
        .read_sel(read_sel),
        .fft_done(fft_done)
    );

initial begin
        $display("add_rd inputs from 0 to 511");

        reset = 0;
        fft_start = 0;
        fft_load = 1;   
        add_rd = 0;

        repeat (5) @(posedge clk);
        reset = 1;

        // FFT load
        $display("\nfft_load = 1");
        $display(" add_rd | r0_add_a | r0_add_b | r1_add_a | r1_add_b");

        for (int i = 0; i < 512; i++) begin
            add_rd = i;
            @(posedge clk);

            $display("%6d | %9d | %9d | %9d | %9d",
                     i, r0_add_a, r0_add_b, r1_add_a, r1_add_b);
        end

        // FFT start mode
        $display("\nfft_start = 1");

        fft_load = 0;
        repeat (2) @(posedge clk);

        fft_start = 1;
        @(posedge clk);
        fft_start = 0;

        $display("Cycle | r0_add_a | r0_add_b | r1_add_a | r1_add_b | fft_done");

        // record 600 cycles
        for (int c = 0; c < 600; c++) begin
            @(posedge clk);

            $display("%5d | %9d | %9d | %9d | %9d | %8b",
                     c, r0_add_a, r0_add_b, r1_add_a, r1_add_b, fft_done);

            if (fft_done) begin
                $display("FFT DONE detected at cycle %0d", c);
                break;
            end
        end
        
        $display("\nfinished cycling");
        $stop;
    end

endmodule

