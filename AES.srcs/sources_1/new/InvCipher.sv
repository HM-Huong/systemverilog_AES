`timescale 1ns / 1ps

module InvCipher (
	input  logic         clk     ,
	input  logic         rst     ,
	input  logic         start   ,
	input  logic [127:0] roundKey,
	input  logic [127:0] iBlock  ,
	output logic [  3:0] round   ,
	output logic [127:0] oBlock  ,
	output logic         idle
);
	typedef enum { IDLE, START_INV_CIPHER, LOOP, FINNAL } Step_t;
	Step_t step, nextStep;
	logic[127:0] state, nextState;
	logic[3:0] cnt, nextCnt;

	// state register
	always_ff @(posedge clk or posedge rst)
		begin
			if (rst)
				begin
					step  <= IDLE;
					state <= '0;
					cnt   <= 0;
				end
			else
				begin
					step  <= nextStep;
					state <= nextState;
					cnt   <= nextCnt;
				end
		end

	// next state logic
	logic[127:0] tmp_addRoundKey, addRoundKeyInput;
	assign round = cnt;
	AddRoundKey AddRoundKeyI (
		.roundKey(roundKey        ),
		.iState  (addRoundKeyInput),
		.oState  (tmp_addRoundKey )
	);

	logic[127:0] tmp_InvShiftRows;
	InvShiftRows InvShiftRowsI (
		.iState(state           ),
		.oState(tmp_InvShiftRows)
	);

	logic[127:0] tmp_InvSubBytes;
	InvSubBytes InvSubBytesI (
		.in(tmp_InvShiftRows),
		.out(tmp_InvSubBytes )
	);

	logic[127:0] tmp_InvMixColumns;
	InvMixColumns InvMixColumnsI (
		.iState(tmp_addRoundKey  ),
		.oState(tmp_InvMixColumns)
	);

	always_comb
		begin
			nextState = state;
			nextStep  = step;
			nextCnt   = cnt - 1;

			addRoundKeyInput = '0;

			case(step)
				IDLE :
					begin
						nextCnt = 10;
						if (start)
							begin
								nextState = iBlock;
								nextStep  = START_INV_CIPHER;
							end
					end

				START_INV_CIPHER : // cnt = 10
					begin
						nextStep         = LOOP;
						addRoundKeyInput = state;
						nextState        = tmp_addRoundKey;
					end

				LOOP : // cnt = 9...1 (9 times)
					begin
						addRoundKeyInput = tmp_InvSubBytes;
						nextState        = tmp_InvMixColumns;
						if (cnt == 1)
							begin
								nextStep = FINNAL;
							end
					end

				FINNAL : // cnt = 0
					begin
						nextStep         = IDLE;
						addRoundKeyInput = tmp_InvSubBytes;
						nextState        = tmp_addRoundKey;
						nextCnt          = 0;
					end
			endcase
		end

	// output logic
	always_comb
		begin
			oBlock = state;
			idle   = (step == IDLE);
		end
endmodule
