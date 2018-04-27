module cache(
	input  wire clk,
	input  wire rst_n,
	input  wire tag_write,
	input  wire data_write,
	input  wire cache_enable,
	input  wire [15:0] address,
	input  wire [15:0] data_in,
	output wire [15:0] data_out,
	output wire cache_miss
);

	wire [127:0] block_num;		//The block select we are using
	wire [7:0] word_num,		//The word select we are using
		   full_tag;		//The tag we are using
	wire [15:0] data_out_internal;

	//The data part of the cache
	DataArray data_array(
		.clk(clk),
		.rst(~rst_n),
		.DataIn(data_in),
		.Write(data_write),
		.BlockEnable(block_num),
		.WordEnable(word_num),
		.DataOut(data_out_internal)
	);

	//The tag part of the cache
	MetaDataArray meta_data_array(
		.clk(clk),
		.rst(~rst_n),
		.DataIn(full_tag),
		.Write(tag_write),
		.BlockEnable(block_num),
		.DataOut(tag_check)
	);

	assign data_out = ~cache_enable ? 16'h0 : 
				data_write ? 16'h0 : data_out_internal;

	//Deciding if the cache has missed
	assign cache_miss = tag_write ? 1'b0 :
	       (full_tag != tag_check) ? cache_enable :
					1'b0;

	//Read address assigns
	//Set the tag for reading in MetaData
	assign tag = address[15:11];

	//Set the full tag for reading
	assign full_tag = {3'b100,tag};

	//Set the word select for reading (one-hot)
	assign word_num = address[3:1] == 0 ? 1 :
		      	       address[3:1] == 1 ? 1 << 1 :
		     	         address[3:1] == 2 ? 1 << 2 :
		      	       address[3:1] == 3 ? 1 << 3 :
		      	       address[3:1] == 4 ? 1 << 4 :
		     	         address[3:1] == 5 ? 1 << 5 :
		      	       address[3:1] == 6 ? 1 << 6 :
		                               	        1 << 7 ;

	//Set the block select for reading (one-hot)
	assign block_num = address[10:4] == 0 ? 1 :
			        address[10:4] == 1 ? 1 << 1 :
   			        address[10:4] == 2 ? 1 << 2 :
    			        address[10:4] == 3 ? 1 << 3 :
    			        address[10:4] == 4 ? 1 << 4 :
    			        address[10:4] == 5 ? 1 << 5 :
    			        address[10:4] == 6 ? 1 << 6 :
    			        address[10:4] == 7 ? 1 << 7 :
    			        address[10:4] == 8 ? 1 << 8 :
    			        address[10:4] == 9 ? 1 << 9 :
    			        address[10:4] == 10 ? 1 << 10 :
    			        address[10:4] == 11 ? 1 << 11 :
    			        address[10:4] == 12 ? 1 << 12 :
    			        address[10:4] == 13 ? 1 << 13 :
    			        address[10:4] == 14 ? 1 << 14 :
    			        address[10:4] == 15 ? 1 << 15 :
    			        address[10:4] == 16 ? 1 << 16 :
    		  	      address[10:4] == 17 ? 1 << 17 :
    			        address[10:4] == 18 ? 1 << 18 :
    			        address[10:4] == 19 ? 1 << 19 :
    			        address[10:4] == 20 ? 1 << 20 :
    			        address[10:4] == 21 ? 1 << 21 :
    			        address[10:4] == 22 ? 1 << 22 :
    			        address[10:4] == 23 ? 1 << 23 :
    			        address[10:4] == 24 ? 1 << 24 :
    			        address[10:4] == 25 ? 1 << 25 :
    			        address[10:4] == 26 ? 1 << 26 :
    			        address[10:4] == 27 ? 1 << 27 :
    			        address[10:4] == 28 ? 1 << 28 :
    			        address[10:4] == 29 ? 1 << 29 :
    			        address[10:4] == 30 ? 1 << 30 :
    			        address[10:4] == 31 ? 1 << 31 :
    			        address[10:4] == 32 ? 1 << 32 :
    			        address[10:4] == 33 ? 1 << 33 :
    			        address[10:4] == 34 ? 1 << 34 :
    			        address[10:4] == 35 ? 1 << 35 :
    			        address[10:4] == 36 ? 1 << 36 :
    			        address[10:4] == 37 ? 1 << 37 :
    			        address[10:4] == 38 ? 1 << 38 :
    			        address[10:4] == 39 ? 1 << 39 :
    			        address[10:4] == 40 ? 1 << 40 :
    			        address[10:4] == 41 ? 1 << 41 :
    			        address[10:4] == 42 ? 1 << 42 :
    			        address[10:4] == 43 ? 1 << 43 :
    			        address[10:4] == 44 ? 1 << 44 :
    			        address[10:4] == 45 ? 1 << 45 :
    			        address[10:4] == 46 ? 1 << 46 :
    			        address[10:4] == 47 ? 1 << 47 :
    			        address[10:4] == 48 ? 1 << 48 :
    			        address[10:4] == 49 ? 1 << 49 :
    			        address[10:4] == 50 ? 1 << 50 :
    			        address[10:4] == 51 ? 1 << 51 :
    			        address[10:4] == 52 ? 1 << 52 :
    			        address[10:4] == 53 ? 1 << 53 :
    			        address[10:4] == 54 ? 1 << 54 :
    			        address[10:4] == 55 ? 1 << 55 :
    			        address[10:4] == 56 ? 1 << 56 :
    			        address[10:4] == 57 ? 1 << 57 :
    			        address[10:4] == 58 ? 1 << 58 :
    			        address[10:4] == 59 ? 1 << 59 :
    			        address[10:4] == 60 ? 1 << 60 :
    			        address[10:4] == 61 ? 1 << 61 :
    			        address[10:4] == 62 ? 1 << 62 :
    			        address[10:4] == 63 ? 1 << 63 :
    			        address[10:4] == 64 ? 1 << 64 :
    			        address[10:4] == 65 ? 1 << 65 :
    			        address[10:4] == 66 ? 1 << 66 :
    			        address[10:4] == 67 ? 1 << 67 :
    			        address[10:4] == 68 ? 1 << 68 :
    			        address[10:4] == 69 ? 1 << 69 :
    			        address[10:4] == 70 ? 1 << 70 :
    			        address[10:4] == 71 ? 1 << 71 :
    			        address[10:4] == 72 ? 1 << 72 :
    			        address[10:4] == 73 ? 1 << 73 :
    			        address[10:4] == 74 ? 1 << 74 :
    			        address[10:4] == 75 ? 1 << 75 :
    			        address[10:4] == 76 ? 1 << 76 :
    			        address[10:4] == 77 ? 1 << 77 :
    			        address[10:4] == 78 ? 1 << 78 :
    			        address[10:4] == 79 ? 1 << 79 :
    			        address[10:4] == 80 ? 1 << 80 :
    			        address[10:4] == 81 ? 1 << 81 :
    			        address[10:4] == 82 ? 1 << 82 :
    			        address[10:4] == 83 ? 1 << 83 :
    			        address[10:4] == 84 ? 1 << 84 :
    			        address[10:4] == 85 ? 1 << 85 :
   			          address[10:4] == 86 ? 1 << 86 :
    			        address[10:4] == 87 ? 1 << 87 :
    			        address[10:4] == 88 ? 1 << 88 :
    			        address[10:4] == 89 ? 1 << 89 :
    			        address[10:4] == 90 ? 1 << 90 :
    			        address[10:4] == 91 ? 1 << 91 :
    			        address[10:4] == 92 ? 1 << 92 :
    			        address[10:4] == 93 ? 1 << 93 :
    			        address[10:4] == 94 ? 1 << 94 :
    			        address[10:4] == 95 ? 1 << 95 :
    			        address[10:4] == 96 ? 1 << 96 :
    			        address[10:4] == 97 ? 1 << 97 :
    			        address[10:4] == 98 ? 1 << 98 :
    			        address[10:4] == 99 ? 1 << 99 :
    			        address[10:4] == 100 ? 1 << 100 :
    			        address[10:4] == 101 ? 1 << 101 :
    			        address[10:4] == 102 ? 1 << 102 :
    			        address[10:4] == 103 ? 1 << 103 :
    			        address[10:4] == 104 ? 1 << 104 :
    			        address[10:4] == 105 ? 1 << 105 :
    			        address[10:4] == 106 ? 1 << 106 :
    			        address[10:4] == 107 ? 1 << 107 :
    			        address[10:4] == 108 ? 1 << 108 :
    			        address[10:4] == 109 ? 1 << 109 :
    			        address[10:4] == 110 ? 1 << 110 :
    			        address[10:4] == 111 ? 1 << 111 :
    			        address[10:4] == 112 ? 1 << 112 :
    			        address[10:4] == 113 ? 1 << 113 :
    			        address[10:4] == 114 ? 1 << 114 :
    			        address[10:4] == 115 ? 1 << 115 :
    			        address[10:4] == 116 ? 1 << 116 :
    			        address[10:4] == 117 ? 1 << 117 :
    			        address[10:4] == 118 ? 1 << 118 :
    			        address[10:4] == 119 ? 1 << 119 :
    			        address[10:4] == 120 ? 1 << 120 :
    			        address[10:4] == 121 ? 1 << 121 :
    			        address[10:4] == 122 ? 1 << 122 :
    			        address[10:4] == 123 ? 1 << 123 :
    			        address[10:4] == 124 ? 1 << 124 :
    			        address[10:4] == 125 ? 1 << 125 :
    			        address[10:4] == 126 ? 1 << 126 :
                      			   	            1 << 127 ;



endmodule
