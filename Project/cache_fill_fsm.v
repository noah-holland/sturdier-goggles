////////////////////////////////////////////////////////////////////////////////
// 
// Module: cache_fill_fsm
// Author: Ryan Job (rjob@wisc.edu)
//
// Class: ECE 552
// Assignment: HW9
//
// How this works:
//   - Wait in STATE_IDLE until a miss is detected
//   - Assert 'fsm_busy' and go to STATE_BUSY
//   - Wait until 'memory_data_valid' is asserted
//   - Assert 'write_data_array' for a clock cycle and increment 'words_read'
//   - If enough words have been read, then assert 'write_tag_array' and go
//       back to STATE_IDLE. Otherwise, keep reading data
//
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Declaration of the module and internal signals
////////////////////////////////////////////////////////////////////////////////

module cache_fill_fsm (
	input   wire            clk,
	input   wire            rst_n,

	output  wire            fsm_busy,

	// Miss detected comes from I_Cache. Address comes from PC
	input   wire            i_cache_miss_detected,
	input   wire    [15:0]  i_cache_miss_address,

	// Goes to the I_Cache thing
	output  wire            write_i_cache_data_array,
	output  wire            write_i_cache_tag_array,

	// Miss detected comes from D_Cache. Address comes from somewhere in CPU
	input   wire            d_cache_miss_detected,
	input   wire    [15:0]  d_cache_miss_address,

	// Goes to the D_Cache thing
	output  wire            write_d_cache_data_array,
	output  wire            write_d_cache_tag_array,

	// Goes to/from the memory module
	output  wire    [15:0]  memory_address,
	input   wire            memory_data_valid
);


// The lines and parameters used to determine the FSM state
wire    [1:0]   state;
wire    [1:0]   next_state;
localparam STATE_IDLE           = 2'h0;
localparam STATE_UPDATE_D_CACHE = 2'h1;
localparam STATE_UPDATE_I_CACHE = 2'h2;
localparam STATE_UNUSED         = 2'h3;

// Stores the partial memory address (the top 12 bits of the memory address)
wire    [11:0]  partial_memory_address;
wire    [11:0]  next_partial_memory_address;

// Counts how many words have been read. I only really care about counting to 7
wire    [2:0]   words_read;
wire    [2:0]   words_read_plus_one;
wire    [2:0]   next_words_read;

// Indicates that the current word is the last word to be read
wire            reading_last_word;


  //////////////////////////////////////////////////////////////////////////////
 // Internal Module Instantiation
////////////////////////////////////////////////////////////////////////////////

// The DFF module to store the 'state' value
dff state_dff_instance[1:0] (
	.q      (state),
	.d      (next_state),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


// The DFF modules to store the part of 'miss_address' that I need so I can
// set 'memory_address' properly. Since 8 words get read, and each word is
// 2 bits, and since addresses are 16 bits, I only need to store the upper 12
// bits of 'miss_address'
dff partial_memory_address_instance[11:0] (
	.q      (partial_memory_address),
	.d      (next_partial_memory_address[11:0]),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


// The DFF modules to store the 'words_read' value
dff words_read_dff_instance[2:0] (
	.q      (words_read),
	.d      (next_words_read),
	.wen    (1'b1),
	.clk    (clk),
	.rst    (~rst_n)
);


// A 3-bit incrementer to increment 'words_read'
incrementer_3_bit words_read_incrementer_instance (
	.input_value  (words_read),
	.output_value (words_read_plus_one)
);


  //////////////////////////////////////////////////////////////////////////////
 // Assign Statements
////////////////////////////////////////////////////////////////////////////////

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

assign next_state =
	~rst_n ? STATE_IDLE :
	(~|(state ^ STATE_UNUSED)) ? STATE_IDLE :
	(~|(state ^ STATE_IDLE) & d_cache_miss_detected) ? STATE_UPDATE_D_CACHE :
	(~|(state ^ STATE_IDLE) & i_cache_miss_detected) ? STATE_UPDATE_I_CACHE :
	(~|(state ^ STATE_UPDATE_D_CACHE) & reading_last_word & i_cache_miss_detected) ? STATE_UPDATE_I_CACHE :
	(|(state ^ STATE_IDLE) & reading_last_word) ? STATE_IDLE :
		state;

// The FSM is busy whenever it's not in STATE_IDLE. This can thus be an OR
// reduction of state ^ STATE_IDLE.
assign fsm_busy = |(state ^ STATE_IDLE);


// On reset, reset the partial memory address to 0 just cuz.
// If not changing state (state == next_state), then leave it alone.
// If next_state is STATE_UPDATE_D_CACHE, then get the top 12 bits of
//     'd_cache_miss_address'.
// If next_state is STATE_UPDATE_I_CACHE, then get the top 12 bits of
//     'i_cache_miss_address'.
// If none of these are taken, then just leave it alone.
assign next_partial_memory_address =
	~rst_n ? 12'h0 :
	|(state ^ next_state) ? partial_memory_address :
	~|(next_state ^ STATE_UPDATE_D_CACHE) ? d_cache_miss_address[15:4] :
	~|(next_state ^ STATE_UPDATE_I_CACHE) ? i_cache_miss_address[15:4] :
		partial_memory_address;


// The lower 4 bits of memory_address is the word being read and a 0 (since
// words are 2 bits wide)
assign memory_address = {partial_memory_address, words_read, 1'b0};


// When in STATE_IDLE, 'words_read' should always be 0. Otherwise, increment
// it whenever 'memory_data_valid' is asserted. Otherwise, just leave it alone
assign next_words_read =
	state == STATE_IDLE ? 4'h0 :
	memory_data_valid   ? words_read_plus_one :
	                      words_read;


// When 'words_read' is 7, then the last word is being read. Since it's 3 bits
// wide, it's 7 when all bits are 1 (hence the AND reduction)
assign reading_last_word = &words_read;


// When in whichever state for updating a cache, write data whenever memory
// data is valid. Otherwise, do not write to the data array.
assign write_d_cache_data_array =
	(state == STATE_UPDATE_D_CACHE) ? memory_data_valid : 1'b0;

assign write_i_cache_data_array =
	(state == STATE_UPDATE_I_CACHE) ? memory_data_valid : 1'b0;


// Write to the tag array when also writing the last word of the block. This
// happens when 'reading_last_word' and 'memory_data_valid' are both asserted.
// Also, make sure it's in the correct state for each of the cache write
// signals.
assign write_d_cache_tag_array =
	(state == STATE_UPDATE_D_CACHE) ? reading_last_word & memory_data_valid : 1'b0;

assign write_i_cache_tag_array =
	(state == STATE_UPDATE_I_CACHE) ? reading_last_word & memory_data_valid : 1'b0;


endmodule

