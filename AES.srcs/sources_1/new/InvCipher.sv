`timescale 1ns / 1ps

module InvCipher(
    input logic clk, rst, start,
    input logic[127 : 0] key,
    input logic[127 : 0] iBlock,
    output logic[127 : 0] oBlock,
    output logic idle
  );
  typedef enum { IDLE, KEY_EXPANSION, START_CIPHER, LOOP, FINNAL } State_t;
  State_t step, nextStep;
  logic[127:0] state, nextState;
  logic[3:0] cnt, nextCnt;

  // state register
  always_ff @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      step <= IDLE;
      state <= '0;
      cnt <= 0;
    end
    else
    begin
      step <= nextStep;
      state <= nextState;
      cnt <= nextCnt;
    end
  end

  // next state logic
  logic[127:0] tmp_addRoundKey, addRoundKeyInput, roundKey;
  AddRoundKey AddRoundKeyI(
                .roundKey(roundKey),
                .iState(addRoundKeyInput),
                .oState(tmp_addRoundKey)
              );

  logic[127:0] tmp_InvShiftRows;
  InvShiftRows InvShiftRowsI(
                 .iState(state),
                 .oState(tmp_InvShiftRows)
               );

  logic[127:0] tmp_InvSubBytes;
  InvSubBytes InvSubBytesI(
                .iState(tmp_InvShiftRows),
                .oState(tmp_InvSubBytes)
              );

  logic[127:0] tmp_InvMixColumns;
  InvMixColumns InvMixColumnsI(
                  .iState(tmp_addRoundKey),
                  .oState(tmp_InvMixColumns)
                );

  logic startGenKeyExpansion, idleKeyExpansion;
  KeyExpansion KeyExpansionI(
                 .clk(clk),
                 .rst(rst),
                 .startGen(startGenKeyExpansion),
                 .inKey(key),
                 .round(cnt),
                 .rKey(roundKey),
                 .idle(idleKeyExpansion)
               );

  always_comb
  begin
    nextState = state;
    nextStep = step;
    nextCnt = cnt - 1;

    addRoundKeyInput = '0;
    startGenKeyExpansion = 0;

    case(step)
      IDLE:
      begin
        nextCnt = 10;
        if (start)
        begin
          startGenKeyExpansion = 1;
          nextStep = KEY_EXPANSION;
        end
      end

      KEY_EXPANSION:
      begin
        nextCnt = 10;
        if (idleKeyExpansion)
        begin
          nextState = iBlock;
          nextStep = START_CIPHER;
        end
      end

      START_CIPHER: // cnt = 10
      begin
        nextStep = LOOP;
        addRoundKeyInput = state;
        nextState = tmp_addRoundKey;
      end

      LOOP: // cnt = 9...1 (9 times)
      begin
        addRoundKeyInput = tmp_InvSubBytes;
        nextState = tmp_InvMixColumns;
        if (cnt == 1)
        begin
          nextStep = FINNAL;
        end
      end

      FINNAL: // cnt = 0
      begin
        nextStep = IDLE;
        addRoundKeyInput = tmp_InvSubBytes;
        nextState = tmp_addRoundKey;
        nextCnt = 0;
      end
    endcase
  end

  // output logic
  always_comb
  begin
    oBlock = state;
    idle = (step == IDLE);
  end
endmodule