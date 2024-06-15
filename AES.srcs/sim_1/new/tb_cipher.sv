// FIXME: modify the tesbench to test the newsest Cipher module

`timescale 1ns / 1ps

module tb_cipher();
  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

  logic clk, rst, start, done;
  logic[127:0] keyVal, iBlock, oBlock, oBlockExpected;

  Cipher cipherI(
           .clk(clk),
           .rst(rst),
           .start(start),
           .key(keyVal),
           .iBlock(iBlock),
           .oBlock(oBlock),
           .idle(done)
         );

  always
  begin: CLK_GEN
    clk = 0;
    #CLK_HALF_PERIOD
     clk = 1;
    #CLK_HALF_PERIOD;
  end

  logic[3*128 - 1 : 0] testVectors [0:100];
  logic[31:0] vectorNum, error;
  initial
  begin: LOAD_TEST_VECTOR
    start = 1; // skip check for the first test vector
    $readmemh("aesTestVector.mem", testVectors);
    vectorNum = 0;
    error = 0;
    rst = 1;
    repeat(2) @(negedge clk);
    rst = 0;
  end

  always @(posedge done)
  begin: APPLY_TEST_VECTOR
    repeat(2) @(negedge clk);
    {keyVal, iBlock, oBlockExpected} = testVectors[vectorNum];
    start = 1;
    @(negedge clk);
    start = 0;
  end

  always @(posedge done)
  begin: CHECK_RESULT
    if (~rst & ~start) // skip during reset and start
    begin
      if (oBlock !== oBlockExpected)
      begin
        $display("Error in test vector %d", vectorNum);
        $display("\tKey:\t%h", keyVal);
        $display("\tInput:\t%h", iBlock);
        $display("\tExpected:\t%h", oBlockExpected);
        $display("\tActual:\t%h", oBlock);
        error = error + 1;
      end
        
      vectorNum = vectorNum + 1; // next test vector
      repeat(2) @(negedge clk);
      if (testVectors[vectorNum][0] === 1'bx)
      begin
        $display("%d tests completed with %d errors", vectorNum, error);
        $finish;
      end
    end
  end
endmodule
