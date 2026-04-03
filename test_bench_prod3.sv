// program 3    CSE141L   product D = OpA * OpB * OpC  
// operands are 8-bit two's comp integers, product is 24-bit two's comp integer
// revised 2025.11.12 to resolve endianness of product and reset connection disparity against the assignment writeup
module test_bench_prod3;

// connections to DUT: clk (clock), reset, start (request), done (acknowledge) 
  bit  clk,
       reset = 'b1,				 // should set your PC = 0
       start = 'b1;				 // falling edge should initiate the program
  wire done;					 // you return 1 when finished

  logic signed[ 7:0] OpA, OpB,OpC;
  logic signed[23:0] Prod;	    // holds 2-byte product		  

  TopLevel D1(.Clk  (clk  ),	        // your design goes here
         .Reset(reset),
		 .Start(start),
		 .Ack (done )); 

  always begin
    #50ns clk = 'b1;
	#50ns clk = 'b0;
  end

  initial begin				   // wrap this in one big FOR loop
    #100ns;
    OpA =  2;		           // generate operands
    OpB = 4;				   // for now, try out different values 
    OpC =  8;

    #10ns   $display("%d, %d, %d",OpA, OpB, OpC);
// 	compute correct answers
    #10ns  Prod = OpA * OpB * OpC;		      // compute prod.
          D1.DM1.core[0] = OpA;
    D1.DM1.core[1] = OpB;	   // load values into mem, copy to Tmp array
    D1.DM1.core[2] = OpC;				  
    	#10ns  start = 'b0; 
    #10ns  reset = 'b0;			
#10ns;
      D1.DM1.core[0] = OpA;
    D1.DM1.core[1] = OpB;	   // load values into mem, copy to Tmp array
    D1.DM1.core[2] = OpC;				  
    #200ns wait (done);						          // avoid false done signals on startup
    if({D1.DM1.core[5],D1.DM1.core[4],D1.DM1.core[3]} == Prod)
	    $display("Yes! %d * %d * %d = %d",OpA,OpB,OpC,Prod);
	  else
	    $display("Boo! %d * %d * %d should = %d",OpA,OpB,OpC,Prod);    
    #20ns start = 'b1;
	#10ns reset = 'b1; 
	$stop;
  end


endmodule

//instantiated the proper top level module and connected the ports accordingly
//moved the memory write to after the start/reset signals