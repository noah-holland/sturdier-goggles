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
	input wire [15:0] memory_address,
	input wire [15:0] memory_data,
	input wire memory_data_write,
	input wire memory_tag_write,
	input wire miss_fixing,
	output wire [15:0] data_out,
	output wire cache_miss,
	output wire [15:0] memory_address
);


	wire data_write;		//For writing and reading from the cache
	wire tag_write;			//For writing and reading the tags
	wire [15:0] cache_in;		//The input to the cache
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
		.cache_miss(cache_miss)
	);

	//Deciding if the fsm or cpu is communicating to the cache
	assign data_write = miss_fixing ? memory_data_write : write;
	assign tag_write = miss_fixing ? memory_tag_write : 1'b0;
	assign cache_in = miss_fixing ? memory_data : data_in; 
	assign address = miss_fixing ? memory_address : cache_address;


endmodule

