// Julia Gong
// 11/10/2025
// spi interface to communicate between FPGA and MCU

module top (input  logic       reset,
	        input  logic       sclk, cs, mosi, // SPI inputs from MCU
            output logic       miso,           // SPI output to MCU
            output logic       hsync, vsync,   // VGA synchronization signals
            output logic [2:0]  rgb            // VGA rbg signals
           );//////////////////////////////////////////
// clock declaration
//////////////////////////////////////////
logic clk;

// Internal high-speed oscillator (freq = 48 MHz)
HSOSC #(.CLKHF_DIV(2'b00)) 
	  hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));	  


//////////////////////////////////////////
// signal definitions
//////////////////////////////////////////
logic       spi_trans_done; // one SPI transaction (8 bit) is done

logic [7:0] note;
logic [7:0] din_spi;

logic [3:0] note_dur;
logic       new_note;


//////////////////////////////////////////
// SPI module declaration
//////////////////////////////////////////

spi #(.SPI_WIDTH('d8))
	spi_inst (.sclk(sclk), .cs(cs), .mosi(mosi),
			  .fft_start_posedge(1'b0),
			  .miso(miso),
			  .received_wd(spi_trans_done),
			  .sample_in(din_spi)); 

fft_ctrl#(.BIT_WIDTH('d16), .N('d9), .FFT_SIZE('d512), .FS('d5000))
	fft_ctrl_inst (.reset(reset), .clk_in(clk),
				   .spi_tran_done(spi_trans_done),
				   .din_spi(din_spi),
				   .note(note),
				   .note_dur(note_dur),
				   .new_note(new_note),
				   .note_dec(note_dec));
				   
vgatop vgatop_inst(.reset(reset), .clk_in(clk),
					.note(note),
					.duration(duration), 
					.note_dec(note_dec),
					.hsync(hsync), 
					.vsync(vsync), 
					.vga_rgb(rgb));

endmodule