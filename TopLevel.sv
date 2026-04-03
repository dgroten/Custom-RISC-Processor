// Revision Date:    2020.08.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only										   
module TopLevel(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

wire [ 9:0] PgmCtr,        // program counter
			PCTarg;
wire [ 8:0] Instruction;   // our 9-bit opcode
wire [ 7:0] ReadA, ReadB;  // reg_file outputs
wire [ 7:0] InA, InB, 	   // ALU operand inputs
            ALU_out;       // ALU result
wire [ 7:0] RegWriteValue, // data in to reg file
            MemWriteValue, // data in to data_memory
	   	    MemReadValue;  // data out from data_memory
wire        MemWrite,	   // data_memory write enable
			RegWrEn,	   // reg_file write enable
			Zero,		   // ALU output = 0 flag
            Jump,	       // to program counter: jump 
            BranchEn;	   // to program counter: branch enable
wire 	    ALU_Carry;
logic       SC_reg;
logic	    Ack_ctrl;
wire [9:0]  BranchImmExt;  // Sign-extended immediate for branch target
wire [2:0]  Waddr_wire;    // Used to select which register to write to
wire [7:0]  ImmExt;    	   // Sign-extended immediate from instruction
logic[15:0] CycleCt;	   // standalone; NOT PC!

// Fetch stage = Program Counter + Instruction ROM
assign BranchImmExt = {{4{Instruction[2]}}, Instruction[2:0], 3'b000};	// Sign-extended immediate for branch target
  InstFetch IF1 (		       // this is the program counter module
	.Reset        (Reset   ) ,  // reset to 0
	.Start        (Start   ) ,  // SystemVerilog shorthand for .grape(grape) is just .grape 
	.Clk          (Clk     ) ,  //    here, (Clk) is required in Verilog, optional in SystemVerilog
	.BranchAbs    (Jump    ) ,  // jump enable
	.BranchRelEn  (BranchEn) ,  // branch enable
	.ALU_flag	  (Zero    ) ,  // 
    .Target       (BranchImmExt) ,  // "where to?" or "how far?" during a jump or branch
	.ProgCtr      (PgmCtr  )	   // program count = index to instruction memory
	);					  

LUT LUT1(.Addr         (TargSel ) ,
         .Target       (PCTarg  )
    );

// instruction ROM -- holds the machine code pointed to by program counter
  InstROM #(.W(9)) IR1(
	.InstAddress  (PgmCtr     ) , 
	.InstOut      (Instruction)
	);

// Decode stage = Control Decoder + Reg_file
// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction) ,  // from instr_ROM
	.Jump         (Jump       ) ,  // to PC to handle jump/branch instructions
	.BranchEn     (BranchEn   )	,  // to PC
	.RegWrEn      (RegWrEn    )	,  // register file write enable
	.MemWrEn      (MemWrite   ) ,  // data memory write enable
    .LoadInst     (LoadInst   ) ,  // selects memory vs ALU output as data input to reg_file
	.RegDst       (RegDst     ) ,  // whether to use rd or rt as the destination register
	.ALUsrc       (ALUsrc     ) ,  // whether to use rt or an immediate as the second ALU input
    .PCTarg       (TargSel    ) ,    
    .Ack          (Ack_ctrl        )	   // "done" flag
  );

assign Ack = Ack_ctrl | (PgmCtr == 10'd300);

assign Waddr_wire = Instruction[5:3];

// reg file
	RegFile #(.W(8),.D(3)) RF1 (			  // D(3) makes this 8 elements deep
		.Clk          (Clk     ) ,
		.Reset	(Reset),
		.WriteEn   (RegWrEn)    , 
		.RaddrA    (3'd7),      
		.RaddrB    ((Instruction[8:6] == 3'b111) || (Instruction[8:6] == 3'b101) || (Instruction[8:6] == 3'b110)
            		? Instruction[5:3] : Instruction[2:0]), 
		.Waddr     (Waddr_wire), 	     
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 )
	);
/* one pointer, two adjacent read accesses: 
  (sample optional approach)
	.raddrA ({Instruction[5:3],1'b0});
	.raddrB ({Instruction[5:3],1'b1});
*/
    assign InA = ReadA;						  // connect RF out to ALU in
	assign ImmExt = {{5{Instruction[2]}}, Instruction[2:0]};   // Sign-extend immediate (bits 2:0) to 8 bits
	assign InB = ALUsrc ? ImmExt : ReadB;	          			  // MUX for second ALU input. If ALUsrc is 1, use immediate (bits 2:0). If 0, use rt.
// controlled by Ctrl1 -- must be high for load from data_mem; otherwise usually low
	assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  // 2:1 switch into reg_file
	assign MemWriteValue = ReadB;
    ALU ALU1  (
	  .InputA  (InA),
	  .InputB  (InB), 
	  .SC_in   (SC_reg),
	  .OP      (Instruction[8:6]),
	  .Out     (ALU_out),//regWriteValue),
	  .CarryOut(ALU_Carry),
	  .Zero		(Zero)                              // status flag; may have others, if desired
	  );
  
	DataMem DM1(
		.DataAddress  (ALU_out)    , 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue)  , 
		.Clk 		  (Clk)		     ,
		.Reset		  (Reset)
	);
	
/* count number of instructions executed
      not part of main design, potentially useful
      This one halts when Ack is high  
*/

always_ff @(posedge Clk or posedge Reset) begin
  if (Reset)
    SC_reg <= 1'b0;
  else
    SC_reg <= ALU_Carry;
end

always_ff @(posedge Clk)
  if (Reset == 1)	   // if(start)
  	CycleCt <= 0;
  else if(Ack == 0)   // if(!halt)
  	CycleCt <= CycleCt+16'b1;

endmodule

// InstFetch: Changed target to be a sign extended immediate
// Ctrl: Added RegDst and ALUsrc signals
// RegFile: Rs is always r7, the destination register is selected by RegDst
// ALU: Second input selected by ALUsrc, either rt or sign-extended immediate
// Things to add: This code doesn't cover branching, will need a separate adder unit for that and a control signal. Also, the branch distance has a maximum of 7 instructions. Should shift it to make it larger. HOWEVER, must shift AFTER the ALU mux!!!