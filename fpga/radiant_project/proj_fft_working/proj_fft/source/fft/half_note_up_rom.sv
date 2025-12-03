// half note with upwards stem
// 20x30


module half_note_up_rom (
    input logic clk,
    input logic [9:0] addr,
    output logic pixel_out
);


logic rom [0:599];
    
    initial begin
        // Initialize all to 0
        for (int i = 0; i < 600; i++) begin
            rom[i] = 0;
        end
        
        // STEM: Vertical line on right side (columns 18-19, rows 0-14)
        for (int y = 0; y < 15; y++) begin
            rom[y * 20 + 18] = 1;
            rom[y * 20 + 19] = 1;
        end
        
        // NOTEHEAD: HOLLOW circle (rows 15-22)
        // Row 15 (top edge): columns 8-19
        for (int x = 8; x <= 19; x++) begin
            rom[15 * 20 + x] = 1;
        end
        
        // Row 16 (left edge, right edge): columns 6-7 and 18-19
        rom[16 * 20 + 6] = 1;
        rom[16 * 20 + 7] = 1;
        rom[16 * 20 + 18] = 1;
        rom[16 * 20 + 19] = 1;
        
        // Row 17 (left edge, right edge): columns 5 and 19
        rom[17 * 20 + 5] = 1;
        rom[17 * 20 + 19] = 1;
        
        // Row 18 (center - left edge, right edge): columns 4 and 18
        rom[18 * 20 + 4] = 1;
        rom[18 * 20 + 18] = 1;
        
        // Row 19 (left edge, right edge): columns 4 and 18
        rom[19 * 20 + 4] = 1;
        rom[19 * 20 + 18] = 1;
        
        // Row 20 (left edge, right edge): columns 5 and 18
        rom[20 * 20 + 5] = 1;
        rom[20 * 20 + 18] = 1;
        
        // Row 21 (left edge, right edge): columns 6-7 and 17-18
        rom[21 * 20 + 6] = 1;
        rom[21 * 20 + 7] = 1;
        rom[21 * 20 + 17] = 1;
        rom[21 * 20 + 18] = 1;
        
        // Row 22 (bottom edge): columns 8-18
        for (int x = 8; x <= 18; x++) begin
            rom[22 * 20 + x] = 1;
        end
    end
    
    always_ff @(posedge clk) begin
        pixel_out <= rom[addr];
    end



endmodule