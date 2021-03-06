/*
Vaibhav Ramachandran
Direct-Mapped Instruction Cache Block Testbench
ramachav@purdue.edu
Section 3
*/

`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"
`include "caches_if.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module icache_tb();

	datapath_cache_if tbdcif();
	caches_if tbcif();
	logic CLK = 0, nRST;
	parameter PERIOD = 10;

	always #(PERIOD/2) CLK++;

	test PROG(CLK, nRST, tbdcif, tbcif);

	`ifndef MAPPED
	icache DUT(CLK, nRST, tbdcif, tbcif);
	`else
	icache DUT(
	.\CLK(CLK),
	.\nRST(nRST),
	.\tbdcif.imemREN(tbdcif.imemREN),
	.\tbdcif.imemaddr(tbdcif.imemaddr),
	.\tbdcif.halt(tbdcif.halt),
	.\tbdcif.ihit(tbdcif.ihit),
	.\tbdcif.imemload(tbdcif.imemload),
	.\tbcif.iwait(tbcif.iwait),
	.\tbcif.iload(tbcif.iload),
	.\tbcif.iREN(tbcif.iREN),
	.\tbcif.iaddr(tbcif.iaddr)
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

initial begin

	//Test case 0: Reset everything
	nRST = 0;
	@(posedge CLK)
	@(posedge CLK)
	nRST = 1;

	tbdcif.imemREN = 0;
	tbdcif.halt = 0;
	tbdcif.imemaddr = '0;
	tbcif.iwait = 1;
	tbcif.iload = '0;

	$display("Instruction Cache Block Test Cases:");

	//Test case 1: Check if cache miss is correctly detected upon reset (Assert imemREN and de-assert halt and iwait)
	test_number = 1;
	@(posedge CLK)
	tbdcif.imemREN = 1;
	tbdcif.halt = 0;
	tbdcif.imemaddr = 32'hFEEDBEEF;
	tbcif.iwait = 1;
	tbcif.iload = 32'hBAD0CAFE;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(!tbdcif.ihit && tbdcif.imemload == 32'hBAD0CAFE && tbcif.iREN && tbcif.iaddr == 32'hFEEDBEEF)
	$display("Test case 1 passed.");
	else $display("Test case 1 failed.");

	//Test case 2: Make sure that nothing happens when halt is asserted
	test_number++;
	@(posedge CLK)
	tbdcif.imemREN = 1;
	tbdcif.halt = 1;
	tbdcif.imemaddr = 32'hAABBCCDD;
	tbcif.iwait = 1;
	tbcif.iload = 32'hBABADADA;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(!tbdcif.ihit && tbdcif.imemload == '0 && !tbcif.iREN && tbcif.iaddr == '0)
	$display("Test case 2 passed.");
	else $display("Test case 2 failed.");

	//Test case 3: Load a word into the cache and then check if the cache gets a hit when the tag matches
	@(posedge CLK)
	test_number++;
	@(posedge CLK)
	tbdcif.imemaddr = 32'h12340000;
	tbcif.iwait = 0;
	tbcif.iload = 32'hFACEBEAD;
	@(posedge CLK)
	tbdcif.imemREN = 1;
	tbdcif.halt = 0;
	tbdcif.imemaddr = 32'h12340000;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbdcif.ihit && tbdcif.imemload == 32'hFACEBEAD && !tbcif.iREN && tbcif.iaddr == '0)
	$display("Test case 3 passed.");
	else $display("Test case 3 failed.");

	//Test case 4: Load a new word into the same cache block but change the incoming address so that the tag won't match anymore
	@(posedge CLK)
	test_number++;
	@(posedge CLK)
	tbdcif.imemREN = 0;
	tbdcif.halt = 0;
	tbdcif.imemaddr = 32'h12340000;
	tbcif.iwait = 0;
	tbcif.iload = 32'h00001111;
	@(posedge CLK)
	tbdcif.imemREN = 1;
	tbdcif.halt = 0;
	tbcif.iwait = 1;
	tbdcif.imemaddr = 32'h02120203;
	tbcif.iload = 32'h23972122;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(!tbdcif.ihit && tbdcif.imemload == 32'h23972122 && tbcif.iREN && tbcif.iaddr == 32'h02120203)
	$display("Test case 4 passed.");
	else $display("Test case 4 failed.");

	//Test case 5: Change the incoming address to the block that was just overwritten and make sure you get a hit
	@(posedge CLK)
	test_number++;
	@(posedge CLK)
	tbdcif.imemaddr = 32'h12340000;
	tbcif.iwait = 1;
	tbcif.iload = '0;
	tbdcif.imemREN = 1;
	tbdcif.halt = 0;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbdcif.ihit && tbdcif.imemload == 32'h00001111 && !tbcif.iREN && tbcif.iaddr == '0)
	$display("Test case 5 passed.");
	else $display("Test case 5 failed.");

	#CHECK_DELAY
	#CHECK_DELAY

$finish;

end
endprogram
