// Julia Gong
// 11/10/2025
// spi interface to communicate between FPGA and MCU

module spi #(parameter SPI_WIDTH = 8)
        (input logic sclk, // need to match MCU clk for spi (I think currently at 2.5Mhz, but double check)
         input logic cs, // active low
         input logic mosi,
         input logic fft_start_posedge, // can start loading more data into buffer when fft is starting
         output logic miso,
         output logic received_wd, // goes high when word is received
         output logic [SPI_WIDTH - 1:0] sample_in // input data for fft , only 16 bit real
        ); 

// for MISO transaction
logic [SPI_WIDTH - 1:0] data_captured; // 8 bits to acomodate for MOSI bit
logic [2:0] bits_captured; // indicates number of bits captured, used to check for 7


// SPI mode is set as cpol = 0 and cpha = 0
// SDI data sampled on first edge (falling edge for since CS active low)
always_ff @(posedge sclk)
    if (cs) begin
        bits_captured <= 0;
        sample_in <= 8'b0;
    end
    else begin // ~cs for active low
        data_captured <= {data_captured[6:0], mosi}; // shifts input, starting from the left, into data captured on every clk
		if (bits_captured == 3'b111) begin // captures 32 bits
			received_wd <= 1'b1; // received 2 bytes
			sample_in <= {data_captured[6:0], mosi}; // only shift in data, leaving out MOSI bit
			bits_captured <= 3'b0;
		end
		else begin
			received_wd <= 0;
			bits_captured <= bits_captured + 1'b1;
		end
    end
        
// SDO data output/change on falling edge
// only begin sending data when 
always_ff @(negedge sclk)
    if (cs) begin
        miso <= 0;
    end
    else begin
        miso <= fft_start_posedge;
    end


endmodule