`timescale 1ns / 1ps

module tb_aesCore();
  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

  logic clk, rst, start, done, encrypt;
  logic[127:0] keyVal, iBlock, oBlock;

  AesCore aesCoreI(
            .clk(clk),
            .rst(rst),
            .start(start),
            .encrypt(encrypt),
            .key(keyVal),
            .iBlock(iBlock),
            .oBlock(oBlock),
            .idle(done)
          );

  logic[3*128 - 1 : 0] testVectors [0:100];
  initial
  begin: LOAD_TEST_VECTOR
    $readmemh("aesTestVector.mem", testVectors);
  end

  task testcase(
      input logic enc,
      input logic[127:0] key,
      input logic[127:0] in,
      input logic[127:0] outExpected,
      output logic correct
    );
    keyVal = key;
    iBlock = in;
    encrypt = enc;
    start = 1;
    repeat(2) @(negedge clk);
    start = 0;
    @(posedge done);
    correct = (oBlock === outExpected);
  endtask

  task test(input logic enc);
    automatic int error = 0;
    automatic int vectorNum;
    automatic logic[127:0] tmp_key, tmp_plain, tmp_cipher;
    automatic logic correct;

    $display("===== Start testing %s =====", enc ? "encryption" : "decryption");

    start = 0;
    rst = 1;
    repeat(2) @(negedge clk);
    rst = 0;

    for (vectorNum = 0; testVectors[vectorNum][0] !== 1'bx; vectorNum++)
    begin
      repeat(2) @(negedge clk);
      {tmp_key, tmp_plain, tmp_cipher} = testVectors[vectorNum];

      if (enc)
        testcase(enc, tmp_key, tmp_plain, tmp_cipher, correct);
      else
        testcase(enc, tmp_key, tmp_cipher, tmp_plain, correct);

      if (!correct)
      begin
        $display("Error in test vector %d", vectorNum);
        $display("\tKey:\t%h", tmp_key);
        $display("\tInput:\t%h", tmp_plain);
        $display("\tExpected:\t%h", tmp_cipher);
        $display("\tActual:\t%h", oBlock);
        error = error + 1;
      end
    end
    $display("%d tests completed with %d errors", vectorNum, error);
  endtask

  initial
  begin: MAIN
    repeat(2) @(negedge clk);
    test(1);
    test(0);
    $finish;
  end

  always
  begin: CLK_GEN
    clk = 0;
    #CLK_HALF_PERIOD
     clk = 1;
    #CLK_HALF_PERIOD;
  end
endmodule
