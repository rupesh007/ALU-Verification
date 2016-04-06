import uvm_pkg::*;
import alu_pkg::*;
`include "uvm_macros.svh"

class my_subscriber extends uvm_subscriber#( alu_transaction );
  `uvm_component_utils( my_subscriber )
  
  
  //virtual alu_if s_if;
 // alu_config s_config;
  int unsigned covered_1;  //this will store number of covered bins
  //int unsigned covered_2;
  int unsigned total_1; //this will store total number of bins
  //int unsigned total_2;
  real pct_1,pct_2; // this will store the ratio of covered and total scaled by 100
  
  int opc;
  int op1, op2, shift;
  
  
  covergroup int_coverage;
    op_code: coverpoint opc
      //{ bins op_c [9] = {[1:9]};}
      { bins low  = {[1:5]};
        bins high= {[6:9]};}
        //ignore_bins rest = {[10:15]};}
    operand_1: coverpoint op1
    
      //{ bins op_1[49] = {[1:49]};} 
      { bins low  = {0};
        bins med  = {[1:254]};
        bins high = {255};}
    operand_2: coverpoint op2
      //{ bins op_2[49]= {[1:49]};}
        { bins low= {0};
          bins med  = {[1:254]};
          bins high= {255};}
    shift_rotate: coverpoint shift
      //{ bins shi[7]= {[0:7]};} 
      { bins low = {[0:3]};
        bins high = {[4:7]};} 
        
    //cross_1: cross opc,op1,op2;
    //cross_2: cross opc, op1,shift;
    
  endgroup: int_coverage
 
 
 function new( string name , uvm_component parent);
    super.new( name , parent );
      int_coverage = new();
  endfunction
  
 
  
  function void write(alu_transaction t);
    //translating transaction item to coverpoints
    opc = t.op_code;
    op1 = t.operand_1;
    op2 = t.operand_2;
    shift = t.shift_rotate; 
    
//coverage collection procedurally, this method can be alternatively used as sensitive to event
    int_coverage.sample();
    //int_coverage.cross_2.sample();
    
  endfunction
  
  function void report_phase( uvm_phase phase );
    pct_1 = int_coverage.get_coverage(covered_1, total_1); // returns the coverage result in percentage
    //pct_2 = int_coverage.cross_2.get_coverage(covered_2, total_2);
    $display("REQ Coverage_1: covered = %0d, total = %0d (%5.2f%%)", covered_1, total_1, pct_1);
   // $display("REQ Coverage_2: covered = %0d, total = %0d (%5.2f%%)", covered_2, total_2, pct_2);

  endfunction
  
endclass: my_subscriber
 
