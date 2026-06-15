////// Design Code /////
module mux
  (
    input [3:0] a,b,c,d, ////input data port have size of 4-bit
    input [1:0] sel,     ////control port have size of 2-bit
    output reg [3:0] y 
  );
  
  always@(*)
    begin
      case(sel)
        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        2'b11: y = d;
      endcase
    end
  
  
endmodule

interface mux_if();
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] c;
  logic [3:0] d;
  logic [3:0] sel;
  logic [3:0] y;
endinterface


//// Tb ////
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  
  rand bit [3:0] a;
  rand bit [3:0] b;
  rand bit [3:0] c;
  rand bit [3:0] d;
  rand bit [1:0] sel;
  bit [3:0] y;
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(a ,UVM_DEFAULT)
  `uvm_field_int(b ,UVM_DEFAULT)
  `uvm_field_int(c ,UVM_DEFAULT)
  `uvm_field_int(d ,UVM_DEFAULT)
  `uvm_field_int(sel ,UVM_DEFAULT)
  `uvm_field_int(y ,UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new (string path = "transaction");
    super.new(path);
  endfunction
  
endclass

//sequence class:send random stimuile and send to driver
class generator extends uvm_sequence#(transaction);
  `uvm_object_utils(generator)
  
  transaction tr;
  
  function new(input string path = "generator");
    super.new(path);
  endfunction
  
  virtual task body();
    //create transaction object
    tr = transaction::type_id::create("tr");
    
    repeat(5) begin
    start_item(tr); //it will notify driver that sequence is ready and as soon as we receive gran from driver will start generating data
    tr.randomize();
    `uvm_info("GEN", $sformatf("Data send to driver: a=%0h | b=%0h | c=%0h | d=%0h | sel=%0h", tr.a, tr.b, tr.c, tr.d, tr.sel), UVM_NONE);
    finish_item(tr);
    end
    
  endtask
    
endclass

class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
  
  transaction tc;
  virtual mux_if mif;
  
  function new (input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tc = transaction::type_id::create("tc");
    
    if(!uvm_config_db#(virtual mux_if)::get(this, "", "mif", mif))
      `uvm_error("DRV", "Unable to access uvm_access_db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      seq_item_port.get_next_item(tc);
      mif.a <= tc.a;
      mif.b <= tc.b;
      mif.c <= tc.c;
      mif.d <= tc.d;
      mif.sel <= tc.sel;
      `uvm_info("DRV", $sformatf("Trigger DUT a=%0h | b=%0h | c=%0h d=%0h | sel=%0h", tc.a, tc.b, tc.c, tc.d, tc.sel), UVM_ERROR);
      seq_item_port.item_done();
      #10;
    end
    
  endtask  
endclass


class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  transaction t;
  virtual mux_if mif;
  
  uvm_analysis_port#(transaction) send;
  
  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       t = transaction::type_id::create("t");
    send = new("send", this);
    
    if(!uvm_config_db#(virtual mux_if)::get(this, "", "mif", mif))
      `uvm_error("MON", "unable to access uvm_config_db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin 
      #10;
      t.a = mif.a;
      t.b = mif.b;
      t.c = mif.c;
      t.d = mif.d;
      t.sel = mif.sel;
      t.y = mif.y;
      
      `uvm_info("MON", $sformatf("Data Send to SCO a=%0h | b=%0h | c=%0h d=%0h | sel=%0h", t.a, t.b, t.c, t.d, t.sel), UVM_ERROR)
      
      send.write(t);
    end
  endtask
endclass

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(transaction, scoreboard) recv;
  
  transaction tr;
  
  function new (input string path = "scoreboard", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction
  
  virtual function void write(input transaction t);
    bit [3:0] exp;
    tr = t;
    
    
    `uvm_info("SCO", $sformatf("Data recv from MON a=%0h | b=%0h | c=%0h d=%0h | sel=%0h | y=%0h", tr.a, tr.b, tr.c, tr.d, tr.sel, tr.y), UVM_NONE);
      
    case(tr.sel)
      2'b00: exp = tr.a;
      2'b01: exp = tr.b;
      2'b10: exp = tr.c;
      2'b11: exp = tr.d;
    endcase
    
    
    if(tr.y == exp)
      `uvm_info("SCO", "Test Passed", UVM_NONE)
    else
      `uvm_info("SCO", "Test Failed", UVM_NONE)
  endfunction
        
endclass


class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  function new (input string path = "Agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  monitor m;
  driver d;
  uvm_sequencer#(transaction)seqr;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("m", this);
    d = driver::type_id::create("d", this);
    seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  function new (input string path = "ENV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  scoreboard s;
  agent a;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    s = scoreboard::type_id::create("s", this);
    a = agent::type_id::create("a", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.m.send.connect(s.recv);
  endfunction
  
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  generator gen;
  env e;
  
  function new (input string path = "TEST", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    gen = generator::type_id::create("gen", this);
    e   = env::type_id::create("e", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seqr);
    phase.drop_objection(this);
  endtask
  
endclass

module tb();
  
  mux_if mif();
  
  mux dut (.a(mif.a), .b(mif.b), .c(mif.c), .d(mif.d), .sel(mif.sel), .y(mif.y));
  
  
  initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
  end
  
  initial begin
    uvm_config_db#(virtual mux_if)::set(null, "uvm_test_top.e.a*", "mif", mif);
    run_test("test");
  end
endmodule
  
