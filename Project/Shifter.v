module Shifter(Shift_Out, Shift_In, Shift_Val, Mode);

input [15:0] Shift_In; //This is the number to perform shift operation on
input [3:0] Shift_Val; //Shift amount
input  [1:0] Mode; // To indicate SLL, SRA or ROR, 00 is SLL, 01 is SRA, 1X is ROR

output [15:0] Shift_Out; //Shifter value

wire [15:0] Shift_Stage_1, Shift_Stage_2, Shift_Stage_3;  //Holding wires between each mux

assign Shift_Stage_1 = (Shift_Val[0] == 0) ? Shift_In[15:0] : 			//No Shift
			    (Mode[1] == 1) ? {Shift_In[0],Shift_In[15:1]} :	//ROR
			    (Mode[0] == 1) ? {Shift_In[15],Shift_In[15:1]} :	//SRA
					     {Shift_In[14:0],1'h0};		//SLL

assign Shift_Stage_2 = (Shift_Val[1] == 0) ? Shift_Stage_1[15:0] : 				//No Shift
			    (Mode[1] == 1) ? {Shift_Stage_1[1:0],Shift_Stage_1[15:2]} :		//ROR
			    (Mode[0] == 1) ? {{2{Shift_Stage_1[15]}},Shift_Stage_1[15:2]} :	//SRA
					     {Shift_Stage_1[13:0],2'h0};			//SLL

assign Shift_Stage_3 = (Shift_Val[2] == 0) ? Shift_Stage_2[15:0] : 				//No Shift
			    (Mode[1] == 1) ? {Shift_Stage_2[3:0],Shift_Stage_2[15:4]} :		//ROR
			    (Mode[0] == 1) ? {{4{Shift_Stage_2[15]}},Shift_Stage_2[15:4]} :	//SRA
					     {Shift_Stage_2[11:0],4'h0};				//SLL

assign Shift_Out = (Shift_Val[3] == 0) ? Shift_Stage_3[15:0] : 					//No Shift
			(Mode[1] == 1) ? {Shift_Stage_3[7:0],Shift_Stage_3[15:8]} :		//ROR
			(Mode[0] == 1) ? {{8{Shift_Stage_3[15]}},Shift_Stage_3[15:8]} :		//SRA
					 {Shift_Stage_3[7:0],8'h0};				//SLL

endmodule
