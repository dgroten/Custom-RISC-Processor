// Create Date:    2019.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
//
// Additional Comments: 					  $clog2

/* parameters are compile time directives 
       this can be an any-width, any-depth reg_file: just override the params!
*/
module RegFile #(parameter W=8, D=3)(		 // W = data path width (leave at 8); D = address pointer width
  input                Clk,
                        Reset,
                       WriteEn,
  input        [D-1:0] RaddrB,				 // address pointers
  input        [D-1:0] RaddrA,
  input        [D-1:0] Waddr,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOutA,			 // showing two different ways to handle DataOutX, for
  output logic [W-1:0] DataOutB				 //   pedagogic reasons only
    );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	             // or just registers[16] if we know D=4 always

// combinational reads 
/* can write always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/
assign DataOutA = (RaddrA == 0) ? {W{1'b0}} :
                  (RaddrA == 1) ? {{(W-1){1'b0}}, 1'b1} :
                  Registers[RaddrA]; 
always_comb DataOutB = (RaddrB == 0) ? {W{1'b0}} :
                       (RaddrB == 1) ? {{(W-1){1'b0}}, 1'b1} :
                       Registers[RaddrB];
// sequential (clocked) writes 
integer i;
always_ff @ (posedge Clk or posedge Reset) begin
  if (Reset) begin
    for (i = 0; i < (1<<D); i = i + 1)
      Registers[i] <= '0;
    Registers[1] <= {{(W-1){1'b0}}, 1'b1}; // r1 = 1
  end else begin
    if (WriteEn && (Waddr != 0) && (Waddr != 1))
      Registers[Waddr] <= DataIn;
  end
end

endmodule

// Changed D from 4 to 3 because there are only 2^3 = 8 registers in my ISA
// R1 is always 1, R0 is always 0, can't write to either