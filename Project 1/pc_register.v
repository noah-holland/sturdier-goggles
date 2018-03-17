////////////////////////////////////////////////////////////////////////////////
// 
// Module: cpu
//
// Class: ECE 552
// Assignment: Project 1
//
// Inputs:
//   clk                System clock
//   rst_n              Active low reset. Resets the PC to address 0x0000
//   instruction        The current instruction being operated on
//   branch_reg_val     The value of the register used in a BR instruction
//   flags              The ALU flags used for checking the branch conditions
//
// Outputs:
//   pc                 The current PC value
//   pc_plus_two        The value of the current PC plus two
//
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Declaration of the module and internal signals
////////////////////////////////////////////////////////////////////////////////

module pc_register (
	input   wire            clk,
	input   wire            rst_n,
	input   wire    [15:0]  instruction,
	input   wire    [15:0]  branch_reg_val,
	input   wire    [2:0]   flags,
	output	wire    [15:0]  pc,
	output  wire    [15:0]  pc_plus_two
);


// These are the opcodes I need for this instruction
localparam OPCODE_B      = 4'hC;
localparam OPCODE_BR     = 4'hD;
localparam OPCODE_HLT    = 4'hF;


// These are parts of the instruction that are helpful to have separate
wire    [3:0]   opcode;
wire    [2:0]   condition;
wire    [15:0]  b_offset;


// These are the wires going in/out of the DFFs for the flag bits
wire            n_flag;
wire            next_n_flag;

wire            z_flag;
wire            set_z_flag;     // The logic to set the Z flag is complicated
wire            next_z_flag;

wire            v_flag;
wire            next_v_flag;


// This is the value of next_pc if it's a B operation and the branch is taken
wire    [15:0]  pc_plus_offset;

// This is the next value of the pc
wire    [15:0]  next_pc;


// This is asserted if the branch condition is met
wire            condition_met;


  //////////////////////////////////////////////////////////////////////////////
 // Internal Modules
////////////////////////////////////////////////////////////////////////////////

// This module just adds two to the pc to produce pc_plus_two
AddTwo pc_increment_adder (
	.in     (pc),
	.out    (pc_plus_two)
);

// The 16-bit CLA used to add pc_plus_two and b_offset to produce pc_plus_offset
word_CLA pc_offset_adder (
	.CIn        (1'b0),
	.A          (pc_plus_two),
	.B          (b_offset),
	.Overflow   (),
	.COut       (),
	.Sum        (pc_plus_offset)
);

// The PC register
dff pc_reg[15:0] (
	.q      (pc),
	.d      (next_pc),
	.wen	(1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);

// Zero flag
dff flag_z (
	.q      (z_flag),
	.d      (next_z_flag),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);

// Overflow flag
dff flag_v (
	.q      (v_flag),
	.d      (next_v_flag),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);

// Negative flag
dff flag_n (
	.q      (n_flag),
	.d      (next_n_flag),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);

  //////////////////////////////////////////////////////////////////////////////
 // Assign things directly from "instruction"
////////////////////////////////////////////////////////////////////////////////

// Sub-components of instruction
assign opcode = instruction[15:12];
assign condition = instruction[11:9];

// The offset if doing a B operation is sign_extend(instruction[8:0] << 1)
assign b_offset = {{6{instruction[8]}}, instruction[8:0], 1'b0};


  //////////////////////////////////////////////////////////////////////////////
 // Assignments for all the flag things
////////////////////////////////////////////////////////////////////////////////

// Only update the n_flag if doing an ADD or SUB instruction. These have
// opcodes of 0x0 and 0x1 respectively, so just check opcode[3:1] == 3'h0
// (done with an OR reduction)
assign next_n_flag = |opcode[3:1] ? flags[2] : n_flag;


// Only update the z_flag if doing ADD, SUB, XOR, SLL, SRA, and ROR. These
// have opcodes of 0x0, 0x1, 0x3, 0x4, 0x5, 0x6. I used a Karnaugh map to
// determine what the proper Sum of Products is for this condition
assign set_z_flag =
	(~opcode[3] & ~opcode[1]) |
	(~opcode[3] & ~opcode[2] &  opcode[0]) |
	(~opcode[3] &  opcode[2] & ~opcode[0]);

assign next_z_flag = set_z_flag ? flag[1] : z_flag;


// Only update the v flag if doing an ADD or SUB instruction, just like N
assign next_v_flag = |opcode[3:1] ? flags[0] : v_flag;


  //////////////////////////////////////////////////////////////////////////////
 // Assignments for branch condition checking and updating the PC
////////////////////////////////////////////////////////////////////////////////

// I used a Karnaugh map to figure this out
assign condition_met =
	(~condition[1] &  condition[0] &  z_flag) |
	( condition[1] &  condition[0] &  n_flag) |
	( condition[2] & ~condition[1] &  z_flag) |
	( condition[2] &  condition[0] &  n_flag) |
	( condition[2] &  condition[1] &  v_flag) |
	( condition[2] &  condition[1] &  condition[0]) |
	(~condition[2] & ~condition[1] & ~condition[0] & ~z_flag) |
	(~condition[2] & ~condition[0] & ~n_flag & ~z_flag) |
	(~condition[1] & ~condition[0] & ~n_flag & ~z_flag);

// Assign the value of next_pc to be one of these things
assign next_pc = (opcode == OPCODE_HLT)     ? pc :
	((opcode == OPCODE_B)  & condition_met) ? pc_plus_offset : 
	((opcode == OPCODE_BR) & condition_met) ? branch_reg_val :
	                                          pc_plus_two;

endmodule

