module PSA_16bit_tb();

logic [15:0] A, B;
logic Opcode;

wire [15:0] Sum;

//instatiate dut
PSA_16bit iDUT(.A(A), .B(B), .Sum(Sum), .Opcode(Opcode));

initial begin

	Opcode = 1;
	A = 16'h8888; //maximum negative ovfl
	B = 16'h8888;
	#20;

	A = 16'h7777; //maximum positive ovfl
	B = 16'h7777;
	#20;

	A = 16'h4444; //minimum positive ovfl
	B = 16'h4444;
	#20;

	A = 16'hBBBB; //minimum negative ovfl
	B = 16'hCCCC;
	#20;

	A = 16'hDDDD; //2 small negative numbers
	B = 16'hDDDD;
	#20;

	A = 16'h3333; //2 small positive numbers
	B = 16'h3333;
	#20;

	A = 16'h7777; //one of each
	B = 16'h8888;
	#20;

	Opcode = 0;
	A = 16'h1111;
	B = 16'h1111;
	#20;

	A = 16'hFFFF;
	B = 16'hFFFF;
	#20;

	A = 16'h137F;
	B = 16'h0000;
	#20;

	A = 16'h0000;
	B = 16'h0000;
	#20;

	A = 16'hAAAA;
	B = 16'h1111;
	#20;

	A = 16'h8686;
	B = 16'h2424;
	#20;

	$display("Test Finished.");

end

endmodule
