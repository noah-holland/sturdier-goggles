module WriteDecoder_4_16 (input [3:0] RegId, input WriteReg, output [15:0] Wordline);

assign Wordline = !WriteReg ? 0 :
                  RegId == 0 ? 1 :
                  RegId == 1 ? 2 :
                  RegId == 2 ? 4 :
                  RegId == 3 ? 8 :
                  RegId == 4 ? 16 :
                  RegId == 5 ? 32 :
                  RegId == 6 ? 64 :
                  RegId == 7 ? 128 :
                  RegId == 8 ? 256 :
                  RegId == 9 ? 512 :
                  RegId == 10 ? 1024 :
                  RegId == 11 ? 2048 :
                  RegId == 12 ? 4096 :
                  RegId == 13 ? 8192 :
                  RegId == 14 ? 16384 :
                  32768 ;

endmodule // WriteDecoder
