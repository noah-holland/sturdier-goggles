module four_bit_CLA_block (input CIn, [3:0] prop, gen, output prop_out, gen_out, [3:0] carry);

// Each carry is determined by either generating a carry or propagating the last carry.
assign carry[0] = gen[0] | prop[0]&CIn;
assign carry[1] = gen[1] | prop[1]&carry[0];
assign carry[2] = gen[2] | prop[2]&carry[1];
assign carry[3] = gen[3] | prop[3]&carry[2];

// The block itself propagates if all propagates are true
// Since prop is defined as A ^ B and gen is A & B
// we shouldn't have gen and prop set at the same time
assign prop_out = &prop & ~(|gen);

// The block generates a carry if there is a carry out.
assign gen_out  = carry[3];

endmodule // 4_bit_CLA_block

module four_bit_CLA (input CIn, [3:0] A, B, output prop_out, gen_out, Overflow, COut, [3:0] Sum);

wire [4:0] carrys;
wire [3:0] prop, gen;

// We need a single CLA block
four_bit_CLA_block CLA_block (.CIn(CIn), .prop(prop), .gen(gen),
                              .carry(carrys[4:1]), .prop_out(prop_out), .gen_out(gen_out));

// Each bit generates if they are both 1
assign gen = A & B;

// Each bit propagates if they can be XOR'd
assign prop = A ^ B;

assign Overflow = ^carrys[4:3]; // Overflow is just the xor of the last two carrys
assign COut = carrys[4]; // Cout is just the last carry
assign carrys[0] = CIn; // The first carry is set to CIn

assign Sum = A ^ B ^ carrys[3:0]; // The at each bit is just a three way XOR of A, B and the incoming carry

endmodule //4_bit_CLA

module word_CLA (input CIn, [15:0] A, B, output Overflow, COut, [15:0] Sum);

wire [4:0] carrys;
wire [3:0] overflows, gen, prop;

// Similar as above carry[0] is set to CIn, and COut is the last carry
assign carrys[0] = CIn;
assign COut = carrys[4];

// We only care if the last adder overflowed
assign Overflow = overflows[3];

// Set up a new CLA block where the propagations and generates are from each 4 bit adder
four_bit_CLA_block CLA_block (.CIn(CIn), .prop(prop), .gen(gen),
                              .carry(carrys[4:1]), .prop_out(), .gen_out());

// Instantiate 4 4-bit adders.
four_bit_CLA four_bit_adders[3:0] (.A(A), .B(B), .CIn(carrys[3:0]),
                                   .Sum(Sum), .COut(), .Overflow(overflows),
                                   .gen_out(gen), .prop_out(prop));

endmodule // word_CLA
