//This file defines the parameters used in the alu
// CSE141L
//	Rev. 2020.5.27
// import package into each module that needs it
//   packages very useful for declaring global variables
package definitions;
    
// Instruction map
    const logic [2:0]kADD  = 3'b000;
    const logic [2:0]kAND  = 3'b001;
    const logic [2:0]kXOR  = 3'b010;
    const logic [2:0]kLSL  = 3'b011;
    const logic [2:0]kLSR  = 3'b100;
    const logic [2:0]kLDR  = 3'b101;
    const logic [2:0]kSTR  = 3'b110;
    const logic [2:0]kBLT  = 3'b111;
// enum names will appear in timing diagram
    typedef enum logic[2:0] {
        ADD, LSL, LSR, XOR,
        AND, LDR, STR, BLT } op_mne;
// note: kADD is of type logic[2:0] (3-bit binary)
//   ADD is of type enum -- equiv., but watch casting
//   see ALU.sv for how to handle this   
endpackage // definitions

// Removed irrelevant instructions and altered opcodes to align with my ISA