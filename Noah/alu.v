module alu (ALU_Out, Error, ALU_In1, ALU_In2, Opcode);

input [3:0] ALU_In1, ALU_In2;
input [1:0] Opcode;
output [3:0] ALU_Out;
output Error; // Just to show overflow

wire[3:0] Adder_Out;
wire Adder_Ovfl;

addsub_4bit adder (.A(ALU_In1), .B(ALU_In2), .Sum(Adder_Out), .sub(Opcode[0]), .Ovfl(Adder_Ovfl));

assign Error = !Opcode[1] ? Adder_Ovfl : 1'b0;

assign ALU_Out = !Opcode[1] ? Adder_Out :
								 !Opcode[0] ? ~(ALU_In1 & ALU_In2) :
								 ALU_In1 ^ ALU_In2;

endmodule

module alu_tb();

integer i;
reg [7:0] stim;
reg [1:0] Opcode;
wire [3:0] Output;
wire Overflow;

// We can use output because at the time this is called we know the 4 bit sum/difference was correct
assign AddOverflow = Output[3] & ~stim[7] & ~stim[3] | ~Output[3] & stim[7] & stim[3];
assign SubOverflow = Output[3] & stim[7] & ~stim[3] | ~Output[3] & ~stim[7] & stim[3];

alu DUT (.ALU_In1(stim[3:0]), .ALU_In2(stim[7:4]), .ALU_Out(Output), .Error(Overflow), .Opcode(Opcode));

initial begin
	Opcode = 2'b0;
	stim = 8'b0;
	for(i = 0; i < 256; i = i + 1) begin
		#20 if( (Output != (stim[3:0] + stim[7:4]))) begin
				$display("The output is incorrect");
				$stop;
			end else if( AddOverflow && ~Overflow) begin
				$display("Expected an overflow, none occurred");
				$stop;
			end else if( ~AddOverflow && Overflow) begin
				$display("An unexpected overflow occurred");
				$stop;
			end
		stim = stim + 1'b1;
	end
	#10;

	Opcode = 2'b1;
	stim = 8'b0;
	for(i = 0; i < 256; i = i + 1) begin
		#20 if( (Output != (stim[3:0] - stim[7:4]))) begin
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
	#10;

	Opcode = 2'b10;
	stim = 8'b0;
	for(i = 0; i < 256; i = i + 1) begin
		#20 if(Output != ~(stim[3:0] & stim[7:4])) begin
			$display("The output is incorrect");
			$stop;
		end else if(Overflow) begin
			$display("There should never be overflow with NAND");
			$stop;
		end
		stim = stim + 1'b1;
	end

	Opcode = 2'b11;
	stim = 8'b0;
	for(i = 0; i < 256; i = i + 1) begin
		#20 if(Output != (stim[3:0] ^ stim[7:4])) begin
			$display("The output is incorrect");
			$stop;
		end else if(Overflow) begin
			$display("There should never be overflow with XOR");
			$stop;
		end
		stim = stim + 1'b1;
	end

	$finish;
end

initial $monitor("Stim:%b Output:%b CO:%b",stim, Output, Overflow );

endmodule
