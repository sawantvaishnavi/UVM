`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  
  rand int data ;
  rand int addr;
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(data, UVM_DEFAULT)
  `uvm_field_int(addr, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string path = "transaction");
    super.new(path);
  endfunction
  
  constraint name {
    data inside {[0:10]}; 
    addr inside {[30:50]};
  				  }
  
endclass

//child to parent
class drv extends uvm_driver;
  `uvm_component_utils(drv)
  
  transaction tr;
  
  function new(string path = "drv", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase( uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0; i<10; i++) begin
      tr.randomize();
      `uvm_info("drv", $sformatf("at DRV: data=%0d | addr= %0d", tr.data, tr.addr), UVM_NONE);
       uvm_config_db#(transaction)::set(this, "", "key", tr);
      #10;
    end
    phase.drop_objection(this);
                         
  endtask
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  transaction tr_dc;
  drv d;
  
  function new(string path = "env", uvm_component parent = this);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase( uvm_phase phase);
    super.build_phase(phase);
    tr_dc = transaction::type_id::create("tr_dc");
    d  = drv :: type_id::create("d", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0; i<10; i++) begin
      #1;
      uvm_config_db#(transaction)::get(this, "d", "key", tr_dc);
      `uvm_info("env", $sformatf("at ENV: data=%0d | addr= %0d", tr_dc.data, tr_dc.addr), UVM_NONE);
      #9;
    end
    phase.drop_objection(this);
  endtask
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  
  function new (string path = "test" , uvm_component parent = null);
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
