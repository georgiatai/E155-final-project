// module to detect note duration

module notedur (input logic clk, reset, 
                input logic [7:0] note,
                input logic note_dec, 
                output logic [3:0] note_dur,
                output logic       new_note);

// note duration
// Sampling at 5Khz for 512 samples is 0.1024s

// 8th note (0.25s) 0b0001
// 2-3 samples

// Quarter note (0.5) 0b0010
// 4-6 samples

// Half note (1s) 0b0100
// 9-12 samples

// Whole note (2s) 0b1000
// 19-22

logic [7:0] prev_note;
logic [5:0] note_cnt, prev_note_cnt;

always_ff @(posedge clk) begin
    if (~reset) begin
        note_cnt <= 6'b0;
        prev_note <= 8'b0;
        prev_note_cnt <= 6'b0;
        new_note <= 0;
    end
    else if (note_dec) begin // check if this signal only pulses once, if not find a different one
        if (prev_note == note) begin 
            note_cnt <= note_cnt + 1;
            prev_note <= note;
            prev_note_cnt <= 6'b0;
            new_note <= 0;
        end
        else begin // reset if new note
            note_cnt <= 6'b000001;
            prev_note <= note;
            prev_note_cnt <= note_cnt;
            new_note <= 0;
        end
    end
    else begin
        prev_note <= prev_note;
        note_cnt <= note_cnt;
        prev_note_cnt <= 6'b0;
        new_note <= 0;
    end
end

// can always change counts to fit notes
always_comb begin
    if (prev_note_cnt >= 6'd2 && prev_note_cnt <= 6'd3) note_dur = 4'b0001; // eighth note
    else if (prev_note_cnt >= 6'd4 && prev_note_cnt <= 6'd6) note_dur = 4'b0010; // quarter note
    else if (prev_note_cnt >= 6'd9 && prev_note_cnt <= 6'd12) note_dur = 4'b0100;
    else if (prev_note_cnt >= 6'd19 && prev_note_cnt <= 22) note_dur = 4'b1000;
    else note_dur = 4'b0000;
end


endmodule