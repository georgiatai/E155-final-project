module note_rom (input logic clk,
                  input logic [14:0] addr,
                  input logic [5:0] note_type,
                  output logic pixel_out
);
    
    // Memory arrays
	(* syn_ramstyle = "block_ram" *)
    logic [0:0] whole_bitmap [0:1799];
	logic [0:0] whole_sharp_bitmap [0:1799];
    logic [0:0] half_up_bitmap [0:1799];
	logic [0:0] half_up_sharp_bitmap [0:1799];
    logic [0:0] half_down_bitmap [0:1799];
	logic [0:0] half_down_sharp_bitmap [0:1799];
    logic [0:0] quarter_up_bitmap [0:1799];
	logic [0:0] quarter_up_sharp_bitmap [0:1799];
    logic [0:0] quarter_down_bitmap [0:1799];
	logic [0:0] quarter_down_sharp_bitmap [0:1799];
    logic [0:0] eighth_up_bitmap [0:1799];
	logic [0:0] eighth_up_sharp_bitmap [0:1799];
    logic [0:0] eighth_down_bitmap [0:1799];
	logic [0:0] eighth_down_sharp_bitmap [0:1799];
    
    
    initial begin
        $readmemb("quarter_up.mem", quarter_up_bitmap);
		$readmemb("quarter_up_sharp.mem", quarter_up_sharp_bitmap);
		
        $readmemb("quarter_down.mem", quarter_down_bitmap);
		$readmemb("quarter_down_sharp.mem", quarter_down_sharp_bitmap);
		
		$readmemb("eighth_up.mem", eighth_up_bitmap);
		$readmemb("eighth_up_sharp.mem", eighth_up_sharp_bitmap);
		
		$readmemb("eighth_down.mem", eighth_down_bitmap);
		$readmemb("eighth_down_sharp.mem", eighth_down_sharp_bitmap);
		
		$readmemb("half_up.mem", half_up_bitmap);
		$readmemb("half_up_sharp.mem", half_up_sharp_bitmap);
		
		$readmemb("half_down.mem", half_down_bitmap);
		$readmemb("half_down_sharp.mem", half_down_sharp_bitmap);
		
		$readmemb("whole.mem", whole_bitmap);
		$readmemb("whole_sharp.mem", whole_sharp_bitmap);
        // Add others when ready
    end
    
    // Pipeline registers
    logic [14:0] addr_d1, addr_d2;
    logic [5:0] note_type_d1, note_type_d2;
    
    always_ff @(posedge clk) begin
        addr_d1 <= addr;
        addr_d2 <= addr_d1;
        note_type_d1 <= note_type;
        note_type_d2 <= note_type_d1;
    end
    
    // Read all bitmaps in parallel, then multiplex the OUTPUT
    logic whole_bit, whole_sharp_bit;
	logic half_up_sharp_bit, half_up_bit, half_down_bit, half_down_sharp_bit;
    logic quarter_up_bit, quarter_up_sharp_bit, quarter_down_bit, quarter_down_sharp_bit;
    logic eighth_up_bit, eighth_up_sharp_bit, eighth_down_bit, eighth_down_sharp_bit;
	
    
    always_comb begin
        whole_bit = (addr_d2 < 1800) ? whole_bitmap[addr_d2] : 1'b0;
		whole_sharp_bit = (addr_d2 < 1800) ? whole_sharp_bitmap[addr_d2] : 1'b0;
		
        half_up_bit = (addr_d2 < 1800) ? half_up_bitmap[addr_d2] : 1'b0;
		half_up_sharp_bit = (addr_d2 < 1800) ? half_up_sharp_bitmap[addr_d2] : 1'b0;
		
        half_down_bit = (addr_d2 < 1800) ? half_down_bitmap[addr_d2] : 1'b0;
		half_down_sharp_bit = (addr_d2 < 1800) ? half_down_sharp_bitmap[addr_d2] : 1'b0;
		
        quarter_up_bit = (addr_d2 < 1800) ? quarter_up_bitmap[addr_d2] : 1'b0;
		quarter_up_sharp_bit = (addr_d2 < 1800) ? quarter_up_sharp_bitmap[addr_d2] : 1'b0;
		
        quarter_down_bit = (addr_d2 < 1800) ? quarter_down_bitmap[addr_d2] : 1'b0;
		quarter_down_sharp_bit = (addr_d2 < 1800) ? quarter_down_sharp_bitmap[addr_d2] : 1'b0;
		
        eighth_up_bit = (addr_d2 < 1800) ? eighth_up_bitmap[addr_d2] : 1'b0;
		eighth_up_sharp_bit = (addr_d2 < 1800) ? eighth_up_sharp_bitmap[addr_d2] : 1'b0;
		
        eighth_down_bit = (addr_d2 < 1800) ? eighth_down_bitmap[addr_d2] : 1'b0;
		eighth_down_sharp_bit = (addr_d2 < 1800) ? eighth_down_sharp_bitmap[addr_d2] : 1'b0;
    end
    
    // Multiplex the single-bit outputs based on note type
	
    always_comb begin
        case (note_type_d2)
            6'b1000_0_1: pixel_out = whole_sharp_bit;
            6'b1000_1_0: pixel_out = whole_bit;
			6'b0100_0_1: pixel_out = half_up_sharp_bit;
            6'b0100_0_0: pixel_out = half_up_bit;
			6'b0100_1_1: pixel_out = half_down_sharp_bit;
            6'b0100_1_0: pixel_out = half_down_bit;
			6'b0010_0_1: pixel_out = quarter_up_sharp_bit;
            6'b0010_0_0: pixel_out = quarter_up_bit;
			6'b0010_1_1: pixel_out = quarter_down_sharp_bit;
            6'b0010_1_0: pixel_out = quarter_down_bit;
			6'b0001_0_1: pixel_out = eighth_up_sharp_bit;
            6'b0001_0_0: pixel_out = eighth_up_bit;
			6'b0001_1_1: pixel_out = eighth_down_sharp_bit;
            6'b0001_1_0: pixel_out = eighth_down_bit;
            default:   pixel_out = 1'b0;
        endcase
    end
 
endmodule