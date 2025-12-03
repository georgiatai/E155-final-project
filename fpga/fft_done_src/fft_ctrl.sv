// fft_control

module fft_ctrl#(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 5000)
			    (input logic reset,
				 input logic A_note,
				 output logic anode1, anode2,
				 output logic [6:0] seg,
				 output logic sharp,
				 output logic led_load, led_start
				);

//////////////////////////////////////////
// clock declaration
//////////////////////////////////////////
logic clk;
logic [23:0] counter;
logic select;

// Internal high-speed oscillator (freq = 48 MHz)
	HSOSC #(.CLKHF_DIV(2'b10)) 
	      hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
		  
// counter for toggling between segment display (delete later)
always_ff @(posedge clk) begin
		if(~reset) counter <= 1'b0;
		else counter <= counter + 24'd100;
end

assign select = counter[23];

//////////////////////////////////////////
// signal definitions
//////////////////////////////////////////

logic [N-1:0] adr_ram;  // counter for loading data (SPI to RAM)
logic [N-1:0] adr_fft; // counter for loading fft  (RAM to FFT)

// operation stage flags
logic data_load;       // loading into RAM from SPI
logic data_full;       // RAM is full and ready to be read by FFT
logic fft_load;        // loading into FFT
logic fft_start;       // FFT calculation in process
logic fft_trigger;     // FFT calculation start

// delayed signals
logic fft_load_d1, fft_load_d2;
logic fft_start_d1, fft_start_d2;
logic [N-1:0] adr_fft_d1, adr_fft_d2;

// FFT signals
logic         fft_done;               // FFT calculations done, determining note
logic [7:0]   note;
logic [31:0]  note_cnt;
logic         note_dec, note_dec_pre;
logic [7:0] din_ram, din_fft;
logic [BIT_WIDTH-1:0] din_out;

// output
logic [7:0] note_hold;
logic locked; // State variable to prevent double-triggering

logic [3:0] s, note_name, octave;

//////////////////////////////////////////
// flag logic
//////////////////////////////////////////

// logic for loading data into RAM
always_ff @(posedge clk) begin
	if (~reset | A_note) begin
		adr_ram <= 0;
		data_load <= 1;
		data_full <= 0;
	end else begin
		if (fft_trigger) begin     // when data in RAM is all read by FFT
			data_full <= 0;
		end
		if (data_load) begin
			if (adr_ram == FFT_SIZE - 1) begin
				adr_ram <= 0;
				data_load <= 0;
				data_full <= 1;
			end else begin
				adr_ram <= adr_ram + 1;
			end
		end else begin
			if (~data_full) begin  // when FFT finish loading in from RAM
				data_load <= 1;
			end
		end
	end
end

// logic for loading data into FFT
always_ff @(posedge clk) begin
	if (~reset | A_note) begin
		adr_fft <= 0;
		fft_load <= 0;
		fft_start <= 0;
	end else begin
		fft_trigger <= 0;
		if (fft_load) begin
			if (adr_fft >= FFT_SIZE - 1) begin
				adr_fft <= 0;
				fft_load <= 0;
				fft_start <= 1;
				fft_trigger <= 1;
			end else begin
				adr_fft <= adr_fft + 1;
			end
		end else if (fft_start) begin
			if (note_dec) begin
				fft_start <= 0;
			end
		end else begin
			if (data_full) begin
				fft_load <= 1;
			end
		end
	end
end


//////////////////////////////////////////
// connection between RAM and FFT
//////////////////////////////////////////

dfiveshLUT LUT(.add_rd(adr_ram), .din(din_out));

assign din_ram = din_out[7:0];

// data buffer RAM for SPI data
ramdp8b ram_databuf(.wr_clk_i(clk), .rd_clk_i(clk), .rst_i(~reset), 
                    .wr_clk_en_i(1'b1),  .rd_clk_en_i(1'b1),
                    .wr_en_i(data_load), .rd_en_i(1'b1), 
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
            .note(note),
            .fft_done(fft_done),
            .note_dec(note_dec),
            .note_dec_pre(note_dec_pre),
            .note_count(note_cnt));

//////////////////////////////////////////
// display logic (change later)
//////////////////////////////////////////

mux mux(select, octave, note_name, s, anode1, anode2);

seg_display disp(s, seg);

always_ff @(posedge clk) begin
    // 1. Reset
    if (~reset) begin
        note_hold <= 8'd0;
        locked <= 1'b0;
    end
    
    // 2. UNLOCK: Reset the lock when a NEW analysis cycle starts
    //    (When we start loading data for the next frame)
    else if (fft_load_d2) begin
        locked <= 1'b0;
    end

    // 3. CAPTURE & LOCK: 
    //    If we haven't locked yet AND valid data arrives:
    else if (note_dec && !locked) begin
        
        // Filter out zero/silence if desired
        if (note != 8'd0) begin
            note_hold <= note;
        end
        
        // ENGAGE LOCK
        // This prevents any subsequent glitches or "ghost notes" 
        // from overwriting the result until the next cycle starts.
        locked <= 1'b1; 
    end
end

assign note_name = note_hold[7:4];
assign octave = {1'b0, note_hold[3:1]};
assign sharp = note_hold[0];
assign led_load = fft_load_d2;
assign led_start = note_dec;

endmodule