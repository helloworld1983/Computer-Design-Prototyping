/*
Vaibhav Ramachandran
Branch Target Buffer Interface
Section 3
ramachav@purdue.edu
*/

`ifndef BRANCH_TARGET_BUFFER_IF_VH
`define BRANCH_TARGET_BUFFER_IF_VH

`include "cpu_types_pkg.vh"

interface branch_target_buffer_if;

import cpu_types_pkg::*;

logic [29:0] target_address, target_address_new;
logic [27:0] tag_bits, tag_bits_new;
logic btb_wen, flush_ifid, flush_exmem, flush_idex, branch_hit, slot_enabled;	//slot_enabled: whether there is anything within the slot of the btb or not, predicted_branch: whether the branch was correctly predicted or not
logic [1:0] mapping_sel, mapping_wsel, branch_history, branch_history_new;

modport btb
(
	input mapping_sel, mapping_wsel, slot_enabled, tag_bits, tag_bits_new, target_address_new, btb_wen, branch_history_new,
	output flush_ifid, flush_idex, flush_exmem, branch_hit, target_address, branch_history
);

endinterface 

`endif