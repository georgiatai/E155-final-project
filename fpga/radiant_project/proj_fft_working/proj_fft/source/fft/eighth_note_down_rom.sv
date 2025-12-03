// eighth note with downwards stem
// 20x30


module eighth_note_down_rom (
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
        
        // FLAG: Curves to the left from top of stem (rows 0-5)
        // Row 0: columns 0-1
        rom[0 * 20 + 0] = 1;
        rom[0 * 20 + 1] = 1;
        
        // Row 1: columns 0-2
        for (int x = 0; x <= 2; x++) begin
            rom[1 * 20 + x] = 1;
        end
        
        // Row 2: columns 0-3
        for (int x = 0; x <= 3; x++) begin
            rom[2 * 20 + x] = 1;
        end
        
        // Row 3: columns 1-4
        for (int x = 1; x <= 4; x++) begin
            rom[3 * 20 + x] = 1;
        end
        
        // Row 4: columns 1-3
        for (int x = 1; x <= 3; x++) begin
            rom[4 * 20 + x] = 1;
        end
        
        // Row 5: columns 1-2
        rom[5 * 20 + 1] = 1;
        rom[5 * 20 + 2] = 1;
        
        // NOTEHEAD: Filled circle (rows 7-14, same as quarter note down)
        // Row 7: columns 1-11
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
        
        // Row 10: columns 1-15
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
        
        // Row 14: columns 1-11
        for (int x = 1; x <= 11; x++) begin
            rom[14 * 20 + x] = 1;
        end
        
        // STEM: Vertical line on left side (columns 0-1, rows 0-14)
        for (int y = 0; y < 15; y++) begin
            rom[y * 20 + 0] = 1;
            rom[y * 20 + 1] = 1;
        end
    end
    
    always_ff @(posedge clk) begin
        pixel_out <= rom[addr];
    end

endmodule