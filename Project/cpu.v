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
wire    [2:0]  flags;


// Lines going in/out of the data memory
wire    [15:0]  data_mem_data_out;		// The value read from data memory
wire            data_mem_wr;            // Enables memory writing. Requires
                                        //     data_mem_enable to be asserted


// Line used to control the hlt DFF
wire            old_hlt;




wire    [15:0]  if_instruction;
wire    [15:0]  if_pc;
wire    [15:0]  if_pc_plus_two;

wire    [31:0]  if_id_register_input;
wire    [31:0]  if_id_register_output;

wire    [3:0]   id_opcode;
wire    [15:0]  id_src_reg_1;
wire    [15:0]  id_src_reg_2;
wire    [15:0]  id_pc_plus_two;
wire    [15:0]  id_src_data_1;
wire    [15:0]  id_src_data_2;
wire    [15:0]  id_alu_immediate;
wire    [3:0]   id_dest_reg;

wire    [55:0]  id_ex_register_input;
wire    [55:0]  id_ex_register_output;

wire    [3:0]   ex_opcode;
wire    [15:0]  ex_pc_plus_two;
wire    [15:0]  ex_src_data_1;
wire    [15:0]  ex_src_data_2;
wire    [3:0]   ex_alu_immediate;
wire    [15:0]  ex_alu_result;
wire    [2:0]   ex_flags;
wire    [3:0]   ex_dest_reg;

wire    [54:0]  ex_mem_register_input;
wire    [54:0]  ex_mem_register_output;

wire    [3:0]   mem_opcode;
wire    [15:0]  mem_data_out;
wire    [15:0]  mem_data_in;		// Gets ex_src_data_2
wire    [15:0]  mem_addr;			// Gets ex_alu_result
wire            mem_enable;
wire            mem_wr;
wire    [3:0]   mem_dest_reg;
wire    [15:0]  mem_reg_write_value;

wire    [19:0]  mem_wb_register_input;
wire    [19:0]  mem_wb_register_output;

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
	.instruction    (instruction),
	.branch_reg_val (src_data_1),
	.flags          (flags),
	.pc             (pc),
	.pc_plus_two    (pc_plus_two)
);

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

// The IF/ID Pipeline Register
pipeline_register if_id_register_instance (
	.stall      (),
	.flush      (),
	.opcode_in  (if_instruction[15:12]),
	.opcode_out (id_opcode),
	.inputs     ({if_pc_plus_two, if_instruction}),
	.outputs    (if_id_register_output)
);


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 2: Instrucgtion Decode
////////////////////////////////////////////////////////////////////////////////

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

// The ID/EX Pipeline Register
pipeline_register id_ex_register_instance (
	.stall      (),
	.flush      (),
	.opcode_in  (id_opcode),
	.opcode_out (ex_opcode),
	.inputs     ({id_pc_plus_two, id_src_data_1, id_src_data_2, id_alu_immediate, id_dest_reg}),
	.outputs    (id_ex_register_output)
);


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 3: Execute
////////////////////////////////////////////////////////////////////////////////

// The ALU module for addition/subtraction
alu alu_instance (
	.src_data_1 (ex_src_data_1),           // The register value from src_reg_1
	.src_data_2 (ex_src_data_2),           // The register value from src_reg_2
	.immediate  (ex_alu_immediate),        // The 4-bit immediate value
	.opcode     (ex_opcode),
	.alu_result (ex_alu_result),
	.flags      (ex_flags)
);

// The EX/MEM Pipeline Register
pipeline_register ex_mem_register_instance (
	.stall      (),
	.flush      (),
	.opcode_in  (ex_opcode),
	.opcode_out (mem_opcode),
	.inputs     ({ex_pc_plus_two, ex_src_data_2, ex_alu_result, ex_alu_flags, ex_dest_reg}),
	.outputs    ()
);


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 4: Memory
////////////////////////////////////////////////////////////////////////////////

// The single cycle data memory
// The memory module was provided to us
memory1c memory1c_data_instance (
	.data_out   (mem_data_out),
	.data_in    (mem_data_in),          // src_reg_2 is the only thing stored
	.addr       (mem_addr),             // The address always comes from the ALU
	.enable     (mem_enable),             // Always read until hlt is asserted
	.wr         (mem_wr),
	.clk        (clk),
	.rst        (~rst_n)
);

// The MEM/WB Pipeline Register
pipeline_register mem_wb_register_instance (
	.stall      (),
	.flush      (),
	.opcode_in  (mem_opcode),
	.opcode_out (wb_opcode),
	.inputs     ({mem_dest_reg, mem_reg_write_value}),
	.outputs    ()
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

// This just makes it easier to write stuff
assign opcode = instruction[15:12];

// If the current instruction is HLT, then assert hlt. Since the opcode for
// HLT is 4'hF, I can just use an AND reduction on the opcode
assign hlt =
	~rst_n  ? 1'b0 :
	&opcode ? 1'b1 :
	        old_hlt;

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
// In order to simplify the logic, I used a Karnaugh map to determine a Product
// of Sums solution to this logic
assign reg_write =
	(~opcode[3] |  opcode[1] | ~opcode[0]) &
	(~opcode[3] | ~opcode[2] |  opcode[1]) &
	(~opcode[3] | ~opcode[2] | ~opcode[0]);

// The data to write to the register. It's usually the output of the ALU, so
// that's why it's the default case
assign reg_write_data =
	(opcode == OPCODE_LW)  ? data_mem_data_out :
	(opcode == OPCODE_LHB) ? {instruction[7:0], src_data_2[7:0]} :
	(opcode == OPCODE_LLB) ? {src_data_2[15:8], instruction[7:0]} :
	(opcode == OPCODE_PCS) ? pc_plus_two :
	                         alu_result;


endmodule
