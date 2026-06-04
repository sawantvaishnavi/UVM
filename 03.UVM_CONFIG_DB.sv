//Used to share data between classes

`include "uvm_macros.svh"
import uvm_pkg::*;

class drv extends uvm_driver;
  `uvm_component_utils(drv)
  	
  int data;
  
  function new(string path = "DRV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRV", "Driver is created", UVM_NONE)

  
  ///driver need to access data and copy that value
  if(uvm_config_db#(int)::get(null, "ENV_TB_TOP", "data", data))
    `uvm_info("DRV", $sformatf("Value of data = %0d", data) , UVM_NONE)
  else
     `uvm_error("ENV", "Unable to accesss data")
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  drv drv1;
  function new(string path = "ENV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV", "Env is created", UVM_NONE);
   
    drv1 = drv::type_id::create("DRV", this);
    
    //use build phase to set the value
    uvm_config_db#(int):: set(null, "ENV_TB_TOP", "data", 11);
  endfunction
endclass

module tb; 
  initial begin
    run_test("env");
  end
endmodule
