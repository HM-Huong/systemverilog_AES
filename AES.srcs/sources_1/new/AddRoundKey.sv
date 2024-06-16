`timescale 1ns / 1ps

module AddRoundKey (
	input  logic [127:0] roundKey, iState,
	output logic [127:0] oState
);

	assign oState = iState ^ roundKey;
endmodule
