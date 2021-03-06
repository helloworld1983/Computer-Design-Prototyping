/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/
/*
Vaibhav Ramachandran
Cache Controller Block that implements Coherence Protocol
Section 3
ramachav@purdue.edu
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;
/*
This entire section is not needed anymore since a new coherence protocol needs to be implemented for the two processor core's caches.

assign ccif.iload = ccif.ramload;
assign ccif.dload = ccif.ramload;

//when (dWEN | dREN), iwait = 1 and dwait = 0 (data is given higher priority as
//compared to the instruction, second stage of a load instruction) else dwait is
//1
assign ccif.dwait = ~((ccif.ramstate == ACCESS) & (ccif.dREN | ccif.dWEN));
//when !dWEN & !dREN & iREN, iwait = 0 and dwait = 1 (here there is no data
//fetch that needs to occur so the instruction is executed) else iwait is 1
assign ccif.iwait = ~((ccif.ramstate == ACCESS) & (~ccif.dREN & ~ccif.dWEN & ccif.iREN));
//ramWEN is simply a passthrough since there is no other WEN. writing is given
//higher precedence over reading if both are asserted simultaneously
assign ccif.ramWEN = ccif.dWEN;
//ramREN = 1 when the dWEN signal is 0 and when either one of the two REN
//signals are asserted, done to prevent both writing and reading simultaneously
assign ccif.ramREN = (ccif.dREN | ccif.iREN) & ~ccif.dWEN;
assign ccif.ramstore = ccif.dstore;
//ramaddr equals daddr or iaddr depending on the value of the RENs and WEN so
//that it accesses the right address location
assign ccif.ramaddr = (~ccif.dREN & ~ccif.dWEN & ccif.iREN)? ccif.iaddr : ccif.daddr;
*/

//LOAD_FROM_MEM, WRITE_TO_MEM and KEEP_COHERENCE need 2 states since each block has 2 words in it
//KEEP_COHERENCE takes care of the case where you would get a dirty snoop hit, i.e., the block that was a hit was modified and needs to update memory in addition to supplying the snooping cache with the block
typedef enum logic [3:0] {IDLE, FETCH_INSTRUCTION, SET_CACHE_ROLES, SNOOP_INTO_CACHE, WRITE_TO_MEM1, WRITE_TO_MEM2, LOAD_FROM_MEM1, LOAD_FROM_MEM2, KEEP_COHERENCE1, KEEP_COHERENCE2} memory_bus_controller;
memory_bus_controller bus_state, bus_nextstate;

//snooper is the cache that is initiating the bus transaction, i.e., it is telling the bus to snoop into the other cache
//snooped is the cache that is getting snooped into by the bus transaction initiated by the other cache
logic snooper, snooped, nextstate_snooper, nextstate_snooped;

//Alternates the icache instruction fetch commands
logic icache_turn, nextstate_icache_turn;

always_ff @ (posedge CLK, negedge nRST) begin
	if(~nRST) begin
		bus_state <= IDLE;
		snooper <= 1;
		snooped <= 0;
		icache_turn <= 1;
	end
	else begin
		bus_state <= bus_nextstate;
		snooper <= nextstate_snooper;
		snooped <= nextstate_snooped;
		icache_turn <= nextstate_icache_turn;
	end
end

assign ccif.ccinv = {ccif.ccwrite[0],ccif.ccwrite[1]};

always_comb begin
	bus_nextstate = bus_state;
	nextstate_snooper = snooper;
	nextstate_snooped = snooped;
	nextstate_icache_turn = icache_turn;
	
	ccif.iwait = 2'b11;
	ccif.dwait = 2'b11;
	ccif.iload = 2'b00;
	ccif.dload = 2'b00;
	
	ccif.ccwait = 2'b00;
	ccif.ccsnoopaddr = '{default:'0};

	ccif.ramaddr = '0;
	ccif.ramstore = '0;
	ccif.ramREN = 0;
	ccif.ramWEN = 0;

	case(bus_state)
		IDLE: begin
			if(ccif.cctrans != 2'b00)
				bus_nextstate = SET_CACHE_ROLES;
			else if(ccif.dWEN != 2'b00)
				bus_nextstate = WRITE_TO_MEM1;
			else if(ccif.iREN != 2'b00)
				bus_nextstate = FETCH_INSTRUCTION;
			else 
				bus_nextstate = IDLE;
		end
		FETCH_INSTRUCTION: begin
			if(ccif.ramstate == ACCESS) begin
				nextstate_icache_turn = ~icache_turn;
				if(ccif.cctrans != 2'b00)
					bus_nextstate = SET_CACHE_ROLES;
				else
					bus_nextstate = IDLE;
			end
			if(ccif.dWEN != 2'b00)
				bus_nextstate = WRITE_TO_MEM1;

			if(ccif.iREN[icache_turn]) begin
				ccif.ramaddr = ccif.iaddr[icache_turn];
				ccif.ramREN = ccif.iREN[icache_turn];
				ccif.iload[icache_turn] = ccif.ramload;
				ccif.iwait[icache_turn] = (ccif.ramstate != ACCESS);
			end
			else if(ccif.iREN[~icache_turn]) begin
				ccif.ramaddr = ccif.iaddr[~icache_turn];
				ccif.ramREN = ccif.iREN[~icache_turn];
				ccif.iload[~icache_turn] = ccif.ramload;
				ccif.iwait[~icache_turn] = (ccif.ramstate != ACCESS);
			end
		end
		SET_CACHE_ROLES: begin
			if(ccif.dREN != 2'b00) begin
				bus_nextstate = SNOOP_INTO_CACHE;
				if(ccif.dREN[0]) begin
					nextstate_snooper = 0;
					nextstate_snooped = 1;
				end
				else if(ccif.dREN[1]) begin
					nextstate_snooper = 1;
					nextstate_snooped = 0;
				end
			end
			else
				bus_nextstate = IDLE;

			ccif.ccwait[nextstate_snooped] = 1;
			ccif.ccsnoopaddr[nextstate_snooped] = ccif.daddr[nextstate_snooper];
		end
		SNOOP_INTO_CACHE: begin
			if(ccif.cctrans[snooped]) begin
				if(ccif.ccwrite[snooped])
					bus_nextstate = KEEP_COHERENCE1;
			end
			else 
				bus_nextstate = LOAD_FROM_MEM1;

			ccif.ccwait[snooped] = 1;
			ccif.ccsnoopaddr[snooped] = ccif.daddr[snooper];
		end
		KEEP_COHERENCE1: begin
			if(ccif.ramstate == ACCESS)
				bus_nextstate = KEEP_COHERENCE2;

			ccif.ccwait[snooped] = 1;
			ccif.ccsnoopaddr[snooped] = ccif.daddr[snooper];
			ccif.dload[snooper] = ccif.dstore[snooped];
			ccif.dwait[snooper] = (ccif.ramstate != ACCESS);
			ccif.dwait[snooped] = (ccif.ramstate != ACCESS);
			ccif.ramWEN = ccif.ccwrite[snooped];
			ccif.ramaddr = ccif.daddr[snooped];
			ccif.ramstore = ccif.dstore[snooped];
		end
		KEEP_COHERENCE2: begin
			if(ccif.ramstate == ACCESS)
				bus_nextstate = IDLE;

			ccif.ccwait[snooped] = 1;
			ccif.ccsnoopaddr[snooped] = ccif.daddr[snooper];
			ccif.dload[snooper] = ccif.dstore[snooped];
			ccif.dwait[snooper] = (ccif.ramstate != ACCESS);
			ccif.dwait[snooped] = (ccif.ramstate != ACCESS);
			ccif.ramWEN = ccif.ccwrite[snooped];
			ccif.ramaddr = ccif.daddr[snooped];
			ccif.ramstore = ccif.dstore[snooped];
		end
		LOAD_FROM_MEM1: begin
			if(ccif.ramstate == ACCESS)
				bus_nextstate = LOAD_FROM_MEM2;

			ccif.ccwait[snooped] = 1;
			ccif.dwait[snooper] = (ccif.ramstate != ACCESS);
			ccif.dload[snooper] = ccif.ramload;
			ccif.ramREN = ccif.dREN[snooper];
			ccif.ramaddr = ccif.daddr[snooper];
		end
		LOAD_FROM_MEM2: begin
			if(ccif.ramstate == ACCESS)
				bus_nextstate = IDLE;

			ccif.ccwait[snooped] = 1;
			ccif.dwait[snooper] = (ccif.ramstate != ACCESS);
			ccif.dload[snooper] = ccif.ramload;
			ccif.ramREN = ccif.dREN[snooper];
			ccif.ramaddr = ccif.daddr[snooper];
		end
		WRITE_TO_MEM1: begin
			if(ccif.ramstate == ACCESS)
				bus_nextstate = WRITE_TO_MEM2;

			if(ccif.dWEN[0]) begin
				ccif.ccwait[1] = 1;
				ccif.ramaddr = ccif.daddr[0];
				ccif.ramstore = ccif.dstore[0];
				ccif.ramWEN = ccif.dWEN[0];
				ccif.dwait[0] = (ccif.ramstate != ACCESS);
			end
			else if(ccif.dWEN[1]) begin
				ccif.ccwait[0] = 1;
				ccif.ramaddr = ccif.daddr[1];
				ccif.ramstore = ccif.dstore[1];
				ccif.ramWEN = ccif.dWEN[1];
				ccif.dwait[1] = (ccif.ramstate != ACCESS);
			end
		end
		WRITE_TO_MEM2: begin
			if(ccif.ramstate == ACCESS)
				bus_nextstate = IDLE;

			if(ccif.dWEN[0]) begin
				ccif.ccwait[1] = 1;
				ccif.ramaddr = ccif.daddr[0];
				ccif.ramstore = ccif.dstore[0];
				ccif.ramWEN = ccif.dWEN[0];
				ccif.dwait[0] = (ccif.ramstate != ACCESS);
			end
			else if(ccif.dWEN[1]) begin
				ccif.ccwait[0] = 1;
				ccif.ramaddr = ccif.daddr[1];
				ccif.ramstore = ccif.dstore[1];
				ccif.ramWEN = ccif.dWEN[1];
				ccif.dwait[1] = (ccif.ramstate != ACCESS);
			end
		end
	endcase
end	

endmodule
