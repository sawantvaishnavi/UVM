`include"uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_object;
  rand bit [3:0] addr;
            
  function new(string path = "packet")          ;
    super.new(path);
  endfunction
  
  
  `uvm_object_utils_begin(packet)
  `uvm_field_int(addr, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

module tb;
  
  packet pck1;
  packet pck2;
  
//   initial begin
//     pck1 = new("packet1");  //adding constructor -- packet1 is object name
//     pck2 = new("packet2");  //before calling copy method -- need to add constructor prior to copy method
    
//     pck1.randomize();
//     pck2.copy(pck1);
    
//     pck2.print();
//     pck1.print();
//   end
  
  initial begin
    pck1 = new("packet1");
    pck1.randomize();
    
    $cast(pck2, pck1.clone());  // $cast(pck2, pck1.clone); is doing casting and doning clone also
    
    pck1.print();
    pck2.print();
    
  end
endmodule
