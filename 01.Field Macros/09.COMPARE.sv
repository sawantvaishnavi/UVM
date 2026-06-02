`include"uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_object;
  
  rand bit [3:0] addr;
  
  function new (string path = "packet");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(packet)
  `uvm_field_int(addr, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

module tb();
  
  packet p1;
  packet p2;
  int status = 0;
  
  initial begin 
    p1 = new("p1");
    p2 = new("p2");
    
    p1.randomize();
    p2.randomize();
    
    p1.print();
    p2.print();
    
    status = p1.compare(p2);
    $display("Status = %0d", status);
  end
endmodule
