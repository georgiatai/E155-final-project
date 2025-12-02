// fft_control

module fft_ctrl#(parameter BIT_WIDTH = 16, N = 9, FFT_SIZE = 512, FS = 5000)
			    (input logic reset,
				 input logic A_note,
				 output logic anode1, anode2,
				 output logic [6:0] seg,
				 output logic sharp,
				 output logic led_load, led_start
				);
				
logic [23:0] counter;
logic [3:0] s, note_name, octave;
logic clk, select;
logic note_dec, note_dec_pre;

// Internal high-speed oscillator (freq = 48 MHz)
	HSOSC #(.CLKHF_DIV(2'b10)) 
	      hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
		  
// counter
always_ff @(posedge clk) begin
		if(~reset) counter <= 1'b0;
		else counter <= counter + 24'd100;
end

assign select = counter[23];

logic fft_load, fft_start, data_load;
logic fft_load_d1, fft_load_d2;
logic fft_start_d1, fft_start_d2;
logic fft_done;
logic [N - 1:0] add_rd, add_rd_test, add_rd_d1, add_rd_d2;
logic [7:0] note;
logic [BIT_WIDTH - 1:0] din_out;

logic fft_load_prev;

logic             read_din, write_din;
logic [N - 1:0]   buf_add_wr, buf_add_rd;
logic [7:0] spi_din, fft_din;
ramdp8b ram_databuf(.wr_clk_i(clk), 
                      .rd_clk_i(clk), 
                      .rst_i(~reset), 
                      .wr_clk_en_i(reset), 
                      .rd_en_i(read_din), 
                      .rd_clk_en_i(reset), 
                      .wr_en_i(write_din), 
                      .wr_data_i(din_out), 
                      .wr_addr_i(buf_add_wr), 
                      .rd_addr_i(buf_add_rd), 
                      .rd_data_o(fft_din));
assign buf_add_wr = add_rd;

always_ff @(posedge clk) begin
    // Synchronous Reset
    if (~reset | A_note) begin
        add_rd        <= '0;
        fft_load_prev <= 1'b0;
    end
    else begin
        // Track the previous state of fft_load to detect rising edges
        fft_load_prev <= fft_load;

        // 1. RESTART: When fft_load goes from Low to High
        //if (fft_load && !fft_load_prev) begin
            //add_rd <= '0;
        //end
		if (note_dec & ~fft_load) begin
			add_rd <= 0;
		end
        // 2. INCREMENT: When loading and not yet at max value (511)
        else if (fft_load && (add_rd < FFT_SIZE - 1)) begin
            add_rd <= add_rd + 1'b1;
        end
        // 3. HOLD: When fft_load is low OR we reached max value (saturation)
        else begin
            add_rd <= add_rd;
        end
    end
end

always_ff @(posedge clk) begin
	if (~reset) begin
		add_rd_d1 <= 0;
		add_rd_d2 <= 0;
	end
	else begin
		add_rd_d1 <= add_rd;
		add_rd_d2 <= add_rd_d1;
	end
end

always_ff @(posedge clk) begin
	if (~reset) begin
		data_load <= 0;
	end
	else if (buf_add_wr >= (FFT_SIZE - 1)) begin
		data_load <= 0;
	end
	else if (fft_load_prev) begin
		data_load <= 1;
	end
	else begin
		data_load <= data_load;
	end
end

always_ff @(posedge clk) begin
    if (~reset | A_note) begin
        fft_load <= 0;
        fft_start <= 0;
    end
    // Restart cycle when previous one finishes
    else if (note_dec) begin
        fft_load <= 1; // Start loading immediately for next cycle
        fft_start <= 0;
    end
    // Stop loading and fire start pulse when memory is full
    else if (fft_load_prev && add_rd >= (FFT_SIZE - 1)) begin
        fft_load <= 0;
        fft_start <= 1; 
    end
    // Initial start condition (Button pressed, not yet started)
    else if (~A_note && ~fft_start && ~fft_load) begin
        fft_load <= 1;
        fft_start <= 0;
    end
    else begin
		fft_load <= fft_load;
		fft_start <= fft_start;
	end
end

always_ff @(posedge clk) begin
	if (~reset) begin
		fft_load_d1 <= 0;
		fft_start_d1 <= 0;
		fft_load_d2 <= 0;
		fft_start_d2 <= 0;
	end
	else begin
		fft_load_d1 <= fft_load;
		fft_start_d1 <= fft_start;
		fft_load_d2 <= fft_load_d1;
		fft_start_d2 <= fft_start_d1;
	end
end

dfiveshLUT LUT(add_rd, din_out);
				
fftfull #(BIT_WIDTH, N, FFT_SIZE, FS)
     fftfull(clk, reset,
			 fft_load_d2, fft_start_d2,
			 din_out, 
			 add_rd_d2, 
			 note,
			 fft_done,
			 note_dec,
			 note_dec_pre,
			 note_cnt);
			 
logic [7:0] note_hold;
logic locked; // State variable to prevent double-triggering

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


mux mux(select, octave, note_name, s, anode1, anode2);

seg_display disp(s, seg);


assign led_load = fft_load_d2;
assign led_start = note_dec;

endmodule