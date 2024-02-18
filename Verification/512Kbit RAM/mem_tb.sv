module mem_tb();
  
  //random array of 6 elements
  bit[15:0] address_array[];  
  
  //random data to write into array
  bit [7:0] data_to_write[];
  
  //data ro read
  bit [7:0] data_to_read[];
  
  //creating test count
  bit [7:0] eCount = 0;
  
  //associative array
  //array is index by address (element)
  bit[8:0] data_read_expect_assoc[bit[15:0]];
  
  
  //instantiation
  logic clk, write, read;
  logic [7:0] data_in;
  logic [15:0] address;
  logic [8:0] data_out;
  
  my_mem(clk, write, read, data_in, address, data_out);
  
  initial clk = 0;
  always #5 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
    //populating arrays with random vals
    address_array = new[6];
    data_to_write = new[6];
    
    foreach(address_array[i])
      address_array[i] = $urandom();
    $display("Address: %p", address_array);
    
    foreach(data_to_write[i])
      data_to_write[i] = $urandom();
    $display("Data: %p", data_to_write);
    
    //associative array creation
    //array is index by address (element)
    foreach(address_array[i])
      data_read_expect_assoc[address_array[i]] = {^data_to_write[i], data_to_write[i]};
    $display(data_read_expect_assoc);
    
    
    
    //Write operation
    for (int i = 0; i < 6; i++) begin
      @(posedge clk);
      write = 1;
      read = 0;
      address = address_array[i];
      data_in = data_to_write[i];
      @(posedge clk);
      write = 0;
    end
    
    //read operation
    //check results
    
    //I had to add add a clock cycle delay to properly read the values, otherwise the testbench would fail
    for (int i = 0; i < 6; i++) begin
      @(posedge clk);
      read = 1;
      address = address_array[i];
      @(posedge clk);
      if (data_out !== data_read_expect_assoc[address]) begin
        $display("Expect %h at address %h: got %h, Test Failed.", data_read_expect_assoc[address], address, data_out);
        eCount++;
      end
      else
        $display("Expect %h at address %h: got %h, Test Passed.", data_read_expect_assoc[address], address, data_out);
      @(posedge clk);
      read = 0;
    end
    $display("%h Errors found.", eCount);
    $finish;
    
    
    
    
  end
    endmodule;
