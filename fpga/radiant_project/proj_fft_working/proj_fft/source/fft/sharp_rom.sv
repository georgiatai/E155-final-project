// sharp symbol 
// 10 x 16
module sharp_rom (input logic clk,
                  input logic [13:0] addr,  // 12 bits for 30*80 = 3200 addresses
                  output logic pixel_out
);
    
    // Memory array for note bitmap
    // 20 pixels wide x 60 pixels tall = 1200 bits
    // Format: logic [DataWidth-1:0] MemoryName [Depth-1:0];
    // We use [0:0] to explicitly make it a 1-bit wide memory.
    logic [0:0] sharp_bitmap [0:159];
   
			
    // Initialize from file - create this file using the Python script
    initial begin
        $readmemb("sharp.mem", sharp_bitmap);
    end
    
    // Pipeline registers for 2-cycle delay
    logic [13:0] addr_d1, addr_d2;
    
    always_ff @(posedge clk) begin
        addr_d1 <= addr;
        addr_d2 <= addr_d1;
    end
    
    // Output the bit at the addressed location
    assign pixel_out = (addr_d2 < 160) ? sharp_bitmap[addr_d2] : 1'b0;
    
endmodule