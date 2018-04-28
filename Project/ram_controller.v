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

	// Used for writing data
	input   wire            ram_write,
	input   wire    [15:0]  ram_write_data,
	input   wire    [15:0]  ram_write_address,

	// The primary output signals for RAM data (used when updating a cache)
	output  wire    [15:0]  ram_data_address,
	output  wire    [15:0]  ram_data_out,

	// The signals used for cache updates to the instruction cache
	input   wire            i_cache_miss,
	input   wire    [15:0]  i_cache_miss_address,
	output  wire            i_cache_updating,
	output  wire            i_cache_write_data_array,
	output  wire            i_cache_write_tag_array,

	// The signals used for cache updates to the data cache
	input   wire            d_cache_miss,
	input   wire    [15:0]  d_cache_miss_address,
	output  wire            d_cache_updating,
	output  wire            d_cache_write_data_array,
	output  wire            d_cache_write_tag_array,
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

// Counts how many words have been read from memory
wire    [3:0]   read_word;
wire    [3:0]   read_word_plus_one;
wire    [3:0]   next_read_word;

// Counts how many words have been returned to the cache
wire    [3:0]   return_word;
wire    [3:0]   return_word_plus_one;
wire    [3:0]   next_return_word;

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


// The DFF modules to store the 'read_word' value
dff read_word_dff_instance[3:0] (
	.q      (read_word),
	.d      (next_read_word),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


// The DFF modules to store the 'return_word' value
dff return_word_dff_instance[3:0] (
	.q      (return_word),
	.d      (next_return_word),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


// A 4-bit incrementer to increment 'read_word'
incrementer_4_bit read_word_incrementer_instance (
	.input_value  (read_word),
	.output_value (read_word_plus_one)
);


// A 4-bit incrementer to increment 'return_word'
incrementer_4_bit return_word_incrementer_instance (
	.input_value  (return_word),
	.output_value (return_word_plus_one)
);


  //////////////////////////////////////////////////////////////////////////////
 // Assign Statements
////////////////////////////////////////////////////////////////////////////////

//
// Next-state logic to feed into the 'state' DFF.
// On reset, go to STATE_IDLE.
// If in the unused state somehow, go to STATE_IDLE.
// If currently in STATE_IDLE and a cache miss was detected, the D_Cache takes
//     precedence over the I_Cache.
// If currently updating the D_Cache and 'reading_last_word' is asserted, then
//     either go to STATE_UPDATE_I_CACHE or STATE_IDLE depending on if there's
//     an I_Cache miss.
// If not in STATE_IDLE and 'reading_last_word' is asserted, then go to
//     STATE_IDLE (only reached if the previous case was false)
// If none of the above cases are taken, then it just stays in the current state
//
assign next_state =
	(~rst_n) ? STATE_IDLE :
	(state == STATE_UNUSED) ? STATE_IDLE :
	((state == STATE_I_CACHE_UPDATE) & d_cache_miss) ? STATE_D_CACHE_UPDATE :
	((state == STATE_IDLE) & ram_write)    ? STATE_IDLE :
	((state == STATE_IDLE) & d_cache_miss) ? STATE_D_CACHE_UPDATE :
	((state == STATE_IDLE) & i_cache_miss) ? STATE_I_CACHE_UPDATE :
	((state != STATE_IDLE) & return_word_plus_one[3]) ? STATE_IDLE :
		state;


// When in STATE_IDLE, clear this to 0. Otherwise, increment it until it gets
// to 4'h8 (increment it while read_word[3] == 0).
assign next_read_word =
	((state == STATE_I_CACHE_UPDATE) & d_cache_miss) ? 4'h0 :
	(state == STATE_IDLE) ? 4'h0 :
	(~read_word[3])       ? read_word_plus_one :
	                        read_word;


// The 'return_word' signal must be carefully timed.
// If 'read_word' equals 4'h3, then increment.
// If 'return_word[3]' is 1, then 'return_word' gets cleared.
// If 'return_word' is nonzero, then increment.
assign next_return_word =
	((state == STATE_I_CACHE_UPDATE) & d_cache_miss) ? 4'h0 :
	(read_word == 4'h3)       ? return_word_plus_one :
	(return_word_plus_one[3]) ? 4'h0 :
	(|return_word)            ? return_word_plus_one :
	                            return_word;


// The I-Cache and D-Cache are updaing if in STATE_I_CACHE_UPDATE or
// STATE_D_CACHE_UPDATE respectively.
assign i_cache_updating = (state == STATE_I_CACHE_UPDATE) ? 1'b1 : 1'b0;
assign d_cache_updating = (state == STATE_D_CACHE_UPDATE) ? 1'b1 : 1'b0;


// The caches need to know what address the data is coming from
assign ram_data_address =
	(state == STATE_I_CACHE_UPDATE) ? {i_cache_miss_address[15:4], return_word[2:0], 1'b0} :
	(state == STATE_D_CACHE_UPDATE) ? {d_cache_miss_address[15:4], return_word[2:0], 1'b0} :
		ram_write_address;


// We need to enable the memory when writing to it (only happens in STATE_IDLE).
// When not in STATE_IDLE, we are reading from memory, so keep the enable high
//     until 'read_word[3]' is 1, meaning that all 8 addresses we need to read
//     has been sent to the memory
assign memory_enable =
	(state == STATE_IDLE) ? ram_write : ~read_word[3];


// We need to enable memory writing when in STATE_IDLE and 'ram_write' is
// asserted.
assign memory_write =
	(state == STATE_IDLE) ? ram_write : 1'b0;


//TODO: Comment this better
assign memory_address =
	(state == STATE_I_CACHE_UPDATE) ? {i_cache_miss_address[15:4], read_word[2:0], 1'b0} :
	(state == STATE_D_CACHE_UPDATE) ? {d_cache_miss_address[15:4], read_word[2:0], 1'b0} :
	                                  ram_write_address;


// Have the caches write to the data array if updating that cache and
// 'memory_data_valid' is asserted. Also have them write to their tag array if
// 'return_word' equals 4'h7
assign i_cache_write_data_array = i_cache_updating & memory_data_valid;
assign i_cache_write_tag_array  = i_cache_updating & (return_word == 4'h7);

assign d_cache_write_data_array = d_cache_updating & memory_data_valid;
assign d_cache_write_tag_array  = d_cache_updating & (return_word == 4'h7);


endmodule
