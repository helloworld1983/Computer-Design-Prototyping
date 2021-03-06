/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/
/*
Vaibhav Ramachandran
Datapath Unit
ramachav@purdue.edu
Section 3
*/

// data path interface
`include "datapath_cache_if.vh"
//control unit interface
`include "control_unit_if.vh"
//request unit interface
`include "request_unit_if.vh"
//alu interface
`include "alu_if.vh"
//register file interface
`include "register_file_if.vh"
// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"

module datapath
(
  	input logic CLK, nRST,
  	datapath_cache_if.dp dpif
);
// import types
import cpu_types_pkg::*;

// pc init
parameter PC_INIT = 0;

//instantiating the interfaces
control_unit_if cuif();
request_unit_if ruif();
alu_if aluif();
register_file_if rfif();

//wrappers for the different components
control_unit CONTROL_UNIT (cuif);
request_unit REQUEST_UNIT (CLK, nRST, ruif);
alu ALU (aluif);
register_file REGISTER_FILE (CLK, nRST, rfif);

//variables used within the datapath
logic [25:0] jump_addr;
logic [15:0] branch_addr, imm16;
logic [4:0] shamt;
word_t imm16_SignExtend;

//registers used for the PC block
word_t pc_input, pc_output, pc_nextstate;
logic pc_wen;

//Datapath signals
assign jump_addr = dpif.imemload[25:0];
assign branch_addr = dpif.imemload[15:0];
//assign dpif.halt = cuif.halt;
assign dpif.imemREN = ruif.imemren;
assign dpif.imemaddr = pc_output;
assign dpif.dmemREN = ruif.dmemren;
assign dpif.dmemWEN = ruif.dmemwen;
assign dpif.dmemstore = rfif.rdat2;
assign dpif.dmemaddr = aluif.output_port;
//assign dpif.datomic = ;

always_ff @(posedge CLK, negedge nRST) begin
	if(~nRST)
		dpif.halt <= 0;
	else
		dpif.halt <= cuif.halt;
end

//PC signals
assign pc_wen = dpif.ihit;
assign pc_nextstate = pc_output + WBYTES;

//PC input combinational logic block
always_comb begin
	pc_input = pc_nextstate;
	if(cuif.PCSrc)
		pc_input = pc_nextstate + { {14{branch_addr[15]}}, branch_addr, 2'b00 };
	else if(cuif.jump)
		pc_input = {pc_nextstate[31:28], jump_addr, 2'b00};
	else if(cuif.jr)
		pc_input = rfif.rdat1;
end

//PC block
always_ff @(posedge CLK, negedge nRST) begin
	if(~nRST)
		pc_output <= '0;
	else if(pc_wen)
		pc_output <= pc_input;
	else
		pc_output <= pc_output;
end

//Control Unit signals
assign cuif.Instruct = opcode_t'(dpif.imemload[31:26]);
assign cuif.funct = funct_t'(dpif.imemload[5:0]);
assign cuif.zero = aluif.zero;
assign cuif.overflow = aluif.overflow;

//Request Unit signals
assign ruif.halt = cuif.halt;
assign ruif.iREN = cuif.iREN;
assign ruif.dREN = cuif.dREN;
assign ruif.dWEN = cuif.dWEN;
assign ruif.ihit = dpif.ihit;
assign ruif.dhit = dpif.dhit;

//Regsiter File signals
assign rfif.rsel1 = dpif.imemload[25:21];
assign rfif.rsel2 = dpif.imemload[20:16];
assign rfif.wsel = (cuif.RegDst == 2'b00)? dpif.imemload[20:16] : ((cuif.RegDst == 2'b01)? dpif.imemload[15:11] : 5'b11111);
assign rfif.WEN = (cuif.Instruct == LW)? (dpif.dhit & cuif.RegWr) : (dpif.ihit & cuif.RegWr);

//Register File input data combinational block
always_comb begin
	rfif.wdat = aluif.output_port;
	if(cuif.mem2reg)
		rfif.wdat = dpif.dmemload;
	else if(cuif.jal)
		rfif.wdat = pc_nextstate;
	else if(cuif.lui)
		rfif.wdat = {imm16, 16'b0};
end

//ALU signals
assign shamt = dpif.imemload[10:6];
assign imm16 = dpif.imemload[15:0];
assign aluif.port_A = rfif.rdat1;
assign aluif.ALUOP = cuif.ALUop;

//ALU Port B combinational block
always_comb begin
	aluif.port_B = rfif.rdat2;
	if(cuif.ALUSrc == 2'b01)
		aluif.port_B = {27'b0, shamt};
	else if(cuif.ALUSrc == 2'b10)
		aluif.port_B = ((cuif.ExtOp == 1)? { {16{imm16[15]}}, imm16 } : {16'b0, imm16});
end

endmodule
