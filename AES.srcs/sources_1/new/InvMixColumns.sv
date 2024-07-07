`timescale 1ns / 1ps

module InvMixColumns (
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
		times3 = times2(a) ^ a;
	endfunction

	function automatic logic[7:0] times4(input logic [7:0] a);
		times4 = times2(times2(a));
	endfunction

	function automatic logic[7:0] times8(input logic [7:0] a);
		times8 = times2(times4(a));
	endfunction

	function automatic logic[7:0] times9(input logic [7:0] a);
		times9 = times8(a) ^ a;
	endfunction

	function automatic logic[7:0] times11(input logic [7:0] a);
		times11 = times9(a) ^ times2(a);
	endfunction

	function automatic logic[7:0] times13(input logic [7:0] a);
		times13 = times9(a) ^ times4(a);
	endfunction

	function automatic logic[7:0] times14(input logic [7:0] a);
		times14 = times8(a) ^ times4(a) ^ times2(a);
	endfunction

	function automatic logic[31:0] invMix(input logic [31:0] a);
		logic[7:0] a0, a1, a2, a3;
		a3 = times14(a[24+:8]) ^ times11(a[16+:8]) ^ times13(a[8+:8]) ^ times9(a[0+:8]);
		a2 = times9(a[24+:8]) ^ times14(a[16+:8]) ^ times11(a[8+:8]) ^ times13(a[0+:8]);
		a1 = times13(a[24+:8]) ^ times9(a[16+:8]) ^ times14(a[8+:8]) ^ times11(a[0+:8]);
		a0 = times11(a[24+:8]) ^ times13(a[16+:8]) ^ times9(a[8+:8]) ^ times14(a[0+:8]);
		invMix = {a3, a2, a1, a0};
		// $display("\tinvMix(%h) = %h", a, invMix);
		// $display("\ta3:\t%h", a3);
		// $display("\ta2:\t%h", a2);
		// $display("\ta1:\t%h", a1);
		// $display("\ta0:\t%h", a0);
	endfunction

	always_comb
		begin
			// $display("InvMixColumns");
			// $display("\tiState:\t%h", iState);
			oState[96+:32] = invMix(iState[96+:32]);
			oState[64+:32] = invMix(iState[64+:32]);
			oState[32+:32] = invMix(iState[32+:32]);
			oState[0+:32]  = invMix(iState[0+:32]);
		end
endmodule
