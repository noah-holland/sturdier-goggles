module PC_control (input [2:0] C, input [8:0] I, input [2:0] F, input [15:0] PC_in, output [15:0] PC_out);

wire jump, Zero, Ovflw, Sign;
wire [15:0] carrys;
wire [14:0] B_Operand;

// Not needed but makes code more readable
assign {Zero, Ovflw, Sign} = F;

assign jump = C[2:1] == 2'b00 ?   C[0] == Zero :
              C[2:1] == 2'b01 ? ~(C[0]|Zero|Sign) | (C[0]&Sign):
              C[2:1] == 2'b10 ?  (C[0] == Sign) | Zero:
                                  C[0] | Ovflw;

// If we want to jump, use the sign extended immidiate sll 1, otherwise 0
assign B_Operand = jump ? {{5{I[8]}},{I}} : 0;
assign carrys[0] = 1'b1; // We always want to increment by 2

// Create a 15 bit adder.
full_adder_1bit adder[14:0] (.Sum(PC_out[15:1]), .A(PC_in[15:1]), .B(B_Operand), .COut(carrys[15:1]), .CIn(carrys[14:0]));
assign PC_out[0] = PC_in[0]; // We're never going to be changing the LSB

endmodule // PC_control

module full_adder_1bit (output Sum, COut, input A, B, CIn);

assign int = A ^ B;
assign Sum = int ^ CIn;
assign COut = int & CIn | A & B;

endmodule
