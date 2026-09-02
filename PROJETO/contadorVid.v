/*module contadorVid(
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
			contando =0;
			done = 0;
			
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
	
endmodule*/

module contadorVid(
    input             reset,   
    input             clk,
    input             enable,
    output reg [8:0]  x,
    output reg [7:0]  y,
    output reg [16:0] address,
    output reg        done
);

    reg [16:0] count;
    reg        contando;
    reg        enable_d;  

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            count    <= 17'd0;
            contando <= 1'b0;
            done     <= 1'b0;
            enable_d <= 1'b0;
        end else begin
            enable_d <= enable;

            if (enable && !enable_d) begin
               
                count    <= 17'd0;
                contando <= 1'b1;
                done     <= 1'b0;
            end else if (contando) begin
                if (count == 17'd76799) begin
                    contando <= 1'b0;
                    done     <= 1'b1;
                end else begin
                    count <= count + 1'b1;
                end
            end
				if(done)begin
					done     <= 1'b0;
				end
        end
    end

    always @(*) begin
        address = count;
        y = count / 320;
        x = count % 320;
    end

endmodule
		
	
	