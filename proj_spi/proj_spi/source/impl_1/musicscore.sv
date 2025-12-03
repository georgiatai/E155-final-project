// Music score rendering module
module musicscore (input logic clk, reset, 
                   input logic [10:0] hcount, 
                   input logic [9:0] vcount, 
                   input logic active_video, 
                   input logic [7:0] note, 
                   input logic [3:0] duration, 
                   input logic note_dec,
                   output logic pixel_out, 
				   output logic found_note);

    // All localparams unchanged
    localparam STAFF_LINE_THICKNESS = 2;
    localparam STAFF_LINE_SPACING = 10;
    localparam SCORE_HEIGHT = 60; // 5 * (STAFF_LINE_SPACING + STAFF_LINE_THICKNESS);
    localparam VERTICAL_MARGIN = 90;
    localparam HORIZONTAL_MARGIN = 200;
    localparam CLEF_START_X = 200;
    localparam CLEF_WIDTH = 40;
    localparam CLEF_HEIGHT = 80;
    localparam NOTE_WIDTH = 30;
    localparam NOTE_HEIGHT = 60;
    localparam NOTE_SPACING = 40;
    localparam NOTES_START_X = CLEF_START_X + CLEF_WIDTH + 10;
    localparam MAX_NOTES = 10;
    
    // Pipeline stages for 2-cycle memory delay
    logic [10:0] hcount_d1, hcount_d2;
    logic [9:0] vcount_d1, vcount_d2;
    logic active_d1, active_d2;
    
    always_ff @(posedge clk) begin
        if (~reset) begin
            hcount_d1 <= 0;
            hcount_d2 <= 0;
            vcount_d1 <= 0;
            vcount_d2 <= 0;
            active_d1 <= 0;
            active_d2 <= 0;
        end else begin
            hcount_d1 <= hcount;
            hcount_d2 <= hcount_d1;
            vcount_d1 <= vcount;
            vcount_d2 <= vcount_d1;
            active_d1 <= active_video;
            active_d2 <= active_d1;
        end
    end
    
    // Staff line rendering - UNCHANGED
    logic staff_pixel;
    logic [9:0] score_base_y;
    logic [9:0] y_in_score;
    logic on_staff_line;
    
    always_comb begin
        staff_pixel = 0;
        score_base_y = 0;
        y_in_score = 0;
        on_staff_line = 0;
        
        if (active_d2 && vcount_d2 >= VERTICAL_MARGIN) begin
			// ONLY DOING 1 STAFF
                score_base_y = VERTICAL_MARGIN + (SCORE_HEIGHT + 100);
                if (vcount_d2 >= score_base_y && vcount_d2 < (score_base_y + SCORE_HEIGHT)) begin
                    y_in_score = vcount_d2 - score_base_y;
                    
                    for (int j = 0; j < 5; j++) begin
                        if (y_in_score >= (j * STAFF_LINE_SPACING) && 
                            y_in_score < (j * STAFF_LINE_SPACING + STAFF_LINE_THICKNESS)) begin
                            on_staff_line = 1;
                        end
                    end
                    
                    if (on_staff_line && hcount_d2 >= HORIZONTAL_MARGIN) begin
                        staff_pixel = 1;
                    end
                end
            end
    end
    
	

	
    // Treble clef ROM interface - UNCHANGED
    logic [13:0] clef_addr;
    logic clef_pixel;
    logic in_clef_region;
    logic [7:0] clef_x, clef_y;
    
    always_comb begin
        in_clef_region = 0;
        clef_x = 0;
        clef_y = 0;
        clef_addr = 0;
        if (active_video) begin
		// ONLY DOING LOGIC for 1 STAFF
                score_base_y = VERTICAL_MARGIN + (SCORE_HEIGHT + 100);
                
                if (hcount >= CLEF_START_X && hcount < (CLEF_START_X + CLEF_WIDTH) &&
                    vcount >= (score_base_y - 22) && vcount < (score_base_y - 22 + CLEF_HEIGHT)) begin
                    in_clef_region = 1;
                    clef_x = hcount - CLEF_START_X;
                    clef_y = vcount - (score_base_y - 22);
                    clef_addr = clef_y * CLEF_WIDTH + clef_x;
                end
        end
    end
    
    treblerom clef_rom (
        .clk(clk),
        .addr(clef_addr),
        .treble_out(clef_pixel)
    );
	
	
	// Note storage 
    logic [3:0] note_duration [0:MAX_NOTES-1];
    logic [10:0] note_x [0:MAX_NOTES-1];
    logic [9:0] note_y [0:MAX_NOTES-1];
    logic [0:0] note_is_sharp [0:MAX_NOTES-1];
    logic [0:0] note_stem_direction [0:MAX_NOTES-1];
    logic [4:0] note_count;  // Reduced from 6 bits to 5 (max 16)
   
    logic [10:0] current_x_pos;

    // Note decoding
    logic [3:0] decoded_letter;
    logic [2:0] decoded_octave;
    logic decoded_sharp;
    logic [5:0] semitone;
	always_comb begin
        decoded_letter = note[7:4];
        decoded_octave = note[3:1];
        decoded_sharp = note[0];
        case(decoded_letter)
            4'b1100: semitone = 4; // C
            4'b1101: semitone = 5; // D
            4'b1110: semitone = 6; // E
            4'b1111: semitone = 7; // F
            4'b1000: semitone = 8; // G
            4'b1010: semitone = 9; // A
            4'b1011: semitone = 10; // B
            default: semitone = 0;
        endcase
    end
	
// Ledger line rendering
logic ledger_pixel;
logic [9:0] ledger_y;
logic [10:0] ledger_x_start, ledger_x_end;
	
	
// Calculate Y position
    logic [9:0] calculated_y;
    logic calculated_stem_direction;
    logic [9:0] staff_base;
    logic [10:0] B4_line_y;
    logic [10:0] note_shift_y;
	
    always_comb begin
        staff_base = VERTICAL_MARGIN + (SCORE_HEIGHT + 100);
        B4_line_y = staff_base - 10; // Middle line (3rd line) of staff
        
        //Calculate Y based on semitone position (5 pixels per semitone step)
        note_shift_y = B4_line_y + 5 * (10 - semitone) ; //+ 5 * (10 - semitone)

       // Adjust for octave
        if (decoded_octave == 3'b011) begin // Octave 3 (one below middle)
            calculated_y = note_shift_y + 35; // Shift down
        end
        else if (decoded_octave == 3'b100) begin // Octave 4 (middle)
            calculated_y = note_shift_y;
        end
        else if (decoded_octave == 3'b101) begin // Octave 5 (one above)
            calculated_y = note_shift_y - 35; // Shift up
        end
        else begin
            calculated_y = note_shift_y; // Default to octave 4 position
        end
        
        // Stem direction: up if note is below middle, down if above
        calculated_stem_direction = (calculated_y < B4_line_y) ? 1'b1 : 1'b0;
    end
	
	always_comb begin
    ledger_pixel = 0;
    ledger_y = 0;
    ledger_x_start = 0;
    ledger_x_end = 0;
    
    if (active_d2 && vcount_d2 >= VERTICAL_MARGIN) begin
        score_base_y = VERTICAL_MARGIN + (SCORE_HEIGHT + 100);
        
        // Check each stored note to see if it needs a ledger line
        for (int i = 0; i < MAX_NOTES; i++) begin
            if (i < note_count) begin
                // Ledger line for notes above the staff (like A5)
                // A5 is one ledger line above the top staff line
                if (note_y[i] < (staff_base - 35)) begin  // Note is above staff
                    // Calculate ledger line Y position (10 pixels above top staff line)
                    ledger_y = score_base_y - 10;
                    
                    // Ledger line X position: centered on note, 12 pixels wide
                    ledger_x_start = note_x[i] + 8;  // 6 pixels left of center
                    ledger_x_end = note_x[i] + 22;    // 6 pixels right of center
                    
                    // Draw ledger line (2 pixels thick)
                    if (hcount_d2 >= ledger_x_start && 
                        hcount_d2 < ledger_x_end &&
                        vcount_d2 >= ledger_y && 
                        vcount_d2 < (ledger_y + STAFF_LINE_THICKNESS)) begin
                        ledger_pixel = 1;
                    end
                end
                
                // Ledger line for notes below the staff (like C4 or lower)
                if (note_y[i] > (staff_base + 15) )begin  // Note is below staff
                    // Calculate ledger line Y position (10 pixels below bottom staff line)
                    ledger_y = score_base_y + 50;
                    
                    // Ledger line X position: centered on note, 12 pixels wide
                    ledger_x_start = note_x[i] + 8;
                    ledger_x_end = note_x[i] + 22;
                    
                    // Draw ledger line
                    if (hcount_d2 >= ledger_x_start && 
                        hcount_d2 < ledger_x_end &&
                        vcount_d2 >= ledger_y && 
                        vcount_d2 < (ledger_y + STAFF_LINE_THICKNESS)) begin
                        ledger_pixel = 1;
                    end
                end
            end
        end
    end
end
    
	
    always_ff @(posedge clk) begin
        if (~reset) begin
            note_count <= 0;
            current_x_pos <= NOTES_START_X;

        end else begin
            
            // Only add note on RISING EDGE of note_dec
            if (note_dec && (note_count < MAX_NOTES)) begin
                note_duration[note_count] <= duration;
                note_x[note_count] <= current_x_pos;
                note_y[note_count] <= calculated_y;
                note_is_sharp[note_count] <= decoded_sharp;
                note_stem_direction[note_count] <= calculated_stem_direction;
                note_count <= note_count + 1'b1;
                current_x_pos <= current_x_pos + NOTE_SPACING;
            end
			else if (note_count == MAX_NOTES) begin
				note_count <= 0;
			end
        end
    end
	
	logic [14:0] note_rom_addr;
    logic [5:0] note_type;
    logic note_pixel;
   
    logic [10:0] x_offset, y_offset;
	
 // PIPELINED NOTE LOOKUP - Stage 1: Check 8 notes in parallel
    logic [14:0] note_rom_addr_s1;
    logic [5:0] note_type_s1;
    logic found_note_s1;
    
    always_ff @(posedge clk) begin
        note_rom_addr_s1 <= 0;
        note_type_s1 <= 0;
        found_note_s1 <= 0;
        
        // Check first 8 notes (indices 0-7)
        for (int i = 0; i < 5; i++) begin
            if (i < note_count &&
                hcount >= note_x[i] &&
                hcount < (note_x[i] + NOTE_WIDTH) &&
                vcount >= note_y[i] &&
                vcount < (note_y[i] + NOTE_HEIGHT)) begin
                
                note_rom_addr_s1 <= (vcount - note_y[i]) * NOTE_WIDTH + (hcount - note_x[i]);
                note_type_s1 <= {note_duration[i], note_stem_direction[i], note_is_sharp[i]};
                found_note_s1 <= 1;
            end
        end
    end
    
    // PIPELINED NOTE LOOKUP - Stage 2: Check remaining 8 notes and merge
    logic [14:0] note_rom_addr_s2;
    logic [5:0] note_type_s2;
    logic found_note_s2;
    
    always_ff @(posedge clk) begin
        logic [14:0] addr_temp;
        logic [5:0] type_temp;
        logic found_temp;
        
        addr_temp = 0;
        type_temp = 0;
        found_temp = 0;
        
        // Check last 8 notes (indices 8-15)
        for (int i = 5; i < 10; i++) begin
            if (i < note_count &&
                hcount_d1 >= note_x[i] &&
                hcount_d1 < (note_x[i] + NOTE_WIDTH) &&
                vcount_d1 >= note_y[i] &&
                vcount_d1 < (note_y[i] + NOTE_HEIGHT)) begin
                
                addr_temp = (vcount_d1 - note_y[i]) * NOTE_WIDTH + (hcount_d1 - note_x[i]);
                type_temp = {note_duration[i], note_stem_direction[i], note_is_sharp[i]};
                found_temp = 1;
            end
        end
        
        // Merge with stage 1 results (stage 1 has priority if both found)
        if (found_note_s1) begin
            note_rom_addr_s2 <= note_rom_addr_s1;
            note_type_s2 <= note_type_s1;
            found_note_s2 <= 1;
        end else if (found_temp) begin
            note_rom_addr_s2 <= addr_temp;
            note_type_s2 <= type_temp;
            found_note_s2 <= 1;
        end else begin
            note_rom_addr_s2 <= 0;
            note_type_s2 <= 0;
            found_note_s2 <= 0;
        end
    end
    
    assign found_note = found_note_s2;

    note_rom note_rom_inst (
        .clk(clk),
        .addr(note_rom_addr_s2),
        .note_type(note_type_s2),
        .pixel_out(note_pixel)
    );
	
	
    // Combine all pixels
    always_comb begin
        if (hcount_d2 <= HORIZONTAL_MARGIN | hcount_d2 >= 720) begin
            pixel_out = 1'b0;
        end else begin
            pixel_out = staff_pixel | note_pixel | ledger_pixel |
                       (in_clef_region & clef_pixel);
        end
    end

endmodule