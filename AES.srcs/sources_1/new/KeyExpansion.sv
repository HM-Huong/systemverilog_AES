`timescale 1ns / 1ps

// key: "0123456789abcdef"
//       ^              ^
//      MSB            LSB

module KeyExpansion (
	input  logic         clk     ,
	input  logic         rst     ,
	input  logic         startGen,
	input  logic [127:0] inKey   ,
	input  logic [  3:0] round   ,
	output logic [127:0] rKey    ,
	output logic         idle
);

	typedef enum { IDLE, UPDATE_ROUND_KEY } Step_t;
	Step_t step, nextStep;
	logic[127:0] preW, curW;
	logic[127:0] w[0:10];
	logic[3:0] cnt, nextCnt;
	logic en_w, update_preW;

	// state register
	always_ff @(posedge clk or posedge rst)
		begin
			if (rst)
				begin
					step <= IDLE;
					cnt  <= 0;
					preW <= 0;
				end
			else
				begin
					step <= nextStep;
					cnt  <= nextCnt;

					if (en_w)
						w[cnt] <= curW;

					if (update_preW)
						preW <= curW;
				end
		end

	logic[31:0] rcon, subWordOut;
	Rcon RconI (
		.round(cnt ),
		.rcon (rcon)
	);

	SubBytes #(4) SubWordI (
		.in ({preW[0 +: 24], preW[24 +: 8]}),
		.out(subWordOut                    )
	);

	// next state logic
	always_comb
		begin
			// calculate curW
			curW[96+:32] = preW[96 +: 32] ^ subWordOut ^ rcon;
			curW[64+:32] = preW[64 +: 32] ^ curW[96 +: 32];
			curW[32+:32] = preW[32 +: 32] ^ curW[64 +: 32];
			curW[0+:32]  = preW[0  +: 32] ^ curW[32 +: 32];

			// default next state values
			nextStep = step;
			nextCnt  = cnt + 1;

			// control signals
			en_w        = 0;
			update_preW = 0;

			case (step)
				IDLE :
					begin
						nextCnt = 0;

						if (startGen)
							begin
								nextCnt = 1;

								// first round key is the input key
								curW        = inKey;

								// update preW and w[0] to curW
								update_preW = 1;
								en_w = 1;

								nextStep = UPDATE_ROUND_KEY;
							end
					end

				UPDATE_ROUND_KEY : // cnt = 1...10
					begin
						// update preW and w[cnt] to curW
						en_w        = 1;
						update_preW = 1;

						if (cnt == 10)
							nextStep = IDLE;
					end
			endcase
		end

	// output logic
	always_comb
		begin
			if (step == IDLE)
				begin
					idle = 1;
					rKey = w[round];
				end
			else
				begin
					idle = 0;
					rKey = '0;
				end
		end
endmodule
