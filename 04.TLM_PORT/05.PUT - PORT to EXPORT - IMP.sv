//producer to consumer - subconsumer

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


class producer extends uvm_component;
  `uvm_component_utils(producer)
  
 trans tr;
  
  uvm_blocking_put_port#(trans) send_sub_port;
  
  function new (string path = "producer", uvm_component parent = null);
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


class sub_consumer extends uvm_component;
  `uvm_component_utils(sub_consumer);
  
  uvm_blocking_put_imp#(trans, sub_consumer) sub_imp;
  
  function new(string path = "sub_consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sub_imp = new("sub_imp", this);
  endfunction
  
  virtual task put(trans tr);
    `uvm_info("sub_consumer", $sformatf("at sc: data=%0d | addr=%0d", tr.data, tr.addr), UVM_NONE)
  endtask
  
endclass


class consumer extends uvm_component;
  `uvm_component_utils(consumer);
  
  sub_consumer sc;
  
  uvm_blocking_put_export#(trans) con_port;
  
  function new(string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    con_port = new("con_port", this);
    sc       = sub_consumer::type_id::create("sc", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
      
    con_port.connect(sc.sub_imp);
    
  endfunction
  
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
    p = producer::type_id::create("p",this);
    c = consumer::type_id::create("c",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    p.send_sub_port.connect(c.con_port);
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
