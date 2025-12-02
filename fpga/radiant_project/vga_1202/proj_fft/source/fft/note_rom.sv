module note_rom (input logic clk,
                  input logic [13:0] addr,
                  input logic [4:0] note_type,
                  output logic pixel_out
);
    
    // Memory arrays
    //logic [0:0] whole_bitmap [0:1199];
    //logic [0:0] half_up_bitmap [0:1199];
    //logic [0:0] half_down_bitmap [0:1199];
    //logic [0:0] quarter_up_bitmap [0:1199];
	(* syn_ramstyle = "block_ram" *)
    logic [0:0] quarter_down_bitmap [0:1199];
    //logic [0:0] eighth_up_bitmap [0:1199];
    //logic [0:0] eighth_down_bitmap [0:1199];
    
    initial begin
        //$readmemb("quarter_up.mem", quarter_up_bitmap);
        $readmemb("quarter_down.mem", quarter_down_bitmap);
        // Add others when ready
    end
    
    // Pipeline registers
    logic [13:0] addr_d1, addr_d2;
    logic [4:0] note_type_d1, note_type_d2;
    
    always_ff @(posedge clk) begin
        addr_d1 <= addr;
        addr_d2 <= addr_d1;
        note_type_d1 <= note_type;
        note_type_d2 <= note_type_d1;
    end
    
    // Read all bitmaps in parallel, then multiplex the OUTPUT
    logic whole_bit, half_up_bit, half_down_bit;
    logic quarter_up_bit, quarter_down_bit;
    logic eighth_up_bit, eighth_down_bit;
    
    always_comb begin
        //whole_bit = (addr_d2 < 1200) ? whole_bitmap[addr_d2] : 1'b0;
        //half_up_bit = (addr_d2 < 1200) ? half_up_bitmap[addr_d2] : 1'b0;
        //half_down_bit = (addr_d2 < 1200) ? half_down_bitmap[addr_d2] : 1'b0;
        //quarter_up_bit = (addr_d2 < 1200) ? quarter_up_bitmap[addr_d2] : 1'b0;
        quarter_down_bit = (addr_d2 < 1200) ? quarter_down_bitmap[addr_d2] : 1'b0;
        //eighth_up_bit = (addr_d2 < 1200) ? eighth_up_bitmap[addr_d2] : 1'b0;
        //eighth_down_bit = (addr_d2 < 1200) ? eighth_down_bitmap[addr_d2] : 1'b0;
    end
    
    // Multiplex the single-bit outputs based on note type
	
	assign pixel_out = quarter_down_bit;
    //always_comb begin
        //case (note_type_d2)
            //5'b1000_0: pixel_out = whole_bit;
            //5'b1000_1: pixel_out = whole_bit;
            //5'b0100_0: pixel_out = half_up_bit;
            //5'b0100_1: pixel_out = half_down_bit;
            //5'b0010_0: pixel_out = quarter_up_bit;
            //5'b0010_1: pixel_out = quarter_down_bit;
            //5'b0001_0: pixel_out = eighth_up_bit;
            //5'b0001_1: pixel_out = eighth_down_bit;
            //default:   pixel_out = 1'b0;
        //endcase
    //end
    
endmodule