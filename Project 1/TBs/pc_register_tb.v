////////////////////////////////////////////////////////////////////////////////
//
// Module: pc_register_tb
//
// Class: ECE 552
// Assignment: Project 1
//
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Declaration of the module and internal signals
////////////////////////////////////////////////////////////////////////////////

module pc_register_tb ();

// Some opcodes I care about
localparam OPCODE_B      = 4'hC;
localparam OPCODE_BR     = 4'hD;
localparam OPCODE_HLT    = 4'hF;


// Wires/regs needed for the pc_register module
reg             clk;
reg             rst_n;
reg     [15:0]  instruction;
// This is small on purpose, that way the PC doesn't end up at a dumb address
reg     [10:0]  branch_reg_val;     
// This is large on purpose, that way I can use it in a for loop
reg     [3:0]   flags;
wire    [15:0]  pc;
wire    [15:0]  pc_plus_two;


// Things to make my life easier so I don't have to constantly decode
// instruction
wire    [3:0]   opcode;
wire    [2:0]   condition;
wire    [8:0]   b_offset;


// Used to check if the branch condition is met
wire            condition_met;


// Used for making sure the PC is correct
reg     [15:0]  old_pc;


// Loop variable
integer         i;


  //////////////////////////////////////////////////////////////////////////////
 // Instantiation of the pc_register module
////////////////////////////////////////////////////////////////////////////////

pc_register pc_register_instance (
	.clk            (clk),
	.rst_n          (rst_n),
	.instruction    (instruction),
	.branch_reg_val ({5'h0, branch_reg_val}),
	.flags          (flags[2:0]),
	.pc             (pc),
	.pc_plus_two    (pc_plus_two)
);


  //////////////////////////////////////////////////////////////////////////////
 // Actual testbench logic
////////////////////////////////////////////////////////////////////////////////

// Set the clock and start counting
initial clk = 1'b0;
always #100 clk = ~clk;

// Get these so that my life is a bit easier
assign opcode = instruction[15:12];
assign condition = instruction[11:9];
assign b_offset = ({{6{instruction[8]}}, instruction[8:0], 1'b0}) + 16'h2;

// Check to see if the branch condition is met
assign condition_met =
	(condition == 3'h0) ? ~flags[1] :
	(condition == 3'h1) ? flags[1] :
	(condition == 3'h2) ? ~flags[2] & ~flags[1] :
	(condition == 3'h3) ? flags[2] :
	(condition == 3'h4) ? flags[1] | (~flags[2] & ~flags[1]) :
	(condition == 3'h5) ? flags[2] | flags[1] :
	(condition == 3'h6) ? flags[0] :
	/*condition== 3'h7*/  1'b1;

// Make sure that pc_plus_two is correct each clock cycle
always @(posedge clk) begin
	#1 if (pc + 16'h2 != pc_plus_two) begin
		$display("ERROR: pc_plus_two != pc + 2");
		$display("    instr: %h", instruction);
		$display("    pc:   %h (%d)", pc, pc);
		$display("    pc+2: %h (%d)", pc_plus_two, pc_plus_two);
		$stop;
	end
end

// Main part of the testbench
initial begin
	// Assign everything a default value
	rst_n = 0;
	instruction = 0;
	branch_reg_val = 0;
	flags = 0;
	i = 0;

	// Let the active-low reset be asserted for a bit
	repeat(20) @(posedge clk);
	#1 rst_n = 1'b1;

	// Make sure pc is at 0x0000
	if (pc != 16'h0000) begin
		$display("ERROR: PC is not 0 after reset");
		$display("    error location code: PC_RST_0");
		$stop;
	end

	// Test all instructions except HLT because why not
	for (i = 0; i < 16'hF000; i = i + 9);
		// Test all possible flags because why not
		for (flags = 0; flags < 4'h8; flags = flags + 1) begin

			// Reset the PC sometimes so it doesn't overflow much
			if (pc > 16'hAFF) begin
				#1 rst_n = 1'b0;
				repeat(20) @(posedge clk);
				#1 rst_n = 1'b1;
				if (pc != 16'h0000) begin
					$display("ERROR: PC is not 0 after reset");
					$display("    error location code: PC_RST_1");
					$stop;
				end
			end

			// Run an ADD instruction to set the flags
			#1 instruction = 0;
			@(posedge clk);
			#1 instruction = i[15:0];

			// Get the current PC that will change in a bit
			#1 old_pc = pc;

			// Randomly assign branch_reg_val for use in a BR instruction
			branch_reg_val = $random;

			// Wait for the instruction to complete
			@(posedge clk);
			#1;

			// Check if pc is correct
			if (opcode == OPCODE_B) begin
				if (!condition_met && (pc != old_pc + 2)) begin
					$display("ERROR: Bad PC after not-taken B instruction");
					$display("    instruction: %h", instruction);
					$display("    cond:   %b", condition);
					$display("    flags:  %b", flags);
					$display("    old_pc: %h (%d)", old_pc, old_pc);
					$display("    pc:     %h (%d)", pc, pc);
					$display("    b_reg:  %h", branch_reg_val);
					$display("    b_off:  %h (%d)", b_offset, b_offset);
					$stop;
				end else if (condition_met && (pc != old_pc + b_offset)) begin
					$display("ERROR: Bad PC after taken B instruction");
					$display("    instruction: %h", instruction);
					$display("    cond:   %b", condition);
					$display("    flags:  %b", flags);
					$display("    old_pc: %h (%d)", old_pc, old_pc);
					$display("    pc:     %h (%d)", pc, pc);
					$display("    b_reg:  %h", branch_reg_val);
					$display("    b_off:  %h (%d)", b_offset, b_offset);
					$stop;
				end
			end else if (opcode == OPCODE_BR) begin
				if (!condition_met && (pc != old_pc + 2)) begin
					$display("ERROR: Bad PC after not-taken BR instruction");
					$display("    instruction: %h", instruction);
					$display("    cond:   %b", condition);
					$display("    flags:  %b", flags);
					$display("    old_pc: %h (%d)", old_pc, old_pc);
					$display("    pc:     %h (%d)", pc, pc);
					$display("    b_reg:  %h", branch_reg_val);
					$display("    b_off:  %h (%d)", b_offset, b_offset);
					$stop;
				end else if (condition_met && (pc != branch_reg_val)) begin
					$display("ERROR: Bad PC after taken BR instruction");
					$display("    instruction: %h", instruction);
					$display("    cond:   %b", condition);
					$display("    flags:  %b", flags);
					$display("    old_pc: %h (%d)", old_pc, old_pc);
					$display("    pc:     %h (%d)", pc, pc);
					$display("    b_reg:  %h", branch_reg_val);
					$display("    b_off:  %h (%d)", b_offset, b_offset);
					$stop;
				end
			end else begin
				if (pc != old_pc + 2) begin
					$display("ERROR: Bad PC after non-branch instruction");
					$display("    instruction: %h", instruction);
					$display("    old_pc: %h (%d)", old_pc, old_pc);
					$display("    cond:   %b", condition);
					$display("    flags:  %b", flags);
					$display("    pc:     %h (%d)", pc, pc);
					$display("    b_reg:  %h", branch_reg_val);
					$stop;
				end
			end
		end
	end

	// Test a bunch of HLT instructions
	repeat(2000) begin
		// Randomly assign instruction, but then give it the HLT opcode
		#1 instruction = $random;
		instruction[15:12] = OPCODE_HLT;

		// Save the current PC
		old_pc = pc;

		// Wait for the next clock cycle, then make sure old_pc == pc
		@(posedge clk);
		#1;
		if (old_pc != pc) begin
			$display("ERROR: PC changed after HLT instruction!");
			$display("    old_pc: %h (%d)", old_pc, old_pc);
			$display("    pc:     %h (%d)", pc, pc);
			$stop;
		end
	end

	// Reset the register, then make sure PC counts when doing an ADD, which
	// has an opcode of 0x0
	#1 instruction = 0;
	rst_n = 1'b0;
	repeat(20) @(posedge clk);
	#1 rst_n = 1'b1;

	// Make sure pc is at 0x0000
	if (pc != 16'h0000) begin
		$display("ERROR: PC is not 0 after reset");
		$display("    error location code: PC_RST_2");
		$stop;
	end

	repeat(2000) begin
		// Save the current PC
		#1 old_pc = pc;

		// Wait for the next clock cycle, then make sure pc = old_pc + 2
		@(posedge clk);
		#1;
		if (pc != old_pc + 2) begin
			$display("ERROR: Bad PC after non-branch instruction after HLT");
			$display("    instruction: %h", instruction);
			$display("    old_pc: %h (%d)", old_pc, old_pc);
			$display("    cond:   %b", condition);
			$display("    flags:  %b", flags);
			$display("    pc:     %h (%d)", pc, pc);
			$display("    b_reg:  %h", branch_reg_val);
			$stop;
		end
	end

	// If this is reached, then it's all good!
	$display("SUCCESS");
	$stop;
end

endmodule

