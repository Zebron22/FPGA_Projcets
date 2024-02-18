`timescale 1ns/1ps

module tb_alu();
  logic [31:0] a, b;
  logic [1:0]  ALUControl;
  logic [31:0] Result;
  logic [3:0]  ALUFlags;
  
  alu DUT(
    .a(a),
    .b(b),
    .ALUControl(ALUControl),
    .Result(Result),
    .ALUFlags(ALUFlags)
  );
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    //$monitor("Time=%t, a=%d, b=%d, ALUControl=%b, Result=%d, ALUFlags=%b", $time, a, b, ALUControl, Result, ALUFlags);
    a = 0;
    b = 0;
    
  end
  
  initial begin
    fork 
      begin //process for add
        $display("Process ADD started at time = %0t.", $time);
        a = $urandom_range(100);
        b = $urandom_range(100);
        #1 ALUControl = 2'b00;
        $monitor("Process ADD: Time=%t, a=%d, b=%d, ALUControl=%b, Result=%d, ALUFlags=%b", $time, a, b, ALUControl, Result, ALUFlags);
      end
      
      begin //process for subtract
        $display("Process SUB started at time = %0t.", $time);
        #2 ALUControl = 2'b01;
        a = $urandom_range(100);
        b = $urandom_range(100);
        $monitor("Process SUB: Time=%t, a=%d, b=%d, ALUControl=%b, Result=%d, ALUFlags=%b", $time, a, b, ALUControl, Result, ALUFlags);
      end
      
      begin //process for AND
        $display("Process AND started at time = %0t.", $time);
        #3 ALUControl = 2'b10;
        a = $urandom_range(100);
        b = $urandom_range(100);
        $monitor("Process AND: Time=%t, a=%d, b=%d, ALUControl=%b, Result=%d, ALUFlags=%b", $time, a, b, ALUControl, Result, ALUFlags);
      end
      
      begin //procees for OR
        $display("Process OR started at time = %0t.", $time);
        #4 ALUControl = 2'b11;
        a = $urandom_range(100);
        b = $urandom_range(100);
        $monitor("Process OR: Time=%t, a=%d, b=%d, ALUControl=%b, Result=%d, ALUFlags=%b", $time, a, b, ALUControl, Result, ALUFlags);
      end
      
    join
    
  end
  
endmodule
