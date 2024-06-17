`timescale 1ns / 1ps

module Cipher (
	input  logic         clk     ,
	input  logic         rst     ,
	input  logic         start   ,
	input  logic [127:0] roundKey,
	input  logic [127:0] iBlock  ,
	output logic [  3:0] round   ,
	output logic [127:0] oBlock  ,
	output logic         idle
);
	typedef enum { IDLE, START_CIPHER, LOOP, FINNAL } Step_t;
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
	logic[127:0] tmp_addRoundKey, tmp_SubBytes, tmp_ShiftRows, tmp_MixColumns, addRoundKeyInput;
	assign round = cnt;
	AddRoundKey addRoundKeyI (
		.roundKey(roundKey        ),
		.iState  (addRoundKeyInput),
		.oState  (tmp_addRoundKey )
	);
	SubBytes subBytesI (
		.in(state       ),
		.out(tmp_SubBytes)
	);
	ShiftRows shiftRowsI (
		.iState(tmp_SubBytes ),
		.oState(tmp_ShiftRows)
	);
	MixColumns mixColumnsI (
		.iState(tmp_ShiftRows ),
		.oState(tmp_MixColumns)
	);

	always_comb
		begin
			nextState = state;
			nextStep  = step;
			nextCnt   = cnt + 1;

			addRoundKeyInput = '0;

			case(step)
				IDLE :
					begin
						nextCnt = 0;
						if (start)
							begin
								nextState = iBlock;
								nextStep  = START_CIPHER;
							end
					end

				START_CIPHER : // cnt = 0
					begin
						nextStep         = LOOP;
						addRoundKeyInput = state;
						nextState        = tmp_addRoundKey;
					end

				LOOP : // cnt = 1...9 (9 times)
					begin
						addRoundKeyInput = tmp_MixColumns;
						nextState        = tmp_addRoundKey;
						if (cnt == 9)
							begin
								nextStep = FINNAL;
							end
					end

				FINNAL : // cnt = 10
					begin
						nextStep         = IDLE;
						addRoundKeyInput = tmp_ShiftRows;
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
