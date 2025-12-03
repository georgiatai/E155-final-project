// vga controller module

module vgactrl (input  logic clk, 
                input  logic reset, 
                output logic hsync, 
                output logic vsync, 
                output logic [10:0] hcount,  
                output logic [9:0]  vcount, 
                output logic active_video);

    // VGA 640x480 @ 60Hz 1024 x 600
    // Pixel clock: 25.175 MHz

    // Front Porch: time between end of the visible line and start of horizontal sync pulse 
    // allows electron beam to move from end of line to start of next

    // Horizontal Sync Pulse: pulse that indicates line done scanning and sto start next

    // Back porch: time after horizontal sync pulse and before start of visible line 
    // allows electron beam to stabilize before drawing next line

    // Visible area: area where line is scanned
	
	logic hsync1, hsync2;
	logic vsync1, vsync2;

    // horizontal
    localparam H_DISPLAY    = 640;  // Visible
    localparam H_FRONT      = 16;   // Front porch
    localparam H_SYNC       = 96;   // Sync pulse
    localparam H_BACK       = 48;   // Back porch
    localparam H_TOTAL      = 800;  // Total

    // vertical
    localparam V_DISPLAY    = 480;  // Visible
    localparam V_FRONT      = 10;   // Front porch
    localparam V_SYNC       = 2;    // Sync pulse
    localparam V_BACK       = 33;   // Back porch
    localparam V_TOTAL      = 525;  // Total

    localparam H_DISPLAY_START = H_SYNC + H_BACK;
    localparam H_DISPLAY_END = H_SYNC + H_BACK + H_DISPLAY;
    localparam V_DISPLAY_START = V_SYNC + V_BACK;
    localparam V_DISPLAY_END = V_SYNC + V_BACK + V_DISPLAY;
    
    always_ff @(posedge clk, negedge reset) begin
        if (~reset) begin
            hcount <= 0;
            vcount <= 0;

        end else begin
            if (hcount == H_TOTAL - 1) begin
                hcount <= 0;
                if (vcount == V_TOTAL - 1) begin
                    vcount <= 0;
                end else begin 
                    vcount <= vcount + 1;
                end
            end else begin
                hcount <= hcount + 1;
            end
        end
    end

    assign hsync = ~(hcount < H_SYNC); // active low
    assign vsync = ~(vcount < V_SYNC); // active low
	

    // the inverse of this will tell me if i am in a blank region (anywhere where i am not in the display zone)
    assign active_video = ((hcount >= H_DISPLAY_START && hcount < H_DISPLAY_END) && (vcount >= V_DISPLAY_START && vcount < V_DISPLAY_END));

endmodule