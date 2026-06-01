`include "uvm_macros.svh"
import uvm_pkg::*;

class array extends uvm_object;
  
  //static array
  int arr1 [3] = {1,2,3};
  
  //Dynamic array
  int arr2[];
  
  //Queue
  int arr3[$];
  
  //assosiative array
  int arr4[int];
  
  function new (string path = "array");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(array)
  `uvm_field_sarray_int(arr1, UVM_DEFAULT);
  `uvm_field_array_int(arr2, UVM_DEFAULT);
  `uvm_field_queue_int(arr3, UVM_DEFAULT);
  `uvm_field_aa_int_int(arr4, UVM_DEFAULT);
  `uvm_field_utils_end
  
  task run();
    //initilize dynamic array
    arr2    = new[2];
    arr2[0] = 0;
    arr2[1] = 1;
    
    //pushing data in que
    arr3.push_front(3);
    arr3.push_front(4);
    arr3.push_front(5);
    
    //assosiative array
    arr4[1] = 6;
    arr4[2] = 7;
    
  endtask
    
endclass

module tb();
  
  array ar;
  
  initial begin
    ar = new("array");
    ar.run();
    ar.print();
  end
  
endmodule
