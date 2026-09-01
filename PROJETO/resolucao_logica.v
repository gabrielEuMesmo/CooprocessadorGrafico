module resolucao_logica(   input wire clock,     // 25 MHz
    input wire reset,     // Active high
	 input [7:0]data,				// Pixel color data (RRRGGGBB)
	 input wren,
	 input [16:0] wraddress,
    output [8:0] next_x_log,  // x-coordinate of NEXT pixel that will be drawn
    output [7:0] next_y_log,  // y-coordinate of NEXT pixel that will be drawn
    output wire hsync,    // HSYNC (to VGA connector)
    output wire vsync,    // VSYNC (to VGA connctor)
    output [7:0] red,     // RED (to resistor DAC VGA connector)
    output [7:0] green,   // GREEN (to resistor DAC to VGA connector)
    output [7:0] blue,    // BLUE (to resistor DAC to VGA connector)
    output sync,          // SYNC to VGA connector
    output clk,           // CLK to VGA connector
    output blank          // BLANK to VGA connector
);
reg clock_25;
wire [9:0] next_x, next_y;
wire [7:0] color_in1, color_in2;
reg [1:0] count;

reg [16:0] readVGA;
//
reg VGA;

wire [7:0] color_in = (VGA ? color_in1 :color_in2);

wire wren1 = (VGA ? 1'b0 :wren);

wire wren2 = (VGA ? wren:1'b0 );

assign next_x_log = next_x/2;
assign next_y_log = next_y/2;

//Divisor de clock

always @(posedge clock or posedge reset) begin
        if (reset) begin
            count   <= 2'b00;
            clock_25 <= 1'b0;
				
        end else begin
				
            count   <= count + 1'b1;
            clock_25 <= count[1]; // O bit 1 alterna a cada 2 pulsos do clk_in
        end
    end
always @(*) begin
	readVGA = (next_y_log*320) + next_x_log;
	
	
end

always @(posedge vsync) begin
	
		if(VGA)begin
			VGA <= 1'b0;
		end else begin
			VGA <= 1'b1;
		end
end
RAMVIDEO(
	clock,
	data,
	readVGA,
	wraddress,
	wren1,
	color_in1
);
	
RAMVIDEO(
	clock,
	data,
	readVGA,
	wraddress,
	wren2,
	color_in2
);




	 
 vga_driver (
    clock_25,     // 25 MHz
    reset,     // Active high
    color_in, // Pixel color data (RRRGGGBB)
    next_x,  // x-coordinate of NEXT pixel that will be drawn
    next_y,  // y-coordinate of NEXT pixel that will be drawn
    hsync,    // HSYNC (to VGA connector)
    vsync,    // VSYNC (to VGA connctor)
    red,     // RED (to resistor DAC VGA connector)
    green,   // GREEN (to resistor DAC to VGA connector)
    blue,    // BLUE (to resistor DAC to VGA connector)
    sync,          // SYNC to VGA connector
    clk,           // CLK to VGA connector
    blank          // BLANK to VGA connector
);
endmodule