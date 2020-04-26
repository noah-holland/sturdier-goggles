////////////////////////////////////////////////////////////////////////////////
// 
// Module: incrementer_4_bit
// Author: Ryan Job (rjob@wisc.edu)
//
// Class: ECE 552
// Assignment: HW9
//
// Takes in a 4-bit value and increments it (adds one)
//
////////////////////////////////////////////////////////////////////////////////

module incrementer_4_bit (
	input   wire    [3:0]   input_value,
	output  wire    [3:0]   output_value
);


// Declare some lines I'll need later
wire and_gate_1;
wire and_gate_2;


// Here's a thing I found on how to make a 4-bit binary incrementer.
// I optimized it a bit, but if you're reading this, you should be able to
// understand what's going on
// http://letslearncomputing.blogspot.com/2013/03/digital-logic-4-bit-binary-incrementer.html
assign output_value[0] = ~input_value[0];

assign output_value[1] = input_value[0] ^ input_value[1];

assign and_gate_1 = input_value[0] & input_value[1];
assign output_value[2] = and_gate_1 ^ input_value[2];

assign and_gate_2 = and_gate_1 & input_value[2];
assign output_value[3] = and_gate_2 ^ input_value[3];

endmodule

