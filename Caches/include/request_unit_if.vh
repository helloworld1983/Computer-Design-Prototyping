/*
Vaibhav Ramachandran
Request Unit Interface
ramachav@purdue.edu
Section 3
*/
`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface request_unit_if;

import cpu_types_pkg::*;

logic ihit, dhit, dmemwen, dmemren, imemren, iREN, dWEN, dREN, halt;

modport ru
(
	input ihit, iREN, dhit, dREN, dWEN, halt,
	output dmemren, dmemwen, imemren
);

endinterface

`endif