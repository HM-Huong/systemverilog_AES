`timescale 1ns / 1ps

module tb_aesCRT ();
	parameter CLK_HALF_PERIOD = 1                  ;
	parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;

	logic clk, rst, start, done, load;
	logic[127:0] key, iv, iBlock, oBlock;

	AesCTR aesCRTI(
		.clk(clk),
		.rst(rst),
		.load(load),
		.start(start),
		.key(key),
		.iv(iv),
		.iBlock(iBlock),
		.oBlock(oBlock),
		.idle(done)
	);
	logic ok         ;
	int   testNum = 0;
	int   error   = 0;

	task automatic test(
			input logic[127:0] in,
			input logic[127:0] expected
		);
		testNum = testNum + 1;
		iBlock = in;
		@(negedge clk);
		start = 1;
		@(negedge clk);
		start = 0;
		ok = 1'b0;
		@(posedge done);
		assert (oBlock === expected)
			begin
				ok = 1'b1;
				$display("[PASSED]");
				$display("\tiBlock \t= %h", in);
				$display("\toBlock \t= %h", oBlock);
			end
		else
			begin
				ok = 1'bx;
				error = error + 1;
				$error("[FAILED]");
				$display("\tiBlock \t= %h", in);
				$display("\toBlock \t= %h", oBlock);
				$display("\texpected \t= %h", expected);
			end
	endtask

	task automatic loadKeyAndIv(
			input logic[127:0] keyVal,
			input logic[127:0] ivVal
		);
		key = keyVal;
		iv = ivVal;
		@(negedge clk);
		load = 1;
		@(negedge clk);
		load = 0;
		// wait for key expansion done
		@(posedge done);
	endtask

	initial
		begin: MAIN
			ok = 1'b0;
			rst = 1;
			load = 0;
			start = 0;
			repeat(2) @(negedge clk);
			rst = 0;

			$display("\n\n===== encrypt iBlock in CTR mode ======");
			loadKeyAndIv(128'h70617373776f726450617373776f7264, 128'h30313233343536373839616263646566);
			test(128'h486f616e67204d696e682048756f6e67, 128'h09353ccc3dff54567bdedb49ddc8deb9);
			test(128'h37383935383739353436383938373835, 128'h54427e87a044f594f110c07e53f5a0c8);
			test(128'h497320746869732061206b65793f3f3f, 128'h704644f8d5824086dac4fb49b80d7ec7);
			test(128'h5965732c2069742069732061206b6579, 128'h4b53114ccbde893540e8dca8581259d2);
			test(128'h31343532363937353235393633343837, 128'h01d1eef69644f6478fe7aed1104561b3);

			$display("\n\n===== decrypt oBlock in CTR mode ======");
			loadKeyAndIv(128'h70617373776f726450617373776f7264, 128'h30313233343536373839616263646566);
			test(128'h09353ccc3dff54567bdedb49ddc8deb9, 128'h486f616e67204d696e682048756f6e67);
			test(128'h54427e87a044f594f110c07e53f5a0c8, 128'h37383935383739353436383938373835);
			test(128'h704644f8d5824086dac4fb49b80d7ec7, 128'h497320746869732061206b65793f3f3f);
			test(128'h4b53114ccbde893540e8dca8581259d2, 128'h5965732c2069742069732061206b6579);
			test(128'h01d1eef69644f6478fe7aed1104561b3, 128'h31343532363937353235393633343837);

			$display("\n\n%d tests completed with %4d errors\n\n", testNum, error);

			// stop simulation
			$finish;
		end

	always
		begin : CLK_GEN
			clk = 0;
			#CLK_HALF_PERIOD
				clk = 1;
			#CLK_HALF_PERIOD;
		end
endmodule
