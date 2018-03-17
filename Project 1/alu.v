module alu (input  [15:0] src_data_1, src_data_2, [3:0] immediate, opcode,
            output [15:0] alu_result, [2:0] flags);

localparam OPCODE_RED    = 4'h2;
localparam OPCODE_XOR    = 4'h3;
localparam OPCODE_SLL    = 4'h4;
localparam OPCODE_SRA    = 4'h5;
localparam OPCODE_ROR    = 4'h6;
localparam OPCODE_PADDSB = 4'h7;

wire [15:0] b, adder_sum, padder_sum, shift_out, xor_out, saturated_adder;
wire Overflow, adder_cin, COut, Error;

// Set the negative flat to the MSB (sign) bit of the result
assign flags[2] = alu_result[15];

// Set the zero flag to reduction and of the bitwise not of the result
assign flags[1] = &(~alu_result);

// Set the Overflow flag to the overflow output of the adder
assign flags[0] = Overflow;

// The B operand needs to be notted for subtraction
// and sign extended and shifted one for memory ops
assign b = opcode[3] ? { {11{immediate[3]}}, immediate, 1'b0} :
           opcode[0] ? ~src_data_2 :
                       src_data_2;

assign adder_cin = opcode[0] & ~opcode[3] ? 1'b1 : 1'b0;

word_CLA adder (
  .CIn         (adder_cin),
  .A           (src_data_1),
  .B           (b),
  .COut        (COut),
  .Overflow    (Overflow),
  .Sum         (adder_sum)
);

PSA_16bit parallel_adder (
  .Sum         (padder_sum),
  .A           (src_data_1),
  .B           (src_data_2),
  .Opcode      (opcode[0])
);

Shifter shifter (
  .Shift_Out   (shift_out),
  .Shift_In    (src_data_1),
  .Shift_Val   (immediate),
  .Mode        (opcode[1:0])
);

assign xor_out = src_data_1 ^ src_data_2;

assign saturated_adder = Overflow & COut ? 16'h8000 :
                         Overflow        ? 16'h7FFF :
                         adder_sum;

assign alu_result = OPCODE_RED    ? padder_sum :
                    OPCODE_PADDSB ? padder_sum :
                    OPCODE_XOR    ? xor_out    :
                    OPCODE_SLL    ? shift_out  :
                    OPCODE_SRA    ? shift_out  :
                    OPCODE_ROR    ? shift_out  :
                    saturated_adder;

endmodule // alu
