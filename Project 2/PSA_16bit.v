module PSA_16bit (Sum, A, B, Opcode);

input [15:0] A, B; //Input values
input Opcode;

output [15:0] Sum; //Sum output either RED or PADDSB

wire [15:0] Sum_From_Adders, PADDSB_Sum, RED_Sum;
wire [7:0] Sum_From_RED;
wire error1, error2, error3, error4; //Needed for saturation
wire COut_1, COut_2, COut_3, COut_4, COut_5, COut_6, COut_7; //Needed for saturation

wire S_123, C_123, S_456, C_456, C_147; //Wires between 1 bit adders for RED

//Instantiate adders
four_bit_CLA adder1(.CIn(1'b0), .A(A[15:12]), .B(B[15:12]), .gen_out(), .prop_out(), .COut(COut_1), .Sum(Sum_From_Adders[15:12]), .Overflow(error1));

four_bit_CLA adder2(.CIn(1'b0), .A(A[11:8]), .B(B[11:8]), .gen_out(), .prop_out(), .COut(COut_2), .Sum(Sum_From_Adders[11:8]), .Overflow(error2));

four_bit_CLA adder3(.CIn(1'b0), .A(A[7:4]), .B(B[7:4]), .gen_out(), .prop_out(), .COut(COut_3), .Sum(Sum_From_Adders[7:4]), .Overflow(error3));

four_bit_CLA adder4(.CIn(1'b0), .A(A[3:0]), .B(B[3:0]), .gen_out(), .prop_out(), .COut(COut_4), .Sum(Sum_From_Adders[3:0]), .Overflow(error4));

//Saturation for PADDSB
assign PADDSB_Sum[15:12] = (error1 == 0) ? Sum_From_Adders[15:12] :
			   (COut_1 == 0) ? 4'b0111 :
					   4'b1000;

assign PADDSB_Sum[11:8] = (error2 == 0) ? Sum_From_Adders[11:8] :
			  (COut_2 == 0) ? 4'b0111 :
					  4'b1000;

assign PADDSB_Sum[7:4] = (error3 == 0) ? Sum_From_Adders[7:4] :
			 (COut_3 == 0) ? 4'b0111 :
					 4'b1000;

assign PADDSB_Sum[3:0] = (error4 == 0) ? Sum_From_Adders[3:0] :
			 (COut_4 == 0) ? 4'b0111 :
					 4'b1000;

//Extra adders for RED
four_bit_CLA adder5(.CIn(1'b0), .A(Sum_From_Adders[15:12]), .B(Sum_From_Adders[11:8]), .gen_out(), .prop_out(), .COut(COut_5), .Sum(Sum_From_RED[7:4]), .Overflow());

four_bit_CLA adder6(.CIn(1'b0), .A(Sum_From_Adders[7:4]), .B(Sum_From_Adders[3:0]), .gen_out(), .prop_out(), .COut(COut_6), .Sum(Sum_From_RED[3:0]), .Overflow());

four_bit_CLA adder7(.CIn(1'b0), .A(Sum_From_RED[7:4]), .B(Sum_From_RED[3:0]), .gen_out(), .prop_out(), .COut(COut_7), .Sum(RED_Sum[3:0]), .Overflow());

//Carry addition for RED
assign S_123 = COut_3 ^ (COut_2 ^ COut_1); 
assign C_123 = (COut_3 & (COut_2 ^ COut_1)) | (COut_2 & COut_1);

assign S_456 = COut_6 ^ (COut_5 ^ COut_4); 
assign C_456 = (COut_6 & (COut_5 ^ COut_4)) | (COut_5 & COut_4);

assign RED_Sum[4] = COut_7 ^ (S_456 ^ S_123); 
assign C_147 = (COut_7 & (S_456 ^ S_123)) | (S_456 & S_123);

assign RED_Sum[5] = C_147 ^ (C_456 ^ C_123); 
assign RED_Sum[6] = (C_147 & (C_456 ^ C_123)) | (C_456 & C_123);

assign RED_Sum[15:7] = 9'h000;

assign Sum = (Opcode == 0) ? RED_Sum : PADDSB_Sum;

endmodule
