`timescale 1ns / 1ps

module AesCore (
	input  logic         clk    ,
	input  logic         rst    ,
	input  logic         load   , //! load key
	input  logic [127:0] key    ,
	input  logic         start  , //! start encrypt/decrypt
	input  logic         encrypt, //! 1: encrypt, 0: decrypt
	input  logic [127:0] iBlock ,
	output logic [127:0] oBlock ,
	output logic         idle
);

	typedef enum { IDLE, KEY_EXPANSION, RUNNING } Step_t;
	Step_t step, nextStep;

	// ==== state register ====
	always_ff @(posedge clk or posedge rst)
		begin
			if (rst)
				begin
					step   <= IDLE;
				end
			else
				begin
					step <= nextStep;
				end
		end

	// ==== next state logic & output logic ====
	logic idleKeyExpansion;
	logic[127:0] roundKey;
	logic[3:0] round;
	KeyExpansion KeyExpansionI (
		.clk     (clk             ),
		.rst     (rst             ),
		.startGen(load            ),
		.inKey   (key             ),
		.round   (round           ),
		.rKey    (roundKey        ),
		.idle    (idleKeyExpansion)
	);

	logic done, cipherIdle;
	logic[127:0] oCipher;
	logic[3:0] cipherRound;
	Cipher cipherI (
		.clk     (clk        ),
		.rst     (rst        ),
		.start   (start      ),
		.roundKey(roundKey   ),
		.iBlock  (iBlock     ),
		.oBlock  (oCipher    ),
		.round   (cipherRound),
		.idle    (cipherIdle )
	);

	logic invCipherIdle;
	logic[127:0] oInvCipher;
	logic[3:0] invCipherRound;
	InvCipher invCipherI (
		.clk     (clk           ),
		.rst     (rst           ),
		.start   (start         ),
		.roundKey(roundKey      ),
		.iBlock  (iBlock        ),
		.oBlock  (oInvCipher    ),
		.round   (invCipherRound),
		.idle    (invCipherIdle )
	);

	always_comb
		begin
			idle = (step == IDLE) ? 1 : 0;
			// mux between cipher and invCipher
			if(encrypt)
				begin
					done   = cipherIdle;
					round  = cipherRound;
					oBlock = oCipher;
				end
			else // decrypt
				begin
					done   = invCipherIdle;
					round  = invCipherRound;
					oBlock = oInvCipher;
				end

			// default values
			nextStep = step;

			case(step)
				IDLE :
					begin
						if (load) // load key
							begin
								nextStep = KEY_EXPANSION;
							end
						else
							if(start)
								begin
									nextStep = RUNNING;
								end
					end

				KEY_EXPANSION :
					begin
						if(idleKeyExpansion)
							begin
								nextStep = IDLE;
							end
					end

				RUNNING :
					begin
						if(done)
							begin
								nextStep = IDLE;
							end
					end
			endcase
		end
endmodule
