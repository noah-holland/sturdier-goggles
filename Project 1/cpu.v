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
	output  reg     [15:0]  pc
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
localparam OPCODE_BPS    = 4'hE;
localparam OPCODE_HLT    = 4'hF;


// Lines going in/out of the memory modules
wire    [15:0]  inst_mem_data_out;      // The value read from instr. memory

wire    [15:0]  data_mem_data_out;		// The value read from data memory
reg     [15:0]  data_mem_data_in;       // The value to write to data memory
reg     [15:0]  data_mem_addr;          // The address to read from or write to
reg             data_mem_enable;        // Enables memory reading and writing
reg             data_mem_wr;            // Enables memory writing. Requires
                                        //     data_mem_enable to be asserted

// Lines going in/out of the register file
reg     [3:0]   src_reg_1;              // The first register to read from
reg     [3:0]   src_reg_2;              // The second register to read from
reg     [3:0]   dest_reg;               // The register to write to
reg             reg_write;              // Reg file write enable
reg     [15:0]  reg_write_data;         // The value to write to dest_reg
wire    [15:0]  src_data_1;             // The value read from src_reg_1
wire    [15:0]  src_data_2;             // The value read from src_reg_2


  //////////////////////////////////////////////////////////////////////////////
 // Internal Modules
////////////////////////////////////////////////////////////////////////////////

// The single cycle data memory
// The memory module was provided to us
memory1c data_mem (
	.data_out	(data_mem_data_out),
	.data_in    (data_mem_data_in),
	.addr       (data_mem_addr),
	.enable     (data_mem_enable),
	.wr         (data_mem_wr),
	.clk        (clk),
	.rst        (~rst_n)
);

// The single cycle instruction memory
// The memory module was provided to us
memory1c inst_mem (
	.data_out	(inst_mem_data_out),
	.data_in    (16'h0000),     // Don't need to write ever
	.addr       (pc),
	.enable     (1'b1),         // Always can read
	.wr         (1'b0),         // Don't need to write ever
	.clk        (clk),
	.rst        (~rst_n)
);

// The register file we made
RegisterFile reg_file (
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


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 1: Instruction Fetch
////////////////////////////////////////////////////////////////////////////////



  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 2: Instruction Decode
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 3: Execute
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 4: Memory
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Pipeline Stage 5: Write Back
////////////////////////////////////////////////////////////////////////////////



endmodule

