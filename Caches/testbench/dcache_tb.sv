/*
Vaibhav Ramachandran
2-Way Set Associative Data Cache Block Testbench
ramachav@purdue.edu
Section 3
*/

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module dcache_tb();

	datapath_cache_if tbdcif();
	caches_if tbcif();
	logic CLK = 0, nRST;
	parameter PERIOD = 10;

	always #(PERIOD/2) CLK++;

	test PROG(CLK, nRST, tbdcif, tbcif);

	`ifndef MAPPED
	dcache DUT(CLK, nRST, tbdcif, tbcif);
	`else
	dcache DUT(
	.\CLK(CLK),
	.\nRST(nRST),
	.\tbdcif.dmemREN(tbdcif.dmemREN),
	.\tbdcif.dmemWEN(tbdcif.dmemWEN),
	.\tbdcif.dmemaddr(tbdcif.dmemaddr),
	.\tbdcif.halt(tbdcif.halt),
	.\tbdcif.dmemstore(tbdcif.dmemstore),
	.\tbdcif.datomic(tbdcif.datomic),
	.\tbdcif.dhit(tbdcif.dhit),
	.\tbdcif.dmemload(tbdcif.dmemload),
	.\tbdcif.flushed(tbdcif.flushed),
	.\tbcif.dwait(tbcif.dwait),
	.\tbcif.dload(tbcif.dload),
	.\tbcif.dREN(tbcif.dREN),
	.\tbcif.dWEN(tbcif.dWEN),
	.\tbcif.daddr(tbcif.daddr),
	.\tbcif.dstore(tbcif.dstore)
	);	
	`endif

endmodule 

program test
(
	input logic CLK,
	output logic nRST,
	datapath_cache_if tbdcif,
	caches_if tbcif
);

int test_number = 0;
parameter CHECK_DELAY = 5;
parameter HALT_DELAY = 300;

initial begin

	//Test case 0: Reset everything
	nRST = 0;
	@(posedge CLK)
	@(posedge CLK)
	nRST = 1;
	
	tbdcif.dmemREN = 0;
	tbdcif.dmemWEN = 0;
	tbdcif.halt = 0;
	tbdcif.datomic = 0;
	tbdcif.dmemstore = '0;
	tbdcif.dmemaddr = '0;
	tbcif.dwait = 1;
	tbcif.dload = '0;

	$display("Data Cache Block Test Cases:");

	//Test case 1: Cache miss on starting up after reset
	@(posedge CLK)
	test_number = 1;
	tbdcif.dmemREN = 1;
	tbdcif.dmemWEN = 0;
	tbdcif.halt = 0;
	tbdcif.datomic = 0;
	tbdcif.dmemstore = '0;
	tbdcif.dmemaddr = 32'h00001234;
	tbcif.dwait = 1;
	tbcif.dload = 32'hCABDDBAC;
	#CHECK_DELAY
	assert(!tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 1 passed.");
	else $display("Test case 1 failed.");
	
	//Test case 2: Check if the controller loads the next word even though memory hasn't said it's finished (dwait is 1)
	@(posedge CLK)
	test_number++;
	@(posedge CLK)
	@(posedge CLK)
	@(posedge CLK)
	assert(!tbdcif.dhit && tbcif.dREN && !tbcif.dWEN && tbcif.daddr == {tbdcif.dmemaddr[31:3],3'b000} && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 2 passed.");
	else $display("Test case 2 failed.");

	//Test case 3: Check if the controller loads the next word as soon as the memory says it's finished with the previous one (dwait is 0)
	@(posedge CLK)
	test_number++;
	tbcif.dwait = 0;
	tbcif.dload = 32'hBADCAFE0;
	#CHECK_DELAY	
	#CHECK_DELAY
	assert(!tbdcif.dhit && tbcif.dREN && !tbcif.dWEN && tbcif.daddr == {tbdcif.dmemaddr[31:3],3'b100} && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 3 passed.");
	else $display("Test case 3 failed.");
	
	//Test case 4: Check if the controller moves out of loading only when memory says it's finished (dwait is 0)
	tbcif.dwait = 1;	
	@(posedge CLK)
	test_number++;
	@(posedge CLK)
	@(posedge CLK)
	#CHECK_DELAY
	assert(!tbdcif.dhit && tbcif.dREN && !tbcif.dWEN && tbcif.daddr == {tbdcif.dmemaddr[31:3],3'b100} && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 4 passed.");
	else $display("Test case 4 failed.");
	
	//Test case 5: Check if the controller moves on to the IDLE state when the memory says it's finished (dwait is 0)
	@(posedge CLK)
	test_number++;
	tbcif.dwait = 0;
	tbcif.dload = 32'h01234537;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == 32'h01234537 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 5 passed.");
	else $display("Test case 5 failed.");

	//Test case 6: Check if you get a hit when trying to load the same word again (since now it's in the cache)
	@(posedge CLK)
	test_number++;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == 32'h01234537 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 6 passed.");
	else $display("Test case 6 failed.");

	//Test case 7: Check if anything happens when there is no request for any data (dmemREN and dmemWEN are 0)
	@(posedge CLK)
	test_number++;
	tbdcif.dmemREN = 0;
	tbdcif.dmemWEN = 0;
	#CHECK_DELAY
	assert(!tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 7 passed.");
	else $display("Test case 7 failed.");

	//Test case 8: Check if you get a hit when trying to load the other word present in the same cache block
	@(posedge CLK)
	test_number++;
	tbdcif.dmemREN = 1;
	tbdcif.dmemaddr = 32'h00001230;
	tbcif.dload = 32'hBAD00BAD;
	tbcif.dwait = 0;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == 32'hBADCAFE0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 8 passed.");
	else $display("Test case 8 failed.");

	//Test case 9: Check if you get a hit when trying to WRITE to an address that's already in the cache
	@(posedge CLK)
	test_number++;
	tbdcif.dmemWEN = 1;
	tbdcif.dmemREN = 0;
	tbdcif.dmemaddr = 32'h00001234;
	tbdcif.dmemstore = 32'h22223333;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 9 passed.");
	else $display("Test case 9 failed.");

	//Test case 10: Check if you get the right data when trying to READ the newly updated word in the cache
	@(posedge CLK)
	test_number++;
	tbdcif.dmemWEN = 0;
	tbdcif.dmemREN = 1;
	tbdcif.dmemaddr = 32'h00001234;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == 32'h22223333 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 10 passed.");
	else $display("Test case 10 failed.");

	//Test case 11: Check if you get a cache miss when trying to WRITE to a block not in the cache yet (since the dirty bit isn't set it'll load from memory)
	@(posedge CLK)
	test_number++;
	tbdcif.dmemWEN = 1;
	tbdcif.dmemREN = 0;
	tbdcif.dmemaddr = 32'h0000124C;
	tbdcif.dmemstore = 32'h02120203;
	tbcif.dwait = 1;
	@(posedge CLK)
	assert(!tbdcif.dhit && tbcif.dREN && !tbcif.dWEN && tbcif.daddr == {tbdcif.dmemaddr[31:3],3'b000} && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 11 passed.");
	else $display("Test case 11 failed.");

	//Test case 12: Load the first block from memory
	@(posedge CLK)
	test_number++;
	tbcif.dload = 32'hFACEFACE;
	tbcif.dwait = 0;
	#CHECK_DELAY
	assert(!tbdcif.dhit && tbcif.dREN && !tbcif.dWEN && tbcif.daddr == {tbdcif.dmemaddr[31:3],3'b000} && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 12 passed.");
	else $display("Test case 12 failed.");

	//Test case 13: Load the second block from memory
	@(posedge CLK)
	test_number++;
	tbcif.dload = 32'hDEADBEEF;
	#CHECK_DELAY
	assert(!tbdcif.dhit && tbcif.dREN && !tbcif.dWEN && tbcif.daddr == {tbdcif.dmemaddr[31:3],3'b100} && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 13 passed.");
	else $display("Test case 13 failed.");

	//Test case 14: Go back to IDLE. dmemWEN is still asserted and now the block should be in the cache so should get a hit
	@(posedge CLK)
	test_number++;
	tbcif.dwait = 1;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 14 passed.");
	else $display("Test case 14 failed.");

	//Test case 15: Now try writing to the other word in the block. Since the block is in the cache, should get a hit
	@(posedge CLK)
	test_number++;
	tbdcif.dmemaddr = 32'h00001248;
	tbdcif.dmemstore = 32'h1BADC0DE;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 15 passed.");
	else $display("Test case 15 failed.");

	//Test case 16: Try a READ into the cache with a different tag, but the same index as a block that was previously written, so you get a cache miss
	@(posedge CLK)
	test_number++;
	tbdcif.dmemaddr = 32'h010112C8;
	tbcif.dload = 32'hC0DEFEED;
	tbdcif.dmemREN = 1;
	tbdcif.dmemWEN = 0;
	tbcif.dwait = 1;
	#CHECK_DELAY
	assert(!tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 16.1 passed.");
	else $display("Test case 16.1 failed.");
	@(posedge CLK)
	@(posedge CLK)
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	tbcif.dload = 32'hBEEFFACE;
	@(posedge CLK)
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	#CHECK_DELAY
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == 32'hC0DEFEED && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 16.2 passed.");
	else $display("Test case 16.2 failed.");

	//Test case 17: Try a READ again into the cache with a different tag, but with the same index as the row that is completely filled (should get a cache miss)
	@(posedge CLK)
	test_number++;
	tbdcif.dmemaddr = 32'h123412CC;
	tbcif.dload = 32'h98765432;
	tbdcif.dmemREN = 1;
	tbdcif.dmemWEN = 0;
	tbcif.dwait = 1;
	#CHECK_DELAY
	assert(!tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 17.1 passed.");
	else $display("Test case 17.1 failed.");
	@(posedge CLK)
	@(posedge CLK)
	//Writes first word to memory
	assert(!tbdcif.dhit && !tbcif.dREN && tbcif.dWEN && tbcif.daddr == 32'h00001248 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == 32'h1BADC0DE)
	$display("Test case 17.2 passed.");
	else $display("Test case 17.2 failed.");
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	@(posedge CLK)
	//Writes second word to memory
	assert(!tbdcif.dhit && !tbcif.dREN && tbcif.dWEN && tbcif.daddr == 32'h0000124C && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == 32'h02120203)
	$display("Test case 17.3 passed.");
	else $display("Test case 17.3 failed.");
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	@(posedge CLK)
	//Loads first word from memory into the block (dload = 98765432)
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	tbcif.dload = 32'hBAD0C0DE;
	@(posedge CLK)
	//Loads second word from memory into the block (dload = BAD0C0DE)
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	#CHECK_DELAY
	//IDLE state
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == 32'hBAD0C0DE && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 17.4 passed.");
	else $display("Test case 17.4 failed.");

	//Test case 18: Try a WRITE again into the cache with a different tag, but with the same index as the row that is completely filled (should get a cache miss)
	@(posedge CLK)
	test_number++;
	tbdcif.dmemaddr = 32'h432112CC;
	tbdcif.dmemstore = 32'h89ABCDEF;
	tbcif.dload = 32'h00000001;
	tbdcif.dmemREN = 0;
	tbdcif.dmemWEN = 1;
	tbcif.dwait = 1;
	#CHECK_DELAY
	assert(!tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 18.1 passed.");
	else $display("Test case 18.1 failed.");
	@(posedge CLK)
	@(posedge CLK)
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	@(posedge CLK)
	//Loads first word from memory into the block (dload = 00000001)
	@(posedge CLK)
	tbcif.dwait = 0;
	tbcif.dload = 32'hC0DE0007;
	@(posedge CLK)
	tbcif.dwait = 1;
	
	@(posedge CLK)
	//Loads second word from memory into the block (dload = C0DE0007)
	@(posedge CLK)
	tbcif.dwait = 0;
	@(posedge CLK)
	tbcif.dwait = 1;
	#CHECK_DELAY
	//IDLE state
	assert(tbdcif.dhit && !tbcif.dREN && !tbcif.dWEN && tbcif.daddr == '0 && tbdcif.dmemload == '0 && !tbdcif.flushed && tbcif.dstore == '0)
	$display("Test case 18.2 passed.");
	else $display("Test case 18.2 failed.");

	//Test case 19: Assert halt and then check the design's behavior
	@(posedge CLK)
	test_number++;
	tbdcif.halt = 1;
	tbcif.dwait = 0;
	#HALT_DELAY
	#HALT_DELAY
	assert(tbdcif.flushed)
	$display("Test case 19 passed.");
	else $display("Test case 19 failed.");

	#CHECK_DELAY
	#CHECK_DELAY

$finish;

end
endprogram 