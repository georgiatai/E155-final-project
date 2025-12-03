// eighth note with upwards stem
// 20x30

module eighth_note_up_rom (
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
        
        // FLAG: Curves to the right from top of stem (rows 0-5)
        // Row 0: columns 18-19
        rom[0 * 20 + 18] = 1;
        rom[0 * 20 + 19] = 1;
        
        // Row 1: columns 18-19 (curve starts)
        for (int x = 17; x <= 19; x++) begin
            rom[1 * 20 + x] = 1;
        end
        
        // Row 2: columns 16-19
        for (int x = 16; x <= 19; x++) begin
            rom[2 * 20 + x] = 1;
        end
        
        // Row 3: columns 15-18
        for (int x = 15; x <= 18; x++) begin
            rom[3 * 20 + x] = 1;
        end
        
        // Row 4: columns 16-18
        for (int x = 16; x <= 18; x++) begin
            rom[4 * 20 + x] = 1;
        end
        
        // Row 5: columns 17-18
        rom[5 * 20 + 17] = 1;
        rom[5 * 20 + 18] = 1;
        
        // STEM: Vertical line (columns 18-19, rows 0-14)
        for (int y = 0; y < 15; y++) begin
            rom[y * 20 + 18] = 1;
            rom[y * 20 + 19] = 1;
        end
        
        // NOTEHEAD: Filled circle (rows 15-22, same as quarter note)
        // Row 15: columns 8-19
        for (int x = 8; x <= 19; x++) begin
            rom[15 * 20 + x] = 1;
        end
        
        // Row 16: columns 6-19
        for (int x = 6; x <= 19; x++) begin
            rom[16 * 20 + x] = 1;
        end
        
        // Row 17: columns 5-19
        for (int x = 5; x <= 19; x++) begin
            rom[17 * 20 + x] = 1;
        end
        
        // Row 18: columns 4-18
        for (int x = 4; x <= 18; x++) begin
            rom[18 * 20 + x] = 1;
        end
        
        // Row 19: columns 4-18
        for (int x = 4; x <= 18; x++) begin
            rom[19 * 20 + x] = 1;
        end
        
        // Row 20: columns 5-18
        for (int x = 5; x <= 18; x++) begin
            rom[20 * 20 + x] = 1;
        end
        
        // Row 21: columns 6-18
        for (int x = 6; x <= 18; x++) begin
            rom[21 * 20 + x] = 1;
        end
        
        // Row 22: columns 8-18
        for (int x = 8; x <= 18; x++) begin
            rom[22 * 20 + x] = 1;
        end
    end
    
    always_ff @(posedge clk) begin
        pixel_out <= rom[addr];
    end


endmodule