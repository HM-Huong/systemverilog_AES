`timescale 1ns / 1ps

module SubBytes(
    input logic [127 : 0] iState,
    output logic [127 : 0] oState
    );
		for (genvar i = 0; i < 16; i++) begin : loop
			SBox sbox(
				.in(iState[i * 8 +: 8]),
				.out(oState[i * 8 +: 8])
			);
		end
endmodule
