module dff
  (
    input clk, rst, din, ////din - data input, rst - active high synchronus
    output reg dout ////dout - data output
  );
  
  always@(posedge clk)
    begin
      if(rst == 1'b1) 
        dout <= 1'b0;
      else
        dout <= din;
    end
  
endmodule

interface dff_if();
  logic clk;
  logic rst;
  logic din;
  logic dout;
endinterface

//// TB ////
`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
  
  rand bit din;
       bit dout;
       bit rst;
  
  `uvm_object_utils_begin(transaction)
  `uvm_field_int(din, UVM_DEFAULT)
  `uvm_field_int(dout, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new (input string path = "TRANS");
    super.new(path);
  endfunction
  
endclass


class generator extends uvm_sequence#(transaction);
  `uvm_object_utils(generator)
  
  transaction t;
  
  function new (input string path = "GEN");
    super.new(path);
  endfunction
  
  virtual task body();
    repeat(10) begin
    t = transaction::type_id::create("t");
      start_item(t);
      assert(t.randomize());
      `uvm_info("GEN", $sformatf("Data send to Driver: din=%0d", t.din), UVM_NONE)
      finish_item(t);
    end
  endtask
 
endclass


class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
  
  function new (input string path = "DRV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  transaction tr;
  virtual dff_if dif;
  
  
  //reset logic
  task reset_dut();
    dif.rst <= 1'b1;
    dif.din <= 1'b0;
    repeat(5) @(posedge dif.clk);  //waiting 5 clock cycle
    dif.rst <= 1'b0;
    `uvm_info("DRV", "Reset Done", UVM_NONE)
  endtask
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    if(!uvm_config_db#(virtual dff_if)::get(this, "", "dif", dif))
      `uvm_error("DRV", "Unable to access uvm_config_db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    reset_dut();
    forever begin
      seq_item_port.get_next_item(tr);
      dif.din <= tr.din;
      `uvm_info("DRV", $sformatf("Triggered DUT: din=%0d", tr.din), UVM_NONE);
      seq_item_port.item_done();
      
      repeat(2)@(posedge dif.clk);  //each new transaction is send after 2 clock cycles
    end
  endtask
endclass

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  uvm_analysis_port#(transaction) send;
  
  function new (input string path = "MON", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  transaction t;
  virtual dff_if dif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
    t = transaction::type_id::create("t");
    if(!uvm_config_db#(virtual dff_if)::get(this, "", "dif", dif))
      `uvm_error("MON", "Unable to access uvm_config_db");
  endfunction
  
  
  //collect respose from dut
  virtual task run_phase(uvm_phase phase);
    @(negedge dif.rst);  //waiting reset to complete
    forever begin
      repeat(2) @(posedge dif.clk);  //wait for 2 clock as we send new data after 2 clock 
      t.din = dif.din;  //collect response from dut
      t.dout = dif.dout;
      t.rst  = dif.rst;
      `uvm_info("MON", $sformatf("Send to SCO: din=%0d", t.din), UVM_NONE);
      send.write(t);
    end
  endtask
endclass


class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(transaction, scoreboard) recv;
    
  function new (input string path = "SCO", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction
  
  virtual function void write(input transaction t);
    bit exp;
    `uvm_info("SCO", $sformatf("Data recvd from Mon: din=%0d, dout=%0d", t.din, t.dout), UVM_NONE);
    
    if(t.rst)
      exp = 0;
    else
      exp = t.din;
    
    
    if(t.dout !== exp)
      `uvm_error("SCO", "Mismaatched Detected");
      
  endfunction
endclass
      
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  function new (input string path = "AGE", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  monitor m;
  driver d;
  uvm_sequencer#(transaction) seq;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m = monitor::type_id::create("m", this);
    d = driver::type_id::create("d", this);
    seq = uvm_sequencer#(transaction)::type_id::create("seq", this);  
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(seq.seq_item_export);
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
  
  function new(input string path = "TEST", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  generator gen;
  env e;
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     gen = generator::type_id::create("gen", this);
     e   = env::type_id::create("e", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.a.seq);
    #60;
    phase.drop_objection(this);
  endtask
endclass

      
module tb();
  
  dff_if dif();
  
  dff dut(.clk(dif.clk), .rst(dif.rst), .din(dif.din), .dout(dif.dout));
  
  initial begin
    dif.clk = 0;
    forever #5 dif.clk = ~dif.clk;
  end
  
  initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
  end
  
  initial begin
    uvm_config_db#(virtual dff_if)::set(null, "*", "dif", dif);
    run_test("test");
  end
endmodule
      
      
