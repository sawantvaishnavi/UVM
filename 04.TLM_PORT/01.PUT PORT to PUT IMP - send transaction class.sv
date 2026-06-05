//Send transaction data from COMPA to COMPB with the help of TLM PUT PORT to PUT IMP . 
//Transaction class code is added in Instruction tab. Use UVM core print method to print the values of data members of transaction class. Submit your TB Code.

`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;

  bit [3:0] a = 12;
  bit [4:0] b = 24;
  int c = 256;
  
  function new(string inst = "transaction");
    super.new(inst);
  endfunction
  
  
    `uvm_object_utils_begin(transaction)
  `uvm_field_int(a, UVM_DEFAULT | UVM_DEC);
  `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
  `uvm_field_int(c, UVM_DEFAULT | UVM_DEC); 
    `uvm_object_utils_end
  
endclass

class COMPA extends uvm_component;
  `uvm_component_utils(COMPA)
  
  transaction tr;
  
  uvm_blocking_put_port #(transaction) send;
  
  function new(string path = "COMPA", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
    tr = transaction::type_id::create("tr"); //as transaction is uvm_object type
  endfunction
  
  task main_phase (uvm_phase phase);
    phase.raise_objection(this);
    send.put(tr);  //here tr not transaction
    `uvm_info("COMPA", "transaction send" , UVM_NONE);
    phase.drop_objection(this);
  endtask
  
endclass

class COMPB extends uvm_component;
  `uvm_component_utils(COMPB)
  
  uvm_blocking_put_imp#(transaction, COMPB) imp;
  
  function new(string path = "COMPB", uvm_component parent = null);
    super.new(path, parent);
  endfunction
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  task put (transaction trans);
    `uvm_info("COMPB", "transaction received", UVM_NONE);
    trans.print();
  endtask
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  	
  COMPA c1;
  COMPB c2;
  
  function new (string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    c1 = COMPA::type_id::create("c1", this);
    c2 = COMPB::type_id::create("c2", this);
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    c1.send.connect(c2.imp);
  endfunction
endclass


class test extends uvm_test;
  `uvm_component_utils(test)
  	
  env e;
  
  function new (string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    e = env::type_id::create("e", this);
    
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass

module tb();
  
  initial begin
    run_test("test");
  end
endmodule
