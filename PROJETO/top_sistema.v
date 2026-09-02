module top_sistema (
    input  wire        clock,      
    input  wire        reset,     
    input  wire [3:0]  KEY,
    input  wire [9:0]  SW,
    input  wire        layer_order, 

    output wire        hsync,
    output wire        vsync_out,   
    output wire [7:0]  red,
    output wire [7:0]  green,
    output wire [7:0]  blue,
    output wire        sync,
    output wire        vga_clk,     
    output wire        blank,

    output wire [1:0]  LED_Modo,
    output wire [1:0]  LED_SubEstado,
	 
	 output LEDIDLE		
);

  
    wire [1:0]  w_bg_Roll;
    wire        w_bg_WRoll;
    wire [5:0]  w_bg_x_tile;
    wire [4:0]  w_bg_y_tile;
    wire        w_bg_write;
    wire [7:0]  w_bg_color;

    wire [1:0]  w_pol_Address;  
    wire [1:0]  w_pol_cordenada;
    wire [8:0]  w_pol_x;
    wire [7:0]  w_pol_y;
    wire [7:0]  w_pol_cor;
    wire        w_pol_visivel;
    wire        w_pol_trapezio;
    wire        w_pol_salva;

    wire [5:0]  w_spr_write_idx;
    wire [31:0] w_spr_write_data;
    wire        w_spr_write_en;

   
    wire [16:0] w_address;
    wire [7:0]  w_pixel;
    wire        w_wren;
    wire        w_vsync;
    wire        w_camada_ativa;

    wire        reset_n = ~reset; 

  
    controlador_MEF u_controlador (
        .clk           (clock),
        .KEY           (KEY),
        .SW            (SW),
        .bg_Roll       (w_bg_Roll),
        .bg_WRoll      (w_bg_WRoll),
        .bg_x_tile     (w_bg_x_tile),
        .bg_y_tile     (w_bg_y_tile),
        .bg_write      (w_bg_write),
        .bg_color      (w_bg_color),
        .pol_Address   (w_pol_Address),
        .pol_cordenada (w_pol_cordenada),
        .pol_x         (w_pol_x),
        .pol_y         (w_pol_y),
        .pol_cor       (w_pol_cor),
        .pol_visivel   (w_pol_visivel),
        .pol_trapezio  (w_pol_trapezio),
        .pol_salva     (w_pol_salva),
        .spr_write_idx (w_spr_write_idx),
        .spr_write_data(w_spr_write_data),
        .spr_write_en  (w_spr_write_en),
        .LED_Modo      (LED_Modo),
        .LED_SubEstado (LED_SubEstado)
    );


    motorVideoTop u_video (
        .clk            (clock),
        .reset          (reset),
        .vsync          (w_vsync),
        .layer_order    (layer_order),

        .pol_polAddress (w_pol_Address),
        .pol_cordenada  (w_pol_cordenada),
        .pol_x          (w_pol_x),
        .pol_y          (w_pol_y),
        .pol_cor        (w_pol_cor),
        .pol_visivel    (w_pol_visivel),
        .pol_trapezio   (w_pol_trapezio),
        .pol_salva      (w_pol_salva),

        .bg_Roll        (w_bg_Roll),
        .bg_WRoll       (w_bg_WRoll),
        .bg_x_tile      (w_bg_x_tile),
        .bg_y_tile      (w_bg_y_tile),
        .bg_write       (w_bg_write),
        .bg_color       (w_bg_color),

        .spr_write_idx  (w_spr_write_idx),
        .spr_write_data (w_spr_write_data),
        .spr_write_en   (w_spr_write_en),

        .address        (w_address),
        .pixel          (w_pixel),
        .camada_ativa   (w_camada_ativa),
        .wren           (w_wren),
		  .LEDIDLE			(LEDIDLE)
    );


    resolucao_logica u_resolucao (
        .clock     (clock),
        .reset     (reset),       
        .data      (w_pixel),
        .wren      (w_wren),
        .wraddress (w_address),
        .hsync     (hsync),
        .vsync     (w_vsync),     
        .red       (red),
        .green     (green),
        .blue      (blue),
        .sync      (sync),
        .clk       (vga_clk),
        .blank     (blank)
    );

    assign vsync_out = w_vsync;

endmodule