// program 1-2-3    CSE141L   
module test_bench_hamming;

// connections to DUT: clock, reset, start (request), done (acknowledge) 
  bit  clk,
       reset = 'b1,				// should set your PC = 0
       start = 'b1;				// falling edge should initiate the program
  wire done;					// you return 1 when finished

  logic[ 3:0] Dist, Min, Max;	// current, min, max Hamming distances
  logic[ 4:0] Min1, Min2;	 	// addresses of pair w/ smallest Hamming distance
  logic[ 4:0] Max1, Max2;		// addresses of pair w/ largest Hamming distance
  logic[ 7:0] Tmp[16];		    // cache of 16 8-bit values assembled from data_mem

  TopLevel D1(.Clk  (clk  ),	        // your design goes here
		 .Reset(reset),			// rename input/output ports as needed
		 .Start(start),
		 .Ack (done )); 

  always begin
    #50ns clk = 'b1;
	#50ns clk = 'b0;
  end


/*

always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b111)) begin
    $display("BLT@PC=%0d Instr=%b  R7=%0d R3=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU.Zero=%b RegWrEn=%b Waddr=%0d",
      D1.PgmCtr,
      D1.Instruction,
      D1.RF1.Registers[7],
      D1.RF1.Registers[3],
      D1.ReadA,
      D1.ReadB,
      D1.InA,
      D1.InB,
      D1.ALU1.Zero,
      D1.Ctrl1.RegWrEn,
      D1.Waddr_wire
    );
  end
end






always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b001)) begin
    $display("AND@PC=%0d Instr=%b  Rdest=%0d RsrcA=%0d RsrcB=%0d InA=%0d InB=%0d ALU.Out=%0d",
      D1.PgmCtr, D1.Instruction,
      D1.Waddr_wire, 3'd7, D1.Instruction[2:0], // Waddr / RaddrA / RaddrB (adjust if you use different fields)
      D1.InA, D1.InB, D1.ALU1.Out
    );
  end
end









always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b110) && D1.Ctrl1.MemWrEn) begin
    $display("STORE@PC=%0d Addr=%0d Data=%0d (r5=%0d r7=%0d)",
      D1.PgmCtr, D1.ALU_out, D1.MemWriteValue,
      D1.RF1.Registers[5], D1.RF1.Registers[7]
    );
  end
end



always_ff @(posedge clk) begin
  if (!reset && (D1.Waddr_wire == 3'd5) && D1.Ctrl1.RegWrEn) begin
    $display("R5_WRITE@PC=%0d NewR5=%0d (was %0d)",
      D1.PgmCtr, D1.ALU1.Out, D1.RF1.Registers[5]
    );
  end
end


always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b100)) begin
    $display("LSR@PC=%0d  InputA=%0d InputB=%0d Shift_amt=%0d ALU.Out=%0d",
      D1.PgmCtr, D1.InA, D1.InB, D1.InB[2:0], D1.ALU1.Out
    );
  end
end



always_ff @(posedge clk) begin
if (!reset && (D1.PgmCtr >= 34 && D1.PgmCtr <= 42)) begin
$display("PC=%0d Instr=%b Waddr=%0d RegWrEn=%b MemWrEn=%b r7=%0d r4=%0d r5=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d ALU_Zero=%b",
D1.PgmCtr,
D1.Instruction,
D1.Waddr_wire,
D1.Ctrl1.RegWrEn,
D1.Ctrl1.MemWrEn,
D1.RF1.Registers[7],
D1.RF1.Registers[4],
D1.RF1.Registers[5],
D1.ReadA,
D1.ReadB,
D1.InA,
D1.InB,
D1.ALU1.Out,
D1.ALU1.Zero
);
end
end




// DEBUG: when add writes r5
always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b000) && (D1.Instruction[5:3] == 3'd5)) begin
    $display("ADD_R5@PC=%0d Instr=%b ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d RegWrEn=%b Waddr=%0d",
      D1.PgmCtr, D1.Instruction, D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU1.Out, D1.Ctrl1.RegWrEn, D1.Waddr_wire);
  end
end




// DEBUG: BLT + store-to-max area
always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b111)) begin
    $display("BLT@PC=%0d Instr=%b ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU.Zero=%b",
      D1.PgmCtr, D1.Instruction, D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU1.Zero);
  end
  // store-to-max opcode = STR (110) and address/addr computed by ALU_out
  if (!reset && (D1.Instruction[8:6] == 3'b110)) begin
    $display("STR@PC=%0d Instr=%b Addr(ALU_out)=%0d Data(MemWriteValue)=%0d RegWrEn=%b MemWrEn=%b",
      D1.PgmCtr, D1.Instruction, D1.ALU_out, D1.MemWriteValue, D1.Ctrl1.RegWrEn, D1.Ctrl1.MemWrEn);
  end
end



always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 29)) begin
    $display("PC29@%0d Instr=%b  Waddr=%0d RegWrEn=%b ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d r5=%0d r7=%0d",
      D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.Ctrl1.RegWrEn,
      D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU1.Out,
      D1.RF1.Registers[5], D1.RF1.Registers[7]);
  end
end


always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr >= 15 && D1.PgmCtr <= 30)) begin
    $display("TRACE PC=%0d Instr=%b Waddr=%0d RegWrEn=%b MemWrEn=%0b r7=%0d r5=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d",
      D1.PgmCtr, D1.Instruction, D1.Waddr_wire, D1.Ctrl1.RegWrEn, D1.Ctrl1.MemWrEn,
      D1.RF1.Registers[7], D1.RF1.Registers[5], D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU1.Out);
  end
end








// DEBUG: inspect the BLT at PC=27 (blt r6, r7, 1)
always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr == 27) && (D1.Instruction[8:6] == 3'b111)) begin
    $display("BLT27@PC=%0d Instr=%b  opcode=%b  R6=%0d R7=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d ALU.Zero=%b BranchEn=%b PCTarg=%b BranchImmExt=%0d",
      D1.PgmCtr,
      D1.Instruction,
      D1.Instruction[8:6],
      D1.RF1.Registers[6],
      D1.RF1.Registers[7],
      D1.ReadA,
      D1.ReadB,
      D1.InA,
      D1.InB,
      D1.ALU1.Out,
      D1.ALU1.Zero,
      D1.Ctrl1.BranchEn,
      D1.Ctrl1.PCTarg,
      D1.BranchImmExt
    );
  end
end







// DEBUG: when XOR executes (compute Hamming number)
always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b010)) begin
    $display("XOR@PC=%0d Instr=%b  r4_before=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d Waddr=%0d RegWrEn=%0b",
      D1.PgmCtr, D1.Instruction, D1.RF1.Registers[4],
      D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU1.Out, D1.Waddr_wire, D1.Ctrl1.RegWrEn);
  end
end





// DEBUG: when LDR writes into r4 (memory -> r4)
always_ff @(posedge clk) begin
  if (!reset && (D1.Instruction[8:6] == 3'b101) && (D1.Waddr_wire == 3'd4)) begin
    $display("LDR->R4@PC=%0d Instr=%b  Addr(ALU_out)=%0d MemRead=%0d Waddr=%0d RegWrEn=%0b",
      D1.PgmCtr, D1.Instruction, D1.ALU_out, D1.MemReadValue, D1.Waddr_wire, D1.Ctrl1.RegWrEn);
  end
end





// DEBUG: any write to r4 (catch overwrites)
always_ff @(posedge clk) begin
  if (!reset && (D1.Waddr_wire == 3'd4) && D1.Ctrl1.RegWrEn) begin
    $display("R4_WRITE@PC=%0d Instr=%b  NewR4=%0d (old=%0d) ALU_Out=%0d MemRead=%0d",
      D1.PgmCtr, D1.Instruction, D1.ALU1.Out, D1.RF1.Registers[4], D1.ALU1.Out, D1.MemReadValue);
  end
end









always_ff @(posedge clk) begin
  if (!reset) begin
    // any LDR instruction (opcode 101)
    if (D1.Instruction[8:6] == 3'b101) begin
      $display("LDR_DBG@PC=%0d Instr=%b LoadInst=%b  Waddr=%0d RegWrEn=%b  ALU_out=%0d MemRead=%0d RegWriteValue=%0d PCTarg=%b BranchImmExt=%0d",
        D1.PgmCtr, D1.Instruction, D1.Ctrl1.LoadInst, D1.Waddr_wire, D1.Ctrl1.RegWrEn,
        D1.ALU_out, D1.MemReadValue, D1.RegWriteValue, D1.Ctrl1.PCTarg, D1.BranchImmExt);
    end

    // any write to r4 (catch overwrites from any opcode)
    if ((D1.Waddr_wire == 3'd4) && D1.Ctrl1.RegWrEn) begin
      $display("R4_DBG_WRITE@PC=%0d Instr=%b  NewR4=%0d (old=%0d) ALU_Out=%0d MemRead=%0d LoadInst=%b RegWriteValue=%0d",
        D1.PgmCtr, D1.Instruction, D1.RegWriteValue, D1.RF1.Registers[4], D1.ALU1.Out, D1.MemReadValue, D1.Ctrl1.LoadInst, D1.RegWriteValue);
    end
  end
end







always_ff @(posedge clk) begin
  if (!reset && (D1.PgmCtr >= 34 && D1.PgmCtr <= 60)) begin
    $display("MM@PC=%0d Instr=%b  r4=%0d r5=%0d r6=%0d r7=%0d ReadA=%0d ReadB=%0d InA=%0d InB=%0d ALU_Out=%0d LoadInst=%b RegWrEn=%b Waddr=%0d MemRead=%0d MemAddr=%0d",
      D1.PgmCtr, D1.Instruction,
      D1.RF1.Registers[4], D1.RF1.Registers[5], D1.RF1.Registers[6], D1.RF1.Registers[7],
      D1.ReadA, D1.ReadB, D1.InA, D1.InB, D1.ALU1.Out,
      D1.Ctrl1.LoadInst, D1.Ctrl1.RegWrEn, D1.Waddr_wire, D1.MemReadValue, D1.ALU_out);
  end
end

*/



  initial begin
// load operands for program 1 into data memory
// 16 8-bit operands go into data_mem [0:15]
// mem[16,17] = min & max Hamming distances among sdata pairs
    #100ns;
	Min = 'd8;						         // start test bench Min at max value
	Max = 'd0;						         // start test bench Max at min value
    $readmemb("C:\\Users\\Daniel\\Desktop\\CSE 141L\\NARM\\test1_2.txt",D1.DM1.core);

    for(int i=0; i<16; i++) begin
      Tmp[i] = {D1.DM1.core[i]};
      $display("%d:  %b",i,Tmp[i]);
	end
	$display();                              // line-space
// DUT data memory preloads beyond [15] (next 3 lines of code)
    D1.DM1.core[16] = 'd8;		             // preset DUT final Min 
    for(int r=17; r<256; r++)
      D1.DM1.core[r] = 'd0;		             // preset DUT final Max to min possible 

// Initialize DUT's register file: clear then ensure r1 == 1 (ISA convention)
    for (int j = 0; j < 8; j = j + 1)
      D1.RF1.Registers[j] = 8'b0;
    D1.RF1.Registers[1] = 8'b1;

// 	compute correct answers
    for(int j=0; j<16; j++) begin
      for(int k=j+1; k<16; k++) begin
	    #1ns Dist = ham(Tmp[j],Tmp[k]);
		$display("j,kj = [%d,%d] dist=%d",j,k,Dist); 
        if(Dist<Min) begin                   // update Hamming minimum
          Min = Dist;						 //   value
		  Min2 = j;							 //	  location of data pair
		  Min1 = k;							 //         "
		end  
		if(Dist>Max) begin 			         // update Hamming maximum
		  Max = Dist;						 //   value
		  Max2 = j;							 //   location of data pair
		  Max1 = k;							 //			"
        end
	  end
    end   
	//D1.DM1.core[16] = Min;
	//D1.DM1.core[17] = Max;
	#200ns start = 'b0;
	#200ns reset = 'b0; 

$readmemb("C:\\Users\\Daniel\\Desktop\\CSE 141L\\NARM\\test1_2.txt",D1.DM1.core);

    #200ns wait (done);						 // avoid false done signals on startup
								 
// check results in data_mem[64] and [65] (Minimum and Maximum distances, respectively)
    if(Min == D1.DM1.core[16]) $display("good Min = %d",Min);
	else                      $display("fail Min: Correct = %d; Yours = %d",Min,D1.DM1.core[16]);
                              $display("Min addr = %d, %d",Min1, Min2);
							  $display("Min valu = %b, %b",Tmp[Min1],Tmp[Min2]);//{D1.DM1.core[2*Min1],D1.DM1.core[2*Min1+1]},{D1.DM1.core[2*Min2],D1.DM1.core[2*Min2+1]});
	if(Max == D1.DM1.core[17]) $display("good Max = %d",Max);
	else                      $display("MAD  Max: Correct = %d; Yours = %d",Max,D1.DM1.core[17]);
	                          $display("Max pair = %d, %d",Max1, Max2);
							  $display("Max valu = %b, %b",Tmp[Max1],Tmp[Max2]);// {D1.DM1.core[2*Max1],D1.DM1.core[2*Max1+1]},{D1.DM1.core[2*Max2],D1.DM1.core[2*Max2+1]});
    #10ns reset = 1; start = 1; 
	$stop;
end
     	
// Hamming distance (anticorrelation) between two 16-bit numbers 
  function[3:0] ham(input[15:0] a, b);
    ham = 'b0;
    for(int q=0;q<8;q++)
      if(a[q]^b[q]) ham++;	                // count number of bits for which a[i] = !b[i]
  endfunction

endmodule

//changed DUT initialization: r1 needs to stay r1 but the test bench kept resetting it to 0
//switched order of reset and start signals
//added a second readmemb to reload data memory after reset
//added then commented out large debug section