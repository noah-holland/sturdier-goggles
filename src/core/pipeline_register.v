module pipeline_register (input stall, flush, clk, nop, [3:0] opcode_in, [63:0] inputs, output [3:0] opcode_out, [63:0] outputs);

wire [67:0] internal_outputs;

dff FFs[67:0] (.clk(clk), .d({opcode_in, inputs}), .q(internal_outputs), .wen(~stall), .rst(flush));

// If we are stalling we want to output all 0's
assign {opcode_out, outputs} = stall & nop ? 67'h0 : internal_outputs;

endmodule // pipeline_register
