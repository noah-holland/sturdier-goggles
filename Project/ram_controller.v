////////////////////////////////////////////////////////////////////////////////
// 
// Module: ram_controller
// Author: Ryan Job (rjob@wisc.edu)
//
// Class: ECE 552
// Assignment: Project 3
//
// How this works:
//
////////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
 // Declaration of the module and internal signals
////////////////////////////////////////////////////////////////////////////////

module ram_controller (
	input   wire            clk,
	input   wire            rst_n,

	// Enable signals for RAM
	input   wire            ram_enable,
	input   wire            ram_write,

	// The primary in/out signals for RAM
	output  wire    [15:0]  ram_data_out,
	input   wire    [15:0]  ram_data_in,
	input   wire    [15:0]  ram_address,

	// The signals used for cache updates to the instruction cache
	input   wire            i_cache_miss,
	input   wire    [15:0]  i_cache_miss_address,
	output  wire            i_cache_data_valid,

	// The signals used for cache updates to the data cache
	input   wire            d_cache_miss,
	input   wire    [15:0]  d_cache_miss_address,
	output  wire            d_cache_data_valid
);


endmodule

