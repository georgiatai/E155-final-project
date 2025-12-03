`timescale 1ns/1ps

module testbench_ctrl();

    // Parameters
    parameter BIT_WIDTH = 16;
    parameter N = 9;
    parameter FFT_SIZE = 512;
    parameter FS = 5000;

    // Inputs to DUT
    logic reset;
    logic A_note; // Active Low (0 = Pressed)

    // Outputs from DUT
    logic anode1, anode2;
    logic [6:0] seg;
    logic sharp;
    logic led_load, led_start;

    // Instantiate the Module
    fft_ctrl #(
        .BIT_WIDTH(BIT_WIDTH),
        .N(N),
        .FFT_SIZE(FFT_SIZE),
        .FS(FS)
    ) DUT (
        .reset(reset),
        .A_note(A_note), // Simulate button press here
        .anode1(anode1),
        .anode2(anode2),
        .seg(seg),
        .sharp(sharp),
        .led_load(led_load),
        .led_start(led_start)
    );

    // Helper to read internal signals for debugging
    // We look inside the DUT to see the "Raw" note vs the output
    logic [7:0] internal_note;
    logic internal_dec;
    logic internal_clk;
    
    assign internal_note = DUT.note;
    assign internal_dec = DUT.note_dec;
    assign internal_clk = DUT.clk; // We need to see the internal HSOSC clock

    // ------------------------------------------------------------
    // STIMULUS
    // ------------------------------------------------------------
    initial begin
        $display("==================================================");
        $display(" Testbench Started: FFT Control Module");
        $display("==================================================");

        // 1. Initial State (Reset Active, Button Released)
        reset = 0;   
        A_note = 1;  
        
        // Wait for HSOSC to start up (Libraries sometimes take 100ns to start oscillating)
        #200;
        
        // 2. Release Reset
        $display("[%0t] Releasing Reset...", $time);
        reset = 1;
        #200;

        // 3. Press the Button (Active Low)
        $display("[%0t] PRESSING BUTTON A...", $time);
        A_note = 0;

        // 4. Hold Button for Multiple FFT Frames
        // Since you are running in "Burst Mode" (Fast Read), 
        // a full FFT cycle takes about ~50 microseconds (approx 600 clocks).
        // We will hold for 200us to see about 4-5 full cycles.
        #5000000; 

        // 5. Release Button
        $display("[%0t] RELEASING BUTTON...", $time);
        A_note = 1;

        #10000;
		
		// 3. Press the Button (Active Low)
        $display("[%0t] PRESSING BUTTON A...", $time);
        A_note = 0;

        // 4. Hold Button for Multiple FFT Frames
        // Since you are running in "Burst Mode" (Fast Read), 
        // a full FFT cycle takes about ~50 microseconds (approx 600 clocks).
        // We will hold for 200us to see about 4-5 full cycles.
        #5000000; 

        // 5. Release Button
        $display("[%0t] RELEASING BUTTON...", $time);
        A_note = 1;

        #10000;
		
		// 3. Press the Button (Active Low)
        $display("[%0t] PRESSING BUTTON A...", $time);
        A_note = 0;

        // 4. Hold Button for Multiple FFT Frames
        // Since you are running in "Burst Mode" (Fast Read), 
        // a full FFT cycle takes about ~50 microseconds (approx 600 clocks).
        // We will hold for 200us to see about 4-5 full cycles.
        #500000; 

        // 5. Release Button
        $display("[%0t] RELEASING BUTTON...", $time);
        A_note = 1;

        #10000;
		
		// 3. Press the Button (Active Low)
        $display("[%0t] PRESSING BUTTON A...", $time);
        A_note = 0;

        // 4. Hold Button for Multiple FFT Frames
        // Since you are running in "Burst Mode" (Fast Read), 
        // a full FFT cycle takes about ~50 microseconds (approx 600 clocks).
        // We will hold for 200us to see about 4-5 full cycles.
        #500000; 

        // 5. Release Button
        $display("[%0t] RELEASING BUTTON...", $time);
        A_note = 1;

        #10000;
        $display("==================================================");
        $display(" Simulation Finished");
        $display("==================================================");
        $stop;
    end

    // ------------------------------------------------------------
    // MONITORING (The Debugger)
    // ------------------------------------------------------------
    
    // Monitor 1: Watch for the VALID note pulse
    always @(posedge internal_dec) begin
        $display("[%0t] FFT DONE! Valid Note Detected: %h", $time, internal_note);
    end

    // Monitor 2: Watch whenever the internal note changes value
    // This will show you the flickering. You will likely see it go to 0 immediately.
    always @(internal_note) begin
        if (reset) begin // Ignore reset noise
            if (internal_note == 0) 
                $display("[%0t] Note signal dropped to 00 (Reset/Loading)", $time);
            else
                $display("[%0t] Note signal set to %h", $time, internal_note);
        end
    end

endmodule