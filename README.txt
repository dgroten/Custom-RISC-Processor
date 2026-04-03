Steps to synthesize my processor:
- Open Quartus
- Create a new project called TopLevel
- Add all of the .sv files except for the ones beginning with test_bench
- Compile
- Select RTL viewer
- The RTL viewer should show my synthesized processor

Steps to simulate my processor:
- Open ModelSim
- Edit line 49 of InstRom.sv to include the machine code file you want to use (my current code uses an absolute path)
	- For program 1 (Hamming distances), use machine1.txt
	- For program 2 (double precision multiplier), use machine2.txt
- Open ModelSim project
- Compile all (may need to do so twice)
- Click start simulation
- Pick the design unit that you want to test
	- For program 1, select work.test_bench_hamming (NOTE: There are two lines in this test bench where I use an absolute path. You may need to edit these lines to work on your PC.)
	- For program 2, select work.test_bench_prod2. You can change the operands in this file to test different values. (NOTE: If changing the values, remember to recompile.)
- Click run -all
- The transcript should show the results of the test

Something to know:
- The LUT isn't utilized but it is required so that the processor runs properly.
