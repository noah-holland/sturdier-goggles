module cache(
	input  wire clk,
	input  wire rst_n,
	input  wire tag_write,
	input  wire data_write,
	input  wire cache_enable,
	input  wire [15:0] read_address,
	input  wire [15:0] write_address,
	input  wire [15:0] data_in,
	output wire [15:0] data_out,
	output wire cache_miss
);

	wire [127:0] block_num_read; 	//The block select for reads (one-hot)
	wire [4:0] tag_read;		//The tag from the read_address
	wire [7:0] word_num_read,	//The word select for reads (one-hot)
		   full_read_tag, 	//The tag with valid bit
		   tag_check;		//The tag in the block when reading

	wire [127:0] block_num_write; 	//The block select for writes (one-hot)
	wire [4:0] write_tag;		//The tag from the write_address
	wire [7:0] word_num_write,	//The word select for writes (one-hot)
		   full_write_tag; 	//The tag with valid bit

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

	assign data_out = data_write ? 16'h0 : data_out_internal;

	//Deciding if the cache has missed
	assign cache_miss = tag_write        ? 1'b0                          :
	       (full_read_tag != tag_check)  ? (cache_enable & ~data_write)  :
			   (full_write_tag != tag_check) ? (cache_enable & data_write)   :
							    			    1'b0;
	//Which address information to use
	assign block_num = data_write ? block_num_write : block_num_read;
	assign word_num = data_write ? word_num_write : word_num_read;
	assign full_tag = tag_write ? full_write_tag : full_read_tag;

	//Read address assigns
	//Set the tag for reading in MetaData
	assign tag_read = read_address[15:11];

	//Set the full tag for reading
	assign full_read_tag = {3'b100,tag_read};

	//Set the word select for reading (one-hot)
	assign word_num_read = read_address[3:1] == 0 ? 1 :
		      	       read_address[3:1] == 1 ? 1 << 1 :
		     	         read_address[3:1] == 2 ? 1 << 2 :
		      	       read_address[3:1] == 3 ? 1 << 3 :
		      	       read_address[3:1] == 4 ? 1 << 4 :
		     	         read_address[3:1] == 5 ? 1 << 5 :
		      	       read_address[3:1] == 6 ? 1 << 6 :
		                               	        1 << 7 ;

	//Set the block select for reading (one-hot)
	assign block_num_read = read_address[10:4] == 0 ? 1 :
			        read_address[10:4] == 1 ? 1 << 1 :
   			        read_address[10:4] == 2 ? 1 << 2 :
    			        read_address[10:4] == 3 ? 1 << 3 :
    			        read_address[10:4] == 4 ? 1 << 4 :
    			        read_address[10:4] == 5 ? 1 << 5 :
    			        read_address[10:4] == 6 ? 1 << 6 :
    			        read_address[10:4] == 7 ? 1 << 7 :
    			        read_address[10:4] == 8 ? 1 << 8 :
    			        read_address[10:4] == 9 ? 1 << 9 :
    			        read_address[10:4] == 10 ? 1 << 10 :
    			        read_address[10:4] == 11 ? 1 << 11 :
    			        read_address[10:4] == 12 ? 1 << 12 :
    			        read_address[10:4] == 13 ? 1 << 13 :
    			        read_address[10:4] == 14 ? 1 << 14 :
    			        read_address[10:4] == 15 ? 1 << 15 :
    			        read_address[10:4] == 16 ? 1 << 16 :
    		  	      read_address[10:4] == 17 ? 1 << 17 :
    			        read_address[10:4] == 18 ? 1 << 18 :
    			        read_address[10:4] == 19 ? 1 << 19 :
    			        read_address[10:4] == 20 ? 1 << 20 :
    			        read_address[10:4] == 21 ? 1 << 21 :
    			        read_address[10:4] == 22 ? 1 << 22 :
    			        read_address[10:4] == 23 ? 1 << 23 :
    			        read_address[10:4] == 24 ? 1 << 24 :
    			        read_address[10:4] == 25 ? 1 << 25 :
    			        read_address[10:4] == 26 ? 1 << 26 :
    			        read_address[10:4] == 27 ? 1 << 27 :
    			        read_address[10:4] == 28 ? 1 << 28 :
    			        read_address[10:4] == 29 ? 1 << 29 :
    			        read_address[10:4] == 30 ? 1 << 30 :
    			        read_address[10:4] == 31 ? 1 << 31 :
    			        read_address[10:4] == 32 ? 1 << 32 :
    			        read_address[10:4] == 33 ? 1 << 33 :
    			        read_address[10:4] == 34 ? 1 << 34 :
    			        read_address[10:4] == 35 ? 1 << 35 :
    			        read_address[10:4] == 36 ? 1 << 36 :
    			        read_address[10:4] == 37 ? 1 << 37 :
    			        read_address[10:4] == 38 ? 1 << 38 :
    			        read_address[10:4] == 39 ? 1 << 39 :
    			        read_address[10:4] == 40 ? 1 << 40 :
    			        read_address[10:4] == 41 ? 1 << 41 :
    			        read_address[10:4] == 42 ? 1 << 42 :
    			        read_address[10:4] == 43 ? 1 << 43 :
    			        read_address[10:4] == 44 ? 1 << 44 :
    			        read_address[10:4] == 45 ? 1 << 45 :
    			        read_address[10:4] == 46 ? 1 << 46 :
    			        read_address[10:4] == 47 ? 1 << 47 :
    			        read_address[10:4] == 48 ? 1 << 48 :
    			        read_address[10:4] == 49 ? 1 << 49 :
    			        read_address[10:4] == 50 ? 1 << 50 :
    			        read_address[10:4] == 51 ? 1 << 51 :
    			        read_address[10:4] == 52 ? 1 << 52 :
    			        read_address[10:4] == 53 ? 1 << 53 :
    			        read_address[10:4] == 54 ? 1 << 54 :
    			        read_address[10:4] == 55 ? 1 << 55 :
    			        read_address[10:4] == 56 ? 1 << 56 :
    			        read_address[10:4] == 57 ? 1 << 57 :
    			        read_address[10:4] == 58 ? 1 << 58 :
    			        read_address[10:4] == 59 ? 1 << 59 :
    			        read_address[10:4] == 60 ? 1 << 60 :
    			        read_address[10:4] == 61 ? 1 << 61 :
    			        read_address[10:4] == 62 ? 1 << 62 :
    			        read_address[10:4] == 63 ? 1 << 63 :
    			        read_address[10:4] == 64 ? 1 << 64 :
    			        read_address[10:4] == 65 ? 1 << 65 :
    			        read_address[10:4] == 66 ? 1 << 66 :
    			        read_address[10:4] == 67 ? 1 << 67 :
    			        read_address[10:4] == 68 ? 1 << 68 :
    			        read_address[10:4] == 69 ? 1 << 69 :
    			        read_address[10:4] == 70 ? 1 << 70 :
    			        read_address[10:4] == 71 ? 1 << 71 :
    			        read_address[10:4] == 72 ? 1 << 72 :
    			        read_address[10:4] == 73 ? 1 << 73 :
    			        read_address[10:4] == 74 ? 1 << 74 :
    			        read_address[10:4] == 75 ? 1 << 75 :
    			        read_address[10:4] == 76 ? 1 << 76 :
    			        read_address[10:4] == 77 ? 1 << 77 :
    			        read_address[10:4] == 78 ? 1 << 78 :
    			        read_address[10:4] == 79 ? 1 << 79 :
    			        read_address[10:4] == 80 ? 1 << 80 :
    			        read_address[10:4] == 81 ? 1 << 81 :
    			        read_address[10:4] == 82 ? 1 << 82 :
    			        read_address[10:4] == 83 ? 1 << 83 :
    			        read_address[10:4] == 84 ? 1 << 84 :
    			        read_address[10:4] == 85 ? 1 << 85 :
   			          read_address[10:4] == 86 ? 1 << 86 :
    			        read_address[10:4] == 87 ? 1 << 87 :
    			        read_address[10:4] == 88 ? 1 << 88 :
    			        read_address[10:4] == 89 ? 1 << 89 :
    			        read_address[10:4] == 90 ? 1 << 90 :
    			        read_address[10:4] == 91 ? 1 << 91 :
    			        read_address[10:4] == 92 ? 1 << 92 :
    			        read_address[10:4] == 93 ? 1 << 93 :
    			        read_address[10:4] == 94 ? 1 << 94 :
    			        read_address[10:4] == 95 ? 1 << 95 :
    			        read_address[10:4] == 96 ? 1 << 96 :
    			        read_address[10:4] == 97 ? 1 << 97 :
    			        read_address[10:4] == 98 ? 1 << 98 :
    			        read_address[10:4] == 99 ? 1 << 99 :
    			        read_address[10:4] == 100 ? 1 << 100 :
    			        read_address[10:4] == 101 ? 1 << 101 :
    			        read_address[10:4] == 102 ? 1 << 102 :
    			        read_address[10:4] == 103 ? 1 << 103 :
    			        read_address[10:4] == 104 ? 1 << 104 :
    			        read_address[10:4] == 105 ? 1 << 105 :
    			        read_address[10:4] == 106 ? 1 << 106 :
    			        read_address[10:4] == 107 ? 1 << 107 :
    			        read_address[10:4] == 108 ? 1 << 108 :
    			        read_address[10:4] == 109 ? 1 << 109 :
    			        read_address[10:4] == 110 ? 1 << 110 :
    			        read_address[10:4] == 111 ? 1 << 111 :
    			        read_address[10:4] == 112 ? 1 << 112 :
    			        read_address[10:4] == 113 ? 1 << 113 :
    			        read_address[10:4] == 114 ? 1 << 114 :
    			        read_address[10:4] == 115 ? 1 << 115 :
    			        read_address[10:4] == 116 ? 1 << 116 :
    			        read_address[10:4] == 117 ? 1 << 117 :
    			        read_address[10:4] == 118 ? 1 << 118 :
    			        read_address[10:4] == 119 ? 1 << 119 :
    			        read_address[10:4] == 120 ? 1 << 120 :
    			        read_address[10:4] == 121 ? 1 << 121 :
    			        read_address[10:4] == 122 ? 1 << 122 :
    			        read_address[10:4] == 123 ? 1 << 123 :
    			        read_address[10:4] == 124 ? 1 << 124 :
    			        read_address[10:4] == 125 ? 1 << 125 :
    			        read_address[10:4] == 126 ? 1 << 126 :
                      			   	            1 << 127 ;

	//Write address assigns
	//Set the tag for writing in MetaData
	assign write_tag = write_address[15:11];

	//Set the full tag for writing
	assign full_write_tag = {3'b100,write_tag};

	//Set the word select for writing (one-hot)
	assign word_num_write = write_address[3:1] == 0 ? 1 :
		      	  write_address[3:1] == 1 ? 1 << 1 :
		       	  write_address[3:1] == 2 ? 1 << 2 :
		      	  write_address[3:1] == 3 ? 1 << 3 :
		      	  write_address[3:1] == 4 ? 1 << 4 :
		      	  write_address[3:1] == 5 ? 1 << 5 :
		      	  write_address[3:1] == 6 ? 1 << 6 :
		                               	   1 << 7 ;

	//Set the block select for writing (one-hot)
	assign block_num_write = write_address[10:4] == 0 ? 1 :
			       write_address[10:4] == 1 ? 1 << 1 :
   			     write_address[10:4] == 2 ? 1 << 2 :
    			   write_address[10:4] == 3 ? 1 << 3 :
    			   write_address[10:4] == 4 ? 1 << 4 :
    			   write_address[10:4] == 5 ? 1 << 5 :
    			   write_address[10:4] == 6 ? 1 << 6 :
    			   write_address[10:4] == 7 ? 1 << 7 :
    			   write_address[10:4] == 8 ? 1 << 8 :
    			   write_address[10:4] == 9 ? 1 << 9 :
    			   write_address[10:4] == 10 ? 1 << 10 :
    			   write_address[10:4] == 11 ? 1 << 11 :
    			   write_address[10:4] == 12 ? 1 << 12 :
    			   write_address[10:4] == 13 ? 1 << 13 :
    			   write_address[10:4] == 14 ? 1 << 14 :
    			   write_address[10:4] == 15 ? 1 << 15 :
    			   write_address[10:4] == 16 ? 1 << 16 :
    		     write_address[10:4] == 17 ? 1 << 17 :
    			   write_address[10:4] == 18 ? 1 << 18 :
    			   write_address[10:4] == 19 ? 1 << 19 :
    			   write_address[10:4] == 20 ? 1 << 20 :
    			   write_address[10:4] == 21 ? 1 << 21 :
    			   write_address[10:4] == 22 ? 1 << 22 :
    			   write_address[10:4] == 23 ? 1 << 23 :
    			   write_address[10:4] == 24 ? 1 << 24 :
    			   write_address[10:4] == 25 ? 1 << 25 :
    			   write_address[10:4] == 26 ? 1 << 26 :
    			   write_address[10:4] == 27 ? 1 << 27 :
    			   write_address[10:4] == 28 ? 1 << 28 :
    			   write_address[10:4] == 29 ? 1 << 29 :
    			   write_address[10:4] == 30 ? 1 << 30 :
    			   write_address[10:4] == 31 ? 1 << 31 :
    			   write_address[10:4] == 32 ? 1 << 32 :
    			   write_address[10:4] == 33 ? 1 << 33 :
    			   write_address[10:4] == 34 ? 1 << 34 :
    			   write_address[10:4] == 35 ? 1 << 35 :
    			   write_address[10:4] == 36 ? 1 << 36 :
    			   write_address[10:4] == 37 ? 1 << 37 :
    			   write_address[10:4] == 38 ? 1 << 38 :
    			   write_address[10:4] == 39 ? 1 << 39 :
    			   write_address[10:4] == 40 ? 1 << 40 :
    			   write_address[10:4] == 41 ? 1 << 41 :
    			   write_address[10:4] == 42 ? 1 << 42 :
    			   write_address[10:4] == 43 ? 1 << 43 :
    			   write_address[10:4] == 44 ? 1 << 44 :
    			   write_address[10:4] == 45 ? 1 << 45 :
    			   write_address[10:4] == 46 ? 1 << 46 :
    			   write_address[10:4] == 47 ? 1 << 47 :
    			   write_address[10:4] == 48 ? 1 << 48 :
    			   write_address[10:4] == 49 ? 1 << 49 :
    			   write_address[10:4] == 50 ? 1 << 50 :
    			   write_address[10:4] == 51 ? 1 << 51 :
    			   write_address[10:4] == 52 ? 1 << 52 :
    			   write_address[10:4] == 53 ? 1 << 53 :
    			   write_address[10:4] == 54 ? 1 << 54 :
    			   write_address[10:4] == 55 ? 1 << 55 :
    			   write_address[10:4] == 56 ? 1 << 56 :
    			   write_address[10:4] == 57 ? 1 << 57 :
    			   write_address[10:4] == 58 ? 1 << 58 :
    			   write_address[10:4] == 59 ? 1 << 59 :
    			   write_address[10:4] == 60 ? 1 << 60 :
    			   write_address[10:4] == 61 ? 1 << 61 :
    			   write_address[10:4] == 62 ? 1 << 62 :
    			   write_address[10:4] == 63 ? 1 << 63 :
    			   write_address[10:4] == 64 ? 1 << 64 :
    			   write_address[10:4] == 65 ? 1 << 65 :
    			   write_address[10:4] == 66 ? 1 << 66 :
    			   write_address[10:4] == 67 ? 1 << 67 :
    			   write_address[10:4] == 68 ? 1 << 68 :
    			   write_address[10:4] == 69 ? 1 << 69 :
    			   write_address[10:4] == 70 ? 1 << 70 :
    			   write_address[10:4] == 71 ? 1 << 71 :
    			   write_address[10:4] == 72 ? 1 << 72 :
    			   write_address[10:4] == 73 ? 1 << 73 :
    			   write_address[10:4] == 74 ? 1 << 74 :
    			   write_address[10:4] == 75 ? 1 << 75 :
    			   write_address[10:4] == 76 ? 1 << 76 :
    			   write_address[10:4] == 77 ? 1 << 77 :
    			   write_address[10:4] == 78 ? 1 << 78 :
    			   write_address[10:4] == 79 ? 1 << 79 :
    			   write_address[10:4] == 80 ? 1 << 80 :
    			   write_address[10:4] == 81 ? 1 << 81 :
    			   write_address[10:4] == 82 ? 1 << 82 :
    			   write_address[10:4] == 83 ? 1 << 83 :
    			   write_address[10:4] == 84 ? 1 << 84 :
    			   write_address[10:4] == 85 ? 1 << 85 :
   			     write_address[10:4] == 86 ? 1 << 86 :
    			   write_address[10:4] == 87 ? 1 << 87 :
    			   write_address[10:4] == 88 ? 1 << 88 :
    			   write_address[10:4] == 89 ? 1 << 89 :
    			   write_address[10:4] == 90 ? 1 << 90 :
    			   write_address[10:4] == 91 ? 1 << 91 :
    			   write_address[10:4] == 92 ? 1 << 92 :
    			   write_address[10:4] == 93 ? 1 << 93 :
    			   write_address[10:4] == 94 ? 1 << 94 :
    			   write_address[10:4] == 95 ? 1 << 95 :
    			   write_address[10:4] == 96 ? 1 << 96 :
    			   write_address[10:4] == 97 ? 1 << 97 :
    			   write_address[10:4] == 98 ? 1 << 98 :
    			   write_address[10:4] == 99 ? 1 << 99 :
    			   write_address[10:4] == 100 ? 1 << 100 :
    			   write_address[10:4] == 101 ? 1 << 101 :
    			   write_address[10:4] == 102 ? 1 << 102 :
    			   write_address[10:4] == 103 ? 1 << 103 :
    			   write_address[10:4] == 104 ? 1 << 104 :
    			   write_address[10:4] == 105 ? 1 << 105 :
    			   write_address[10:4] == 106 ? 1 << 106 :
    			   write_address[10:4] == 107 ? 1 << 107 :
    			   write_address[10:4] == 108 ? 1 << 108 :
    			   write_address[10:4] == 109 ? 1 << 109 :
    			   write_address[10:4] == 110 ? 1 << 110 :
    			   write_address[10:4] == 111 ? 1 << 111 :
    			   write_address[10:4] == 112 ? 1 << 112 :
    			   write_address[10:4] == 113 ? 1 << 113 :
    			   write_address[10:4] == 114 ? 1 << 114 :
    			   write_address[10:4] == 115 ? 1 << 115 :
    			   write_address[10:4] == 116 ? 1 << 116 :
    			   write_address[10:4] == 117 ? 1 << 117 :
    			   write_address[10:4] == 118 ? 1 << 118 :
    			   write_address[10:4] == 119 ? 1 << 119 :
    			   write_address[10:4] == 120 ? 1 << 120 :
    			   write_address[10:4] == 121 ? 1 << 121 :
    			   write_address[10:4] == 122 ? 1 << 122 :
    			   write_address[10:4] == 123 ? 1 << 123 :
    			   write_address[10:4] == 124 ? 1 << 124 :
    			   write_address[10:4] == 125 ? 1 << 125 :
    			   write_address[10:4] == 126 ? 1 << 126 :
                                          1 << 127 ;



endmodule
