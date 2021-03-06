/*
Vaibhav Ramachandran
Request Unit
ramachav@purdue.edu
Section 3
*/
`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

module request_unit
(
	input logic CLK, nRST,
	request_unit_if ruif
);

import cpu_types_pkg::*;

assign ruif.imemren = 1;//~ruif.halt;

always_ff @(posedge CLK, negedge nRST) begin
	if(~nRST) begin
		ruif.dmemren <= 0;
		ruif.dmemwen <= 0;
	end
	else if(ruif.dhit) begin
		ruif.dmemren <= 0;
		ruif.dmemwen <= 0;
	end
	else if(ruif.ihit) begin
		ruif.dmemren <= ruif.dREN;
		ruif.dmemwen <= ruif.dWEN;
	end
	else begin
		ruif.dmemren <= ruif.dmemren;
		ruif.dmemwen <= ruif.dmemwen;
	end
end

endmodule
