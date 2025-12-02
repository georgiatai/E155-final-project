// half note with downwards stem
// 20x30


module half_note_down_rom (
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
        
        // NOTEHEAD: HOLLOW circle (rows 7-14)
        // Row 7 (top edge): columns 1-11
        for (int x = 1; x <= 11; x++) begin
            rom[7 * 20 + x] = 1;
        end
        
        // Row 8 (left edge, right edge): columns 1-2 and 12-13
        rom[8 * 20 + 1] = 1;
        rom[8 * 20 + 2] = 1;
        rom[8 * 20 + 12] = 1;
        rom[8 * 20 + 13] = 1;
        
        // Row 9 (left edge, right edge): columns 1 and 14
        rom[9 * 20 + 1] = 1;
        rom[9 * 20 + 14] = 1;
        
        // Row 10 (center - left edge, right edge): columns 1 and 15
        rom[10 * 20 + 1] = 1;
        rom[10 * 20 + 15] = 1;
        
        // Row 11 (left edge, right edge): columns 1 and 15
        rom[11 * 20 + 1] = 1;
        rom[11 * 20 + 15] = 1;
        
        // Row 12 (left edge, right edge): columns 1 and 14
        rom[12 * 20 + 1] = 1;
        rom[12 * 20 + 14] = 1;
        
        // Row 13 (left edge, right edge): columns 1-2 and 12-13
        rom[13 * 20 + 1] = 1;
        rom[13 * 20 + 2] = 1;
        rom[13 * 20 + 12] = 1;
        rom[13 * 20 + 13] = 1;
        
        // Row 14 (bottom edge): columns 1-11
        for (int x = 1; x <= 11; x++) begin
            rom[14 * 20 + x] = 1;
        end
        
        // STEM: Vertical line on left side (columns 0-1, rows 7-29)
        for (int y = 7; y < 30; y++) begin
            rom[y * 20 + 0] = 1;
            rom[y * 20 + 1] = 1;
        end
    end
    
    always_ff @(posedge clk) begin
        pixel_out <= rom[addr];
    end


endmodule