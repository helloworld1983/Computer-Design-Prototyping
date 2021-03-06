/*
Vaibhav Ramachandran
Control Unit
ramachav@purdue.edu
Section 3
*/
`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"

module control_unit
(
	control_unit_if cuif
);

import cpu_types_pkg::*;

always_comb begin
	cuif.beq = 0;
	cuif.bne = 0;
	cuif.RegWr = 0;
	cuif.ExtOp = 0;
	cuif.dREN = 0;
	cuif.dWEN = 0;
	cuif.jal = 0;
	cuif.jump = 0;
	cuif.mem2reg = 0;
	cuif.jr = 0;
	cuif.lui = 0;
	cuif.ALUSrc = '0;	//00: rdat2,	01: shamt,	10: Imm16
	cuif.RegDst = '0;	//00: Rt,	01: Rd,		10: $31
	cuif.ALUop = ALU_SLL;
	cuif.halt = 0;
	cuif.datomic = 0;

	casez(cuif.Instruct)
		//R-Type instructions//
		RTYPE: begin
			cuif.RegDst = 2'b01;
			cuif.ALUSrc = 2'b00;
      			cuif.RegWr = 1;

			casez(cuif.funct)
				SLL: begin
					cuif.ALUSrc = 2'b01;
					cuif.ALUop = ALU_SLL;
				end
				SRL: begin
					cuif.ALUSrc = 2'b01;
					cuif.ALUop = ALU_SRL;
				end
				JR: begin
					cuif.jr = 1;
					cuif.RegWr = 0;
				end
				ADD:  cuif.ALUop = ALU_ADD;

				ADDU: cuif.ALUop = ALU_ADD;

				SUB:  cuif.ALUop = ALU_SUB;

				SUBU: cuif.ALUop = ALU_SUB;

				AND:  cuif.ALUop = ALU_AND;

				OR:   cuif.ALUop = ALU_OR;

				XOR:  cuif.ALUop = ALU_XOR;

				NOR:  cuif.ALUop = ALU_NOR;

				SLT:  cuif.ALUop = ALU_SLT;

				SLTU: cuif.ALUop = ALU_SLTU;

			endcase
		end
		//J-Type instructions//
		J: 	cuif.jump = 1;

		JAL: begin
			cuif.jump = 1;
			cuif.jal = 1;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b10;
		end
		//I-Type instructions//
		BEQ: begin
			cuif.ALUop = ALU_SUB;
			cuif.beq = 1;
		end
		BNE: begin
			cuif.ALUop = ALU_SUB;
			cuif.bne = 1;
		end
		ADDI: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_ADD;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		ADDIU: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_ADD;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		SLTI: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_SLT;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		SLTIU: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_SLTU;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		ANDI: begin
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_AND;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		ORI: begin
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_OR;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		XORI: begin
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_XOR;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		LUI: begin
			cuif.lui = 1;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
		end
		LW: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_ADD;
			cuif.mem2reg = 1;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
			cuif.dREN = 1;
		end
		SW: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_ADD;
			cuif.dWEN = 1;
		end
		LL: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_ADD;
			cuif.mem2reg = 1;
			cuif.RegWr = 1;
			cuif.RegDst = 2'b00;
			cuif.dREN = 1;
			cuif.datomic = 1;
		end
		SC: begin
			cuif.ExtOp = 1;
			cuif.ALUSrc = 2'b10;
			cuif.ALUop = ALU_ADD;
			cuif.dWEN = 1;
			cuif.datomic = 1;
			cuif.RegDst = 2'b00;
			cuif.RegWr = 1;
			cuif.mem2reg = 1;
		end			
		HALT: 	cuif.halt = 1;

	endcase
end

//assign cuif.halt = (cuif.Instruct == HALT);
assign cuif.iREN = 1;//(cuif.Instruct != HALT);

endmodule
