////////////////////////////////////////////////////////////////////////////////
// 
// Module: cache_fill_fsm
// Author: Ryan Job (rjob@wisc.edu)
//
// Class: ECE 552
// Assignment: Project 3
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

	input   wire            miss_detected,      // A cache miss was detected
	input   wire    [15:0]  miss_address,       // The address that had the miss

	output  wire            fsm_busy,           // This FSM is busy

	output  wire            write_data_array,   // Enable signal for cache data array
	output  wire            write_tag_array,    // Once all words filled in, 

	output  wire    [15:0]  memory_address,
	input   wire            memory_data_valid
);


// The lines and parameters used to determine the FSM state
wire            state;
wire            next_state;
localparam STATE_IDLE = 1'b0;
localparam STATE_BUSY = 1'b1;

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
dff state_dff_instance (
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
	.d      (next_partial_memory_address),
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

// Next-state logic to feed into the 'state' DFF. Basically, go to STATE_IDLE
// on reset. If in STATE_IDLE and a miss was detected, go to STATE_BUSY. If in
// STATE_BUSY and both 'reading_last_word' and 'memory_data_valid' are
// asserted, then the last word is being read, so go back to STATE_IDLE.
// Otherwise, just stay in whatever the current state is

assign next_state =
	~rst_n ? STATE_IDLE :
	(~|(state ^ STATE_IDLE) & miss_detected) ? STATE_BUSY :
	(~|(state ^ STATE_BUSY) & reading_last_word & memory_data_valid) ? STATE_IDLE :
		state;


// The FSM is busy whenever it's not in STATE_IDLE
assign fsm_busy = |(state ^ STATE_IDLE);


// On reset, clear the partial memory address to 0 just cuz.
// When in STATE_IDLE and a miss was detected, capture the upper 12 bits of
// 'miss_address' and store it in 'partial_memory_address_instance'.
// Otherwise, leave it alone
assign next_partial_memory_address =
	~rst_n ? 12'h0 :
	(~(state ^ STATE_IDLE) & miss_detected) ? miss_address[15:4] :
		partial_memory_address;


// The upper 12 bits are 'partial_memory_address' cuz that's what it's for.
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


// When in STATE_IDLE, do not write to the data array. When in other states,
// write to the data array when the memory data is valid
assign write_data_array =
	(state == STATE_BUSY) ? memory_data_valid : 1'b0;


// Write to the tag array when also writing the last word of the block. This
// happens when 'reading_last_word' and 'memory_data_valid' are both asserted.
// 'reading_last_word' will only ever be asserted when in STATE_BUSY.
assign write_tag_array = reading_last_word & memory_data_valid;


endmodule

