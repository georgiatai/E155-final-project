// Julia Gong
// 11/10/2025
// spi interface to communicate between FPGA and MCU

module spi #(parameter BIT_WIDTH = 16)
        (input logic sclk,
         input logic cs, // active low
         input logic mosi,
         input logic play_back, // indicate notes to play back for MCU
         input logic [BIT_WIDTH - 1:0] note, // decoded note
         input logic [BIT_WIDTH - 1:0] duration, // decoded duration
         output logic miso,
         output logic received_wd, // goes high when word is received
         output logic [BIT_WIDTH - 1:0] sample_in // input data for fft , only 16 bit real
        ); 

// for MISO transaction
logic [BIT_WIDTH - 1:0] data_captured; // 33 bits to acomodate for MOSI bit
logic [4:0] bits_captured; // indicates number of bits captured, used to check for 16

// for MOSI transaction
logic [BIT_WIDTH*2 - 1:0] data_sent;

// SPI mode is set as cpol = 0 and cpha = 0
// SDI data sampled on first edge (rising edge)
always_ff @(posedge sclk)
    if (cs) bits_captured <= 0;
    else begin
        bits_captured <= bits_captured + 1'b1;
        data_captured <= {data_captured[BIT_WIDTH - 1:0], mosi}; // shifts input, starting from the left, into data captured on every clk
            if (bits_captured == 5'd15) begin // captures 32 bits
                received_wd <= 1'b1; // received 2 bytes
                sample_in <= data_captured[ BIT_WIDTH - 1: 0]; // only shift in data, leaving out MOSI bit
            end
            else begin
            // still receiving 2 bytes
                received_wd <= 0;
            end
    end

// data to send back to MCU
always_ff @(posedge play_back) begin
    data_sent = {note, duration};
end

// SDO data output/change on falling edge
// only begin sending data when 
always_ff @(negedge sclk)
    if (cs) begin
        miso <= 0;
    end
    else if (play_back) begin
        miso <= data_sent[2*BIT_WIDTH - 1]; // send 1 bit at a time starting with MSB
        data_sent <= {data_sent[2*BIT_WIDTH - 2:0], 1'b0}; // shifting data every clock cycle to send
    end

endmodule