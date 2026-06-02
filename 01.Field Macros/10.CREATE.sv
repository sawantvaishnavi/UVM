//1.HOW TO USE CRETE METHOD 
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

  
  initial begin 
    p1 = packet::type_id::create("p1");
    p2 = packet::type_id::create("p2");
    
    p1.randomize();
    p2.randomize();
    
    p1.print();
    p2.print();

  end
endmodule



//2.ADVANTAGES OF CRETE METHOD
//2.1. SUPPOSE WE HAVE TRANSACTION CLASS AND WE REGISTER TO ENVIORNMENT AND SHOW OUTPUT

`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_object;
  
  rand bit [3:0] data;
  
  function new(string path  = "transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

class env extends uvm_component;
  `uvm_component_utils(env)
  
  transaction tr;
  
  function new (string path = "env", uvm_component parent = null);
    super.new(path, parent);
    tr = transaction::type_id::create("tr");
    tr.randomize();
    tr.print();
  endfunction
endclass

module tb;
  env e;
  
  initial begin
    e = env::type_id::create("e", null);
  end
endmodule 

//2.2 WHEN NEW SIGNAL cntrl GETS ADD IN 2ND REALESE WE EXTENDS OLD TRANSACTION CLASS TO MODIFIED_TRANSACTION CLASS AND SHOW OUPUT LIKE THIS.
///// NOW HERE WE HAVE TO CHANGES FROM transaction to modified_transaction IN TWO PLACES
//// SO IN THIS TYPE OF PATTERN WE HAVE TO DO LOT OV VARIATION

`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_object;
  
  rand bit [3:0] data;
  
  function new(string path  = "transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

class modified_transaction extends transaction;
  
  rand bit cntrl;
  
  function new(string path = "modified_transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(modified_transaction)
  `uvm_field_int(cntrl, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

class env extends uvm_component;
  `uvm_component_utils(env)
  
  modified_transaction tr;
  
  function new (string path = "env", uvm_component parent = null);
    super.new(path, parent);
    tr = modified_transaction::type_id::create("tr");
    tr.randomize();
    tr.print();
  endfunction
endclass

module tb;
  env e;
  
  initial begin
    e = env::type_id::create("e", null);
  end
endmodule 

//2.3 NOT CHANGING THE DEFAULT CODE, (MEANS WITHOUT CHNAGING transaction to modified_transaction) and USING FACTORY OVERRIDE
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_object;
  
  rand bit [3:0] data;
  
  function new(string path  = "transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

class modified_transaction extends transaction;
  
  rand bit cntrl;
  
  function new(string path = "modified_transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(modified_transaction)
  `uvm_field_int(cntrl, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass

class env extends uvm_component;
  `uvm_component_utils(env)
  
  transaction tr;
  
  function new (string path = "env", uvm_component parent = null);
    super.new(path, parent);
    tr = transaction::type_id::create("tr");
    tr.randomize();
    tr.print();
  endfunction
endclass

module tb;
  env e;
  
  initial begin
    e.set_type_override_by_type(transaction::get_type, modified_transaction::get_type);
    e = env::type_id::create("e", null);
  end
endmodule 
