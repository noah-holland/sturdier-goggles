//////////////////////////////////////////////////////////
/// This module instantiates a cache and a miss fsm for 
/// one of the caches.  It will also be the interaction
/// between the cpu and the cache.
//////////////////////////////////////////////////////////

module cache_controller(
	input wire clk,
	input wire rst_n,
	input wire write,
	input wire cache_enable,
	input wire [15:0] cache_address,
	input wire [15:0] data_in,
	input wire [15:0] memory_data,
	input wire memory_data_valid,
	output wire [15:0] data_out,
	output wire cache_miss,
	output wire [15:0] memory_address
);


	wire cache_miss_internal;	//If the cache missed or not
	wire fsm_busy;			//If the fsm is fixing the miss
	wire tag_write;			//For when we miss and take info from mem
	wire data_write;		//For writing and reading from the cache
	wire [15:0] cache_in;		//The input to the cache
	wire write_data_array;		//Data write from fsm
	wire write_tag_array;		//Tag write
	wire [15:0] address;		//The address for the cache

	//The cache that this is controlling
	cache cache(
		.clk(clk),
		.rst_n(rst_n),
		.tag_write(tag_write),
		.data_write(data_write),
		.cache_enable(cache_enable),
		.address(address),
		.data_in(cache_in),
		.data_out(data_out),
		.cache_miss(cache_miss_internal)
	);

	//The fsm for if the cache has a miss
	cache_fill_fsm cache_fsm(
		.clk(clk),
		.rst_n(rst_n),
		.fsm_busy(fsm_busy),
		.miss_detected(cache_miss_internal),
		.miss_address(cache_address),
		.write_data_array(write_data_array),
		.write_tag_array(write_tag_array),
		.memory_address(memory_address),
		.memory_data_valid(memory_data_valid)
	);

	//The full cache_miss signal is asserted when the miss happens and while the fsm is fixing it
	assign cache_miss = cache_miss_internal | fsm_busy;

	//Deciding if the fsm or cpu is communicating to the cache
	assign data_write = fsm_busy ? write_data_array : write;
	assign tag_write = write_tag_array;
	assign cache_in = fsm_busy ? memory_data : data_in; 
	assign address = fsm_busy ? memory_address : cache_address;


endmodule

