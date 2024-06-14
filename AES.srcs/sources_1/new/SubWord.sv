`timescale 1ns / 1ps

module SubWord(
    input logic [31 : 0] in,
    output logic [31 : 0] out
    );

    for (genvar i = 0; i < 4; i++) begin : loop
        SBox sbox(
            .in(in[i * 8 +: 8]),
            .out(out[i * 8 +: 8])
        );
    end

endmodule
