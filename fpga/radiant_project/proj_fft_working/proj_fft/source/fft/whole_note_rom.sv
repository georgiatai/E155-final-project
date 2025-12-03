// whole note
// 20x30


module whole_note_rom (
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
        
        // NOTEHEAD: HOLLOW oval shape, wider than half note (rows 13-20)
        // Row 13 (top edge): columns 5-14
        for (int x = 5; x <= 14; x++) begin
            rom[13 * 20 + x] = 1;
        end
        
        // Row 14 (left edge, right edge): columns 3-4 and 15-16
        rom[14 * 20 + 3] = 1;
        rom[14 * 20 + 4] = 1;
        rom[14 * 20 + 15] = 1;
        rom[14 * 20 + 16] = 1;
        
        // Row 15 (left edge, right edge): columns 2 and 17
        rom[15 * 20 + 2] = 1;
        rom[15 * 20 + 17] = 1;
        
        // Row 16 (center - left edge, right edge): columns 2 and 17
        rom[16 * 20 + 2] = 1;
        rom[16 * 20 + 17] = 1;
        
        // Row 17 (left edge, right edge): columns 2 and 17
        rom[17 * 20 + 2] = 1;
        rom[17 * 20 + 17] = 1;
        
        // Row 18 (left edge, right edge): columns 3-4 and 15-16
        rom[18 * 20 + 3] = 1;
        rom[18 * 20 + 4] = 1;
        rom[18 * 20 + 15] = 1;
        rom[18 * 20 + 16] = 1;
        
        // Row 19 (bottom edge): columns 5-14
        for (int x = 5; x <= 14; x++) begin
            rom[19 * 20 + x] = 1;
        end
    end
    
    always_ff @(posedge clk) begin
        pixel_out <= rom[addr];
    end

endmodule