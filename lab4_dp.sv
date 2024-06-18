module lab4_dp #(parameter DW=8, AW=4, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
	output logic [7:0] encryptByte, // encrypted byte output
// TODO: ... 
	output logic packetDone,
 	output logic preambleDone,
	output logic incomingByteValid,
//	 
	 input logic prelenen,
	 input logic tapsen,
	 input logic seedEn,
	 input logic loadLFSR,
	 input logic incReadAddr,
	 input logic lfsrEn,
	 input logic incByteCnt,
	 input logic payLoad,
	 input logic validIn,
	 input logic [7:0] plainByte,
	 input logic getNext,
	 input logic packetEnd,
	 //input logic validOut,
	 input logic done,
	input logic clk, // clock signal 
	input logic rst           // reset
	);
   
   //
   // ROM interface wires
   //
   wire [DW-1:0] data_out;        // from dat_mem


   // 
   // TODO: declare signals that conect to lfsr5
	//logic lfsr_en; //lfsr5 enable
	//logic load_LFSR; // initialize LFSR
   // TODO: for example:   
   logic [lfsr_bitwidth-1:0] taps;       // LFSR feedback pattern temp register //taps
   logic [lfsr_bitwidth-1:0] LFSR;            // LFSR current value            //
   //
	logic [4:0] start;


   logic [AW-1:0] 	       raddr;    // memory read address
   
   // TODO: control the raddr
   // TODO: there are many ways you can do this.
   // TODO: one way is to have a counter here to count 0, 1, 2 and control this coutner
   // TODO: from your state machine
   // TODO: another is to have raddr be the output of mux where you control the mux from your
   // TODO: state machine and the mux selects 0, 1 or 2.
   // TODO: or you can drive raddr from your state machine directly since its only 2 bits it
   // TODO: isn't alot of wires
	//assign raddr = incReadAddr ? raddr+1 : raddr;//if 0 and ira then gotes 1 etc
	
	//what am i reading from? what do i read? where's the input?
	// memory core contents
	//   operands test bench provides to you
	// [0]     = preamble length   (max 12 characters)
	// [1]     = feedback taps in bits [4:0]   
	// [2]     = LFSR starting state in bits [4:0]
	// read preamble length (1 bit for each 0x7E), feedback taps (5 bits), lfsr starting state (5 bits)
	// read these every 3 clock cycle
	//assign preamble_len = prelenen ? data_out[0] : 0;
	//assign fb_taps = tapsenm ? data_out[1] : 0;
	//assign lfsr_state = seeden ? data_out[2] : 0;
	
	

   //
   // FIFO
   // This fifo takes data from the outside (testbench) and captures it
   // Your logic reads from this fifo.
   //
   logic [7:0] 		       fInPlainByte;  // data from the input fifo
 		       
   fifo fm (
	    .rdDat(fInPlainByte),             // data from the FIFO
	    .valid(incomingByteValid),                 // there is valid data from the FIFO
	    .wrDat(plainByte),                // data into the FIFO
	    .push(validIn),                   // data into the fifo is valid
	    .pop(getNext),                    // read the next entry from the fifo
	    .clk(clk), .rst(rst));
   
   // TODO: detect preambleDone 
	logic [7:0]preamble_len;
	logic [7:0]byteCount;
	assign preambleDone = (preamble_len == byteCount);
   
   // TODO: detect packet end (i.e. 32 bytes have been processed)
	assign packetDone = (byteCount == 32);

   // instantiate the ROM
   dat_mem dm1(.raddr, .data_out);
	
   // instantiate the lfsr
   lfsr5 l5(.clk, 
            .en(lfsrEn),          // advance LFSR on rising clk
            .init(loadLFSR),	   // initialize LFSR
            .taps(taps), 		   // tap pattern
				//IMPORTANT
            .start(start), 		   // starting state for LFSR //DOUBLE CHECK
				//IMPORTANT
            .state(LFSR));	   // LFSR state = LFSR output 
   
   //assign preamble////
   // TODO: write an expression for encryptByte
   // TODO: for example:

   assign encryptByte = {payLoad, 2'b00, LFSR}^fInPlainByte;
	
	//logic [4:0] fb_taps;
	always_ff @(posedge clk) begin
        if(prelenen) begin
            preamble_len <= data_out;
        end else
            preamble_len <= preamble_len;

        if(tapsen) begin
            taps <= data_out;
        end else
            taps <= taps;

        if(seedEn) begin
            start <= data_out;
        end else
            start <= start;

	end
	
	//logic incRaddr;
   always_ff @(posedge clk) begin
      
      // TODO: capture preamble length, taps, and seed that you read from the ROM
		if (rst) begin
		raddr <= 0;
		end
		else
		// how to capture preamble lenght? what's taps here? what's seed?
		// rom only output data, what data?
		if(incReadAddr) begin
			raddr <= raddr + 1;
			end
   end

   //
   // byte counter - count the number of bytes processed
   //
	//logic incByteCount;
   always_ff @(posedge clk) begin
   if (rst) begin
		byteCount <= 0;
   end else begin
	if (incByteCnt) begin
	   byteCount <= byteCount + 1;
	end else begin
	   byteCount <= byteCount;
	end
      end
   end // always_ff @ (posedge clk)
	
	
endmodule // lab4_dp

