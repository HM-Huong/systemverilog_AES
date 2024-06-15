// FIXME: modify the tesbench to test the newsest Cipher and InvCipher modules

`timescale 1ns / 1ps

module tb_cipher_invCipher();
  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

  logic clk, rst;
  always
  begin: CLK_GEN
    clk = 0;
    #CLK_HALF_PERIOD
     clk = 1;
    #CLK_HALF_PERIOD;
  end

  logic [127:0] cKey, cInput, cOutput;
  logic cStart, cDone;
  Cipher cipherI(
           .clk(clk),
           .rst(rst),
           .start(cStart),
           .key(cKey),
           .iBlock(cInput),
           .oBlock(cOutput),
           .idle(cDone)
         );

  logic [127:0] iKey, iInput, iOutput;
  logic iStart, iDone;
  InvCipher invCipherI(
              .clk(clk),
              .rst(rst),
              .start(iStart),
              .key(iKey),
              .iBlock(iInput),
              .oBlock(iOutput),
              .idle(iDone)
            );

  class TestVector;
    rand logic [128*2-1:0] get;
  endclass

  task test();
    static TestVector vector = new();
    static int cnt = 0;
    vector.randomize();
    {cKey, cInput} = vector.get;
    cStart = 1;
    repeat(2) @(negedge clk);
    cStart = 0;
    @(posedge cDone);

    iKey = cKey;
    iInput = cOutput;
    iStart = 1;
    repeat(2) @(negedge clk);
    iStart = 0;
    @(posedge iDone);

    repeat(2) @(negedge clk);
    if (iOutput !== cInput)
    begin
      $display("Error in test vector");
      $display("\tKey:\t%h", cKey);
      $display("\tInput:\t%h", cInput);
      $display("\tEncrypted:\t%h", cOutput);
      $display("\tDecrypted:\t%h", iOutput);
      $finish;
    end
    $display("Test %4d: passed", cnt++);
    $display("\tKey:\t%h", cKey);
    $display("\tInput:\t%h", cInput);
  endtask

  task init();
    rst = 1;
    cStart = 0;
    iStart = 0;
    repeat(2) @(negedge clk);
    rst = 0;
  endtask


  initial
  begin: MAIN
    init();
    repeat(100) test();
    $display("Seems OK :v");
    $finish;
  end
endmodule
