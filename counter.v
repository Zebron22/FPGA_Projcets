module counter(i_clk, i_rst, i_inc, LEDR);
	
	//4-bit counter
	input i_clk;
	input i_rst;
	input i_inc;
	output reg [3:0] LEDR = 0;
	
	
	reg [32:0] counter = 0;
	
	
	always @ (posedge i_clk) begin
	//increments the counter
	
	counter <= counter + 1;
		
		//checks if the reset button has been pressed
		if (i_rst == 0) begin
			//if button has been pressed, LEDR and counter are set to 0
			LEDR <= 0;
			counter <= 0;
			//counter increments to 25,000,000 to get 1hz frequency
		end else if (counter == 25000000) begin
			//when counter reaches 25M limit, increment the LEDR by 1 and set counter to 0
			counter <= 0;
			LEDR <= LEDR + 1;
		end
	
	end
	
endmodule 