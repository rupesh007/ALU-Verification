import uvm_pkg::*;
import alu_pkg::*;
`include "uvm_macros.svh"
class my_scoreboard extends  uvm_scoreboard;
	`uvm_component_utils(my_scoreboard)
	
uvm_analysis_export #(alu_transaction) amPort; //connects to active agent monitor
uvm_analysis_export #(alu_transaction) m_port; //connects to monitor



//uvm_analysis_export #(alu_transaction) d_port; //connects to driver
uvm_tlm_analysis_fifo #(alu_transaction) am_fifo; //fifo to read from agent monitor
uvm_tlm_analysis_fifo #(alu_transaction) m_fifo; //fifo to read from monitor

//int num_of_matches, num_of_mismatches;
logic [8:0] temp_result;

local my_subscriber scb_subscriber;
//alu_config mac_config;
//virtual alu_if mac_if;
//int iteration;
	
function new (string name, uvm_component parent);
	super.new(name,parent);
		
endfunction
	
function void build_phase (uvm_phase phase);	
	   super.build_phase(phase);
	   //creates ports with no overriding
	    
	     amPort = new ("analysis_port1",this);
	     m_port = new ("analysis_port2",this);
	     
	    //fifos without overriding
	     am_fifo = new ("fifo_d",this);
	     m_fifo = new ("fifo_m",this);
	     
	     scb_subscriber = my_subscriber::type_id::create("scb_subscriber",this);
	     
	   
	     
endfunction: build_phase
   
function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
      
      amPort.connect(am_fifo.analysis_export); //agent monitor and fifo connection
	    m_port.connect(m_fifo.analysis_export); //monitor and fifo connection
	    
endfunction: connect_phase


task run_phase (uvm_phase phase);
  alu_transaction m_tr,am_tr;
	forever begin
	
	   am_fifo.get(am_tr);
	   m_fifo.get(m_tr);
	   predict_output(am_tr); // predicts the output based on input read from before monitor
	   
	   //print these values
	    //$display("Analysis component retrieved from agent monitor @ %0t operand_1=%b operand_2=%b op_code=%b shift_rotate=%b",$time,
	            // am_tr.operand_1, am_tr.operand_2, am_tr.op_code, am_tr.shift_rotate);

	  // $display("Analysis component retreived from monitor @ %0t operand_1=%b operand_2=%b op_code=%b shift_rotate=%b reslut=%b carry=%b",$time,
	  // m_tr.operand_1, m_tr.operand_2,m_tr.op_code, m_tr.shift_rotate, m_tr.result, m_tr.carry);
	  

	if ((am_tr.result == m_tr.result) && (am_tr.carry == m_tr.carry)) 
	        begin
          //$display ("Predictor result and DUT result matched");
          `uvm_info("Predictor result and DUT result matched", {"Test: OK!"}, UVM_LOW);
       end 
        else begin
       // $display ("Predictor result and DUT result mis-matched");
          `uvm_info("Predictor result and DUT result mismatch", {"Test: Failed!"}, UVM_LOW);
         
        end   
	end

endtask

virtual function void predict_output(alu_transaction a_tr);
    case (a_tr.op_code)
			  //this is just a simple implementation...
				4'b0001: temp_result = a_tr.operand_1 & a_tr.operand_2;
				4'b0010: temp_result = a_tr.operand_1 | a_tr.operand_2;
				4'b0011: temp_result = a_tr.operand_1 ^ a_tr.operand_2;
				4'b0100: temp_result = a_tr.operand_1 + a_tr.operand_2;				
				4'b0101: temp_result = a_tr.operand_1 - a_tr.operand_2;
				
				4'b0110: temp_result = a_tr.operand_1 >> a_tr.shift_rotate;
				4'b0111: temp_result = a_tr.operand_1 << a_tr.shift_rotate;
				4'b1000: temp_result = a_tr.operand_1 >>> a_tr.shift_rotate;
				4'b1001: temp_result = a_tr.operand_1 <<<a_tr.shift_rotate;				
				default: temp_result = 9'bz;
		endcase
	
		
		a_tr.result = temp_result[7:0]; 
		  if (temp_result[8]==1) 		  
			   a_tr.carry = 1;			
		  else if(temp_result[8]==0)
			   a_tr.carry = 0;
			 else a_tr.carry = 1'bz;
		 
endfunction


endclass
