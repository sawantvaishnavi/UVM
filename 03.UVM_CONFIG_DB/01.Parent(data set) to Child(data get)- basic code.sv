//1.
`include "uvm_macros.svh"
import uvm_pkg::*;

//child - gets the data
class driver extends uvm_driver;
  `uvm_component_utils(driver)
  
  int datar;  //receiver data container manditory
  function new (string path = "driver" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(int)::get(null, "Test_TB_Top", "key", datar);
    `uvm_info("driver", $sformatf("Value passed from parent is: %0d ", datar), UVM_NONE) ;
  endfunction
  
endclass


////parent - setting the data
class test extends uvm_test;
  `uvm_component_utils(test)
  
  driver drv;
 
  function new (string path = "test" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(int)::set (null, "Test_TB_Top", "key", 10);  //10 as value we are passing to child in data container
    
    drv = driver::type_id::create("drv", this);
  endfunction
  
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule

//2.
`include "uvm_macros.svh"
import uvm_pkg::*;

//child - gets the data
class driver extends uvm_driver;
  `uvm_component_utils(driver)
  
  int datar;
  function new (string path = "driver" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(int)::get(null, "Test_TB_Top", "key", datar);
    `uvm_info("driver", $sformatf("Value passed from parent is: %0d ", datar), UVM_NONE) ;
  endfunction
  
endclass

////parent - setting the data
class test extends uvm_test;
  `uvm_component_utils(test)
  
  driver drv;
  int data = 10;
  
  function new (string path = "test" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    uvm_config_db#(int)::set (null, "Test_TB_Top", "key", data);  //passing variable , whatever value inside variable that will be passed in data container
    
    drv = driver::type_id::create("drv", this);
  endfunction
  
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule

//3. do rendom 10 transaction and pass that
`include "uvm_macros.svh"
import uvm_pkg::*;

//child - gets the data
class driver extends uvm_driver;
  `uvm_component_utils(driver)
  
  int datar;
  function new (string path = "driver" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0; i<10; i++) begin
      
      uvm_config_db#(int)::get(this, "", "key", datar);
    `uvm_info("driver", $sformatf("Value passed from parent is: %0d ", datar), UVM_NONE) ;
      #10;
    end
    
    phase.drop_objection(this);
  endtask
  
endclass

////parent - setting the data
class test extends uvm_test;
  `uvm_component_utils(test)
  
  driver drv;
  int data;
  
  function new (string path = "test" , uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    for(int i=0; i<10; i++) begin
      data = $urandom_range(0, 100);
      
      // Set it in config_db for the driver to get
      uvm_config_db#(int)::set(this, "drv", "key", data);
      
      #10;
    end
  endtask  
endclass

module tb;
  initial begin
    run_test("test");
  end
endmodule
