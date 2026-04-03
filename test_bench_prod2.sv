// program 2    CSE141L   product C = OpA * OpB  
// operands are 8-bit two's comp integers, product is 16-bit two's comp integer
// revised 2025.11.12 to resolve big/little endian question -- now conforms to the assignment writeup
//   revision also adds reset port and connection to the DUT, again to conform to the assignment writeup
module test_bench_prod2;

// connections to DUT: clk (clock), reset, start (request), done (acknowledge) 
  bit  clk,
       reset = 'b1,				 // should set your PC = 0
       start = 'b1;				 // falling edge should initiate the program
  wire done;					 // you return 1 when finished

  logic signed[ 7:0] OpA, OpB;
  logic signed[15:0] Prod;	    // holds 2-byte product
/*
  // debug sample registers (store pre-posedge values)
logic [9:0]  dbg_PgmCtr_pre;
logic [7:0]  dbg_RegWriteValue_pre, dbg_MemReadValue_pre, dbg_ALU_out_pre;
logic [2:0]  dbg_Waddr_pre;
logic        dbg_LoadInst_pre, dbg_RegWrEn_pre;		  
*/

  TopLevel D1(.Clk  (clk  ),	        // your design goes here
         .Reset(reset),
		 .Start(start),
		 .Ack (done )); 

  always begin
    #50ns clk = 'b1;
	#50ns clk = 'b0;
  end


/*


// sample combinational signals right before the posedge so we see the values
always @(negedge clk) begin
  if (!reset) begin
    dbg_PgmCtr_pre         = D1.PgmCtr;
    dbg_RegWriteValue_pre  = D1.RegWriteValue;
    dbg_MemReadValue_pre   = D1.MemReadValue;
    dbg_ALU_out_pre        = D1.ALU_out;
    dbg_Waddr_pre          = D1.Waddr_wire;
    dbg_LoadInst_pre       = D1.Ctrl1.LoadInst;
    dbg_RegWrEn_pre        = D1.Ctrl1.RegWrEn;
  end
  // ---- add this inside your existing "always @(negedge clk)" sampler ----
  // print what we sampled (pre-posedge values)
  $display("NEGEDGE_SAMPLED PC_pre=%0d LoadInst_pre=%b MemRead_pre=%0d RegWrite_pre=%0d Waddr_pre=%0d RegWrEn_pre=%0b ALU_out_pre=%0d",
           dbg_PgmCtr_pre, dbg_LoadInst_pre, dbg_MemReadValue_pre, dbg_RegWriteValue_pre, dbg_Waddr_pre, dbg_RegWrEn_pre, dbg_ALU_out_pre);
end

*/

/*

// Debug monitor: show PC, instruction, key regs, ALU addr, mem reads/writes
always_ff @(posedge clk) begin
  if (!reset) begin
    // print a short trace for every cycle
    $display("CYCLE: PC=%0d  Instr=%b  r3=%0d r5=%0d r6=%0d r7=%0d  ALU_out=%0d LoadInst=%b MemRead=%0d MemWr=%b",
             D1.PgmCtr, D1.Instruction,
             D1.RF1.Registers[3], D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7],
             D1.ALU_out, D1.Ctrl1.LoadInst, D1.DM1.core[D1.ALU_out], D1.Ctrl1.MemWrEn);
  end
end

// Debug: print whenever a store (STR / MemWrEn) occurs
always_ff @(posedge clk) begin
  if (!reset && D1.Ctrl1.MemWrEn) begin
    $display("STORE@PC=%0d Addr=%0d Data=%0d (r5=%0d r6=%0d r7=%0d)",
             D1.PgmCtr, D1.ALU_out, D1.MemWriteValue,
             D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7]);
  end
end



// Snapshot registers slightly after the clock edge so sequential writes complete
always @(posedge clk) begin
  #1ns;
  if (!reset) begin
    $display("SNAP@PC=%0d r0=%0d r1=%0d r2=%0d r3=%0d r4=%0d r5=%0d r6=%0d r7=%0d",
             D1.PgmCtr,
             D1.RF1.Registers[0], D1.RF1.Registers[1], D1.RF1.Registers[2], D1.RF1.Registers[3],
             D1.RF1.Registers[4], D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7]);
  end
end






// Monitor: show when a register write is *issued* by the control unit
always @(posedge clk) begin
  if (!reset && D1.Ctrl1.RegWrEn) begin
    $display("REGWRITE_ISSUED@PC=%0d Instr=%b Waddr=%0d DataIn=%0d LoadInst=%b",
             D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.RegWriteValue, D1.Ctrl1.LoadInst);
  end
end







// Print LDR behavior (loads into registers)
always_ff @(posedge clk) begin
if (!reset && (D1.Instruction[8:6] == 3'b101)) begin
$display("LDR_DBG@PC=%0d Instr=%b Waddr=%0d ReadA=%0d ImmExt=%0d ALU_out=%0d MemRead=%0d RegWriteValue=%0d RegWrEn=%b",
D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.ReadA, D1.ImmExt, D1.ALU_out, D1.DM1.core[D1.ALU_out], D1.RegWriteValue, D1.Ctrl1.RegWrEn);
end
end

// Print ADDs that write into r5 or r6 (the accumulation ops)
always_ff @(posedge clk) begin
if (!reset && (D1.Instruction[8:6] == 3'b000) && ((D1.Waddr_wire == 3'd5) || (D1.Waddr_wire == 3'd6))) begin
$display("ADD_ACC@PC=%0d Instr=%b Waddr=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_out=%0d RegWriteValue=%0d RegWrEn=%0b",
D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU_out, D1.RegWriteValue, D1.Ctrl1.RegWrEn);
end
end

// Generic register-write issued (already have this, but keep it)
always_ff @(posedge clk) begin
if (!reset && D1.Ctrl1.RegWrEn) begin
$display("REGWRITE_ISSUED@PC=%0d Instr=%b Waddr=%0d DataIn=%0d LoadInst=%0b",
D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.RegWriteValue, D1.Ctrl1.LoadInst);
end
end






// LDR debug: show memory read and the register write value after combinational settle
always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b101)) begin
    // immediate print (optional) - shows memory cell
    $display("LDR_IMM@PC=%0d ALU_out=%0d MemCell=%0d LoadInst=%b",
      D1.PgmCtr, D1.ALU_out, D1.DM1.core[D1.ALU_out], D1.Ctrl1.LoadInst);
    $display("LDR_SETTLE@PC=%0d MemReadValue=%0d RegWriteValue=%0d RegWrEn=%0b Waddr=%0d",
      D1.PgmCtr, D1.MemReadValue, D1.RegWriteValue, D1.Ctrl1.RegWrEn, D1.Waddr_wire);
  end
end




// LDR debug: show memory cell immediately and settled read/write values at end-of-time-step
always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b101)) begin
    // immediate view of memory cell using direct array index
    $display("LDR_IMM@PC=%0d ALU_out=%0d MemCell=%0d LoadInst=%0b",
      D1.PgmCtr, D1.ALU_out, D1.DM1.core[D1.ALU_out], D1.Ctrl1.LoadInst);

    // strobe at end of time step after all combinational updates settle
    $strobe("LDR_SETTLE@PC=%0d MemReadValue=%0d RegWriteValue=%0d RegWrEn=%0b Waddr=%0d",
      D1.PgmCtr, D1.MemReadValue, D1.RegWriteValue, D1.Ctrl1.RegWrEn, D1.Waddr_wire);
  end
end

always_ff @(posedge clk) begin
  if (!reset && dbg_LoadInst_pre) begin
    $display("DBG_PRE@PC=%0d MemRead_pre=%0d RegWriteValue_pre=%0d Waddr_pre=%0d RegWrEn_pre=%0b ALU_out_pre=%0d",
      dbg_PgmCtr_pre, dbg_MemReadValue_pre, dbg_RegWriteValue_pre, dbg_Waddr_pre, dbg_RegWrEn_pre, dbg_ALU_out_pre);
  end
end



always_ff @(posedge clk) begin
if (!reset && (D1.Instruction[8:6] == 3'b000)) begin
$display("ADD_ALL@PC=%0d Instr=%b Waddr=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_out=%0d RegWrEn=%0b RegWriteValue=%0d",
D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU_out, D1.Ctrl1.RegWrEn, D1.RegWriteValue);
end
end


always_ff @(posedge clk) begin
if (!reset && (D1.Instruction[8:6] == 3'b011 /* lsl? / || D1.Instruction[8:6] == 3'b100 / lsr? / || D1.Instruction[8:6] == 3'b010 / xor? ))
$display("SHIFT_XOR@PC=%0d opcode=%b Instr=%b InA=%0d InB=%0d ALU_out=%0d Waddr=%0d RegWrEn=%0b",
D1.PgmCtr, D1.Instruction[8:6], D1.Instruction, D1.InA, D1.InB, D1.ALU_out, D1.Waddr_wire, D1.Ctrl1.RegWrEn);
end



// Print when we reach the ADD that should update r6 (pc 19)
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 19)) begin
    $display("PC19@%0d Instr=%b r7=%0d r6=%0d r4=%0d r2=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_out=%0d RegWrEn=%0b Waddr=%0d",
      D1.PgmCtr, D1.Instruction,
      D1.RF1.Registers[7], D1.RF1.Registers[6], D1.RF1.Registers[4], D1.RF1.Registers[2],
      D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU_out, D1.Ctrl1.RegWrEn, D1.Waddr_wire);
  end
end

always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b111)) begin
    $display("BLT_DBG@PC=%0d Instr=%b ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU.Zero=%b BranchEn=%0b BranchImmExt=%0d PCTarg=%0b",
      D1.PgmCtr, D1.Instruction,
      D1.ReadA, D1.ReadB, D1.InA, D1.InB,
      D1.ALU1.Zero, D1.Ctrl1.BranchEn, D1.BranchImmExt, D1.Ctrl1.PCTarg);
  end
end


// Print r5 whenever PC == 25
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 25)) begin
    $display("R5_AT_PC25@%0d r5=%0d (r6=%0d r7=%0d)",
             D1.PgmCtr,
             D1.RF1.Registers[5],
             D1.RF1.Registers[6],
             D1.RF1.Registers[7]);
  end
end


// Monitor: at PC==15 print r2 and branch outcome/details
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 15)) begin
    $display("BRANCH_CHECK@%0d Instr=%b r2=%0d ReadA=%0d ReadB=%0d ALU.Zero=%b BranchEn=%0b BranchImmExt=%0d PCTarg=%0d",
             D1.PgmCtr,
             D1.Instruction,
             D1.RF1.Registers[2],
             D1.ReadA,
             D1.ReadB,
             D1.ALU1.Zero,
             D1.Ctrl1.BranchEn,
             D1.BranchImmExt,
             D1.Ctrl1.PCTarg);
  end
end


// Monitor: at PC==100 print r7 and branch outcome/details
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 100)) begin
    $display("BRANCH_AT_PC100@%0d Instr=%b r7=%0d ReadA=%0d ReadB=%0d ALU.Zero=%b BranchEn=%0b BranchImmExt=%0d PCTarg=%0d",
             D1.PgmCtr,
             D1.Instruction,
             D1.RF1.Registers[7],
             D1.ReadA,
             D1.ReadB,
             D1.ALU1.Zero,
             D1.Ctrl1.BranchEn,
             D1.BranchImmExt,
             D1.Ctrl1.PCTarg);
  end
end


logic printed_pc0;
always_ff @(posedge clk or posedge reset) begin
  if (reset) begin
    printed_pc0 <= 1'b0;
  end else begin
    if (!printed_pc0 && (D1.PgmCtr == 0)) begin
      $display("FIRST_PC0@%0t PC=%0d Instr=%b r3=%0d ReadA=%0d ReadB=%0d",
               $time, D1.PgmCtr, D1.Instruction, D1.RF1.Registers[3], D1.ReadA, D1.ReadB);
      printed_pc0 <= 1'b1;
    end
  end
end

/* Print r5 whenever a write to r5 is issued — sample after write completes

/* Monitor: print inputs (pre-posedge) when PC == 88 or 91
always @(negedge clk) begin
  if (!reset && (D1.PgmCtr == 88 || D1.PgmCtr == 91)) begin
    $display("PRE@%0t PC=%0d Instr=%b  ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_out_pre=%0d MemCell_pre=%0d MemReadValue=%0d RegWriteValue=%0d Waddr=%0d RegWrEn=%0b",
             $time, D1.PgmCtr, D1.Instruction,
             D1.ReadA, D1.ReadB, D1.InA, D1.InB,
             D1.ALU_out, D1.DM1.core[D1.ALU_out], D1.MemReadValue, D1.RegWriteValue, D1.Waddr_wire, D1.Ctrl1.RegWrEn);
  end
end

/* Monitor: print outputs (post-posedge) when PC == 88 or 91 — wait small delta so writes complete
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 88 || D1.PgmCtr == 91)) begin
    $display("POST@%0t PC=%0d Instr=%b  RegWriteValue=%0d Waddr=%0d RegWrEn=%0b  r0=%0d r1=%0d r2=%0d r3=%0d r4=%0d r5=%0d r6=%0d r7=%0d",
             $time, D1.PgmCtr, D1.Instruction,
             D1.RegWriteValue, D1.Waddr_wire, D1.Ctrl1.RegWrEn,
             D1.RF1.Registers[0], D1.RF1.Registers[1], D1.RF1.Registers[2], D1.RF1.Registers[3],
             D1.RF1.Registers[4], D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7]);
  end
end


always_ff @(posedge clk) begin
  if (!reset && D1.Ctrl1.RegWrEn && (D1.Waddr_wire == 3'd5)) begin
    $display("R5_UPDATED@%0t PC=%0d Instr=%b RegWriteValue=%0d r5=%0d",
             $time, D1.PgmCtr, D1.Instruction, D1.RegWriteValue, D1.RF1.Registers[5]);
  end
end


always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 57)) begin
    $display("PC57@%0t PC=%0d Instr=%b r3=%0d mem[0]=%0d mem[1]=%0d",
             $time, D1.PgmCtr, D1.Instruction,
             D1.RF1.Registers[3], D1.DM1.core[0], D1.DM1.core[1]);
  end
end




// Monitor inputs (pre-posedge) for PCs 26,33,39,47
always @(negedge clk) begin
  if (!reset && (D1.PgmCtr == 26 || D1.PgmCtr == 33 || D1.PgmCtr == 39 || D1.PgmCtr == 47)) begin
    $display("PRE@%0t PC=%0d Instr=%b  ReadA=%0d ReadB=%0d  InA=%0d InB=%0d  ALU_out_pre=%0d MemCell_pre=%0d MemReadValue=%0d Waddr=%0d LoadInst=%0b RegWrEn=%0b",
             $time, D1.PgmCtr, D1.Instruction,
             D1.ReadA, D1.ReadB,
             D1.InA, D1.InB,
             D1.ALU_out, D1.DM1.core[D1.ALU_out], D1.MemReadValue, D1.Waddr_wire, D1.Ctrl1.LoadInst, D1.Ctrl1.RegWrEn);
  end
end

// Monitor outputs (post-posedge) for PCs 26,33,39,47 — wait small delta so writes complete
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 26 || D1.PgmCtr == 33 || D1.PgmCtr == 39 || D1.PgmCtr == 47)) begin
    $display("POST@%0t PC=%0d Instr=%b  RegWriteValue=%0d Waddr=%0d RegWrEn=%0b  r0=%0d r1=%0d r2=%0d r3=%0d r4=%0d r5=%0d r6=%0d r7=%0d",
             $time, D1.PgmCtr, D1.Instruction,
             D1.RegWriteValue, D1.Waddr_wire, D1.Ctrl1.RegWrEn,
             D1.RF1.Registers[0], D1.RF1.Registers[1], D1.RF1.Registers[2], D1.RF1.Registers[3],
             D1.RF1.Registers[4], D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7]);
  end
end

*/

/* Print r7 after writes when PC == 23
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 23)) begin
    $display("PC23@%0t PC=%0d Instr=%b r7=%0d",
             $time, D1.PgmCtr, D1.Instruction, D1.RF1.Registers[7]);
  end
end

/* Print r6 after writes when PC == 24
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 24)) begin
    $display("PC24@%0t PC=%0d Instr=%b r6=%0d",
             $time, D1.PgmCtr, D1.Instruction, D1.RF1.Registers[6]);
  end
end

*/



  initial begin				   //wrap this in one big FOR loop
    #100ns;
    OpA =  -128;		           // generate operands
    OpB = -128;				   // for now, try out different values 
    #10ns   $display("%d, %d",OpA, OpB);
// 	compute correct answers
    #10ns  Prod = OpA * OpB;		      // compute prod.
          D1.DM1.core[0] = OpA;
    D1.DM1.core[1] = OpB;	   // load values into mem, copy to Tmp array
    	#10ns start = 'b0; 
    #10ns  reset = 'b0;
							  
  #10ns;
      D1.DM1.core[0] = OpA;
    D1.DM1.core[1] = OpB;	   // load values into mem, copy to Tmp array
    #200ns wait (done);						          // avoid false done signals on startup
    if({D1.DM1.core[3],D1.DM1.core[2]} == Prod)
	    $display("Yes! %d * %d = %d",OpA,OpB,Prod);
	  else
	    $display("Boo! %d * %d should = %d",OpA,OpB,Prod);    
    #20ns start = 'b1;
	#10ns reset = 'b1; 
	$stop;

$display("Final mem[2]=%0d mem[3]=%0d  Prod_expected=%0d", D1.DM1.core[2], D1.DM1.core[3], Prod);
$display("Final regs: r5=%0d r6=%0d r7=%0d r3=%0d", D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7], D1.RF1.Registers[3]);

  end


endmodule

//instantiated the proper top level module and connected the ports accordingly
//moved the memory write to after the start/reset signals