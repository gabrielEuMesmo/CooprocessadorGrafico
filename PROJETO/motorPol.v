module motorPol(
	input enable,
	input clk,
	input [2:0] polAddress,
	input [1:0] cordenada,
	input [8:0] x,
	input [7:0] y,
	input [7:0] cor,
	input visivel,
	input trapezio,
	input salva,
	input reset,
	output [16:0] memAdress,
	output reg [7:0] pixelS,
	output done

);

	reg [77:0] pol [0:7];
	
	wire [7:0] pixel [0:7];
	wire [8:0] next_x;
	wire [7:0] next_y;
	
	integer i;
	genvar e;
	integer u;
	
	always @(posedge salva or negedge reset)begin 
		if(!reset)begin
			for(i = 0; i < 8; i = i +1)begin
				pol[i] = 0;
			end
		end else begin
			if (cordenada == 0) begin
				pol[polAddress]= {visivel, trapezio, cor, pol[polAddress][67:51], pol[polAddress][50:34], pol[polAddress][33:17], x, y};
			end else if (cordenada == 1) begin
				pol[polAddress]= {visivel, trapezio, cor, pol[polAddress][67:51], pol[polAddress][50:34], x, y, pol[polAddress][16:0]};
			end else if (cordenada == 2) begin
				pol[polAddress]= {visivel, trapezio, cor, pol[polAddress][67:51], x, y, pol[polAddress][33:17], pol[polAddress][16:0]};
			end else if (cordenada == 3) begin
				pol[polAddress]= {visivel, trapezio, cor, x, y, pol[polAddress][50:34], pol[polAddress][33:17], pol[polAddress][16:0]};
			end
		end
		
	end
	
poligono_gerador(
	 .trapezio(pol[0][76]),
	 .x(next_x),
	 .y(next_y),

	 .x0(pol[0][16:8]),
	 .y0(pol[0][7:0]),

	 .x1(pol[0][33:25]),
	 .y1(pol[0][24:17]),

	 .x2(pol[0][50:42]),
	 .y2(pol[0][41:34]),
	 
	 .x3(pol[0][67:59]),
	 .y3(pol[0][58:51]),

	 .color(pol[0][75:68]),

	 .pixel(pixel [0])
);

poligono_gerador(
	 .trapezio(pol[1][76]),
	 .x(next_x),
	 .y(next_y),

	 .x0(pol[1][16:8]),
	 .y0(pol[1][7:0]),

	 .x1(pol[1][33:25]),
	 .y1(pol[1][24:17]),

	 .x2(pol[1][50:42]),
	 .y2(pol[1][41:34]),
	 
	 .x3(pol[1][67:59]),
	 .y3(pol[1][58:51]),

	 .color(pol[1][75:68]),

	 .pixel(pixel [1])
);                   
                     
poligono_gerador(    
	 .trapezio(pol[2][76]),
	 .x(next_x),      
	 .y(next_y),      
	 
	 .x0(pol[2][16:8]),
	 .y0(pol[2][7:0]),

	 .x1(pol[2][33:25]),
	 .y1(pol[2][24:17]),

	 .x2(pol[2][50:42]),
	 .y2(pol[2][41:34]),
	
	 .x3(pol[2][67:59]),
	 .y3(pol[2][58:51]),

	 .color(pol[2][75:68]),

	 .pixel(pixel [2])
);

poligono_gerador(
	 .trapezio(pol[3][76]),
	 .x(next_x),
	 .y(next_y),

	 .x0(pol[3][16:8]),
	 .y0(pol[3][7:0]),

	 .x1(pol[3][33:25]),
	 .y1(pol[3][24:17]),

	 .x2(pol[3][50:42]),
	 .y2(pol[3][41:34]),
	
	 .x3(pol[3][67:59]),
	 .y3(pol[3][58:51]),

	 .color(pol[3][75:68]),

	 .pixel(pixel [3])
);

 
	 always @(*)begin
		for(u = 0; u < 8; u = u + 1)begin
			if(pixel[u])begin
				pixelS = pixel[u];
			end else begin
				pixelS = pixelS;
			end
		end
	 
	 end
	 
		contadorVid(
			.reset(reset),
			.clk(clk),
			.enable(enable),
			.x(next_x),
			.y(next_y),
			.address(address),
			.done(done)
		);
		

endmodule