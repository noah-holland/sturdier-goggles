module four_bit_CLA_block (input CIn, [3:0] prop, gen, output [3:0] carry);

assign carry[0] = gen[0] | prop[0]&CIn;
assign carry[1] = gen[1] | prop[1]&carry[0];
assign carry[2] = gen[2] | prop[2]&carry[1];
assign carry[3] = gen[3] | prop[3]&carry[2];

endmodule // 4_bit_CLA_block

module four_bit_CLA (input CIn, [3:0] A, B, output Overflow, COut, [3:0] Sum);

wire [4:0] carrys;
wire [3:0] prop, gen;

four_bit_CLA_block CLA_block (.CIn(CIn), .prop(prop), .gen(gen), .carry(carrys[4:1]));

assign gen = A & B;
assign prop = A ^ B;
 
assign Overflow = ^carrys[4:3];
assign COut = carrys[4];
assign carrys[0] = CIn;

assign Sum = A ^ B ^ carrys[3:0];

endmodule //4_bit_CLA

module word_CLA (input CIn, [15:0] A, B, output Overflow, COut, [15:0] Sum);

wire [4:0] carrys;
wire [3:0] overflows;

assign carrys[0] = CIn;
assign COut = carrys[4];
assign Overflow = overflows[3];

four_bit_CLA four_bit_adders[3:0] (.A(A), .B(B), .CIn(carrys[3:0]),
                                   .Sum(Sum), .COut(carrys[4:1]), .Overflow(overflows));

endmodule // word_CLA
