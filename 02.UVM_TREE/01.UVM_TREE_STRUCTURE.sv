//Que.Create the following UVM component hierarchy:

// my_test
//  |
//  +-- env
//       |
//       +-- agent1
//       |     |
//       |     +-- driver
//       |     +-- monitor
//       |
//       +-- agent2
//             |
//             +-- driver
//             +-- monitor
// Requirements:
// Create all components using type_id::create().
// Connect the hierarchy using the appropriate parent handle.
// In the build_phase, print a message whenever a component is created.
// Run the test using run_test("my_test").

`include "uvm_macros.svh"
import uvm_pkg::*;

class drv extends uvm_driver;
  `uvm_component_utils(drv)
  	
  function new(string path = "DRV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRV", "Driver is created", UVM_NONE)
  endfunction
  
endclass

class mon extends uvm_monitor;
  `uvm_component_utils(mon)
  
  function new(string path = "MON", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MON", "Monitor is created", UVM_NONE);
  endfunction
  
endclass

class agent1 extends uvm_agent;
  `uvm_component_utils(agent1)
  
  //create instance
  drv drv1;
  mon mon1;
  
  function new (string path = "AGENT1", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT1", "Agent1 is created", UVM_NONE);
    
    //crete object of instance 
    drv1 = drv::type_id::create("DRV1", this);
    mon1 = mon::type_id::create("MON1", this);
  endfunction
  
endclass

class agent2 extends uvm_agent;
  `uvm_component_utils(agent2)
  
  //create instance
  drv drv2;
  mon mon2;
  
  function new (string path = "AGENT2", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT2", "Agent2 is created", UVM_NONE);
    
    //crete object of instance 
    drv2 = drv::type_id::create("DRV2", this);
    mon2 = mon::type_id::create("MON2", this);
  endfunction
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent1 a1;
  agent2 a2;
  
  function new(string path = "ENV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV", "Env is created", UVM_NONE);
   
    a2 = agent2::type_id::create("AGENT2", this);
    a1 = agent1::type_id::create("AGENT1", this);
    //since a2 is creted first but at output a1 will results first bez UVM stores children by name and often traverses them alphabetically.
  endfunction
  
endclass


class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  env e;

  function new(string path = "MY_TEST", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MY_TEST", "My_test is created", UVM_NONE);
   
    e = env::type_id::create("MY_TEST", this);
  endfunction
  
endclass

module tb;
  
  initial begin
    run_test("my_test");
  end
endmodule
