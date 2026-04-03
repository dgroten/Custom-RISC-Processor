// Create Date:    2018.10.15
// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision 2020.01.27
// Additional Comments: 
//   combinational (unclocked) ALU
import definitions::*;			         // includes package "definitions"
module ALU(
  input        [7:0] InputA,             // data inputs
                     InputB,
  input        [2:0] OP,		         // ALU opcode, part of microcode
  input              SC_in,              // shift or carry in
  output logic [7:0] Out,		         // or:  output reg [7:0] OUT,
  output logic       Zero,                // output = zero flag
  output logic       CarryOut
           // you may provide additional status flags, if desired
    );								    
	 
  op_mne op_mnemonic;			         // type enum: used for convenient waveform viewing
 
	
  always_comb begin
    automatic logic [8:0] fullsum = 9'b0;
    Out = 0;                             // No Op = default
    CarryOut = 1'b0;
    case(OP)
      kADD: begin
        fullsum = InputA + InputB + SC_in;
        Out = fullsum[7:0];
        CarryOut = fullsum[8];
      end
      kLDR : Out = InputA + InputB;      // add for load
      kSTR : Out = InputA + InputB;      // add for store
      kBLT : Out = InputA + InputB;      // add for branch (unused because of InstFetch design)
      kLSL : Out = InputA << InputB[3:0];
	  kLSR : Out = InputA >> InputB[3:0];
 	  kXOR : Out = InputA ^ InputB;      // exclusive OR
      kAND : Out = InputA & InputB;      // bitwise AND
    endcase
  end

  always_comb begin
    if (OP == kBLT)
      Zero = (InputB < InputA) ? 1'b1 : 1'b0;
    else
      Zero = 1'b0;
  end

  always_comb
    op_mnemonic = op_mne'(OP);			 // displays operation name in waveform viewer

endmodule

// Changed LSH to ignore SC_in and fill in with 0
// Should I add more status flags like carry out or negative?
// Added extra instructions to make sure everything works with my ISA
// How to make sure that the zero flag works? I don't have subtraction