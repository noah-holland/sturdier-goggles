////////////////////////////////////////////////////////////////////////////////
// 
// Module: AddTwo
//
// Class: ECE 552
// Assignment: Project 1
//
// This module takes in an input, adds two (2) to it, then outputs the result.
// It's basically a big wrapper for a modified/pre-calculated full adder.
//
////////////////////////////////////////////////////////////////////////////////


module AddTwo (
	input   wire    [15:0]  in,
	output  wire    [15:0]  out
);


// The carry signals. The carry-out for bits 0, 1, and 15 are either known or
// don't matter, so they're not included
wire    [14:2]  cout;


// By taking a full-adder and simplifying it based on the known values of
// adding 2, I've determined the following:
//      out[0] = in[0]
//      out[1] = ~in[1]
//      out[2] = in[2] ^ in[1]          cout[2] = in[2] & in[1]
//      out[i] = in[i] ^ cout[i-1]      cout[i] = in[i] & cout[i-1]
assign out[0] = in[0];

assign out[1] = ~in[1];

assign  out[2] = in[2] ^ in[1];
assign cout[2] = in[2] & in[1];

assign  out[15:3] = in[15:3] ^ cout[14:2];
assign cout[14:3] = in[14:3] & cout[13:2];


endmodule

