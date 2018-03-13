module PSA_16bit (Sum, Error, A, B);
input [15:0] A, B; //Input values
output [15:0] Sum; //sum output
output Error; //To indicate overflows

wire[3:0] Overflows;

assign Error = |Overflows;

addsub_4bit HalfWord1 (.Sum(Sum[3:0]),   .Ovfl(Overflows[0]), .A(A[3:0]),   .B(B[3:0]),   .sub(1'b0));
addsub_4bit HalfWord2 (.Sum(Sum[7:4]),   .Ovfl(Overflows[1]), .A(A[7:4]),   .B(B[7:4]),   .sub(1'b0));
addsub_4bit HalfWord3 (.Sum(Sum[11:8]),  .Ovfl(Overflows[2]), .A(A[11:8]),  .B(B[11:8]),  .sub(1'b0));
addsub_4bit HalfWord4 (.Sum(Sum[15:12]), .Ovfl(Overflows[3]), .A(A[15:12]), .B(B[15:12]), .sub(1'b0));

endmodule

module PSA_tb();

reg  errors;
reg  [15:0] A, B;
wire [15:0] Sum;
wire Error;

reg word = 0;

assign AddOverflow = Sum[word*4+3] & ~A[word*4+3] & ~B[word*4+3] | ~Sum[word*4+3] & A[word*4+3] & B[word*4+3];

PSA_16bit DUT (.A(A), .B(B), .Sum(Sum), .Error(Error));

initial begin
	{A,B} = 32'b0;
	repeat(1000) begin
	#20 if( (Sum[3:0] != (A[3:0] + B[3:0]))) begin
			$display("The first byte is incorrect");
			errors = 1'b1;
		end if( (Sum[7:4] != (A[7:4] + B[7:4]))) begin
  			$display("The second byte is incorrect");
  			errors = 1'b1;
  	end if( (Sum[11:8] != (A[11:8] + B[11:8]))) begin
  			$display("The third byte is incorrect");
  			errors = 1'b1;
  	end if( (Sum[15:12] != (A[15:12] + B[15:12]))) begin
  			$display("The fourth byte is incorrect");
  			errors = 1'b1;
  	end if(!Error && AddOverflow) begin
        $display("The first byte overflowed, but didn't cause an error");
  			errors = 1'b1;
    end word = 1; if(!Error && AddOverflow) begin
        $display("The second byte overflowed, but didn't cause an error");
  			errors = 1'b1;
    end word = 2; if(!Error && AddOverflow) begin
        $display("The third byte overflowed, but didn't cause an error");
  			errors = 1'b1;
    end word = 3; if(!Error && AddOverflow) begin
        $display("The fourth byte overflowed, but didn't cause an error");
  			errors = 1'b1;
    end if(errors)
      $stop;
	{A,B} = $random;
	end
	$finish;
end

initial $monitor("A:%h B:%h Sum:%h Error:%b",A, B, Sum, Error );

endmodule
