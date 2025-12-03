// Julia Gong
// 11/15/2025
// testbench of addgen module

`timescale 1ns/1ps

module testbench_addgen #(parameter BIT_WIDTH = 16, N = 9) ();

logic clk, reset, fft_enable;
logic [N-1:0] add_a, exp_add_a;
logic [N-1:0] add_b, exp_add_b;
logic [N-2:0] add_tw, exp_add_tw;
logic mem_write0, exp_mem_write0;
logic mem_write1, exp_mem_write1;
logic read_sel, exp_read_sel;
logic fft_done, exp_fft_done;

logic [N-1:0] exp_fft_level;
logic [N-1:0] exp_fft_bf;

int errors;

// Instantiate DUT
addgen #(.BIT_WIDTH(BIT_WIDTH), .level(N)) addgen(
    clk,
    reset,
    fft_enable,
    add_a,
    add_b,
    add_tw,
    mem_write0,
    mem_write1,
    read_sel,
    fft_done
);

// Clock
always begin
    clk = 1; #5; clk = 0; #5;
end

initial begin
    errors = 0;
	reset = 0;
	#1;
    reset = 1;
    fft_enable = 1;
end

//---------------------------------------------------------
//  GLOBAL check task (✓ allowed)
//---------------------------------------------------------
task check(string nm, logic [63:0] exp, logic [63:0] got);
    if (exp !== got) begin
        errors++;
        $display("\nERROR [%s] at time %0t", nm, $time);
        $display("  EXPECTED = %0h", exp);
        $display("  GOT      = %0h", got);
    end
endtask

//---------------------------------------------------------
// compute_expected (contains NO nested tasks)
//---------------------------------------------------------
task compute_expected();
    logic [N-1:0] a, b;
    logic [N-1:0] tw_mask;
    logic [N-1:0] tw_full;

    // Butterfly
    a = exp_fft_bf << 1;
    b = a + 1;

    exp_add_a = (a << exp_fft_level) | (a >> (N - exp_fft_level));
    exp_add_b = (b << exp_fft_level) | (b >> (N - exp_fft_level));

    // Twiddle mask
    tw_mask = ({1'b1, {(N-1){1'b0}}}) >> exp_fft_level;
    tw_full = tw_mask & exp_fft_bf;
    exp_add_tw = tw_full[N-2:0];

    // RAM switching
    exp_read_sel   = exp_fft_level[0];
    exp_mem_write0 = (exp_fft_level[0] & fft_enable);
    exp_mem_write1 = (~exp_fft_level[0] & fft_enable);

    // Done
    exp_fft_done = (exp_fft_level == N);
endtask

//---------------------------------------------------------
initial begin
    exp_fft_level = 0;
    exp_fft_bf    = 0;

    @(posedge reset);

    while (!fft_done) begin
        @(posedge clk);

        // Update expected counters
        if (fft_enable && !exp_fft_done) begin
            if (exp_fft_bf < 255)
                exp_fft_bf++;
            else begin
                exp_fft_bf = 0;
                exp_fft_level++;
            end
        end

        compute_expected();

        check("add_a",       exp_add_a,       add_a);
        check("add_b",       exp_add_b,       add_b);
        check("add_tw",      exp_add_tw,      add_tw);
        check("read_sel",    exp_read_sel,    read_sel);
        check("mem_write0",  exp_mem_write0,  mem_write0);
        check("mem_write1",  exp_mem_write1,  mem_write1);
        check("fft_done",    exp_fft_done,    fft_done);
    end

    $display("\nAll tests completed with %0d errors\n", errors);
    $stop;
end

endmodule
