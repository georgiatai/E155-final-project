// Julia Gong E155
// mux.sv
// jgong@g.hmc.edu
// Date created: 9/5/2025
// This module turns on a dual 7-segment display using time multiplexing and outputs the sum of both numbers onto 5 LEDs
// The 7 segment display takes inputs from 8 DIP switches on the development board

module mux(input logic select,
		   input logic [3:0] s1, s2,
		   output logic [3:0] s,
		   output logic anode1, anode2
);

always_comb begin
    if (select) begin
        s = s1;
        anode1 = 1'b1;
        anode2 = 1'b0;
    end
    else begin
        s = s2; 
        anode1 = 1'b0;
        anode2 = 1'b1;
    end
end

endmodule