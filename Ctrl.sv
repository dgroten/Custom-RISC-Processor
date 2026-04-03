// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0] Instruction,	   // machine code
  output logic Jump     ,
               BranchEn ,
			   RegWrEn  ,	   // write to reg_file (common)
			   MemWrEn  ,	   // write to mem (store only)
			   LoadInst	,	   // mem or ALU to reg_file ?
         RegDst   ,	   // whether to use rd or rt as the destination register
         ALUsrc   ,     // whether to use rt or an immediate as the second ALU input
               PCTarg   ,
			   Ack		       // "done w/ program"
  );

/* ***** All numerical values are completely arbitrary and for illustration only *****
*/

// STR commands only -- write to data_memory
assign MemWrEn = Instruction[8:6]==3'b110;

// all but STR and NOOP (or maybe CMP or TST) -- write to reg_file
assign RegWrEn = Instruction[8:7]!=2'b11;

// route data memory --> reg_file for loads
//   whenever instruction = 9'b101??????; 
assign LoadInst = Instruction[8:6]==3'b101;  // calls out load specially

assign RegDst = (Instruction[8:6] <= 3'b100); // If the instruction is an R-type, use rd as the destination register. Else, use rt.

assign ALUsrc = (Instruction[8:6] == 3'b101)  // LDR
              || (Instruction[8:6] == 3'b110); // STR

// jump enable command to program counter / instruction fetch module on right shift command
// equiv to simply: assign Jump = Instruction[2:0] == kRSH;
/*
always_comb
  if(Instruction[2:0] ==  kRSH)
    Jump = 1;
  else
    Jump = 0;
*/

// branch every time instruction == 9'b111??????;
assign BranchEn = Instruction[8:6]==3'b111;

// whenever branch or jump is taken, PC gets updated or incremented from "Target"
//  PCTarg = 2-bit address pointer into Target LUT  (PCTarg in --> Target out
assign PCTarg  = Instruction[3:2];

// reserve instruction = 9'b111111111; for Ack
// assign Ack = &Instruction;

endmodule

// Commented out Ack, I will just throw a done flag once the PC reaches a certain value. Note: need to code this
// Fixed the bit values to align with my ISA specifications
// Commented out the jump signal, I don't know what it does
// Added RegDst signal
// Added ALUsrc signal