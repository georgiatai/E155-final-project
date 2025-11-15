// Julia Gong
// 11/14/2025
// module determines the duration of the notes based on the number maximum magnitudes of fft frames

module notedur #(parameter BIT_WIDTH = 16)
                (input logic clk, reset,
                 input logic [7:0] note_in,
                 input logic note_dec,
                 output logic [7:0] note_out,
                 output logic [BIT_WIDTH - 1:0] duration,
                 output logic note_ready);

logic [7:0] note_prev;
logic [BIT_WIDTH - 1:0] duration_cnt;
logic note_first;

always_ff @(posedge clk, reset) begin
    if (~reset) begin
        duration_cnt <= 0;
        note_prev <= 0;
        note_ready <= 0;
        note_first <= 1'b1;
    end
    else begin
    note_ready <= 0;
        if (note_dec) begin
            if (note_first) begin
                note_prev <= note_in;
                duration_cnt <= 1'b1;
                note_first <= 0;
            end
            else if (note_prev == note_in) begin
                duration_cnt <= duration_cnt + 1'b1;
            end
            else begin // note_prev != note_in
                note_ready <= 1'b1;
                note_out <= prev_note;
                duration <= duration_cnt;
                // reset duration and set new note
                note_prev <= note_in;
                duration_cnt <= 1'b1
            end
        end
    end
end


endmodule