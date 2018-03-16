////////////////////////////////////////////////////////////////////////////////
// 
// Module: cpu
//
// Class: ECE 552
// Assignment: Project 1
//
// Inputs:
//   clk System clock
//   rst_n  Active low reset. Causes execution to start at address 0x0000
//
// Outputs:
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

// This is asserted if the branch condition is met
wire            condition_met;

// This is the value of next_pc if it's a B operation and the branch is taken
wire    [15:0]  pc_plus_offset;

// This is the next value of the pc
wire    [15:0]  next_pc;

// Make separate lines for the flags in case they need to get changed around
wire            neg_flag;       // negative
wire            zro_flag;	    // zero
wire            ovf_flag;       // overflow


  //////////////////////////////////////////////////////////////////////////////
 // Assignment of various things
////////////////////////////////////////////////////////////////////////////////

assign opcode = instruction[15:12];
assign condition = instruction[11:9];

// The offset if doing a B operation is sign_extend(instruction[8:0] << 1)
assign b_offset = {{6{instruction[8]}}, instruction[8:0], 1'b0};

// Assign the value of next_pc to be one of these things
assign next_pc = (opcode == OPCODE_HLT)      ? pc :
	((opcode == OPCODE_B)  && condition_met) ? pc_plus_offset : 
	((opcode == OPCODE_BR) && condition_met) ? branch_reg_val :
	                                           pc_plus_two;


  //////////////////////////////////////////////////////////////////////////////
 // Instantiation of Non-DFF Modules
////////////////////////////////////////////////////////////////////////////////



  //////////////////////////////////////////////////////////////////////////////
 // Instantiation of the DFF modules used to make the PC register
////////////////////////////////////////////////////////////////////////////////

// These are the 16 D-Flip-Flop modules used for the PC register
dff pc_00 (
	.q (pc[0]), .d (next_pc[0]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_01 (
	.q (pc[1]), .d (next_pc[1]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_02 (
	.q (pc[2]), .d (next_pc[2]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_03 (
	.q (pc[3]), .d (next_pc[3]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_04 (
	.q (pc[4]), .d (next_pc[4]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_05 (
	.q (pc[5]), .d (next_pc[5]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_06 (
	.q (pc[6]), .d (next_pc[6]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_07 (
	.q (pc[7]), .d (next_pc[7]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_08 (
	.q (pc[8]), .d (next_pc[8]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_09 (
	.q (pc[9]), .d (next_pc[9]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_10 (
	.q (pc[10]), .d (next_pc[10]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_11 (
	.q (pc[11]), .d (next_pc[11]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_12 (
	.q (pc[12]), .d (next_pc[12]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_13 (
	.q (pc[13]), .d (next_pc[13]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_14 (
	.q (pc[14]), .d (next_pc[14]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);

dff pc_15 (
	.q (pc[15]), .d (next_pc[15]), .wen (~hlt),
	.clk (clk), .rst (~rst_n)
);


endmodule

