module seqsm 
   (
// TODO: define your outputs and inputs
    input logic clk,
    input logic rst,
	 input logic encRqst,
	 input logic packetDone,
	 input logic preambleDone, 
	 input logic incomingByteValid,
	 
	 output logic prelenen,
	 output logic tapsen,
	 output logic getNext,                                 
	 output logic seedEn,
	 output logic loadLFSR,
	 output logic incReadAddr,
	 output logic lfsrEn,
	 output logic incByteCnt,
	 output logic payLoad,
	 output logic packetEnd,
	 
//	 output logic finValid,//just added 03/11
	 output logic validOut,
	 output logic done
	 
    );
	 
typedef enum { Idle, LoadPreamble, LoadTaps, LoadSeed, InitLFSR, 
													ProcessPreamble, Encrypt, Done} states_t;
													
   states_t curState;
   states_t nxtState;
													
// sequential part of our state machine

   always_ff @(posedge clk)
     begin
       if (rst)
         curState <= Idle;
       else
         curState <= nxtState;
     end 

	always_comb begin
		 prelenen = 0;
		 tapsen = 0;
		 getNext = 0;
		 seedEn = 0;
		 loadLFSR = 0;
		 incReadAddr = 0;
		 lfsrEn = 0;
		 incByteCnt = 0;
		 payLoad = 0;
		 packetEnd = 0;
		 validOut = 0;
		 done = 0;
	 
				
				unique case (curState)
				
				Idle : begin
					if(encRqst) begin
						nxtState = LoadPreamble;
					end else 
						nxtState = Idle;
				end
					
				LoadPreamble : begin
					incReadAddr = 1;
					prelenen = 1;
					nxtState = LoadTaps;
					
				end
				
				LoadTaps : begin
					incReadAddr = 1;
					tapsen = 1;
					nxtState = LoadSeed;

				end 
				LoadSeed : begin
//					incReadAddr = 1;
					seedEn = 1;
					nxtState = InitLFSR;
				end
				
				InitLFSR : begin
//					lfsrEn = 1;
					loadLFSR = 1;
					nxtState = ProcessPreamble;
				end
				
				ProcessPreamble : begin
					if(incomingByteValid) begin
						lfsrEn = 1;
						incByteCnt = 1;
						getNext = 1; // double check
						payLoad = 0;
						validOut = 1;
					end
						
					if(preambleDone) begin
					   payLoad = 1;
						nxtState = Encrypt;
					end else
						nxtState = ProcessPreamble;
				end
				Encrypt : begin
				
					if(incomingByteValid) begin
						lfsrEn = 1;
						incByteCnt = 1;
						getNext = 1; // double check
						payLoad = 1;
						validOut = 1;
					end
					
					if(packetDone) begin
						nxtState = Done;
					end else
						nxtState = Encrypt;
				end
				
				Done : begin
					done = 1;
					nxtState = Done;
				end
				
				default: nxtState = Idle;
			endcase //(unique case)
		end // end comb

   // TODO: define your states
   // TODO: here is one suggestion, but you can implmenet any number of states
   // TODO: you like
   // TODO: typedef enum {
   // TODO:		 Idle, LoadPreamble, LoadTaps, LoadSeed, InitLFSR, 
   // TODO:		 ProcessPreamble, Encrypt, Done
   // TODO:		 } states_t;
   // TODO: for example
   // TODO:  1: Idle -> 
   // TODO:  2: LoadPreamble (read the preamble from the ROM and capture it in some registers (reg/logic/wire)) ->
   // TODO:  3: LoadTaps (read the taps from the ROM and capture it in some registers) ->
   // TODO:  4: LoadSeed (read the seed from the ROM and capture it in some registers) ->
   // TODO:  5: InitLFSR (load the LFSR with the taps and seed) ->
   // TODO:  6: ProcessPremble (encrypt preamble until byteCount is the same as preamble length) ->
   // TODO:  7: Encrypt rest of packet until byteCount == 32 (max packet length)
   // TODO:  8: Done
   // TODO:
   // TODO: implement your state machine
   // TODO:
   // TODO: sequential part
   // TODO: always_ff @(posedge clk) begin 
   // TODO:     . . .
   // TODO: end
   // TODO:
   // TODO: always_comb begin
   // TODO:     . . .
   // TODO: end
endmodule // seqsm
