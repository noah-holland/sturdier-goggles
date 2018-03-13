module RegisterFileTb();

reg clk, rst, WriteReg;
reg [3:0] SrcReg1, SrcReg2, DstReg;
reg [15:0] DstData;
wire [15:0] SrcData1, SrcData2;

RegisterFile regfile (clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);

initial begin
clk = 0;
rst = 1;
SrcReg1 = 0;
SrcReg2 = 0;
DstReg = 0;
WriteReg = 0;
DstData = 0;
#50 rst = 0;

#20
DstReg = 2;
DstData = 6;
#40;
WriteReg = 1;
repeat(2) @(posedge clk);
WriteReg = 0;
repeat(2) @(posedge clk);
SrcReg1 = 2;
repeat(2) @(posedge clk);
SrcReg2 = 8;
WriteReg = 1;
DstData = 10;
DstReg = 8;

end

always #10 clk = ~clk;


endmodule
