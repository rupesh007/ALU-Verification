import uvm_pkg::*;
import alu_pkg::*;
`include "uvm_macros.svh"
class agent_monitor extends uvm_monitor;
	`uvm_component_utils (agent_monitor)
	
	int iteration; //this is set through config variable
	
	//external interface 
	uvm_analysis_port # (alu_transaction) am_port;
	
	alu_transaction am_tr; //internal variable
	virtual alu_if am_if; //virtual interface
	 
	alu_config am_config; // config object
	
function new(string name, uvm_component parent);
    super.new(name, parent);
    am_tr = new("am_tr");
endfunction
	

function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		am_port=new("am_port",this); // no overriding
		//am_config = alu_config::type_id::create("am_config",this); 
		
		//this section retreives the alu_config just to read the number of transaction
		 if(!uvm_config_db # (alu_config)::get(this,"","alu_config",am_config))
	     `uvm_fatal("agentMonitor_config error", "can't get handle to the interface" );
		    //iteration = am_config.number_of_transaction;
		 //  this section gets the handle to the interface  
         //if(!uvm_config_db # (virtual alu_if)::get(this,"","top_alu",am_if))
	     //`uvm_fatal("Monitor error", "can't get handle to the interface" );

endfunction

function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
	     am_if = am_config.a_interface; // set local vitrual if property
	    
endfunction: connect_phase
	
task run_phase (uvm_phase phase);
	forever begin
			@(posedge am_if.drive); 
			//converts pin level activity to response transaction
			am_tr.op_code = am_if.op_code;
			am_tr.shift_rotate = am_if.shift_rotate;
			am_tr.operand_1 = am_if.operand_1;
			am_tr.operand_2 = am_if.operand_2;
			
			
			//writes transaction to analysis port
			am_port.write(am_tr); //broadcasts to the analysis component
			//$display("Agent Monitor @ %0t operand_1=%b operand_2=%b op_code=%b shift_rotate=%b",$time,am_tr.operand_1, 
			           //am_tr.operand_2, am_tr.op_code, am_tr.shift_rotate);

		end
	endtask
	
endclass
