// Julia Gong
// 11/1/25
// This module is the address generation unit that:
// 1. creates addresses for reading and writing data in RAM
// 2. gets twiddle factors from RAM? (have separate module that calculates twiddle factors)
// 3. generate write signals for data RAM

module addgen #(parameter BIT_WIDTH = 16, level = 9) // level = log2(512)
              (input logic clk, reset,
               input logic fft_enable, 
               output logic [level - 1:0]add_a,
               output logic [level - 1:0]add_b,
               output logic [level - 2:0]add_tw, // only need 0 - 255
               output logic mem_write0, // write enable for RAM0
               output logic mem_write1, // write enable for RAM1
               output logic read_sel, // select rd
               output logic fft_done
);

// logic for levels and butterflies
logic [level - 1:0] fft_level; // indicies for total of 5 levels
logic [level - 1:0] fft_bf; // indicies for total of 256 butterflies per level
logic [7:0] total_bf; 

// logic for a, b, tw agu
logic [level - 1:0] a, b, tw, tw_mask;

// set limit for butterfly index loop 0-255
assign total_bf = 8'b1111_1111;

// loops through each of the levels and butterflies
    always_ff @(posedge clk) begin
        if (~reset) begin
            fft_level <= 0;
            fft_bf <= 0;
        end
        else if (fft_enable & ~fft_done) begin // begin fft
            if (fft_bf < total_bf) begin // increment butterfly element every cycle
                fft_bf <= fft_bf + 1'b1;
            end
            else begin // reaches end of the level
                fft_bf <= 0; // reset butterfly index to 0
                fft_level <= fft_level + 1'b1; // increment level
            end
        end
    end

// address generation logic for A, B, and TW
// address generation unit for {m, n} pair, m is address of A factor and n is address of B factor
// where m = Rotate_N(2j, i) and n = Rotate_N(2j+1, i)
    always_comb begin
        a = fft_bf << 1'b1; // multiply bf index by 2
        b = a + 1'b1; 

        // rotate by fft_level
        add_a = (a << fft_level) | (a >> level - fft_level); 
        add_b = (b << fft_level) | (b >> level - fft_level);

        // generate tw add by masking out (N - 1 - fft_level) least significant bits of bf index
        tw_mask = {1'b1, 8'b0} >> fft_level; // shift dependent on level
        // this masking ensures that at level 0, tw = 1_0000_0000 and add_tw = 0000_0000
        // add_tw corresponds to address on twiddleLUT.sv
        tw = tw_mask & fft_bf; // masking with butterfly index to generate tw address
        add_tw = tw[level - 2: 0];
    end


// needs to finish level - 1 (8 in our case), then increment to next level after completion
assign fft_done = (fft_level == level); 

// assign register/mem_write
// switches between RAM0 and RAM1 every level, starts with selecting RAM0
assign read_sel = fft_level[0]; 
// only write when fft agu is occurring
assign mem_write0 = (fft_level[0] & fft_enable); 
assign mem_write1 = (~fft_level[0] & fft_enable);


endmodule
