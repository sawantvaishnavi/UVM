//Que. Parent → Child – Transaction Object
// Hierarchy: env → driver
// Task: Create a transaction object with addr and data, randomize it, pass it from env → driver. Driver prints the fields.
// Goal: Practice passing object handles, not just integers.


`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  
  randc int data;
  randc int addr;
  
  function new (string path = "transaction");
  super.new(path);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(data, UVM_DEFAULT)
  `uvm_field_int(addr, UVM_DEFAULT)
  `uvm_object_utils_end
  
  constraint values { 
    data inside {[0:10]}; 
    addr inside  {[20:40]};
  					}
  
endclass

class driver extends uvm_driver;
  `uvm_component_utils(driver)
  
  transaction trv_dc;
 
  function new (string path = "driver" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
   virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0; i<5; i++) begin
      #1;
      uvm_config_db#(transaction)::get(this, "", "radha", trv_dc);
      `uvm_info("driver", $sformatf("In DRV: Data=%0d | Addr=%0d", trv_dc.data, trv_dc.addr), UVM_NONE)
      #9;
    end
    phase.drop_objection(this);
  endtask
  
  //here best practice is Sequence --> Sequencer --> Driver or tlm ports or mailbox to avoid race around condition instade #1 #9 arrangement
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  driver drv;
  transaction tr;
  
  function new (string path = "env" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv", this);
    tr = transaction::type_id::create("tr");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0; i<5; i++) begin
      tr.randomize();
      uvm_config_db#(transaction)::set(this, "drv", "radha", tr);
      `uvm_info("driver", $sformatf("IN ENV: Data=%0d | Addr=%0d", tr.data, tr.addr), UVM_NONE)
      #10;
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
