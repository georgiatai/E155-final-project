    // Note storage - UNCHANGED
    logic [6:0] note_chromatic_pitch [0:MAX_NOTES-1];
    logic [3:0] note_duration [0:MAX_NOTES-1];
    logic [10:0] note_x [0:MAX_NOTES-1];
    logic [9:0] note_y [0:MAX_NOTES-1];
    logic [1:0] note_staff [0:MAX_NOTES-1];
    logic [0:0] note_is_sharp [0:MAX_NOTES-1];
    logic [0:0] note_stem_direction [0:MAX_NOTES-1];
    logic [6:0] note_count;    

    logic [10:0] current_x_pos;
    logic [1:0]  current_staff_num;

    // Note decoding - UNCHANGED
    logic [3:0] decoded_letter;
    logic [2:0] decoded_octave;
    logic       decoded_sharp;
    logic [3:0] semitone;
    logic [6:0] chromatic_pitch;

    always_comb begin
        decoded_letter = note[7:4];
        decoded_octave = note[3:1];
        decoded_sharp = note[0];
        case(decoded_letter)
            4'b1100: semitone = 0;
            4'b1101: semitone = 2;
            4'b1110: semitone = 4;
            4'b1111: semitone = 5;
            4'b1000: semitone = 7;
            4'b1010: semitone = 9;
            4'b1011: semitone = 11;
            default: semitone = 0;
        endcase
        chromatic_pitch = decoded_octave * 12 + semitone + decoded_sharp;
    end

    // Y position calculation - UNCHANGED
    logic [9:0] calculated_y;
    logic [9:0] staff_base;
    logic [9:0] B4_line_y;
    logic signed [10:0] steps_from_B4;

    always_comb begin
        staff_base = VERTICAL_MARGIN + current_staff_num * (SCORE_HEIGHT + SPACE_BETWEEN_SCORES);
        B4_line_y = staff_base + 4 * STAFF_LINE_SPACING;
        steps_from_B4 = chromatic_pitch - 59; 
        calculated_y = B4_line_y - (steps_from_B4 * (STAFF_LINE_SPACING / 2)) - (NOTE_HEIGHT / 2);
    end

    // Stem direction - UNCHANGED
    logic calculated_stem_direction;
    logic [9:0] middle_line_y;
    logic [9:0] note_center_y;

    always_comb begin
        middle_line_y = staff_base + 2 * STAFF_LINE_SPACING;
        note_center_y = calculated_y + (NOTE_HEIGHT / 2);
        if (note_center_y <= middle_line_y) begin
            calculated_stem_direction = 1'b1;
        end else begin
            calculated_stem_direction = 1'b0;
        end
    end

    // Note storage - UNCHANGED
    always_ff @(posedge clk) begin
        if (~reset) begin
            note_count <= 0;
            current_x_pos <= NOTES_START_X;
            current_staff_num <= 0;
        end
        else if (note_dec && note_count < MAX_NOTES) begin
            note_chromatic_pitch[note_count] <= chromatic_pitch;
            note_duration[note_count] <= duration;
            note_x[note_count] <= current_x_pos;
            note_staff[note_count] <= current_staff_num;
            note_y[note_count] <= calculated_y;
            note_is_sharp[note_count] <= decoded_sharp;
            note_stem_direction[note_count] <= calculated_stem_direction;
            note_count <= note_count + 1'b1;
            current_x_pos <= current_x_pos + NOTE_SPACING;
            
            if (current_x_pos + NOTE_SPACING > 600) begin
                current_staff_num <= current_staff_num + 1;
                current_x_pos <= NOTES_START_X;
            end
        end
    end

    // ============ FIXED: Note rendering ============
    logic [9:0] note_rom_addr;
    logic [4:0] note_type;
    logic note_pixel;
    logic found_note;
    
    note_rom note_rom_inst (
        .clk(clk), 
        .addr(note_rom_addr),  
        .note_type(note_type), 
        .pixel_out(note_pixel)
    );

    logic [4:0] x_offset, y_offset;
    
    // STAGE 1: Calculate address using d1 (for ROM input)
    always_comb begin
        note_rom_addr = 0;
        note_type = 0;
        found_note = 0;
        
        for (int i = 0; i < MAX_NOTES; i++) begin
            if (i < note_count &&
                hcount_d1 >= note_x[i] && 
                hcount_d1 < (note_x[i] + NOTE_WIDTH) &&
                vcount_d1 >= note_y[i] && 
                vcount_d1 < (note_y[i] + NOTE_HEIGHT)) begin
                
                x_offset = hcount_d1 - note_x[i];
                y_offset = vcount_d1 - note_y[i];
                note_rom_addr = y_offset * NOTE_WIDTH + x_offset;
                note_type = {note_duration[i], note_stem_direction[i]};
                found_note = 1;
            end
        end
    end
    
    // Pipeline the flag through 2 cycles
    logic found_note_d1, found_note_d2;
    always_ff @(posedge clk) begin
        if (~reset) begin
            found_note_d1 <= 0;
            found_note_d2 <= 0;
        end else begin
            found_note_d1 <= found_note;
            found_note_d2 <= found_note_d1;
        end
    end
    
    // STAGE 2: Use ROM output (after 2-cycle delay)
    logic notes_pixel;
    always_comb begin
        notes_pixel = found_note_d2 & note_pixel;
    end

    // ============ FIXED: Sharp rendering ============
    logic [7:0] sharp_rom_addr;
    logic sharp_rom_output;
    logic found_sharp;
    logic [10:0] sharp_x;
    logic [9:0] sharp_y;
    
    sharp_rom sharp_rom_inst (
        .clk(clk),
        .addr(sharp_rom_addr),
        .pixel_out(sharp_rom_output)
    );
    
    // STAGE 1: Calculate sharp address using d1
    always_comb begin
        sharp_rom_addr = 0;
        found_sharp = 0;
        
        for (int i = 0; i < MAX_NOTES; i++) begin
            if (i < note_count && note_is_sharp[i]) begin
                sharp_x = note_x[i] + SHARP_OFFSET_X;
                sharp_y = note_y[i] + (NOTE_HEIGHT - SHARP_HEIGHT) / 2;

                if (hcount_d1 >= sharp_x && 
                    hcount_d1 < (sharp_x + SHARP_WIDTH) &&
                    vcount_d1 >= sharp_y && 
                    vcount_d1 < (sharp_y + SHARP_HEIGHT)) begin
                    
                    logic [3:0] sharp_x_offset, sharp_y_offset;
                    sharp_x_offset = hcount_d1 - sharp_x;
                    sharp_y_offset = vcount_d1 - sharp_y;
                    sharp_rom_addr = sharp_y_offset * SHARP_WIDTH + sharp_x_offset;
                    found_sharp = 1;
                end
            end
        end
    end
    
    // Pipeline sharp flag
    logic found_sharp_d1, found_sharp_d2;
    always_ff @(posedge clk) begin
        if (~reset) begin
            found_sharp_d1 <= 0;
            found_sharp_d2 <= 0;
        end else begin
            found_sharp_d1 <= found_sharp;
            found_sharp_d2 <= found_sharp_d1;
        end
    end
    
    // STAGE 2: Use sharp ROM output
    logic sharp_pixel;
    always_comb begin
        sharp_pixel = found_sharp_d2 & sharp_rom_output;
    end


// sharp symbol 
// 10 x 16

module sharp_rom (
    input logic clk,
    input logic [7:0] addr,
    output logic pixel_out
);

 logic rom [0:159];
    
    initial begin
        // Initialize all to 0
        for (int i = 0; i < 160; i++) begin
            rom[i] = 0;
        end
        
        // Sharp symbol: two vertical lines and two horizontal lines
        // Vertical lines at columns 3 and 6 (rows 0-15)
        for (int y = 0; y < 16; y++) begin
            rom[y * 10 + 3] = 1;
            rom[y * 10 + 6] = 1;
        end
        
        // Top horizontal line (slightly slanted): row 4-5
        // Row 4: columns 1-8
        for (int x = 1; x <= 8; x++) begin
            rom[4 * 10 + x] = 1;
        end
        // Row 5: columns 2-9
        for (int x = 2; x <= 9; x++) begin
            rom[5 * 10 + x] = 1;
        end
        
        // Bottom horizontal line (slightly slanted): row 10-11
        // Row 10: columns 0-7
        for (int x = 0; x <= 7; x++) begin
            rom[10 * 10 + x] = 1;
        end
        // Row 11: columns 1-8
        for (int x = 1; x <= 8; x++) begin
            rom[11 * 10 + x] = 1;
        end
    end
    
    always_ff @(posedge clk) begin
        pixel_out <= rom[addr];
    end

endmodule