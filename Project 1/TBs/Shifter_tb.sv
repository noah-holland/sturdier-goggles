module Shifter_tb();

logic [1:0] Mode;

wire [15:0] Shift_Out;

integer Shift_In, Shift_Val;

logic [15:0] SLL, SRA, ROR;

assign SLL = Shift_In[15:0] << Shift_Val[3:0];
assign SRA = $signed(Shift_In[15:0]) >>> Shift_Val[3:0];

//instantiate dut
Shifter iDUT(.Shift_In(Shift_In[15:0]), .Shift_Val(Shift_Val[3:0]), .Mode(Mode), .Shift_Out(Shift_Out));

initial begin

	//SLL
	Mode = 2'b00;
	for(Shift_In = 0; Shift_In <= 16'hFFFF; Shift_In = Shift_In + 1) begin
		for(Shift_Val = 0; Shift_Val <= 4'hF; Shift_Val = Shift_Val + 1) begin
			#20;
			if(Shift_Out != SLL) begin
				$display("SLL had a problem.");
				$stop;
			end
		end
	end

	//SRA
	Mode = 2'b01;
	for(Shift_In = 0; Shift_In <= 16'hFFFF; Shift_In = Shift_In + 1) begin
		for(Shift_Val = 0; Shift_Val <= 4'hF; Shift_Val = Shift_Val + 1) begin
			#20;
			if(Shift_Out != SRA) begin
				$display("SRA had a problem.");
				$stop;
			end
		end
	end

	//ROR Must Inspect Visually
	Mode = 2'b10;
	Shift_In[15:0] = 16'b0001100000100100;
	for(Shift_Val = 0; Shift_Val <= 4'hF; Shift_Val = Shift_Val + 1) begin
		#20;
	end

	$display("The test passed.");

end

endmodule
