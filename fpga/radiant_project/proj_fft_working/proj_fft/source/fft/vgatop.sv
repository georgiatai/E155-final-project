// top module for vga music score control

module vgatop (input logic reset,
               //input logic [7:0] note, // letter(4b)_octave(3b)_sharp/flat/normal(1b)
               //input logic [3:0] duration, 
               output logic hsync, 
               output logic vsync, 
               output logic [2:0] vga_rgb,
               output logic found_note);

// note duration
// Sampling at 5Khz for 512 samples is 0.1024s

// 8th note (0.25s) 0b0001
// 2-3 samples

// Quarter note (0.5) 0b0010
// 4-6 samples

// Half note (1s) 0b0100
// 9-12 samples

// Whole note (2s) 0b1000
// 19-22

// vga controller logic
logic [10:0] hcount;
logic [9:0] vcount;
logic active_video;

// pll clock logic
logic pll_clk_internal, pll_lock;

// music score rendering signals
logic score_pixel;

// note decoding logic 
logic [7:0] note;
logic [3:0] duration;
logic note_dec;
int counter;

assign note = 8'b1011_100_0;
assign duration = 4'b1000;
assign note_dec = 1;

//always_ff @(posedge pll_clk_internal) begin
	//if (~reset) begin
		//note_dec <= 0;
		//counter <= 0;
	//end
	//else if (counter >= 'd25000000) begin
		//note_dec <= 1;
		//counter <= 0;
	//end
	//else begin
		//note_dec <= 0;
		//counter <= counter +1;
	//end
//end


pllclk  #(.CLKHF_DIV("0b00"),
                .DIVR("0"),
		        .DIVF("16"),
		        .DIVQ("5")) 
    pllclk (.rst_n(reset),
            .clk_internal(pll_clk_internal),
            .clk_external(debug_pll_clk),
            .clk_HSOSC(debug_HSOSC_clk),
            .locked(pll_lock));

vgactrl vgactrl (.clk(pll_clk_internal),
                 .reset(reset & pll_lock),
                 .hsync(hsync),
                 .vsync(vsync),
                 .hcount(hcount),
                 .vcount(vcount),
                 .active_video(active_video));

musicscore score (.clk(pll_clk_internal),
                   .reset(reset & pll_lock),
                   .hcount(hcount),
                   .vcount(vcount),
                   .active_video(active_video),
                   .note(note),
				    .duration(duration),
					.note_dec(note_dec),
                   .pixel_out(score_pixel));
				   


// RGB output white background and black drawings
assign vga_rgb = (active_video && ~score_pixel) ? 3'b111 : 3'b000;

endmodule