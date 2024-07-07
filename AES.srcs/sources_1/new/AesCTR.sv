`timescale 1ns / 1ps

module AesCTR (
`ifdef USE_POWER_PINS
	inout                VPWR  ,
	inout                VGND  ,
`endif
	input  logic         clk   ,
	input  logic         rst   ,
	input  logic         load  , //! load key and iv
	input  logic         start , //! start encrypt/decrypt iBlock in CTR mode
	input  logic [127:0] key   ,
	input  logic [127:0] iv    ,
	input  logic [127:0] iBlock,
	output logic [127:0] oBlock,
	output logic         idle
);

	typedef enum { IDLE, KEY_EXPANSION, RUNNING } Step_t;
	Step_t step, nextStep;
	logic[127:0] cnt, nextCnt;
	logic[127:0] regIBlock;
	logic enRegIBlock;

	// ==== state register ====
	always_ff @(posedge clk or posedge rst)
		begin : STATE_REGISTER
			if (rst)
				begin
					step      <= IDLE;
					cnt       <= 0;
					regIBlock <= 0;
				end
			else
				begin
					step <= nextStep;
					cnt  <= nextCnt;

					if (enRegIBlock)
						begin
							regIBlock <= iBlock;
						end
				end
		end

	// ==== next state logic ====
	logic aesCoreIdle;
	logic[127:0] aesCoreOutput;
	AesCore aesCoreI(
		.clk(clk),
		.rst(rst),
		.start(start),
		.encrypt(1'b1),
		.key(key),
		.load(load),
		.iBlock(cnt),
		.oBlock(aesCoreOutput),
		.idle(aesCoreIdle)
	);

	always_comb
		begin : NEXT_STATE_LOGIC
			nextStep = step;
			nextCnt  = cnt;

			enRegIBlock = 0;

			case(step)
				IDLE :
					if (load) begin
						nextCnt  = iv;
						nextStep = KEY_EXPANSION;
					end else if (start) begin
						nextStep    = RUNNING;
						enRegIBlock = 1;
					end

				KEY_EXPANSION :
					if (aesCoreIdle) begin
						nextStep = IDLE;
					end

				RUNNING :
					if (aesCoreIdle) begin
						nextStep = IDLE;
						nextCnt  = cnt + 1;
					end
			endcase
		end

	// ==== output logic ====
	always_comb
		begin : OUTPUT_LOGIC
			idle   = (step == IDLE);
			oBlock = aesCoreOutput ^ regIBlock;
		end
endmodule
