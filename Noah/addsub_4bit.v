module full_adder_1bit (output Sum, COut, input A, B, CIn);

assign int = A ^ B; //Using an intermidate values reduces size
assign Sum = int ^ CIn;
assign COut = int & CIn | A & B;

endmodule

module addsub_4bit (Sum, Ovfl, A, B, sub);
input [3:0] A, B; //Input values
input sub; // add-sub indicator
output [3:0] Sum; //sum output
output Ovfl; //To indicate overflow

wire C0,C1,C2,C3;

full_adder_1bit FA0 (.Sum(Sum[0]), .COut(C0), .A(A[0]), .B(B[0] ^ sub), .CIn(sub));
full_adder_1bit FA1 (.Sum(Sum[1]), .COut(C1), .A(A[1]), .B(B[1] ^ sub), .CIn(C0));
full_adder_1bit FA2 (.Sum(Sum[2]), .COut(C2), .A(A[2]), .B(B[2] ^ sub), .CIn(C1));
full_adder_1bit FA3 (.Sum(Sum[3]), .COut(C3), .A(A[3]), .B(B[3] ^ sub), .CIn(C2));

assign Ovfl = C3 ^ C2;

endmodule

module adder_tb();

reg [7:0] stim;
wire [3:0] Sum;
wire Overflow;

reg sub;

// We can use output because at the time this is called we know the 4 bit sum/difference was correct
assign AddOverflow = Sum[3] & ~stim[7] & ~stim[3] | ~Sum[3] & stim[7] & stim[3];
assign SubOverflow = Sum[3] & stim[7] & ~stim[3] | ~Sum[3] & ~stim[7] & stim[3];

addsub_4bit DUT (.A(stim[3:0]), .B(stim[7:4]), .Sum(Sum), .sub(sub), .Ovfl(Overflow));

initial begin
	sub = 1'b0;
	stim = 8'b0;
	repeat(100) begin
	#20 if( (Sum != (stim[3:0] + stim[7:4]))) begin
			$display("The output is incorrect");
			$stop;
		end else if( AddOverflow && ~Overflow) begin
			$display("Expected an overflow, none occurred");
			$stop;
		end else if( ~AddOverflow && Overflow) begin
			$display("An unexpected overflow occurred");
			$stop;
		end
	stim = $random;
	end

	sub = 1'b1;
	repeat(100) begin
		#20 if( (Sum != (stim[3:0] - stim[7:4]))) begin
				$display("The output is incorrect");
				$stop;
			end else if( SubOverflow && ~Overflow) begin
				$display("Expected an overflow, none occurred");
				$stop;
			end else if( ~SubOverflow && Overflow) begin
				$display("An unexpected overflow occurred");
				$stop;
			end
		stim = $random;
	end
	$finish;
end

initial $monitor("Stim:%b Sum:%b Overflow:%b",stim, Sum, Overflow );

endmodule
