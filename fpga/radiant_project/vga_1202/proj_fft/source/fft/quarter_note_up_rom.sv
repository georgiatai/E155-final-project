// quarter note with upwards stem
// 20x60
module quarter_note_up_rom (input logic clk,
                  input logic [13:0] addr,  // 12 bits for 30*80 = 3200 addresses
                  output logic qup_out
);
    
    // Memory array for treble clef bitmap
    // 20 pixels wide x 30 pixels tall = 600 bits
    // Format: logic [DataWidth-1:0] MemoryName [Depth-1:0];
    // We use [0:0] to explicitly make it a 1-bit wide memory.
    logic [0:0] qup_bitmap [0:1199];
    case 
    // Initialize from file - create this file using the Python script
    initial begin
        $readmemb("quarter_up.mem", qup_bitmap);
    end
    
    // Pipeline registers for 2-cycle delay
    logic [13:0] addr_d1, addr_d2;
    
    always_ff @(posedge clk) begin
        addr_d1 <= addr;
        addr_d2 <= addr_d1;
    end
    
    // Output the bit at the addressed location
    assign qup_out = (addr_d2 < 600) ? qup_bitmap[addr_d2] : 1'b0;
    
endmodule