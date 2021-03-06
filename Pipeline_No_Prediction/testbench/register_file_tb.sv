/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;
  
  logic CLK = 0, nRST;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;
  
  
  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();
  // test program
  test PROG (CLK, nRST, rfif);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif

endmodule

program test
(
	input logic CLK,
	output logic nRST,
	register_file_if.tb tbif
);

parameter CHECK_DELAY = 5;
int test_number = 0;
int i;

initial begin
	//Test case 1: Reset everything and check the values.
	test_number = test_number + 1;
	nRST = 0;
	@(posedge CLK)
	nRST = 1;
	tbif.rsel1 = 5'd15;
	tbif.rsel2 = 5'd31;
	assert(!tbif.rdat1 && !tbif.rdat2)
	else $error("Test case %d failed.", test_number);
	
	//Test case 2: Test writing to register 0. Output should still be 0.
	@(posedge CLK)
	test_number = test_number + 1;
	nRST = 1;
	#1
	tbif.WEN = 1;
	tbif.wsel = 5'd0;
	tbif.wdat = 32'hdeadbeef;
	@(posedge CLK)
	tbif.rsel1 = 5'd0;
	tbif.rsel2 = 5'd0;
	assert(!tbif.rdat1 && !tbif.rdat2)
	else $error("Test case %d failed.", test_number);
	
	//Test case 3: Test writing to and reading from random registers.
	test_number = test_number + 1;
	nRST = 0;
	@(posedge CLK)
	nRST = 1;
	#1
	tbif.WEN = 1;
	tbif.wsel = 5'd10;
	tbif.wdat = 32'hbad00cab;
	#CHECK_DELAY
	tbif.rsel1 = 5'd10;
	assert(tbif.rdat1 == 32'hbad00cab)
	else $error("Test case %d failed.", test_number);
	#CHECK_DELAY
	tbif.WEN = 1;
	tbif.wsel = 5'd23;
	tbif.wdat = 32'hfacebead;
	#CHECK_DELAY
	tbif.rsel1 = 5'd23;
	tbif.rsel2 = 5'd10;
	assert((tbif.rdat2 == 32'hbad00cab) && (tbif.rdat1 == 32'hfacebead))
	else $error("Test case %d failed.", test_number);
	#CHECK_DELAY
	tbif.WEN = 1;
	tbif.wsel = 5'd19;
	tbif.wdat = 32'habcdef03;
	#CHECK_DELAY
	tbif.rsel1 = 5'd19;
	tbif.rsel2 = 5'd4;
	assert((tbif.rdat2 == 32'h0) && (tbif.rdat1 == 32'habcdef03))
	else $error("Test case %d failed.", test_number);

	//Test case 4: Test writing without turning on the WEN signal. Output should be 0 or the previous value.
	
	@(posedge CLK)
	test_number = test_number + 1;

	tbif.WEN = 0;
	tbif.wsel = 5'd23;
	tbif.wdat = 32'habcdef03;
	#CHECK_DELAY
	tbif.wsel = 5'd7;
	tbif.wdat = 32'h23972122;
	#CHECK_DELAY
	tbif.rsel1 = 5'd23;
	tbif.rsel2 = 5'd7;
	assert((tbif.rdat2 == 32'h0) && (tbif.rdat1 == 32'hfacebead))
		$display("rdat1 = %x", tbif.rdat1);
	else $error("Test case %d failed.", test_number);
	#CHECK_DELAY
	#CHECK_DELAY
$finish;
end
endprogram
