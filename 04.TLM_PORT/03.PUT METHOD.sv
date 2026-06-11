//Write a UVM testbench where a monitor acts as a producer and sends 10 randomized transactions to a scoreboard using a uvm_blocking_put_port and uvm_blocking_put_imp. 
//Display the transaction details at both producer and consumer sides

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


//monitor as producer
class mon extends uvm_monitor;
  `uvm_component_utils(mon)
  
  trans trs;
  
  uvm_blocking_put_port#(trans) send;  //he parameter must be a type, not an object handle.
  
  function new(string path = "mon", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send  = new("send", this);
    trs   = trans::type_id::create("tr");
  endfunction
  
  //method which try to send data to put method
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat(10) begin
      trs.randomize();
      send.put(trs); //When execution reaches here, UVM automatically calls the scoreboard's put() method and execute that first and then come back here and run below uvm_info.
      `uvm_info("mon", $sformatf("AT MON: Data=%0d | Addr=%0d", trs.data, trs.addr), UVM_NONE)
      #10;
    end
    
    phase.drop_objection(this);
  endtask
endclass

//scoreboard as consumer
class sco extends uvm_scoreboard;
  `uvm_component_utils(sco)
  
  trans trcv;
  
  uvm_blocking_put_imp#(trans, sco) imp;
  
  function new(string path = "sco", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp  = new("imp", this);
    trcv = trans::type_id::create("trcv");
  endfunction
  
  virtual task put(trans trcv);
    `uvm_info("sco", $sformatf("AT SCO: Data=%0d | Addr=%0d", trcv.data, trcv.addr), UVM_NONE)
  endtask
  
endclass


class env extends uvm_env;
  `uvm_component_utils(env)
  
  mon m;
  sco s;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = mon::type_id::create("m", this);
    s = sco::type_id::create("s", this);
  endfunction
    
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    m.send.connect(s.imp);
    
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
