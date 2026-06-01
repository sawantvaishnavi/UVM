`include "uvm_macros.svh";
import uvm_pkg::*;

class parent extends uvm_object;
  
  rand bit [7:0]  addr;
  
  function new(string path = "parent");
    super.new("parent");
  endfunction
  
  `uvm_object_utils_begin(parent)
  `uvm_field_int (addr, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

class child extends uvm_object;
  parent p;
  
  function new(string path = "child");
    super.new(path);
    p = new("parent");
  endfunction
  
  `uvm_object_utils_begin(child)
  `uvm_field_object(p, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

module tb();
  
  child c;
  
  initial begin
    c = new("child");
    c.p.randomize();
    c.print();
  end
  
endmodule

