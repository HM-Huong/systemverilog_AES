`timescale 1ns / 1ps

module tb_aesCRT();
  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

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

  initial
  begin: MAIN
    rst = 1;
    load = 0;
    start = 0;
    repeat(2) @(negedge clk);
    rst = 0;

    // load key and iv
    load = 1;
    key = 128'h70617373776f726450617373776f7264;
    iv = 128'h30313233343536373839616263646566;
    repeat(2) @(negedge clk);
    load = 0;

    // start encrypt/decrypt iBlock in CTR mode
    start = 1;
    iBlock = 128'h486f616e67204d696e682048756f6e67;
    repeat(2) @(negedge clk);
    start = 0;

    // wait for first block to be done
    @(posedge done);
    assert (oBlock === 128'h09353ccc3dff54567bdedb49ddc8deb9)
           $display("[PASSED] oBlock = %h", oBlock);
    else
      $error("oBlock = %h", oBlock);

    // block 2
    start = 1;
    iBlock = 128'h37383935383739353436383938373835;
    repeat(2) @(negedge clk);
    start = 0;
    @(posedge done);
    assert (oBlock === 128'h54427e87a044f594f110c07e53f5a0c8)
           $display("[PASSED] oBlock = %h", oBlock);
    else
      $error("oBlock = %h", oBlock);

    // block 3
    start = 1;
    iBlock = 128'h497320746869732061206b65793f3f3f;
    repeat(2) @(negedge clk);
    start = 0;
    @(posedge done);
    assert (oBlock === 128'h704644f8d5824086dac4fb49b80d7ec7)
           $display("[PASSED] oBlock = %h", oBlock);
    else
      $error("oBlock = %h", oBlock);

    // block 4
    start = 1;
    iBlock = 128'h5965732c2069742069732061206b6579;
    repeat(2) @(negedge clk);
    start = 0;
    @(posedge done);
    assert (oBlock === 128'h4b53114ccbde893540e8dca8581259d2)
           $display("[PASSED] oBlock = %h", oBlock);
    else
      $error("oBlock = %h", oBlock);

    // block 4
    start = 1;
    iBlock = 128'h31343532363937353235393633343837;
    repeat(2) @(negedge clk);
    start = 0;
    @(posedge done);
    assert (oBlock === 128'h01d1eef69644f6478fe7aed1104561b3)
           $display("[PASSED] oBlock = %h", oBlock);
    else
      $error("oBlock = %h", oBlock);

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
