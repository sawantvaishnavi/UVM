//Question:
// Interview-Tricky Question: Enum + Field Macro + Randomization Constraint
// Create a class packet with:

// typedef enum {LOW=0, MEDIUM=5, HIGH=10} priority_t;
// typedef enum {UNICAST=1, MULTICAST=2, BROADCAST=4} pkt_type_t;

// rand priority_t priority;
// rand pkt_type_t pkt_type;
// Constraints / Tricky Part
// The sum of priority + pkt_type must always be ≤ 12.
// Use uvm_field_enum() for both enum fields.
// Randomize 10 times and print the values.


//Solution:
`include "uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_object;
  
  typedef enum {LOW = 0, MEDIUM = 5, HIGH = 10} priority_t;
  typedef enum {UNICAST = 1, MULTICAST = 2, BROADCAST = 4} pkt_type_t;
  
  rand priority_t priorityy;
  rand pkt_type_t packet_type;
  
  function new(string path = "packet");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(packet)
  `uvm_field_enum(priority_t, priorityy, UVM_DEFAULT);       
  `uvm_field_enum(pkt_type_t, packet_type, UVM_DEFAULT);
  `uvm_object_utils_end
  
    // Constraint: sum of priority + pkt_type <= 12
  constraint sum_const { priorityy + packet_type <= 12; }

endclass

module tb;
  packet pck;
  
  initial begin
    pck = new("packet");
    
    //randomizinf for 10 times
    for(int i = 0; i<10; i++) begin
      if(pck.randomize())
        pck.print();
      else
        $display("Randomization failed!");
    end
    
  end
endmodule
