// quarter note with downwards stem
// 20x30

module quarter_note_down_rom (
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
        
        // NOTEHEAD: Filled circle (rows 7-14)
        // Row 7 (top of circle): columns 1-11
        for (int x = 1; x <= 11; x++) begin
            rom[7 * 20 + x] = 1;
        end
        
        // Row 8: columns 1-13
        for (int x = 1; x <= 13; x++) begin
            rom[8 * 20 + x] = 1;
        end
        
        // Row 9: columns 1-14
        for (int x = 1; x <= 14; x++) begin
            rom[9 * 20 + x] = 1;
        end
        
        // Row 10 (center): columns 1-15
        for (int x = 1; x <= 15; x++) begin
            rom[10 * 20 + x] = 1;
        end
        
        // Row 11: columns 1-15
        for (int x = 1; x <= 15; x++) begin
            rom[11 * 20 + x] = 1;
        end
        
        // Row 12: columns 1-14
        for (int x = 1; x <= 14; x++) begin
            rom[12 * 20 + x] = 1;
        end
        
        // Row 13: columns 1-13
        for (int x = 1; x <= 13; x++) begin
            rom[13 * 20 + x] = 1;
        end
        
        // Row 14 (bottom of circle): columns 1-11
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