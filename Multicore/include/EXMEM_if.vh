/*
Vaibhav Ramachandran
Execute/Memory Pipeline Register Interface
ramachav@purdue.edu
Section 3
*/

`ifndef EXMEM_IF_VH
`define EXMEM_IF_VH

`include "cpu_types_pkg.vh"

interface EXMEM_if;

import cpu_types_pkg::*;

logic enable_exmem, dhit;
logic flush_exmem;
logic zero_ex, zero_mem, beq_ex, beq_mem, bne_ex, bne_mem, jr_ex, jal_ex, jal_mem, jump_ex, mem2reg_ex, mem2reg_mem, halt_ex, halt_mem, lduse_hit_ex, lduse_hit_mem;
logic lui_ex, lui_mem, dREN_ex, dmemren, dWEN_ex, dmemwen, RegWr_ex, RegWr_mem;
//LL/SC
logic datomic_ex, datomic_mem; 
logic [4:0] RegDst_ex, RegDst_mem; //Here RegDst means the actual destination register not the mux control signal
word_t rdat1_ex, rdat2_ex, pc_nextstate_ex, pc_nextstate_mem, dmemaddr, dmemstore, wdat_ex, wdat_mem, branch_target_ex, branch_target_mem, imemaddr_ex, imemload_ex, imemaddr_mem, imemload_mem, dmemload_mem;
logic [25:0] jumpaddr_ex;
logic [3:0] jumpoffset_ex;
logic [15:0] imm16_ex, imm16_mem;
logic branch_hit_mem, branch_hit_ex;
logic [29:0] target_address_mem, target_address_ex;
logic [1:0] branch_history_mem, branch_history_ex;

modport EXMEM
(
	input datomic_ex, branch_hit_ex, branch_history_ex, target_address_ex, lduse_hit_ex, imemaddr_ex, imemload_ex, branch_target_ex, imm16_ex, enable_exmem, dhit, flush_exmem, zero_ex, beq_ex, bne_ex, jr_ex, jal_ex, jump_ex, mem2reg_ex, halt_ex, lui_ex, dREN_ex, dWEN_ex, RegWr_ex, RegDst_ex, rdat1_ex, rdat2_ex, pc_nextstate_ex, wdat_ex, jumpaddr_ex, jumpoffset_ex,
	output datomic_mem, branch_hit_mem, branch_history_mem, target_address_mem, lduse_hit_mem, imemaddr_mem, imemload_mem, branch_target_mem, imm16_mem, jal_mem, mem2reg_mem, halt_mem, lui_mem, dmemren, dmemwen, zero_mem, beq_mem, bne_mem, RegWr_mem, RegDst_mem, pc_nextstate_mem, dmemaddr, dmemstore, wdat_mem, dmemload_mem
);

endinterface

`endif