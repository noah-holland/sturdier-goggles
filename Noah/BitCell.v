module BitCell (input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2,
                inout BitLine1, BitLine2);
wire q;

dff FF (.clk(clk), .q(q), .d(D), .wen(WriteEnable), .rst(rst));

assign BitLine1 = ReadEnable1 ? q : 1'bz;
assign BitLine2 = ReadEnable2 ? q : 1'bz;

endmodule // BitCell
