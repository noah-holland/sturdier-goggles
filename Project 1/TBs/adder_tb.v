module adder_tb();

reg [8:0] stim;
wire [4:0] Sum;
wire Overflow;

// We can use output because at the time this is called we know the 4 bit sum/difference was correct
assign AddOverflow = Sum[3] & ~stim[7] & ~stim[3] | ~Sum[3] & stim[7] & stim[3];
assign SubOverflow = Sum[3] & stim[7] & ~stim[3] | ~Sum[3] & ~stim[7] & stim[3];

four_bit_CLA DUT (.A(stim[3:0]), .B(stim[7:4]), .Sum(Sum[3:0]), .Overflow(Overflow), .CIn(stim[8]), .COut(Sum[4]));

initial begin
	stim = 9'b0;
	repeat(100) begin
	#20 if( (Sum != (stim[3:0] + stim[7:4] + stim[8]))) begin
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
	$finish;
end

initial $monitor("Stim:%b Sum:%b Overflow:%b",stim, Sum, Overflow );

endmodule

module word_adder_tb();

reg [32:0] stim;
wire [16:0] Sum;
wire Overflow;

// We can use output because at the time this is called we know the 4 bit sum/difference was correct
assign AddOverflow = Sum[15] & ~stim[31] & ~stim[15] | ~Sum[15] & stim[31] & stim[15];
assign SubOverflow = Sum[15] & stim[31] & ~stim[15] | ~Sum[15] & ~stim[31] & stim[15];

word_CLA DUT (.A(stim[15:0]), .B(stim[31:16]), .Sum(Sum[15:0]), .Overflow(Overflow), .CIn(stim[32]), .COut(Sum[16]));

initial begin
	stim = 32'b0;
	repeat(100) begin
	#20 if( (Sum != (stim[15:0] + stim[31:16] + stim[32]))) begin
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
	$finish;
end

initial $monitor("Stim:%b Sum:%b Overflow:%b",stim, Sum, Overflow );

endmodule
