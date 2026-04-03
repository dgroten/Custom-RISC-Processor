def convert(inFile, outFile):
	assembly_file = open(inFile, 'r')
	machine_file = open(outFile, 'w')
	assembly = list(assembly_file.read().split('\n'))

	#dictionaries to ease conversion of opcodes/operands to binary
	opcodes = {'add' : '000', 'and' : '001', 'xor' : '010', 'lsl' : '011',
	'lsr' : '100', 'ldr' : '101', 'str' : '110', 'blt' : '111'}
	registers = {'r0' : '000', 'r1' : '001', 'r2' : '010', 'r3' : '011',
	'r4' : '100', 'r5' : '101', 'r6' : '110', 'r7' : '111'}
	immediates = {'-4' : '100', '-3' : '101', '-2' : '110', '-1' : '111',
    '0' : '000', '1' : '001', '2' : '010', '3' : '011'}
	
	#reads through file to convert instructions to machine code
	for line in assembly:
		output = ""
		instr = line.replace(',', '').split(); #split to get instruction and different operands
		#make sure it is an instruction, skip over labels
		if instr[0] in opcodes:
			output += opcodes[instr[0]]
			if output == '101' or output == '110' or output == '111': #load, store, and branch are an immediate type
				output += registers[instr[1]]
				output += immediates[instr[3]]
			else: # others are register type
				output += registers[instr[1]]
				output += registers[instr[3]]
			machine_file.write(str(output) + '\n')

	assembly_file.close()
	machine_file.close()

#convert("assembly.txt", "machine.txt")
convert("Program 1.txt", "machine1.txt")
convert("Program 2.txt", "machine2.txt")
convert("Program 3.txt", "machine3.txt")