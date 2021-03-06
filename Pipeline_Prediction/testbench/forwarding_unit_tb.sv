/*
Vaibhav Ramachandran
Forwarding Unit Testbench
Section 3
ramachav@purdue.edu
*/

`include "cpu_types_pkg.vh"
`include "forwarding_unit_if.vh"
`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module forwarding_unit_tb();

	forwarding_unit_if tbfuif();
	logic CLK = 0, nRST;
	parameter PERIOD = 10;

	always #(PERIOD/2) CLK++;

	test PROG (CLK, nRST, tbfuif);

	`ifndef MAPPED
	forwarding_unit DUT(tbfuif);
	`else
	forwarding_unit DUT(
	.\tbfuif.RegWr_wb (tbfuif.RegWr_wb),
	.\tbfuif.RegWr_mem (tbfuif.RegWr_mem),
	.\tbfuif.RegDst_wb (tbfuif.RegDst_wb),
	.\tbfuif.RegDst_mem (tbfuif.RegDst_mem),
	.\tbfuif.Rs_ex (tbfuif.Rs_ex),
	.\tbfuif.Rt_ex (tbfuif.Rt_ex),
	.\tbfuif.forward_A (tbfuif.forward_A),
	.\tbfuif.forward_B (tbfuif.forward_B)
	);
	`endif

endmodule

program test
(
	input logic CLK,
	output logic nRST,
	forwarding_unit_if tbfuif
);

int test_number = 0;
parameter CHECK_DELAY = 5;

initial begin

	//Test case 0: Reset everything
	nRST = 0;
	@(posedge CLK)
	@(posedge CLK)
	nRST = 1;

	tbfuif.RegWr_wb = 0;
	tbfuif.RegWr_mem = 0;
	tbfuif.RegDst_wb = '0;
	tbfuif.RegDst_mem = '0;
	tbfuif.Rs_ex = '0;
	tbfuif.Rt_ex = '0;

	$display("Forwarding Unit Test Cases:");

	//Test case 1: Check forwarding into the ALU's second input from the MEM stage
	test_number = 1;
	@(posedge CLK)
	tbfuif.RegWr_wb = 0;
	tbfuif.RegWr_mem = 1;
	tbfuif.RegDst_wb = '0;
	tbfuif.RegDst_mem = 5'd20;
	tbfuif.Rs_ex = '0;
	tbfuif.Rt_ex = 5'd20;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b00 && tbfuif.forward_B == 2'b10)
	$display("Test case 1 passed.");
	else $display("Test case 1 failed.");

	//Test case 2: Check forwarding into the ALU's first input from the MEM stage
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_wb = 0;
	tbfuif.RegWr_mem = 1;
	tbfuif.RegDst_wb = '0;
	tbfuif.RegDst_mem = 5'd12;
	tbfuif.Rs_ex = 5'd12;
	tbfuif.Rt_ex = '0;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b10 && tbfuif.forward_B == 2'b00)
	$display("Test case 2 passed.");
	else $display("Test case 2 failed.");

	//Test case 3: Check forwarding into the ALU's second input from the WB stage
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_wb = 1;
	tbfuif.RegWr_mem = 0;
	tbfuif.RegDst_wb = 5'd29;
	tbfuif.RegDst_mem = '0;
	tbfuif.Rs_ex = '0;
	tbfuif.Rt_ex = 5'd29;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b00 && tbfuif.forward_B == 2'b01)
	$display("Test case 3 passed.");
	else $display("Test case 3 failed.");

	//Test case 4: Check forwarding into the ALU's first input from the WB stage
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_wb = 1;
	tbfuif.RegWr_mem = 0;
	tbfuif.RegDst_wb = 5'd7;
	tbfuif.RegDst_mem = '0;
	tbfuif.Rs_ex = 5'd7;
	tbfuif.Rt_ex = '0;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b01 && tbfuif.forward_B == 2'b00)
	$display("Test case 4 passed.");
	else $display("Test case 4 failed.");

	//Test case 5: Check forwarding into the ALU's second input when both the MEM and the WB destination registers match
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_wb = 1;
	tbfuif.RegWr_mem = 1;
	tbfuif.RegDst_wb = 5'd11;
	tbfuif.RegDst_mem = 5'd11;
	tbfuif.Rs_ex = '0;
	tbfuif.Rt_ex = 5'd11;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b00 && tbfuif.forward_B == 2'b10)
	$display("Test case 5 passed.");
	else $display("Test case 5 failed.");

	//Test case 6: Check forwarding into the ALU's first input when both the MEM and the WB destination registers match
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_wb = 1;
	tbfuif.RegWr_mem = 1;
	tbfuif.RegDst_wb = 5'd2;
	tbfuif.RegDst_mem = 5'd2;
	tbfuif.Rs_ex = 5'd2;
	tbfuif.Rt_ex = '0;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b10 && tbfuif.forward_B == 2'b00)
	$display("Test case 6 passed.");
	else $display("Test case 6 failed.");

	//Test case 7: Check forwarding into the ALU's first input from the MEM stage and into the ALU's second input from the WB stage
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_mem = 1;
	tbfuif.RegWr_wb = 1;
	tbfuif.RegDst_mem = 5'd15;
	tbfuif.RegDst_wb = 5'd23;
	tbfuif.Rs_ex = 5'd15;
	tbfuif.Rt_ex = 5'd23;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b10 && tbfuif.forward_B == 2'b01)
	$display("Test case 7 passed.");
	else $display("Test case 7 failed.");

	//Test case 8: Check forwarding into the ALU's first input from the WB stage and into the ALU's second input from the MEM stage
	test_number++;
	@(posedge CLK)
	tbfuif.RegWr_mem = 1;
	tbfuif.RegWr_wb = 1;
	tbfuif.RegDst_mem = 5'd10;
	tbfuif.RegDst_wb = 5'd1;
	tbfuif.Rs_ex = 5'd1;
	tbfuif.Rt_ex = 5'd10;
	#CHECK_DELAY
	#CHECK_DELAY
	assert(tbfuif.forward_A == 2'b01 && tbfuif.forward_B == 2'b10)
	$display("Test case 8 passed.");
	else $display("Test case 8 failed.");

	#CHECK_DELAY
	#CHECK_DELAY

$finish;

end
endprogram
