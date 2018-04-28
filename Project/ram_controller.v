////////////////////////////////////////////////////////////////////////////////
//
// Module: ram_controller
// Author: Ryan Job (rjob@wisc.edu)
//
// Class: ECE 552
// Assignment: Project 3
//
// This is basically a big FSM that determines what module can use memory.
// Only the caches are allowed to read from memory.
// Reading a word cannot be interrupted.
// Writing a word gets highest precedence.
// I-cache reads takes precedence over D-cache reads.
//
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Declaration of the module and internal signals
////////////////////////////////////////////////////////////////////////////////

module ram_controller (
	input   wire            clk,
	input   wire            rst_n,

	// Indicates that the RAM module is busy
	output  wire            ram_busy,

	// Used for writing data
	input   wire            ram_write,
	input   wire    [15:0]  ram_write_data,
	input   wire    [15:0]  ram_write_address,

	// The primary output signal for RAM data (used when updating a cache)
	output  wire    [15:0]  ram_data_out,

	// The signals used for cache updates to the instruction cache
	input   wire            i_cache_miss,
	input   wire    [15:0]  i_cache_miss_address,
	output  wire            i_cache_data_valid,

	// The signals used for cache updates to the data cache
	input   wire            d_cache_miss,
	input   wire    [15:0]  d_cache_miss_address,
	output  wire            d_cache_data_valid
);


// The states for this FSM. Reading from RAM takes multiple cycles, so they
// get their own state. Writing to RAM is done in the same cycle, so it
// doesn't need its own state (it can just use STATE_IDLE)
localparam STATE_IDLE           = 2'd0;
localparam STATE_I_CACHE_UPDATE = 2'd1;
localparam STATE_D_CACHE_UPDATE = 2'd2;
localparam STATE_UNUSED         = 2'd3;     // Effectively the same as IDLE

// Lines to determine the current and next state of this FSM
wire    [1:0]   state;
wire    [1:0]   next_state;

// Lines going to/from the memory instance
wire            memory_enable;
wire            memory_write;
wire    [15:0]  memory_address;
wire            memory_data_valid;


  //////////////////////////////////////////////////////////////////////////////
 // Internal Module Instantiations
////////////////////////////////////////////////////////////////////////////////

// The 4 cycle memory instance
memory4c memory_instance (
	.data_out   (ram_data_out),
	.data_in    (ram_write_data),
	.addr       (memory_address),
	.enable     (memory_enable),
	.wr         (memory_write),
	.clk        (clk),
	.rst        (~rst_n),
	.data_valid (memory_data_valid)
);

// The current state of this FSM. This is a 2-bit FSM
dff current_state_instance[1:0] (
	.q      (state),
	.d      (next_state),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


  //////////////////////////////////////////////////////////////////////////////
 // Basic Assign Statements
////////////////////////////////////////////////////////////////////////////////

//
// In either of the CACHE_UPDATE states, stay in the state until the
//     'memory_data_valid' signal is asserted, then go to STATE_IDLE.
//
// STATE_UNUSED will be have exactly like STATE_IDLE since it's invalid.
//
// In STATE_IDLE, the order of precedence of what happens next is as follows:
//     1) Write data to the RAM/memory (ram_write asserted)
//	       - Stays in STATE_IDLE since writes are only one clock cycle
//     2) Read data for the I-Cache (i_cache_miss asserted)
//         - Go to STATE_I_CACHE_UPDATE
//     3) Read data for the D-Cache (d_cache_miss asserted)
//	       - Go to STATE_D_CACHE_UPDATE
//     4) Stay in STATE_IDLE
//
assign next_state =
	state == STATE_I_CACHE_UPDATE ?
		(memory_data_valid ? STATE_IDLE : STATE_I_CACHE_UPDATE) :
	state == STATE_D_CACHE_UPDATE ?
		(memory_data_valid ? STATE_IDLE : STATE_D_CACHE_UPDATE) :
	// state == STATE_IDLE or state == STATE_UNUSED
	ram_write    ? STATE_IDLE :
	i_cache_miss ? STATE_I_CACHE_UPDATE :
	d_cache_miss ? STATE_D_CACHE_UPDATE :
				   STATE_IDLE;


// The RAM is busy whenever not in STATE_IDLE. Thus, it's just the ORs
// reduction of next_state.
assign ram_busy = |next_state;


// We need to enable the memory when either reading from it or writing to it.
// Reading from memory occurrs when 'next_state' is not STATE_IDLE.
// Since STATE_IDLE is state == 0, we can use an OR reduction on 'next_state'.
assign memory_enable = i_cache_miss | d_cache_miss | memory_write;


// We need to enable memory writing when in STATE_IDLE and 'ram_write' is
// asserted.
assign memory_write =
	state == STATE_IDLE ? ram_write : 1'b0;


// The 'memory_address' signal needs to be chosen based on the state.
// If in STATE_I_CACHE_UPDATE, then it should be 'i_cache_miss_address'.
// If in STATE_D_CACHE_UPDATE, then it should be 'd_cache_miss_address'.
// If in STATE_UNUSED, then treat it like STATE_IDLE.
// If in STATE_IDLE and 'ram_write' is asserted, then it should be
//     'ram_write_address'.
// If none of these cases are done, then let's just use the dummy address 0.
assign memory_address =
	state == STATE_I_CACHE_UPDATE ? i_cache_miss_address :
	state == STATE_D_CACHE_UPDATE ? d_cache_miss_address :
	// state == STATE_IDLE or state == STATE_UNUSED
	ram_write ? ram_write_address :
	            16'h0;


// When in STATE_I_CACHE_UPDATE, 'i_cache_data_valid' gets 'memory_data_valid'.
// Otherwise, it stays deasserted.
assign i_cache_data_valid =
	state == STATE_I_CACHE_UPDATE ? memory_data_valid : 1'b0;


// When in STATE_D_CACHE_UPDATE, 'd_cache_data_valid' gets 'memory_data_valid'.
// Otherwise, it stays deasserted.
assign d_cache_data_valid =
	state == STATE_D_CACHE_UPDATE ? memory_data_valid : 1'b0;


endmodule
