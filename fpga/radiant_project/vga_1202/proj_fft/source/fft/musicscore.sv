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
    localparam NUM_SCORES = 4;
    localparam SCORE_HEIGHT = 5 * (STAFF_LINE_SPACING + STAFF_LINE_THICKNESS);
    localparam VERTICAL_MARGIN = 90;
    localparam HORIZONTAL_MARGIN = 200;
    localparam TOTAL_CONTENT_HEIGHT = NUM_SCORES * SCORE_HEIGHT;
    localparam SPACE_BETWEEN_SCORES = (480 - VERTICAL_MARGIN - TOTAL_CONTENT_HEIGHT) / (NUM_SCORES - 1);
    localparam CLEF_START_X = 200;
    localparam CLEF_WIDTH = 40;
    localparam CLEF_HEIGHT = 80;
    localparam NOTE_WIDTH = 20;
    localparam NOTE_HEIGHT = 60;
    localparam NOTE_SPACING = 40;
    localparam NOTES_START_X = CLEF_START_X + CLEF_WIDTH + 20;
    localparam SHARP_WIDTH = 10;
    localparam SHARP_HEIGHT = 16;
    localparam SHARP_OFFSET_X = -12;
    localparam MAX_NOTES = 32;
    
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
    logic [1:0] current_score;
    logic [9:0] score_base_y;
    logic [9:0] y_in_score;
    logic [3:0] line_num;
    logic on_staff_line;
    
    always_comb begin
        staff_pixel = 0;
        current_score = 0;
        score_base_y = 0;
        y_in_score = 0;
        line_num = 0;
        on_staff_line = 0;
        
        if (active_d2 && vcount_d2 >= VERTICAL_MARGIN) begin
            for (int i = 0; i < NUM_SCORES; i++) begin
                score_base_y = VERTICAL_MARGIN + i * (SCORE_HEIGHT + SPACE_BETWEEN_SCORES);
                if (vcount_d2 >= score_base_y && vcount_d2 < (score_base_y + SCORE_HEIGHT)) begin
                    current_score = i;
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
            for (int i = 0; i < NUM_SCORES; i++) begin
                score_base_y = VERTICAL_MARGIN + i * (SCORE_HEIGHT + SPACE_BETWEEN_SCORES);
                
                if (hcount >= CLEF_START_X && hcount < (CLEF_START_X + CLEF_WIDTH) &&
                    vcount >= (score_base_y - 22) && vcount < (score_base_y - 22 + CLEF_HEIGHT)) begin
                    in_clef_region = 1;
                    clef_x = hcount - CLEF_START_X;
                    clef_y = vcount - (score_base_y - 22);
                    clef_addr = clef_y * CLEF_WIDTH + clef_x;
                end
            end
        end
    end
    
    treblerom clef_rom (
        .clk(clk),
        .addr(clef_addr),
        .treble_out(clef_pixel)
    );
	
	
	
	logic [9:0] note_rom_addr;
    logic [4:0] note_type; // To feed the ROM
    logic found_in_box;

    logic [10:0] x_offset;
    logic [9:0]  y_offset;

localparam FIXED_NOTE_X = 280; 
    localparam FIXED_NOTE_Y = 200; // Middle of screen
	localparam [4:0] FIXED_NOTE_TYPE = {4'd4, 1'b1};
    always_comb begin
        note_rom_addr = 0;
        note_type = 0;
        found_in_box = 0;

        // Check if delayed coordinates are inside our Hardcoded Box
        if (hcount_d1 >= FIXED_NOTE_X && hcount_d1 < (FIXED_NOTE_X + NOTE_WIDTH) &&
            vcount_d1 >= FIXED_NOTE_Y && vcount_d1 < (FIXED_NOTE_Y + NOTE_HEIGHT)) begin
            
            x_offset = hcount_d1 - FIXED_NOTE_X;
            y_offset = vcount_d1 - FIXED_NOTE_Y;
            
            // Calculate Address
            note_rom_addr = y_offset * NOTE_WIDTH + x_offset;
            note_type = FIXED_NOTE_TYPE;
            found_in_box = 1;
        end
    end
  
      logic note_pixel_from_rom;

    note_rom note_rom_inst (
        .clk(clk), 
        .addr(note_rom_addr),  
        .note_type(note_type), 
        .pixel_out(note_pixel_from_rom)
    );

    
    // Combine all pixels
    always_comb begin
        if (hcount_d2 <= HORIZONTAL_MARGIN | hcount_d2 >= 720) begin
            pixel_out = 1'b0;
        end else begin
            pixel_out = staff_pixel | note_pixel_from_rom | 
                       (in_clef_region & clef_pixel);
        end
    end

endmodule