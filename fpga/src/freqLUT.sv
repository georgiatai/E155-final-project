// Julia Gong
// 11/14/2025
// Look up table for notes

module freqLUT #(parameter BIT_WIDTH = 16)
                (input logic [BIT_WIDTH:0] frequency,
                 output logic [7:0] note);

// note decoding 
// letter(4b)_octave(3b)_sharp/flat/normal(1b)

always_comb begin
    if      (frequency >= 214 && frequency < 226) note = 8'b1010_011_0; // A3
    else if (frequency >= 226 && frequency < 240) note = 8'b1010_011_1; // A#3
    else if (frequency >= 240 && frequency < 254) note = 8'b1011_011_0; // B3
    else if (frequency >= 254 && frequency < 259) note = 8'b1100_100_0; // C4
    else if (frequency >= 259 && frequency < 285) note = 8'b1100_100_1; // C#4
    else if (frequency >= 285 && frequency < 303) note = 8'b1101_100_0; // D4
    else if (frequency >= 303 && frequency < 320) note = 8'b1101_100_1; // D#4
    else if (frequency >= 320 && frequency < 340) note = 8'b1110_100_0; // E4
    else if (frequency >= 340 && frequency < 360) note = 8'b1111_100_0; // F4
    else if (frequency >= 360 && frequency < 381) note = 8'b1111_100_1; // F#4
    else if (frequency >= 381 && frequency < 404) note = 8'b1000_100_0; // G4
    else if (frequency >= 404 && frequency < 428) note = 8'b1000_100_1; // G#4
    else if (frequency >= 428 && frequency < 453) note = 8'b1010_100_0; // A4
    else if (frequency >= 453 && frequency < 480) note = 8'b1010_100_1; // A#4
    else if (frequency >= 480 && frequency < 508) note = 8'b1011_100_0; // B4
    else if (frequency >= 508 && frequency < 538) note = 8'b1100_101_0; // C5
    else if (frequency >= 538 && frequency < 562) note = 8'b1100_101_1; // C#5
    else if (frequency >= 562 && frequency < 605) note = 8'b1101_101_0; // D5
    else if (frequency >= 605 && frequency < 641) note = 8'b1101_101_1; // D#5
    else if (frequency >= 641 && frequency < 679) note = 8'b1110_101_0; // E5
    else if (frequency >= 679 && frequency < 719) note = 8'b1111_101_0; // F5
    else if (frequency >= 719 && frequency < 762) note = 8'b1111_101_1; // F#5
    else if (frequency >= 762 && frequency < 807) note = 8'b1000_101_0; // G5
    else if (frequency >= 807 && frequency < 855) note = 8'b1000_101_1; // G#5
    else if (frequency >= 855 && frequency < 906) note = 8'b1010_101_0; // A5
    else                                         note = 8'b0000_000_0; // default
end

endmodule