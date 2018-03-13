module RegisterFile(input clk, rst, [3:0] SrcReg1, [3:0] SrcReg2, [3:0] DstReg,
                    input WriteReg, [15:0] DstData, inout [15:0] SrcData1, [15:0] SrcData2 );

wire [15:0] ReadWl1, ReadWl2, WriteWl, Output1, Output2;

ReadDecoder_4_16 readecoder1 (.RegId(SrcReg1), .Wordline(ReadWl1));
ReadDecoder_4_16 readecoder2 (.RegId(SrcReg2), .Wordline(ReadWl2));
WriteDecoder_4_16 writedecoder (.RegId(DstReg), .WriteReg(WriteReg), .Wordline(WriteWl));

Register register[15:0] (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteWl),
                         .ReadEnable1(ReadWl1), .ReadEnable2(ReadWl2),
                         .BitLine1(Output1), .BitLine2(Output2));


assign SrcData1 = SrcReg1 == DstReg ? DstData : Output1;
assign SrcData2 = SrcReg2 == DstReg ? DstData : Output2;

endmodule
