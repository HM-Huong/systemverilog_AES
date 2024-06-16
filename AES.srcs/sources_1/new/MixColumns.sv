`timescale 1ns / 1ps

module MixColumns (
	input  logic [127:0] iState,
	output logic [127:0] oState
);

	function automatic logic[7:0] times2(input logic [7:0] a);
		if (a[7] == 1)
			times2 = (a << 1) ^ 8'h1b;
		else
			times2 = a << 1;
	endfunction

	function automatic logic[7:0] times3(input logic [7:0] a);
		times3 = a ^ times2(a);
	endfunction

	function automatic logic[31:0] mix(input logic [31:0] a);
		logic[7:0] a0, a1, a2, a3;
		a3 = times2(a[24+:8]) ^ times3(a[16+:8]) ^ a[8+:8] ^ a[0+:8];
		a2 = a[24+:8] ^ times2(a[16+:8]) ^ times3(a[8+:8]) ^ a[0+:8];
		a1 = a[24+:8] ^ a[16+:8] ^ times2(a[8+:8]) ^ times3(a[0+:8]);
		a0 = times3(a[24+:8]) ^ a[16+:8] ^ a[8+:8] ^ times2(a[0+:8]);
		mix = {a3, a2, a1, a0};
	endfunction

	always_comb
		begin
			oState[96+:32] = mix(iState[96+:32]);
			oState[64+:32] = mix(iState[64+:32]);
			oState[32+:32] = mix(iState[32+:32]);
			oState[0+:32]  = mix(iState[0+:32]);
		end
endmodule
