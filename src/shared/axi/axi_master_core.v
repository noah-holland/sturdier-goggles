
`timescale 1 ns / 1 ps

	module axi4_lite_master #
	(
			// Width of M_AXI address bus.
    // The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of M_AXI data bus.
    // The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
		parameter integer C_M_AXI_DATA_WIDTH	= 32

	)
	(
		// Users to add ports here
    input wire [15:0] cpu_rw_addr_i,
    input wire [15:0] cpu_w_data_i,
    output reg [15:0] cpu_r_addr_o,
    output reg [15:0] cpu_r_data_o,
    input wire rw,

		// Initiate AXI transactions
		input wire  INIT_AXI_TXN,
		// Asserts when ERROR is detected
		output reg  ERROR,
		// Asserts when AXI transactions is complete
		output reg  TXN_DONE,
		// AXI clock signal
		input wire  M_AXI_ACLK,
		// AXI active low reset signal
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address Channel ports. Write address (issued by master)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Write channel Protection type.
    // This signal indicates the privilege and security level of the transaction,
    // and whether the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Write address valid.
    // This signal indicates that the master signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready.
    // This signal indicates that the slave is ready to accept an address and associated control signals.
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data Channel ports. Write data (issued by master)
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes.
    // This signal indicates which byte lanes hold valid data.
    // There is one write strobe bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write valid. This signal indicates that valid write data and strobes are available.
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response Channel ports.
    // This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Write response valid.
    // This signal indicates that the channel is signaling a valid write response
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address Channel ports. Read address (issued by master)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Protection type.
    // This signal indicates the privilege and security level of the transaction,
    // and whether the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Read address valid.
    // This signal indicates that the channel is signaling valid read address and control information.
		output wire  M_AXI_ARVALID,
		// Read address ready.
    // This signal indicates that the slave is ready to accept an address and associated control signals.
		input wire  M_AXI_ARREADY,
		// Master Interface Read Data Channel ports. Read data (issued by slave)
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer.
		input wire [1 : 0] M_AXI_RRESP,
		// Read valid. This signal indicates that the channel is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can accept the read data and response information.
		output wire  M_AXI_RREADY
	);

	// Example State machine to initialize counter, initialize write transactions,
	// initialize read transactions and comparison of read data with the
	// written data words.
	parameter [1:0] IDLE = 2'b00, // This state initiates AXI4Lite transaction
			// after the state machine changes state to INIT_WRITE
			// when there is 0 to 1 transition on INIT_AXI_TXN
		INIT_WRITE   = 2'b01, // This state initializes write transaction,
			// once writes are done, the state machine
			// changes state to INIT_READ
		INIT_READ = 2'b10, // This state initializes read transaction
			// once reads are done, the state machine
			// changes state to INIT_COMPARE
		INIT_COMPARE = 2'b11; // This state issues the status of comparison
			// of the written data with the read data

	 reg [1:0] mst_exec_state;

	// AXI4LITE signals
	//write address valid
	reg  	axi_awvalid;
	//write data valid
	reg  	axi_wvalid;
	//read address valid
	reg  	axi_arvalid;
	//read data acceptance
	reg  	axi_rready;
	//write response acceptance
	reg  	axi_bready;
	//write address
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	//write data
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	//read addresss
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	//Asserts when there is a write response error
	wire  	write_resp_error;
	//Asserts when there is a read response error
	wire  	read_resp_error;
	//A pulse to initiate a write transaction
	reg  	start_single_write;
	//A pulse to initiate a read transaction
	reg  	start_single_read;
	//Asserts when a single beat write transaction is issued and remains asserted till the completion of write trasaction.
	reg  	write_issued;
	//Asserts when a single beat read transaction is issued and remains asserted till the completion of read trasaction.
	reg  	read_issued;
	//The error register is asserted when any of the write response error, read response error or the data mismatch flags are asserted.
	reg  	error_reg;
	reg  	init_txn_ff;
	reg  	init_txn_ff2;
	reg  	init_txn_edge;
	wire  	init_txn_pulse;
	reg txn_rw;

  reg [C_M_AXI_ADDR_WIDTH-1:0]read_addr;

	// I/O Connections assignments

	//Adding the offset address to the base addr of the slave
	assign M_AXI_AWADDR	= axi_awaddr;
	//AXI 4 write data
	assign M_AXI_WDATA	= axi_wdata;
	assign M_AXI_AWPROT	= 3'b000;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WVALID	= axi_wvalid;
	//Set all byte strobes in this example
	assign M_AXI_WSTRB	= 4'b0011;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARADDR	= axi_araddr;
	assign M_AXI_ARVALID	= axi_arvalid;
	assign M_AXI_ARPROT	= 3'b001;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Example design I/O
	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;


	//Generate a pulse to initiate AXI transaction.
	always @(posedge M_AXI_ACLK)
	  begin
	    // Initiates AXI transaction delay
	    if (M_AXI_ARESETN == 0 )
	      begin
	        init_txn_ff <= 1'b0;
	        init_txn_ff2 <= 1'b0;
	      end
	    else
	      begin
	        init_txn_ff <= INIT_AXI_TXN;
	        init_txn_ff2 <= init_txn_ff;
	      end
	  end


	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and
	// command information for the entire transaction.  It is a single beat
	// of information.

	// Note for this example the axi_awvalid/axi_wvalid are asserted at the same
	// time, and then each is deasserted independent from each other.
	// This is a lower-performance, but simplier control scheme.

	// AXI VALID signals must be held active until accepted by the partner.

	// A data transfer is accepted by the slave when a master has
	// VALID data and the slave acknoledges it is also READY. While the master
	// is allowed to generated multiple, back-to-back requests by not
	// deasserting VALID, this design will add rest cycle for
	// simplicity.

	// Since only one outstanding transaction is issued by the user design,
	// there will not be a collision between a new request and an accepted
	// request on the same clock cycle.

	  always @(posedge M_AXI_ACLK)
	  begin
	    //Only VALID signals must be deasserted during reset per AXI spec
	    //Consider inverting then registering active-low reset for higher fmax
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
	      begin
	        axi_awvalid <= 1'b0;
	      end
	      //Signal a new address/data command is available by user logic
	    else
	      begin
	        if (start_single_write)
	          begin
	            axi_awvalid <= 1'b1;
	          end
	     //Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
	        else if (M_AXI_AWREADY && axi_awvalid)
	          begin
	            axi_awvalid <= 1'b0;
	          end
	      end
	  end


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data channel is for transfering the actual data.
	//The data generation is speific to the example design, and
	//so only the WVALID/WREADY handshake is shown here

	   always @(posedge M_AXI_ACLK)
	   begin
	     if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)
	       begin
	         axi_wvalid <= 1'b0;
	       end
	     //Signal a new address/data command is available by user logic
	     else if (start_single_write)
	       begin
	         axi_wvalid <= 1'b1;
	       end
	     //Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)
	     else if (M_AXI_WREADY && axi_wvalid)
	       begin
	        axi_wvalid <= 1'b0;
	       end
	   end


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur after both the data and the write address
	//has arrived and been accepted by the slave, and can guarantee that no
	//other accesses launched afterwards will be able to be reordered before it.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error.

	//While not necessary per spec, it is advisable to reset READY signals in
	//case of differing reset latencies between master/slave.

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
	      begin
	        axi_bready <= 1'b0;
	      end
	    // accept/acknowledge bresp with axi_bready by the master
	    // when M_AXI_BVALID is asserted by slave
	    else if (M_AXI_BVALID && ~axi_bready)
	      begin
	        axi_bready <= 1'b1;
	      end
	    // deassert after one clock cycle
	    else if (axi_bready)
	      begin
	        axi_bready <= 1'b0;
	      end
	    // retain the previous value
	    else
	      axi_bready <= axi_bready;
	  end

	//Flag write errors
	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);


	//----------------------------
	//Read Address Channel
	//----------------------------

	  // A new axi_arvalid is asserted when there is a valid read address
	  // available by the master. start_single_read triggers a new read
	  // transaction
	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
	      begin
	        axi_arvalid <= 1'b0;
	      end
	    //Signal a new read address command is available by user logic
	    else if (start_single_read)
	      begin
	        axi_arvalid <= 1'b1;
	      end
	    //RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)
	    else if (M_AXI_ARREADY && axi_arvalid)
	      begin
	        axi_arvalid <= 1'b0;
	      end
	    // retain the previous value
	  end


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	//The Read Data channel returns the results of the read request
	//The master will accept the read data by asserting axi_rready
	//when there is a valid read data available.
	//While not necessary per spec, it is advisable to reset READY signals in
	//case of differing reset latencies between master/slave.

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
	      begin
	        axi_rready <= 1'b0;
	      end
	    // accept/acknowledge rdata/rresp with axi_rready by the master
	    // when M_AXI_RVALID is asserted by slave
	    else if (M_AXI_RVALID && ~axi_rready)
	      begin
	        axi_rready <= 1'b1;
	      end
	    // deassert after one clock cycle
	    else if (axi_rready)
	      begin
	        axi_rready <= 1'b0;
	      end
	    // retain the previous value
	  end

	//Flag write errors
	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);


	//--------------------------------
	//User Logic
	//--------------------------------

	  //Write Addresses
	  always @(posedge M_AXI_ACLK)
      if (M_AXI_ARESETN == 0)
        begin
          axi_awaddr <= 0;
        end
	    else if (INIT_AXI_TXN)
	      axi_awaddr <= {15'b0,cpu_rw_addr_i};

	  // Write data generation
	  always @(posedge M_AXI_ACLK)
      if (M_AXI_ARESETN == 0)
        begin
          axi_wdata <= 0;
        end
      else if (INIT_AXI_TXN)
        axi_wdata <= {15'b0,cpu_w_data_i};

	  //Read Addresses
	  always @(posedge M_AXI_ACLK)
      if (M_AXI_ARESETN == 0)
        begin
          axi_araddr <= 0;
        end
      else if (INIT_AXI_TXN)
        axi_araddr <= {15'b0,cpu_rw_addr_i};

    always @(posedge M_AXI_ACLK)
      if (M_AXI_ARESETN == 0)
        begin
          cpu_r_addr_o <= 0;
          cpu_r_data_o <= 0;
        end
      else if (M_AXI_RVALID && axi_rready) // The data is good if RVALID and rready are set
        begin
          cpu_r_addr_o <= read_addr[15:0];
          cpu_r_data_o <= M_AXI_RDATA[15:0];
        end

	  always @(posedge M_AXI_ACLK)
      if (M_AXI_ARESETN == 0)
        begin
          txn_rw <= 0;
        end
	    else if (INIT_AXI_TXN)
	      txn_rw <= rw;

	  //implement master command interface state machine
	  always @ ( posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 1'b0)
	      begin
	      // reset condition
	      // All the signals are assigned default values under reset condition
	        mst_exec_state  <= IDLE;
	        start_single_write <= 1'b0;
	        start_single_read  <= 1'b0;
          read_issued <= 1'b0;
          write_issued <= 1'b0;
          read_addr <= 0;
	        ERROR <= 1'b0;
	      end
	    else
	      begin
	       // state transition
	        case (mst_exec_state)

	          IDLE:
	          // This state is responsible to initiate
	          // AXI transaction when init_txn_pulse is asserted
	            if ( init_txn_pulse == 1'b1 )
	              begin
	                mst_exec_state  <= txn_rw ? INIT_WRITE : INIT_READ;
	                ERROR <= 1'b0;
	              end
	            else
	              begin
                  TXN_DONE <= 1'b0;
	                mst_exec_state  <= IDLE;
	              end

	          INIT_WRITE:
	            // This state is responsible to issue start_single_write pulse to
	            // initiate a write transaction. Write transactions will be
              if (axi_bready)
                begin
                  mst_exec_state <= IDLE;
                  write_issued <= 1'b0;
                  TXN_DONE <= 1'b1;
                end
              else
                begin
                  mst_exec_state  <= INIT_WRITE;

                    if (~axi_awvalid && ~axi_wvalid && ~M_AXI_BVALID && ~start_single_write && ~write_issued)
                      begin
                        start_single_write <= 1'b1;
                        write_issued <= 1'b1;
                      end
                    else
                      begin
                        start_single_write <= 1'b0; //Negate to generate a pulse
                      end
                end

	          INIT_READ:
	            // This state is responsible to issue start_single_read pulse to
	            // initiate a read transaction.
	             if (axi_rready)
	               begin
	                 mst_exec_state <= IDLE;
                   read_issued <= 1'b0;
                   TXN_DONE <= 1'b1;
	               end
	             else
	               begin
	                 mst_exec_state  <= INIT_READ;

	                 if (~axi_arvalid && ~M_AXI_RVALID && ~start_single_read && ~read_issued)
	                   begin
	                     start_single_read <= 1'b1;
                       read_issued  <= 1'b1;
                       read_addr <= axi_awaddr;
	                   end
	                 else
	                   begin
	                     start_single_read <= 1'b0; //Negate to generate a pulse
	                   end
	               end
	           default :
	             begin
	               mst_exec_state  <= IDLE;
	             end
	        endcase
	    end
	  end //MASTER_EXECUTION_PROC

	endmodule
