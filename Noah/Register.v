module Register (input clk, rst, [15:0] D, input WriteReg, ReadEnable1, ReadEnable2,
                 inout [15:0] BitLine1, [15:0] BitLine2);

BitCell BC[15:0] (.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg),
                  .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2),
                  .BitLine1(BitLine1), .BitLine2(BitLine2));

endmodule // Register
