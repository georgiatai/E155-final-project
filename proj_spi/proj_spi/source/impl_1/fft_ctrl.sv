// fft_control

module fft_ctrl#(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 5000)
			    (input  logic       reset, clk_in,
				 input  logic       spi_tran_done,
				 input  logic [7:0] din_spi,          // data inputted from SPI
				 output logic [7:0] note,
				 output logic [3:0] note_dur,
				 output logic       new_note, note_dec
				);
				
//////////////////////////////////////////
// clock divider (48MHz -> 12MHz)
//////////////////////////////////////////

logic [1:0] clk_div_counter;
logic       clk;             // divided clock of 12MHz

always_ff @(posedge clk_in) begin // clk_in is 48MHz
    if (~reset) begin
        clk_div_counter <= 2'b00;
    end else begin
        clk_div_counter <= clk_div_counter + 1;
    end
end

// Bit 0 divides by 2 (24 MHz)
// Bit 1 divides by 4 (12 MHz)
assign clk = clk_div_counter[1];

//////////////////////////////////////////
// state machine definition
//////////////////////////////////////////

typedef enum logic [1:0] {
	S0_SPI_WAIT,  // Waiting for data from MCU and fill RAM when available
	S1_FFT_LOAD,  // Read data into FFT (fft_load)
	S2_FFT_CALC   // FFT calculations in progress (fft_calc and fft_done)
} state_t;

state_t state;

//////////////////////////////////////////
// signal definitions
//////////////////////////////////////////

logic [N-1:0] adr_ram;  // counter for loading data (SPI to RAM)
logic [N-1:0] adr_fft; // counter for loading fft  (RAM to FFT)

// RAM signals
logic      ram_wr_en;
logic [7:0] din_ram;
logic [7:0] din_fft;

// FFT signals
logic       fft_load;               // loading into FFT
logic       fft_start;              // FFT calculation in process
logic       fft_done;               // FFT calculations done, determining note
logic       note_dec_pre;
logic [7:0]  note_raw;
logic [31:0] note_cnt;

// delayed signals
logic fft_load_d1, fft_load_d2;
logic fft_start_d1, fft_start_d2;
logic [N-1:0] adr_fft_d1, adr_fft_d2;

// output
logic [7:0] note_hold;
logic locked; // State variable to prevent double-triggering


//////////////////////////////////////////
// SPI signal timing
//////////////////////////////////////////

logic spi_done_sync1, spi_done_sync2, spi_done_sync3;
logic spi_byte_valid;

always_ff @(posedge clk) begin
    if (~reset) begin
        spi_done_sync1 <= 0;
        spi_done_sync2 <= 0;
        spi_done_sync3 <= 0;
    end else begin
        // Double flop synchronizer to fix metastability
        spi_done_sync1 <= spi_tran_done;
        spi_done_sync2 <= spi_done_sync1; 
        // Delay for edge detection
        spi_done_sync3 <= spi_done_sync2;
    end
end

// Create a pulse that is high for exactly ONE 48MHz cycle
// Rising edge detection: Current is high, previous was low
assign spi_byte_valid = spi_done_sync2 && !spi_done_sync3;

//////////////////////////////////////////
// flag logic
//////////////////////////////////////////

always_ff @(posedge clk) begin
	if (~reset) begin
		state <= S0_SPI_WAIT;
		adr_ram <= 0;
		adr_fft <= 0;
		fft_load <= 0;
		fft_start <= 0;
	end else begin
		ram_wr_en <= 0;
		case (state)
			S0_SPI_WAIT: begin
				fft_start <= 0;
				fft_load <= 0;
				if (spi_byte_valid) begin
					ram_wr_en <= 1;
					din_ram <= din_spi;
					if (adr_ram == FFT_SIZE - 1) begin
						adr_ram <= 0;
						state <= S1_FFT_LOAD;
					end else begin
						adr_ram <= adr_ram + 1;
					end
				end
			end
			S1_FFT_LOAD: begin
				fft_load <= 1;
				if (adr_fft >= FFT_SIZE - 1) begin
					adr_fft <= 0;
					fft_load <= 0;
					fft_start <= 1;
					state <= S2_FFT_CALC;
				end else begin
					adr_fft <= adr_fft + 1;
				end
			end
			S2_FFT_CALC: begin
				if (note_dec) begin
					fft_start <= 0;
					state <= S0_SPI_WAIT;
				end else begin
					fft_start <= 1;
				end
			end
			default: state <= S0_SPI_WAIT;
		endcase
	end
end
				
	
//////////////////////////////////////////
// connection between RAM and FFT
//////////////////////////////////////////

// data buffer RAM for SPI data
ramdp8b ram_databuf(.wr_clk_i(clk), .rd_clk_i(clk), .rst_i(~reset), 
                    .wr_clk_en_i(1'b1),  .rd_clk_en_i(1'b1),
                    .wr_en_i(ram_wr_en), .rd_en_i(1'b1), 
                    .wr_addr_i(adr_ram), 
                    .wr_data_i(din_ram), 
                    .rd_addr_i(adr_fft), 
                    .rd_data_o(din_fft));


// 2-cycle delay to account for reading delay from RAM block
always_ff @(posedge clk) begin
	if (~reset) begin
		fft_load_d1 <= 0;
		fft_start_d1 <= 0;
		fft_load_d2 <= 0;
		fft_start_d2 <= 0;
		adr_fft_d1 <= 0;
		adr_fft_d2 <= 0;
	end else begin
		fft_load_d1 <= fft_load;
		fft_start_d1 <= fft_start;
		fft_load_d2 <= fft_load_d1;
		fft_start_d2 <= fft_start_d1;
		adr_fft_d1 <= adr_fft;
		adr_fft_d2 <= adr_fft_d1;
	end
end

// FFT full module
fftfull #(BIT_WIDTH, N, FFT_SIZE, FS)
    fftfull(.clk(clk), .reset(reset),
            .fft_load(fft_load_d2), 
            .fft_start(fft_start_d2),
            .din(din_fft), 
            .add_rd(adr_fft_d2), 
            .note(note_raw),
            .fft_done(fft_done),
            .note_dec(note_dec),
            .note_dec_pre(note_dec_pre),
            .note_count(note_cnt));


//////////////////////////////////////////
// display logic (change later)
//////////////////////////////////////////

always_ff @(posedge clk) begin
    if (~reset) begin
        note_hold <= 8'd0;
        locked <= 1'b0;
    end else if (fft_load_d2) begin
        locked <= 1'b0;
    end else if (note_dec && !locked) begin
        if (note_raw != 8'd0) begin
            note_hold <= note_raw;
        end
        locked <= 1'b1; 
    end
end

assign note = note_hold;

//////////////////////////////////////////
// note duration
//////////////////////////////////////////

notedur notedur(.clk(clk), .reset(reset), 
                .note(note),
                .note_dec(note_dec), 
                .note_dur(note_dur),
                .new_note(new_note));

endmodule