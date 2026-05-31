`include "uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_object;
  
  function new(string path = "packet");
    super.new(path);
  endfunction
  
  real voltage = 1.8;
  string name  =  "vaishnavi";
  
  `uvm_object_utils_begin(packet);
  `uvm_field_real(voltage, UVM_DEFAULT);
  `uvm_field_string (name, UVM_DEFAULT);
  `uvm_object_utils_end
endclass

module tb;
  packet pck;
  
  initial begin
    pck = new("packet");
    pck.print();
  end
  
endmodule
