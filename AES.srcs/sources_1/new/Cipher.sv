`timescale 1ns / 1ps

module Cipher(
    input logic clk, rst, start,
    input logic[127 : 0] key,
    input logic[127 : 0] iBlock,
    output logic[127 : 0] oBlock,
    output logic idle
  );
  typedef enum { IDLE, START, LOOP, FINNAL } State_t;
  State_t step, nextStep;
  logic[127:0] state, nextState, roundKey, nextRoundKey;
  logic[3:0] cnt, nextCnt;

  // state register
  always_ff @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      step <= IDLE;
      state <= '0;
      roundKey <= '0;
      cnt <= 0;
    end
    else
    begin
      step <= nextStep;
      state <= nextState;
      roundKey <= nextRoundKey;
      cnt <= nextCnt;
    end
  end

  // next state logic
  logic[127:0] tmp_addRoundKey, tmp_SubBytes, tmp_ShiftRows, tmp_MixColumns, tmp_nextRoundKey, addRoundKeyInput;

  AddRoundKey addRoundKeyI(
                .roundKey(roundKey),
                .iState(addRoundKeyInput),
                .oState(tmp_addRoundKey)
              );
  SubBytes subBytesI(
             .iState(state),
             .oState(tmp_SubBytes)
           );
  ShiftRows shiftRowsI(
              .iState(tmp_SubBytes),
              .oState(tmp_ShiftRows)
            );
  MixColumns mixColumnsI(
               .iState(tmp_ShiftRows),
               .oState(tmp_MixColumns)
             );
  getNextRoundKey getNextRoundKeyI(
                    .round(cnt),
                    .inKey(roundKey),
                    .outKey(tmp_nextRoundKey)
                  );

  always_comb
  begin
    nextState = state;
    nextStep = step;
    nextRoundKey = roundKey;
    nextCnt = cnt + 1;
    addRoundKeyInput = '0;
    idle = 0;
    case(step)
      IDLE:
      begin
        idle = 1;
        nextCnt = 1;
        if (start)
        begin
          nextStep = START;
          nextRoundKey = key;
          nextState = iBlock;
        end
      end

      START:
      begin
        nextStep = LOOP;
        // addRoundKey using first round key (original key)
        addRoundKeyInput = state;
        nextState = tmp_addRoundKey;
        // Note: Rcon starts from 1
        // cnt must be 1 to get the second round key (which is used in the next round)
        nextRoundKey = tmp_nextRoundKey;
      end

      LOOP: // cnt = 2...10 (9 times)
      begin
        addRoundKeyInput = tmp_MixColumns;
        nextState = tmp_addRoundKey;
        nextRoundKey = tmp_nextRoundKey;
        if (cnt == 10)
        begin
          nextStep = FINNAL;
        end
      end

      FINNAL:
      begin
        nextStep = IDLE;
        addRoundKeyInput = tmp_ShiftRows;
        nextState = tmp_addRoundKey;
      end
    endcase
  end

  // output logic
  always_comb
  begin
    if (idle)
    begin
      oBlock = state;
    end
    else
    begin
      oBlock = '0;
    end
  end
endmodule
