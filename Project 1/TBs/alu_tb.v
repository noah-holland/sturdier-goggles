module alu_tb ();
reg  [36:0] stim;
reg  [3:0] opcode;
wire signed [15:0] A, B, Sum, exp_sum, exp_diff, red_sum, PSA_sum_sat;
wire [3:0] imm;
wire [2:0] flags;
wire signed [16:0] signed_sum, signed_diff;
wire signed [19:0] PSA_sum;

assign signed_sum = A + B;
assign signed_diff = A - B;

assign exp_sum = signed_sum < $signed(16'h8000) ? 16'h8000 :
                 signed_sum > $signed(16'h7FFF) ? 16'h7FFF :
                 signed_sum[15:0];
assign exp_diff = signed_diff < $signed(16'h8000) ? 16'h8000 :
                  signed_diff > $signed(16'h7FFF) ? 16'h7FFF :
                  signed_diff[15:0];

assign red_sum = A[15:12] + A[11:8] + A[7:4] + A[3:0] + B[15:12] + B[11:8] + B[7:4] + B[3:0];

assign PSA_sum[19:15] = $signed(A[15:12]) + $signed(B[15:12]);
assign PSA_sum[14:10] = $signed(A[11:8])  + $signed(B[11:8]);
assign PSA_sum[9:5] =   $signed(A[7:4])   + $signed(B[7:4]);
assign PSA_sum[4:0] =   $signed(A[3:0])   + $signed(B[3:0]);

assign PSA_sum_sat[3:0] = $signed(PSA_sum[4:0]) < $signed(4'b1000) ? 5'h8 :
                          $signed(PSA_sum[4:0]) > $signed(4'b0111) ? 5'h7 :
                          $signed(PSA_sum[3:0]);

assign PSA_sum_sat[7:4] = $signed(PSA_sum[9:5]) < $signed(4'b1000) ? 5'h8 :
                          $signed(PSA_sum[9:5]) > $signed(4'b0111) ? 5'h7 :
                          $signed(PSA_sum[8:5]);

assign PSA_sum_sat[11:8] = $signed(PSA_sum[14:10]) < $signed(4'b1000) ? 5'h8 :
                           $signed(PSA_sum[14:10]) > $signed(4'b0111) ? 5'h7 :
                           $signed(PSA_sum[13:10]);

assign PSA_sum_sat[15:12] = $signed(PSA_sum[19:15]) < $signed(4'b1000) ? 5'h8 :
                            $signed(PSA_sum[19:15]) > $signed(4'b0111) ? 5'h7 :
                            $signed(PSA_sum[18:15]);

assign {imm,A,B} = stim[35:0];

alu alu(A, B, imm, opcode, Sum, flags);

initial begin

  // Test Add
  opcode = 4'b0;
  $display("Testing Add...");
  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if(exp_sum !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, exp_sum);
        $stop;
      end
  end
  $display("Add Passed!");

  // Test Subtract
  opcode = 4'b1;
  $display("Testing Subtract...");

  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if(exp_diff !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, exp_diff);
        $stop;
      end
  end
  $display("Subtract Passed!");

  // Test RED
  opcode = 4'b10;
  $display("Testing RED...");

  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if( red_sum !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, red_sum);
        $stop;
      end
  end
  $display("RED Passed!");

  // Test XOR
  opcode = 4'b11;
  $display("Testing XOR...");

  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if( (A^B) !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, A^B);
        $stop;
      end
  end
  $display("XOR Passed!");

  // Test SLL
  opcode = 4'b100;
  $display("Testing SLL...");

  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if( (A<<imm) !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, A<<imm);
        $stop;
      end
  end
  $display("SLL Passed!");

  // Test SRA
  opcode = 4'b101;
  $display("Testing SRA...");

  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if( (A>>>imm) !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, A>>>imm);
        $stop;
      end
  end
  $display("SRA Passed!");

  // Test ROR
  opcode = 4'b110;
  $display("Skipping ROR...");

  // Test PADDSB
  opcode = 4'b111;
  $display("Testing PADDSB...");

  // for(stim = 36'h0; stim < 36'h3FFFFFFFFF; stim = stim + 1) begin
  repeat(10000) begin
    stim = $random;
    #5 if( PSA_sum_sat !== Sum) begin
        $display("The output is incorrect");
        $display("           A: %b\n           B: %b\n         Sum: %b\nExpected Sum: %b",A, B, Sum, PSA_sum_sat);
        $stop;
      end
  end
  $display("PADDSB Passed!");

end

// initial begin
//   $monitor("A: %d B: %d Sum: %d Expected Sum: %d", A, B, Sum, exp_val);
//   // #5000 $display("Stim: %b", stim);
// end

endmodule // alu_tb
