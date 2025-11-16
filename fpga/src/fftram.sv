module fftram (
    input logic clk,              // Clock signal
    input logic reset,            // Reset signal
    input logic [8:0] address,   // 14-bit address input (for 16K x 16 RAM)
    input logic [31:0] data_in,   // 32-bit input data (16-bit real + 16-bit imaginary)
    input logic we,               // Write enable
    output logic [31:0] data_out  // 32-bit output data (16-bit real + 16-bit imaginary)
);

	logic chipselect;
	assign chipselect = 1'b1;
    // Split data into real and imaginary
    logic [15:0] real_data, imag_data;
    assign real_data = data_in[31:16];  // Real part (bits 31 to 16)
    assign imag_data = data_in[15:0];   // Imaginary part (bits 15 to 0)

    // Instantiate RAM for real part (16K x 16)
    SB_SPRAM256KA real_ram_inst (
        .ADDRESS(address),      // 14-bit address input
        .DATAIN(real_data),     // 16-bit data input (real part)
        .WE(we),                // Write enable
        .MASKWREN(4'b0000),     // Not used (for 16-bit write)
        .CHIPSELECT(chipselect), // Chip select
        .CLOCK(clk),            // Clock signal
        .STANDBY(1'b0),         // Standby signal (inactive)
        .SLEEP(1'b0),           // Sleep signal (inactive)
        .POWEROFF(1'b0),        // Power-off signal (inactive)
        .DATAOUT(data_out[31:16])  // Output real part (bits 31 to 16)
    );

    // Instantiate RAM for imaginary part (16K x 16)
    SB_SPRAM256KA imag_ram_inst (
        .ADDRESS(address),      // 14-bit address input
        .DATAIN(imag_data),     // 16-bit data input (imaginary part)
        .WE(we),                // Write enable
        .MASKWREN(4'b0000),     // Not used (for 16-bit write)
        .CHIPSELECT(chipselect), // Chip select
        .CLOCK(clk),            // Clock signal
        .STANDBY(1'b0),         // Standby signal (inactive)
        .SLEEP(1'b0),           // Sleep signal (inactive)
        .POWEROFF(1'b0),        // Power-off signal (inactive)
        .DATAOUT(data_out[15:0])  // Output imaginary part (bits 15 to 0)
    );

endmodule
