//put subproducer - producer to consumer connection

`include "uvm_macros.svh"
import uvm_pkg::*;

class trans extends uvm_sequence_item;
  
  rand bit [7:0] data;
  rand bit [7:0] addr;
  
  `uvm_object_utils_begin(trans)
  `uvm_field_int(data, UVM_DEFAULT)
  `uvm_field_int(addr, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string path = "trans");
    super.new(path);
  endfunction
  
endclass 


class generator extends uvm_component;
  `uvm_component_utils(generator)
  
 trans tr;
  
  uvm_blocking_put_port#(trans) send_sub_port;
  
  function new (string path = "generator", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send_sub_port = new("send_sub_port", this);
    tr = trans::type_id::create("tr", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat(5) begin
      tr.randomize();
      send_sub_port.put(tr);
      `uvm_info("gen", $sformatf("at gen: data=%0d | addr=%0d", tr.data, tr.addr), UVM_NONE);
      #10;
    end
    phase.drop_objection(this);
  endtask
endclass


class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  generator gen;
  
  uvm_blocking_put_port#(trans) send_port;
  
  function new(string path = "agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gen = generator::type_id::create("gen", this);
    send_port = new("send_port", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    gen.send_sub_port.connect(send_port);
    
  endfunction
  
endclass

class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)
  
  function new (string path = "sco", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  uvm_blocking_put_imp#(trans,sco) imp_recv;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp_recv = new ("imp_recv", this);
  endfunction
  
  virtual task put( trans tr);
    `uvm_info("sco", $sformatf("at sco: data=%0d | addr=%0d", tr.data, tr.addr), UVM_NONE);
  endtask
  
endclass


class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent a;
  sco s;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a = agent::type_id::create("a", this);
    s = sco::type_id::create("s", this);
  endfunction
    
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    a.send_port.connect(s.imp_recv);
    
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
