`timescale 1ns / 1ps

// key: "0123456789abcdef"
//       ^              ^
//      MSB            LSB

module getNextRoundKey(
    input logic[3:0] round,
    input logic[127 : 0] inKey,
    output logic[127:0] outKey
  );

  logic[31:0] rcon, tmp1, tmp2;

  assign tmp1 = {inKey[0 +: 24], inKey[24 +: 8]}; // RotWord
  SubWord SubWordI(.in(tmp1), .out(tmp2));
  Rcon RconI(.r(round), .rcon(rcon));

  always_comb
  begin
    outKey[96 +: 32] = inKey[96 +: 32] ^ tmp2 ^ rcon;
    outKey[64 +: 32] = inKey[64 +: 32] ^ outKey[96 +: 32];
    outKey[32 +: 32] = inKey[32 +: 32] ^ outKey[64 +: 32];
    outKey[0  +: 32] = inKey[0  +: 32] ^ outKey[32 +: 32];
  end
endmodule
