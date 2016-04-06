import uvm_pkg::*;
import alu_pkg::*;
import agent_pkg::*;
`include"uvm_macros.svh"

class alu_driver extends uvm_driver # (alu_transaction);
//declaration macros 
//this provides factory automation for the driver
//also enables methods for automatically for copy,compare,print,pack and unpack
`uvm_component_utils(alu_driver)
//virtual interface
virtual alu_if a_vif;
alu_config d_config;

uvm_analysis_port #(alu_transaction) dport;
alu_transaction req;
int transaction_count;

function new (string name, uvm_component parent); // new function constructor
super.new(name,parent);
endfunction: new

function void build_phase (uvm_phase phase); // build phase for uvm_component
	super.build_phase(phase);
	
	dport=new("d_port",this); //no overriding for the port
	
//	d_config = alu_config::type_id::create("d_config",this);
	if (!uvm_config_db # (alu_config)::get(this,"","alu_config",d_config)) 
		 `uvm_fatal("Driver error", "can't locate alu_config" );
      transaction_count = d_config.number_of_transaction;
      //a_vif = d_config.a_interface;
      
 //if (!uvm_config_db # (agent_config)::get(this,"*","env_agent_config",dri_config)) 
	// `uvm_fatal("Alu_interface error in driver", "can't locate alu_interface" );	
	
		 
      
endfunction: build_phase

function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
	     a_vif = d_config.a_interface; // set local vitrual if property
	    // a_vif = dri_config.a_interface;
endfunction: connect_phase

task run_phase (uvm_phase phase); // run phase for UVM
phase.raise_objection(this, "run phase commenced"); // raise the objection for the task if busy
	//seq4dut;
repeat(transaction_count) 
	begin 
      @(posedge a_vif.drive); // sensitive to drive
      
     	seq_item_port.get_next_item (req); // tries the next //item possible, returns null if not
  	      dport.write(req);  //writes to the driver export
  	      //$display("Port_data @ %0t operand_1=%b operand_2=%b op_code=%b shift_rotate=%b",$time,req.operand_1, req.operand_2, req.op_code, req.shift_rotate);
  	      
  	      drive_dut();
 	    seq_item_port.item_done();
 	    
   end
phase.drop_objection(this, "run phase dropped"); // drops the objection once the task is completed
endtask: run_phase


task drive_dut();
  //transaction item to pin level activity
  
  a_vif.op_code = req.op_code;
  a_vif.shift_rotate = req.shift_rotate;
  a_vif.operand_1 = req.operand_1;
  a_vif.operand_2 = req.operand_2;
  
  
  
  //$display("Driver @ %0t operand_1=%b operand_2=%b op_code=%b shift_rotate=%b",$time,req.operand_1, req.operand_2, req.op_code, req.shift_rotate);
  
endtask: drive_dut
endclass: alu_driver