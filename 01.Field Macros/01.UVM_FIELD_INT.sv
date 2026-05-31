`include "uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_object;
  
  function new (string path = "packet");
    super.new(path);
  endfunction
  
  rand bit [7:0] addr;
  rand bit [7:0] data;
  
  `uvm_object_utils_begin(packet)
  `uvm_field_int(addr, UVM_DEFAULT);            //DEFAULT HEXADECIMAL REP
  `uvm_field_int(data, UVM_DEFAULT | UVM_BIN);  //FOR BINARY REPRESENTATION
  `uvm_object_utils_end
  
endclass

module tb;
  packet pck;
  
  initial begin
    pck = new("packet");
    pck.randomize();
    pck.print();                              //DEFAULT TABLE PRINT
   // pck.print(uvm_default_line_printer);    //FOR LINE PRINT
    
  end
endmodule
