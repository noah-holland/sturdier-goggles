module register_file(input clk, rst, [3:0] SrcReg1, [3:0] SrcReg2, [3:0] DstReg,
                    input WriteReg, [15:0] DstData, inout [15:0] SrcData1, [15:0] SrcData2 );

wire [15:0] ReadWl1, ReadWl2, WriteWl, Output1, Output2;

ReadDecoder_4_16 readecoder1 (.RegId(SrcReg1), .Wordline(ReadWl1));
ReadDecoder_4_16 readecoder2 (.RegId(SrcReg2), .Wordline(ReadWl2));
WriteDecoder_4_16 writedecoder (.RegId(DstReg), .WriteReg(WriteReg), .Wordline(WriteWl));

Register register[15:0] (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteWl),
                         .ReadEnable1(ReadWl1), .ReadEnable2(ReadWl2),
                         .BitLine1(Output1), .BitLine2(Output2));

// Disable register forwarding
// assign SrcData1 = SrcReg1 == DstReg ? DstData : Output1;
// assign SrcData2 = SrcReg2 == DstReg ? DstData : Output2;

assign SrcData1 = Output1;
assign SrcData2 = Output2;

endmodule

module Register (input clk, rst, [15:0] D, input WriteReg, ReadEnable1, ReadEnable2,
                 inout [15:0] BitLine1, [15:0] BitLine2);

BitCell BC[15:0] (.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg),
                  .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
                  .BitLine1(BitLine1), .BitLine2(BitLine2));

endmodule // Register

module BitCell (input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2,
                inout BitLine1, BitLine2);
wire q;

dff FF (.clk(clk), .q(q), .d(D), .wen(WriteEnable), .rst(rst));

assign BitLine1 = ReadEnable1 ? q : 1'bz;
assign BitLine2 = ReadEnable2 ? q : 1'bz;

endmodule // BitCell
