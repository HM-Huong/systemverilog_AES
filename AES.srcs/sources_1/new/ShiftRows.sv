`timescale 1ns / 1ps

module ShiftRows (
	input  logic [127:0] iState,
	output logic [127:0] oState
);

	always_comb
		begin
			/* column 0 no change */
			oState[120+:8] = iState[120+:8];
			oState[88+:8]  = iState[88+:8];
			oState[56+:8]  = iState[56+:8];
			oState[24+:8]  = iState[24+:8];

			/*2nd column , column 1 , 1 shift up */
			oState[112+:8] = iState[80+:8];
			oState[80+:8]  = iState[48+:8];
			oState[48+:8]  = iState[16+:8];
			oState[16+:8]  = iState[112+:8];

			/*3rd column , column 2 , 2 shifts up */
			oState[104+:8] = iState[40+:8];
			oState[72+:8]  = iState[8+:8];
			oState[40+:8]  = iState[104+:8];
			oState[8+:8]   = iState[72+:8];

			/*4th column , column 3 , 3 shifts up */
			oState[96+:8] = iState[0+:8];
			oState[64+:8] = iState[96+:8];
			oState[32+:8] = iState[64+:8];
			oState[0+:8]  = iState[32+:8];
		end;
endmodule
