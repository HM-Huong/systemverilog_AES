`timescale 1ns / 1ps

module SubBytes #(parameter n = 16) (
	input  logic [n*8-1:0] in ,
	output logic [n*8-1:0] out
);
	for (genvar i = 0; i < n; i++) begin : loop
		SBox sbox(
			.in(in[i * 8 +: 8]),
			.out(out[i * 8 +: 8])
		);
	end
endmodule
