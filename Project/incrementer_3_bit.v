////////////////////////////////////////////////////////////////////////////////
// 
// Module: incrementer_3_bit
// Author: Ryan Job (rjob@wisc.edu)
//
// Class: ECE 552
// Assignment: HW9
//
// Takes in a 3-bit value and increments it (adds one)
//
////////////////////////////////////////////////////////////////////////////////

module incrementer_3_bit (
	input   wire    [2:0]   input_value,
	output  wire    [2:0]   output_value
);


// Declare a line I'll need later
wire and_gate_1;


// Here's a thing I found on how to make a 4-bit binary incrementer.
// I optimized it a bit and made it only 3 bits, but if you're reading this, you
// should be able to understand what's going on
// http://letslearncomputing.blogspot.com/2013/03/digital-logic-4-bit-binary-incrementer.html
assign output_value[0] = ~input_value[0];

assign output_value[1] = input_value[0] ^ input_value[1];

assign and_gate_1 = input_value[0] & input_value[1];
assign output_value[2] = and_gate_1 ^ input_value[2];

endmodule

