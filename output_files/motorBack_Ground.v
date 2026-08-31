module motorBack_Ground(
	input reset,
	input enable,
	input clk,
	input [1:0] Roll,
	input WRoll,
	input [5:0] x_tile,
	input [4:0] y_tile,
	input write,
	input [7:0] color, 
	output [7:0] colorOut,
	output [16:0] address,
	output done
);
	reg [7:0] right_edge [0:29];
	reg [7:0] left_edge [0:29];
	reg [7:0] down_edge [0:39];
	reg [7:0] up_edge [0:39];
	
	wire [8:0] next_x;
	wire [7:0] next_y;
	
	reg [7:0] tileMap [0:1199];
	
	integer i;
	
	wire [11:0] enderecoTile;
	
	wire [5:0] tile_x = next_x[8:3]; // next_x / 8
    wire [4:0] tile_y = next_y[7:3]; // next_y / 8
    
    assign enderecoTile = (tile_y * 6'd40) + tile_x; 
    assign colorOut = tileMap[enderecoTile];
    
    // 2. Inferência correta de Memória BRAM (Sem Reset Assíncrono!)
    always @(posedge clk or posedge enable) begin 
			if(enable)begin
				for(i=0; i<1200; i = i +1)begin
					tileMap[i] <= 0;
				end
			end else begin
			
				  if (write) begin
						// Como x_tile e y_tile já vêm de fora (0 a 39 e 0 a 29), a fórmula é direta
						tileMap[(y_tile * 40) + x_tile] <= color;
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
	
	