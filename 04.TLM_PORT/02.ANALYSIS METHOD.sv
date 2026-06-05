//Design an environment consisting of a single producer class 'PROD' and three subscribers viz., iz. 'SUB1', 'SUB2', and 'SUB3'. Submit your TB code.

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

class PROD extends uvm_component;
  `uvm_component_utils(PROD)
  
  transaction tr;
  
  uvm_analysis_port#(transaction) port;
  
  function new(string path = "PROD", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    port = new("port", this);
  endfunction
  
 task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);
    port.write(tr);
    phase.drop_objection(this);
 endtask
  
endclass

class SUB1 extends uvm_component ;
  `uvm_component_utils(SUB1)
  
  uvm_analysis_imp#(transaction, SUB1) imp;
  
  function new(string path = "SUB1", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  virtual function void write(transaction tr);
    `uvm_info("SUB1", "Data received at SUB1", UVM_NONE)
    tr.print();
  endfunction
  
endclass

class SUB2 extends uvm_component ;
  `uvm_component_utils(SUB2)
  
  uvm_analysis_imp#(transaction, SUB2) imp;
  
  function new(string path = "SUB2", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  virtual function void write(transaction tr);
    `uvm_info("SUB2", "Data received at SUB2", UVM_NONE)
    tr.print();
  endfunction
  
endclass

class SUB3 extends uvm_component ;
  `uvm_component_utils(SUB3)
  
  uvm_analysis_imp#(transaction, SUB3) imp;
  
  function new(string path = "SUB3", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  virtual function void write(transaction tr);
    `uvm_info("SUB3", "Data received at SUB3", UVM_NONE)
    tr.print();
  endfunction
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  PROD p;
  SUB1 s1;
  SUB2 s2;
  SUB3 s3;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    p  = PROD::type_id::create("p",  this);
    s1 = SUB1::type_id::create("s1", this);
    s2 = SUB2::type_id::create("s2", this);
    s3 = SUB3::type_id::create("s3", this);
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    p.port.connect(s1.imp);
    p.port.connect(s2.imp);
    p.port.connect(s3.imp);
    
  endfunction
  
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  env e;
 
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = new("e", this);
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
  
endclass


module tb;
  initial begin
    run_test("test");
  end
endmodule
