////////////////////////////////////////////////////////////////////////////////
//
// Module: cpu
//
// Class: ECE 552
// Assignment: Project 2
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

// NO IMPLICIT DECLARATIONS BECAUSE THOSE ARE HORRIBLE
// ^bump
//`default_nettype none

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

// Line used to control the hlt DFF
wire            old_hlt;


wire    [15:0]  if_instruction;
wire    [15:0]  if_pc;
wire    [15:0]  if_pc_plus_two;

wire    [63:0]  if_id_register_input;
wire    [63:0]  if_id_register_output;

wire    [3:0]   id_opcode;
wire    [15:0]  id_instruction;
wire    [15:0]  id_pc_plus_two;
wire    [3:0]   id_src_reg_1;
wire    [3:0]   id_src_reg_2;
wire    [15:0]  id_src_data_1;
wire    [15:0]  id_src_data_2;
wire    [3:0]   id_alu_immediate;
wire    [3:0]   id_dest_reg;
wire    [7:0]   id_load_half_byte;

wire    [63:0]  id_ex_register_input;
wire    [63:0]  id_ex_register_output;

wire    [3:0]   ex_opcode;
wire    [15:0]  ex_pc_plus_two;
wire    [15:0]  ex_src_data_1;
wire    [15:0]  ex_src_data_2;
wire    [3:0]   ex_alu_immediate;
wire    [15:0]  ex_alu_result;
wire    [2:0]   ex_alu_flags;
wire    [3:0]   ex_dest_reg;
wire    [7:0]   ex_load_half_byte;

wire    [63:0]  ex_mem_register_input;
wire    [63:0]  ex_mem_register_output;

wire    [3:0]   mem_opcode;
wire    [15:0]  mem_pc_plus_two;
wire    [15:0]  mem_data_in;		// Gets ex_src_data_2
wire    [15:0]  mem_alu_result;
wire    [15:0]  mem_addr;			// Gets ex_alu_result
wire    [2:0]   mem_alu_flags;
wire    [7:0]   mem_load_half_byte;
wire    [15:0]  mem_data_out;
wire            mem_enable;
wire            mem_wr;
wire    [3:0]   mem_dest_reg;
wire    [15:0]  mem_reg_write_value;

wire    [63:0]  mem_wb_register_input;
wire    [63:0]  mem_wb_register_output;

wire            wb_reg_write;
wire    [3:0]   wb_opcode;
wire    [3:0]   wb_dest_reg;
wire    [15:0]  wb_reg_write_value;



  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 1: Instrucgtion Fetch
////////////////////////////////////////////////////////////////////////////////

// The PC register module, which is in charge of maintaining the current PC
// and updating it each clock cycle
pc_register pc_register_instance (
	.clk            (clk),
	.rst_n          (rst_n),
	.instruction    (if_instruction),
	.branch_reg_val (ex_src_data_1),
	.flags          (ex_alu_flags),
	.pc             (if_pc),
	.pc_plus_two    (if_pc_plus_two)
);

assign pc = if_pc;

// The single cycle instruction memory
// The memory module was provided to us
memory1c memory1c_instruction_instance (
	.data_out	(if_instruction),
	.data_in    (16'h0000),                 // Don't need to write ever
	.addr       (if_pc),
	.enable     (~old_hlt),                 // Always read until hlt is asserted
	.wr         (1'b0),                     // Don't need to write ever
	.clk        (clk),
	.rst        (~rst_n)
);

assign if_id_register_input[15:0]  = if_pc_plus_two;
assign if_id_register_input[31:16] = if_instruction;

// The IF/ID Pipeline Register
pipeline_register if_id_register_instance (
	.stall      (0),
	.flush      (~rst_n),
	.clk        (clk),
	.opcode_in  (if_instruction[15:12]),
	.opcode_out (id_opcode),
	.inputs     (if_id_register_input),
	.outputs    (if_id_register_output)
);


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stages 2 & 5: Instrucgtion Decode & Write Back
////////////////////////////////////////////////////////////////////////////////

// Decompress data from the if_id_register_output
assign id_pc_plus_two = if_id_register_output[15:0];
assign id_instruction = if_id_register_output[31:16];


// All instructions use instruction[7:4] as src_reg_1 (if they use it at all).
// If it's not needed, then it doesn't matter what's being read
assign id_src_reg_1 = id_instruction[7:4];

// Compute instructions use instruction[3:0]. SW uses instruction[11:8].
// No other instruction uses src_reg_2, so it can just be whatever.
// If opcode[3] == 1'b0, then it's a compute instruction.
assign id_src_reg_2 = (id_opcode[3] == 1'b0) ?id_instruction[3:0] : id_instruction[11:8];

// There are no instructions where dest_reg is not instruction[11:8]. Thus,
// it'll just be up to the reg_write signal to make sure writes don't screw
// things up
assign id_dest_reg = id_instruction[11:8];

// The LHB and LLB instructions need this
assign id_load_half_byte = id_instruction[7:0];




// Decompress data from the mem_wb_register_output
assign wb_reg_write_value = mem_wb_register_output[15:0];
assign wb_dest_reg = mem_wb_register_output[19:16];


// Only write to registers for certain instructions. These instructions are
// LW, LHB, LLB, PCS, and all compute instructions (opcode[3] == 1'b0).
// In order to simplify the logic, I used a Karnaugh map to determine a Product
// of Sums solution to this logic
assign wb_reg_write =
	(~wb_opcode[3] |  wb_opcode[1] | ~wb_opcode[0]) &
	(~wb_opcode[3] | ~wb_opcode[2] |  wb_opcode[1]) &
	(~wb_opcode[3] | ~wb_opcode[2] | ~wb_opcode[0]);




// The register file we made
register_file register_file_instance (
	.clk        (clk),
	.rst        (~rst_n),
	.SrcReg1    (id_src_reg_1),
	.SrcReg2    (id_src_reg_2),
	.DstReg     (wb_dest_reg),
	.WriteReg   (wb_reg_write),
	.DstData    (wb_reg_write_value),
	.SrcData1   (id_src_data_1),
	.SrcData2   (id_src_data_2)
);


// Compress data for the id_ex_register_input
assign id_ex_register_input[15:0]  = id_pc_plus_two;
assign id_ex_register_input[31:16] = id_src_data_1;
assign id_ex_register_input[47:32] = id_src_data_2;
assign id_ex_register_input[51:48] = id_alu_immediate;
assign id_ex_register_input[55:52] = id_dest_reg;
assign id_ex_register_input[63:56] = id_load_half_byte;

// The ID/EX Pipeline Register
pipeline_register id_ex_register_instance (
	.stall      (0),
	.flush      (~rst_n),
	.clk        (clk),
	.opcode_in  (id_opcode),
	.opcode_out (ex_opcode),
	.inputs     (id_ex_register_input),
	.outputs    (id_ex_register_output)
);


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 3: Execute
////////////////////////////////////////////////////////////////////////////////

// Decompress data from the id_ex_register_output
assign ex_pc_plus_two    = id_ex_register_output[15:0];
assign ex_src_data_1     = id_ex_register_output[31:16];
assign ex_src_data_2     = id_ex_register_output[47:32];
assign ex_alu_immediate  = id_ex_register_output[51:48];
assign ex_dest_reg       = id_ex_register_output[55:52];
assign ex_load_half_byte = id_ex_register_output[63:56];


// The ALU module for addition/subtraction
alu alu_instance (
	.src_data_1 (ex_src_data_1),           // The register value from src_reg_1
	.src_data_2 (ex_src_data_2),           // The register value from src_reg_2
	.immediate  (ex_alu_immediate),        // The 4-bit immediate value
	.opcode     (ex_opcode),
	.alu_result (ex_alu_result),
	.flags      (ex_alu_flags)
);


// Compress data for the ex_mem_register_input
assign ex_mem_register_input[15:0]  = ex_pc_plus_two;
assign ex_mem_register_input[31:16] = ex_src_data_2;
assign ex_mem_register_input[47:32] = ex_alu_result;
assign ex_mem_register_input[50:48] = ex_alu_flags;
assign ex_mem_register_input[54:51] = ex_dest_reg;
assign ex_mem_register_input[62:55] = ex_load_half_byte;

// The EX/MEM Pipeline Register
pipeline_register ex_mem_register_instance (
	.stall      (0),
	.flush      (~rst_n),
	.clk        (clk),
	.opcode_in  (ex_opcode),
	.opcode_out (mem_opcode),
	.inputs     (ex_mem_register_input),
	.outputs    (ex_mem_register_output)
);


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 4: Memory
////////////////////////////////////////////////////////////////////////////////

// Decompress data from the ex_mem_register_output
assign mem_pc_plus_two    = ex_mem_register_output[15:0];
assign mem_data_in        = ex_mem_register_output[31:16];     // Gets ex_src_data_2
assign mem_alu_result     = ex_mem_register_output[47:32];
assign mem_alu_flags      = ex_mem_register_output[50:48];
assign mem_dest_reg       = ex_mem_register_output[54:51];
assign mem_load_half_byte = ex_mem_register_output[62:55];


// Only write to memory for SW instructions
assign mem_wr = (mem_opcode == OPCODE_SW) ? 1'b1 : 1'b0;

// The data to write to the register. It's usually the output of the ALU, so
// that's why it's the default case
assign mem_reg_write_value =
	(mem_opcode == OPCODE_LW)  ? mem_data_out :
	(mem_opcode == OPCODE_LHB) ? {mem_load_half_byte, mem_data_in[7:0]} :
	(mem_opcode == OPCODE_LLB) ? {mem_data_in[15:8], mem_load_half_byte} :
	(mem_opcode == OPCODE_PCS) ? mem_pc_plus_two :
	                             mem_alu_result;


// The single cycle data memory
// The memory module was provided to us
memory1c memory1c_data_instance (
	.data_out   (mem_data_out),
	.data_in    (mem_data_in),          // src_reg_2 is the only thing stored
	.addr       (mem_alu_result),       // The address always comes from the ALU
	.enable     (~old_hlt),           // Always read until hlt is asserted
	.wr         (mem_wr),
	.clk        (clk),
	.rst        (~rst_n)
);


// Compress data for the mem_wb_register_input
assign mem_wb_register_input[15:0]  = mem_reg_write_value;
assign mem_wb_register_input[19:16] = mem_dest_reg;

// The MEM/WB Pipeline Register
pipeline_register mem_wb_register_instance (
	.stall      (0),
	.flush      (~rst_n),
	.clk        (clk),
	.opcode_in  (mem_opcode),
	.opcode_out (wb_opcode),
	.inputs     (mem_wb_register_input),
	.outputs    (mem_wb_register_output)
);





// A D-Flip-Flop used to control the hlt signal
dff hlt_instance (
	.q      (old_hlt),
	.d      (hlt),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


  //////////////////////////////////////////////////////////////////////////////
 // Not Register File Control Stuff
////////////////////////////////////////////////////////////////////////////////

// If the current instruction is HLT, then assert hlt. Since the opcode for
// HLT is 4'hF, I can just use an AND reduction on the opcode
assign hlt =
	~rst_n  ? 1'b0 :
	&wb_opcode ? 1'b1 :
	        old_hlt;


endmodule
