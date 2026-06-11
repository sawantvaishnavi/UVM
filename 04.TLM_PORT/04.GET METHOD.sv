`include"uvm_macros.svh"
import uvm_pkg::*;

class trans extends uvm_sequence_item;
  
  rand bit [7:0] data;
  rand bit [7:0] addr;
  
  function new(string path = "trans");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(trans)
  `uvm_field_int(data, UVM_DEFAULT)
  `uvm_field_int(addr, UVM_DEFAULT)
  `uvm_object_utils_end
  
endclass

//receive 
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  trans tr1;
  
  uvm_blocking_get_imp#(trans, producer) imp;
  
  function new(string path = "producer", uvm_component parent = null );
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr1 = trans::type_id::create("tr1");
    imp = new("imp", this);
  endfunction
  
  virtual task get(output trans trcv);
    tr1.randomize();
    trcv = tr1;
    `uvm_info("prod", $sformatf("at prod: data=%0d | addr=%0d", trcv.data, trcv.addr), UVM_NONE);
  endtask
    
endclass


//consumer will send data
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
 
  trans tr;
  
  uvm_blocking_get_port#(trans) port ;
  function new(string path = "consumer", uvm_component parent = null );
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    tr   = trans::type_id::create("tr");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this); 
    
    repeat(5) begin
      port.get(tr);
      `uvm_info("con", $sformatf("at con: data=%0d | addr=%0d", tr.data, tr.addr), UVM_NONE);
        #10;
    end
  
    phase.drop_objection(this);
  endtask
  
endclass


class env extends uvm_env;
  `uvm_component_utils(env)
  
  producer p;
  consumer c;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction
    
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    c.port.connect(p.imp);
    
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
    e = env::type_id::create("e", this);
  endfunction
  
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule
