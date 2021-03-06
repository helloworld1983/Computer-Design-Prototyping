/*
Register File Code for Lab 1
Vaibhav Ramachandran
Email: ramachav@purdue.edu
*/
`include "register_file_if.vh"
//import register_file_if::*;
module register_file
(
	input logic clk, n_rst,
	register_file_if.rf rfif
);

logic [31:0][31:0] register_array;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst) begin
		register_array <= '{default:'0};
	end
	else begin
		if(rfif.WEN && rfif.wsel != '0) begin
			register_array[rfif.wsel] <= rfif.wdat;
		end
	end
end

assign rfif.rdat1 = register_array[rfif.rsel1];
assign rfif.rdat2 = register_array[rfif.rsel2];

endmodule
