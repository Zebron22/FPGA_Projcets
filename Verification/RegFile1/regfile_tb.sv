`timescale 1ns/1ps

module regfile_tb();
  logic clk; 
  logic we3; 
  logic [3:0] ra1, ra2, ra3;
  logic [31:0] wd3, r15;
  logic [31:0] rd1, rd2;

  //A1/RD1 and A2/RD2 are read operations
  //A3/WD3 is write operation
  
  regfile DUT ( .clk(clk),
               .we3(we3),
               .ra1(ra1), //reading addresses
               .ra2(ra2),
               .ra3(ra3),
               .wd3(wd3),
               .r15(r15),
               .rd1(rd1),  //outputs as data is being read
               .rd2(rd2)); //outputs as data is being read
  
  always begin
    clk = 1;
    forever #1 clk = ~clk;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    $monitor("Time=%t, rd1=%h, rd2=%h", $time, rd1, rd2);
  end
  
  
  initial begin
    we3 = 0;
    ra1 = 0; 
    ra2 = 0;
    ra3 = 0;
    wd3 = 0;
    r15 = 32'hFFFFFFFF; //setting a default val in 32-bit hex for r15
    
    //write operation. Write 32'hAAAA_AAAA to A1
    #5;
    we3 = 1;
    ra3 = 4'd1; //selecting register to write to 
    wd3 = 32'haaaa_aaaa; //write data
    
    
    //read operation
    #10;
    we3 = 0;    //disable write
    ra1 = 4'd1; //read from register 2
    ra2 = 4'd2; //read from another register
    
    //write again
    #15;
    we3 = 1;
    ra3 = 4'd2;          //select register
    wd3 = 32'h1111_1111; //write data
    #20;
    ra3 = 4'd1; //writing again to rd1 address
    wd3 = 32'hABCD_1110;
    
    //read again
    #25;
    we3 = 0;
    ra1 = 4'd1;
    ra2 = 4'd2;
    
    //reading values from rd1 and rd2
    #50;
    ra1 = 4'b1111;
    ra2 = 4'b1111;
    
    #100;
    $finish;
    
  end
endmodule
