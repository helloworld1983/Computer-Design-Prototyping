/*
Vaibhav Ramachandran
Pipeline Register File
ramachav@purdue.edu
Section 3
*/

`include "cpu_types_pkg.vh"
`include "IFID_if.vh"
`include "IDEX_if.vh"
`include "EXMEM_if.vh"
`include "MEMWB_if.vh"

module pipeline_register
(
	input CLK, nRST,
	IFID_if ifid,
	IDEX_if idex,
	EXMEM_if exmem,
	MEMWB_if memwb
);

import cpu_types_pkg::*;

//The Instruction Fetch/Instruction Decode Latch

always_ff @ (posedge CLK, negedge nRST) begin
	if(~nRST) begin
		ifid.imemload_id <= '0;
		ifid.pc_nextstate_id <= '0;
		ifid.imemaddr_id <= '0;
		ifid.branch_hit_id <= 0;
		ifid.branch_history_id <= '0;
		ifid.target_address_id <= '0;
	end
	else if(ifid.flush_ifid) begin
		ifid.imemload_id <= '0;
		ifid.pc_nextstate_id <= '0;
		ifid.imemaddr_id <= '0;
		ifid.branch_hit_id <= 0;
		ifid.branch_history_id <= '0;
		ifid.target_address_id <= '0;
	end
	else if(ifid.enable_ifid) begin
		ifid.imemload_id <= ifid.imemload_if;
		ifid.pc_nextstate_id <= ifid.pc_nextstate_if;
		ifid.imemaddr_id <= ifid.imemaddr_if;
		ifid.branch_hit_id <= ifid.branch_hit_if;
		ifid.branch_history_id <= ifid.branch_history_if;
		ifid.target_address_id <= ifid.target_address_if;
	end
	else begin
		ifid.imemload_id <= ifid.imemload_id;
		ifid.pc_nextstate_id <= ifid.pc_nextstate_id;
		ifid.imemaddr_id <= ifid.imemaddr_id;
		ifid.branch_hit_id <= ifid.branch_hit_id;
		ifid.branch_history_id <= ifid.branch_history_id;
		ifid.target_address_id <= ifid.target_address_id;
	end
end

//The Instruction Decode/Execute Latch

always_ff @ (posedge CLK, negedge nRST) begin
	if(~nRST) begin
		idex.jumpaddr_ex  <= '0;
		idex.pc_nextstate_ex <= '0;
		idex.imm16_ex <= '0;
		idex.rdat1_ex <= '0;
		idex.rdat2_ex <= '0;
		idex.ALUop_ex <= ALU_SLL;
		idex.ALUSrc_ex <= '0;
		idex.Rd_ex <= '0;
		idex.Rt_ex <= '0;
		idex.Rs_ex <= '0;
		idex.RegDst_ex <= '0;
		idex.RegWr_ex <= '0;
		idex.halt_ex <= 0;
		idex.lui_ex <= 0;
		idex.dREN_ex <= 0;
		idex.dWEN_ex <= 0;
		idex.jump_ex <= 0;
		idex.jr_ex <= 0;
		idex.jal_ex <= 0;
		idex.ExtOp_ex <= 0;
		idex.mem2reg_ex <= 0;
		idex.beq_ex <= 0;
		idex.bne_ex <= 0;
		idex.imemload_ex <= '0;
		idex.imemaddr_ex <= '0;
		idex.branch_hit_ex <= 0;
		idex.branch_history_ex <= '0;
		idex.target_address_ex <= '0;
	end
	else if(idex.flush_idex) begin
		idex.jumpaddr_ex  <= '0;
		idex.pc_nextstate_ex <= '0;
		idex.imm16_ex <= '0;
		idex.rdat1_ex <= '0;
		idex.rdat2_ex <= '0;
		idex.ALUop_ex <= ALU_SLL;
		idex.ALUSrc_ex <= '0;
		idex.Rd_ex <= '0;
		idex.Rt_ex <= '0;
		idex.Rs_ex <= '0;
		idex.RegDst_ex <= '0;
		idex.RegWr_ex <= '0;
		idex.halt_ex <= 0;
		idex.lui_ex <= 0;
		idex.dREN_ex <= 0;
		idex.dWEN_ex <= 0;
		idex.jump_ex <= 0;
		idex.jr_ex <= 0;
		idex.jal_ex <= 0;
		idex.ExtOp_ex <= 0;
		idex.mem2reg_ex <= 0;
		idex.beq_ex <= 0;
		idex.bne_ex <= 0;
		idex.imemload_ex <= '0;
		idex.imemaddr_ex <= '0;
		idex.branch_hit_ex <= 0;
		idex.branch_history_ex <= '0;
		idex.target_address_ex <= '0;
	end
	else if(idex.enable_idex) begin
		idex.jumpaddr_ex  <= idex.jumpaddr_id;
		idex.pc_nextstate_ex <= idex.pc_nextstate_id;
		idex.imm16_ex <= idex.imm16_id;
		idex.rdat1_ex <= idex.rdat1_id;
		idex.rdat2_ex <= idex.rdat2_id;
		idex.ALUop_ex <= idex.ALUop_id;
		idex.ALUSrc_ex <= idex.ALUSrc_id;
		idex.Rd_ex <= idex.Rd_id;
		idex.Rt_ex <= idex.Rt_id;
		idex.Rs_ex <= idex.Rs_id;
		idex.RegDst_ex <= idex.RegDst_id;
		idex.RegWr_ex <= idex.RegWr_id;
		idex.halt_ex <= idex.halt_id;
		idex.lui_ex <= idex.lui_id;
		idex.dREN_ex <= idex.dREN_id;
		idex.dWEN_ex <= idex.dWEN_id;
		idex.jump_ex <= idex.jump_id;
		idex.jr_ex <= idex.jr_id;
		idex.jal_ex <= idex.jal_id;
		idex.ExtOp_ex <= idex.ExtOp_id;
		idex.mem2reg_ex <= idex.mem2reg_id;
		idex.beq_ex <= idex.beq_id;
		idex.bne_ex <= idex.bne_id;
		idex.imemload_ex <= idex.imemload_id;
		idex.imemaddr_ex <= idex.imemaddr_id;
		idex.branch_hit_ex <= idex.branch_hit_id;
		idex.branch_history_ex <= idex.branch_history_id;
		idex.target_address_ex <= idex.target_address_id;
	end
	else begin
		idex.jumpaddr_ex  <= idex.jumpaddr_ex;
		idex.pc_nextstate_ex <= idex.pc_nextstate_ex;
		idex.imm16_ex <= idex.imm16_ex;
		idex.rdat1_ex <= idex.rdat1_ex;
		idex.rdat2_ex <= idex.rdat2_ex;
		idex.ALUop_ex <= idex.ALUop_ex;
		idex.ALUSrc_ex <= idex.ALUSrc_ex;
		idex.Rd_ex <= idex.Rd_ex;
		idex.Rt_ex <= idex.Rt_ex;
		idex.Rs_ex <= idex.Rs_ex;
		idex.RegDst_ex <= idex.RegDst_ex;
		idex.RegWr_ex <= idex.RegWr_ex;
		idex.halt_ex <= idex.halt_ex;
		idex.lui_ex <= idex.lui_ex;
		idex.dREN_ex <= idex.dREN_ex;
		idex.dWEN_ex <= idex.dWEN_ex;
		idex.jump_ex <= idex.jump_ex;
		idex.jr_ex <= idex.jr_ex;
		idex.jal_ex <= idex.jal_ex;
		idex.ExtOp_ex <= idex.ExtOp_ex;
		idex.mem2reg_ex <= idex.mem2reg_ex;
		idex.beq_ex <= idex.beq_ex;
		idex.bne_ex <= idex.bne_ex;
		idex.imemload_ex <= idex.imemload_ex;
		idex.imemaddr_ex <= idex.imemaddr_ex;
		idex.branch_hit_ex <= idex.branch_hit_ex;
		idex.branch_history_ex <= idex.branch_history_ex;
		idex.target_address_ex <= idex.target_address_ex;
	end
end 

//The Execute/Memory Latch

always_ff @ (posedge CLK, negedge nRST) begin
	if(~nRST) begin
		exmem.beq_mem <= 0;
		exmem.bne_mem <= 0;
		exmem.zero_mem <= 0;
		exmem.lduse_hit_mem <= 0;
		exmem.imm16_mem <= '0;
		exmem.jal_mem <= 0;
		exmem.mem2reg_mem <= 0;
		exmem.halt_mem <= 0;
		exmem.lui_mem <= 0;
		exmem.dmemren <= 0;
		exmem.dmemwen <= 0;
		exmem.RegWr_mem <= 0;
		exmem.RegDst_mem <= '0;
		exmem.pc_nextstate_mem <= '0;
		exmem.wdat_mem <= '0;
		exmem.dmemstore <= '0;
		exmem.imemload_mem <= '0;
		exmem.imemaddr_mem <= '0;
		exmem.branch_hit_mem <= 0;
		exmem.branch_history_mem <= '0;
		exmem.target_address_mem <= '0;
	end
	else if(exmem.flush_exmem || exmem.dhit) begin
		exmem.beq_mem <= 0;
		exmem.bne_mem <= 0;
		exmem.zero_mem <= 0;
		exmem.lduse_hit_mem <= 0;
		exmem.imm16_mem <= '0;
		exmem.jal_mem <= 0;
		exmem.mem2reg_mem <= 0;
		exmem.halt_mem <= 0;
		exmem.lui_mem <= 0;
		exmem.dmemren <= 0;
		exmem.dmemwen <= 0;
		exmem.RegWr_mem <= 0;
		exmem.RegDst_mem <= '0;
		exmem.pc_nextstate_mem <= '0;
		exmem.wdat_mem <= '0;
		exmem.dmemstore <= '0;
		exmem.imemload_mem <= '0;
		exmem.imemaddr_mem <= '0;
		exmem.branch_hit_mem <= 0;
		exmem.branch_history_mem <= '0;
		exmem.target_address_mem <= '0;
	end
	else if(exmem.enable_exmem) begin
		exmem.beq_mem <= exmem.beq_ex;
		exmem.bne_mem <= exmem.bne_ex;
		exmem.zero_mem <= exmem.zero_ex;
		exmem.lduse_hit_mem <= exmem.lduse_hit_ex;
		exmem.imm16_mem <= exmem.imm16_ex;
		exmem.jal_mem <= exmem.jal_ex;
		exmem.mem2reg_mem <= exmem.mem2reg_ex;
		exmem.halt_mem <= exmem.halt_ex;
		exmem.lui_mem <= exmem.lui_ex;
		exmem.dmemren <= exmem.dREN_ex;
		exmem.dmemwen <= exmem.dWEN_ex;
		exmem.RegWr_mem <= exmem.RegWr_ex;
		exmem.RegDst_mem <= exmem.RegDst_ex;
		exmem.pc_nextstate_mem <= exmem.pc_nextstate_ex;
		exmem.wdat_mem <= exmem.wdat_ex;
		exmem.dmemstore <= exmem.rdat2_ex;
		exmem.imemload_mem <= exmem.imemload_ex;
		exmem.imemaddr_mem <= exmem.imemaddr_ex;
		exmem.branch_hit_mem <= exmem.branch_hit_ex;
		exmem.branch_history_mem <= exmem.branch_history_ex;
		exmem.target_address_mem <= exmem.target_address_ex;
	end
	else begin
		exmem.beq_mem <= exmem.beq_mem;
		exmem.bne_mem <= exmem.bne_mem;
		exmem.zero_mem <= exmem.zero_mem;
		exmem.lduse_hit_mem <= exmem.lduse_hit_mem;
		exmem.imm16_mem <= exmem.imm16_mem;
		exmem.jal_mem <= exmem.jal_mem;
		exmem.mem2reg_mem <= exmem.mem2reg_mem;
		exmem.halt_mem <= exmem.halt_mem;
		exmem.lui_mem <= exmem.lui_mem;
		exmem.dmemren <= exmem.dmemren;
		exmem.dmemwen <= exmem.dmemwen;
		exmem.RegWr_mem <= exmem.RegWr_mem;
		exmem.RegDst_mem <= exmem.RegDst_mem;
		exmem.pc_nextstate_mem <= exmem.pc_nextstate_mem;
		exmem.wdat_mem <= exmem.wdat_mem;
		exmem.dmemstore <= exmem.dmemstore;
		exmem.imemload_mem <= exmem.imemload_mem;
		exmem.imemaddr_mem <= exmem.imemaddr_mem;
		exmem.branch_hit_mem <= exmem.branch_hit_mem;
		exmem.branch_history_mem <= exmem.branch_history_mem;
		exmem.target_address_mem <= exmem.target_address_mem;
	end
end 

//The Memory/Write Back Latch

always_ff @ (posedge CLK, negedge nRST) begin
	if(~nRST) begin
		memwb.mem2reg_wb <= 0;
		memwb.jal_wb <= 0;
		memwb.lui_wb <= 0;
		memwb.RegWr_wb <= 0;
		memwb.RegDst_wb <= '0;
		memwb.wdat_wb <= '0;
		memwb.pc_nextstate_wb <= '0;
		memwb.imm16_wb <= '0;
		memwb.dmemload_wb <= '0;
		memwb.halt_wb <= 0;
		memwb.imemload_wb <= '0;
		memwb.imemaddr_wb <= '0;
	end
	else if(memwb.enable_memwb) begin
		memwb.mem2reg_wb <= memwb.mem2reg_mem;
		memwb.jal_wb <= memwb.jal_mem;
		memwb.lui_wb <= memwb.lui_mem;
		memwb.RegWr_wb <= memwb.RegWr_mem;
		memwb.RegDst_wb <= memwb.RegDst_mem;
		memwb.wdat_wb <= memwb.wdat_mem;
		memwb.pc_nextstate_wb <= memwb.pc_nextstate_mem;
		memwb.imm16_wb <= memwb.imm16_mem;
		memwb.dmemload_wb <= memwb.dmemload;
		memwb.halt_wb <= memwb.halt_mem;
		memwb.imemload_wb <= memwb.imemload_mem;
		memwb.imemaddr_wb <= memwb.imemaddr_mem;
	end
	else begin
		memwb.mem2reg_wb <= memwb.mem2reg_wb;
		memwb.jal_wb <= memwb.jal_wb;
		memwb.lui_wb <= memwb.lui_wb;
		memwb.RegWr_wb <= memwb.RegWr_wb;
		memwb.RegDst_wb <= memwb.RegDst_wb;
		memwb.wdat_wb <= memwb.wdat_wb;
		memwb.pc_nextstate_wb <= memwb.pc_nextstate_wb;
		memwb.imm16_wb <= memwb.imm16_wb;
		memwb.dmemload_wb <= memwb.dmemload_wb;
		memwb.halt_wb <= memwb.halt_wb;
		memwb.imemload_wb <= memwb.imemload_wb;
		memwb.imemaddr_wb <= memwb.imemaddr_wb;
	end
end 
endmodule 