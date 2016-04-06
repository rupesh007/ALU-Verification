import uvm_pkg::*;
`include"uvm_macros.svh"

class alu_transaction extends uvm_sequence_item;

	rand logic[3:0] op_code; // 4 bit op_code
	rand logic[7:0] operand_1; // 8 bit operand
	rand logic[7:0] operand_2;
	rand logic[2:0] shift_rotate; //maximum by 8 bits
	rand logic[7:0] result; // result
	rand logic carry;  
	
	//this sections constrain transaction item to be randomized

	constraint opcode_range {
      //op_code >= 4'b0100;
      //op_code <= 4'b0101;
	     op_code >= 0;
	     op_code <= 9;
	   }

  constraint opr1_range {
	   //operand_1 == 255;
	   
	     operand_1 >= 0;
	     operand_1 <= 254;
    	}
  constraint opr2_range {
   //operand_2 == 255;
  
	     operand_2 >= 0;
	     operand_2 <= 254;
	    }
//constraint shift_range {
//	   shift_rotate >= 0;
//	   shift_rotate <= 8;
//	}
	// registers with factory

	`uvm_object_utils(alu_transaction) 
	// new function constructor
	function new (string name="alu_transaction"); 
		super.new(name);
	endfunction

	/* Defines the field automation cocept of UVM.
	do_xx methods are defined automatically*/

	//`uvm_object_utils_begin(alu_transaction)
//     `uvm_field_int(op_code, UVM_ALL_ON)
//     `uvm_field_int(operand_1, UVM_ALL_ON)
//     `uvm_field_int(operand_2, UVM_ALL_ON)
//     `uvm_field_int(shift_rotate, UVM_ALL_ON)
//     `uvm_field_int(result, UVM_ALL_ON)
//     `uvm_field_int(carry, UVM_ALL_ON)
//     `uvm_object_utils_end

	//Define constraints if any

endclass: alu_transaction


