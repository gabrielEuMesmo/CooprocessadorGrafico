module contadorVid(
	input reset,
	input clk,
	input enable,
	output reg [8:0] x,
	output reg [7:0] y,
	output reg [16:0] address,
	output reg done);
	
	reg [16:0] count;
	reg contando;
	
	
	always @(posedge clk or posedge enable or negedge reset)begin
		if(~reset)begin
			count = 0;
			
		end else if(enable)begin
			
			done = 0;
			count = 0;
			contando = 1;
			
		end else if(clk && contando)begin
		
			count = count +1;
			
		end else if(count == 76800)begin
		
			count = 0;
			contando = 0;
			done = 1;
			
		end
	end
	
	
	always @(*)begin
	
		address = count;
		y = count/320;
		x = count%320;
		
	end
	
endmodule
		
	
	