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


// Lines going in/out of the memory modules
wire    [15:0]  inst_mem_data_out;      // The value read from instr. memory

wire    [15:0]  data_mem_data_out;		// The value read from data memory
reg     [15:0]  data_mem_data_in;       // The value to write to data memory
reg     [15:0]  data_mem_addr;          // The address to read from or write to
reg             data_mem_enable;        // Enables memory reading and writing
reg             data_mem_wr;            // Enables memory writing. Requires
                                        //     data_mem_enable to be asserted


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


endmodule

