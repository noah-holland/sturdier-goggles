////////////////////////////////////////////////////////////////////////////////
// 
// Module: cpu
//
// Class: ECE 552
// Assignment: Project 1
//
// Inputs:
//   clk    System clock
//   rst_n  Active low reset. Causes execution to start at address 0x0000
//
// Outputs:
//   hlt    When the processor hits the HLT instruction, this signal will be
//              asserted once done processing the instruction prior to the HLT
//   pc     The PC value over the course of program execution
//
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Declaration of the module and internal signals
////////////////////////////////////////////////////////////////////////////////

module cpu (
	input   wire            clk,
	input   wire            rst_n,
	output  wire            hlt,
	output  wire    [15:0]  pc
);


// Parameters used to determine opcodes (most significant 4 bits)
localparam OPCODE_ADD    = 4'h0;
localparam OPCODE_SUB    = 4'h1;
localparam OPCODE_RED    = 4'h2;
localparam OPCODE_XOR    = 4'h3;
localparam OPCODE_SLL    = 4'h4;
localparam OPCODE_SRA    = 4'h5;
localparam OPCODE_ROR    = 4'h6;
localparam OPCODE_PADDSB = 4'h7;
localparam OPCODE_LW     = 4'h8;
localparam OPCODE_SW     = 4'h9;
localparam OPCODE_LHB    = 4'hA;
localparam OPCODE_LLB    = 4'hB;
localparam OPCODE_B      = 4'hC;
localparam OPCODE_BR     = 4'hD;
localparam OPCODE_PCS    = 4'hE;
localparam OPCODE_HLT    = 4'hF;

// This is just the opcode of the current instruction (for ease of use)
wire    [3:0]   opcode;


// This is output by the PC register just for the PCS instruction
wire    [15:0]  pc_plus_two;


// This is the only thing not directly mapped in the instruction memory. It's
// just the current instruction
wire    [15:0]  instruction;


// Lines going in/out of the register file
wire    [3:0]   src_reg_1;              // The first register to read from
wire    [3:0]   src_reg_2;              // The second register to read from
wire    [3:0]   dest_reg;               // The register to write to
wire            reg_write;              // Reg file write enable
wire    [15:0]  reg_write_data;         // The value to write to dest_reg
wire    [15:0]  src_data_1;             // The value read from src_reg_1
wire    [15:0]  src_data_2;             // The value read from src_reg_2


// Lines going in/out of the ALU (some are manually assigned)
wire    [15:0]  alu_result;
wire    [15:0]  flags;


// Lines going in/out of the data memory
wire    [15:0]  data_mem_data_out;		// The value read from data memory
wire            data_mem_wr;            // Enables memory writing. Requires
                                        //     data_mem_enable to be asserted


  //////////////////////////////////////////////////////////////////////////////
 // Internal Modules
////////////////////////////////////////////////////////////////////////////////

// The PC register module, which is in charge of maintaining the current PC
// and updating it each clock cycle
pc_register pc_register_instance (
	.clk            (clk),
	.rst_n          (rst_n),
	.instruction    (instruction),
	.branch_reg_val (src_reg_1),
	.flags          (flags),
	.pc             (pc),
	.pc_plus_two    (pc_plus_two)
);

// The single cycle instruction memory
// The memory module was provided to us
memory1c memory1c_instruction_instance (
	.data_out	(instruction),
	.data_in    (16'h0000),     // Don't need to write ever
	.addr       (pc),
	.enable     (~hlt),         // Always read until hlt is asserted
	.wr         (1'b0),         // Don't need to write ever
	.clk        (clk),
	.rst        (~rst_n)
);

// The register file we made
register_file register_file_instance (
	.clk        (clk),
	.rst        (~rst_n),
	.SrcReg1    (src_reg_1),
	.SrcReg2    (src_reg_2),
	.DstReg     (dest_reg),
	.WriteReg   (reg_write),
	.DstData    (reg_write_data),
	.SrcData1   (src_data_1),
	.SrcData2   (src_data_2)
);

// The ALU module for addition/subtraction
alu alu_instance (
	.src_data_1 (src_data_1),           // The register value from src_reg_1
	.src_data_2 (src_data_2),           // The register value from src_reg_2
	.immediate  (instruction[3:0]),     // The 4-bit immediate value
	.opcode     (opcode),
	.alu_result (alu_result),
	.flags      (flags)
);

// The single cycle data memory
// The memory module was provided to us
memory1c memory1c_data_instance (
	.data_out	(data_mem_data_out),
	.data_in    (src_reg_2),            // src_reg_2 is the only thing stored
	.addr       (alu_result),           // The address always comes from the ALU
	.enable     (~hlt),                 // Always read until hlt is asserted
	.wr         (data_mem_wr),
	.clk        (clk),
	.rst        (~rst_n)
);


  //////////////////////////////////////////////////////////////////////////////
 // Not Register File Control Stuff
////////////////////////////////////////////////////////////////////////////////

// This just makes it easier to write stuff
assign opcode = instruction[15:12];

// If the current instruction is HLT, then assert hlt. Since the opcode for
// HLT is 4'hF, I can just use an AND reduction on the opcode
assign hlt = &opcode;

// Only write to memory for SW instructions
assign data_mem_wr = (opcode == OPCODE_SW) ? 1'b1 : 1'b0;


  //////////////////////////////////////////////////////////////////////////////
 // Register File Control Stuff
////////////////////////////////////////////////////////////////////////////////

// To learn more about the register assignments, see "instruction_encoding.txt"

// All instructions use instruction[7:4] as src_reg_1 (if they use it at all).
// If it's not needed, then it doesn't matter what's being read
assign src_reg_1 = instruction[7:4];

// Compute instructions use instruction[3:0]. SW uses instruction[11:8].
// No other instruction uses src_reg_2, so it can just be whatever.
// If opcode[3] == 1'b0, then it's a compute instruction.
assign src_reg_2 = (opcode[3] == 1'b0) ? instruction[3:0] : instruction[11:8];

// There are no instructions where dest_reg is not instruction[11:8]. Thus,
// it'll just be up to the reg_write signal to make sure writes don't screw
// things up
assign dest_reg = instruction[11:8];

// Only write to registers for certain instructions. These instructions are
// LW, LHB, LLB, PCS, and all compute instructions (opcode[3] == 1'b0).
// In order to simplify the logic, I used a Karnaugh map to determine a Sum of
// Products solution to this logic
assign reg_write =
	(~opcode[3]) |				    // Compute instructions
	(~opcode[2] & ~opcode[0]) |     // LW, LHB
	(~opcode[2] & opcode[1])  |     // LHB, LLB
	(opcode[1] & ~opcode[0]);       // LHB, PCS

// The data to write to the register. It's usually the output of the ALU, so
// that's why it's the default case
assign reg_write_data =
	(opcode == OPCODE_LW)  ? data_mem_data_out :
	(opcode == OPCODE_LHB) ? {instruction[7:0], 8'h00} :
	(opcode == OPCODE_LLB) ? {8'h00, instruction[7:0]} :
	(opcode == OPCODE_PCS) ? pc_plus_two :
	                         alu_out;


endmodule

