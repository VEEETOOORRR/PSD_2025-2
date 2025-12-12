module FechaduraTop (
	
  
  	input 	logic clk, 
  	input 	logic rst, 
  	input 	logic sensor_de_contato, 
  	input 	logic botao_interno, 
  	input 	logic botao_bloqueio, 
  	input 	logic botao_config,
	input		logic [3:0] matricial_col,
	output	logic [3:0] matricial_lin,
	output 	logic [6:0] dispHex0, 
  	output 	logic [6:0] dispHex1, 
	output 	logic [6:0] dispHex2, 
  	output 	logic [6:0] dispHex3, 
  	output 	logic [6:0] dispHex4, 
	output 	logic [6:0] dispHex5, 
	output 	logic tranca, 
  	output 	logic bip

);
   
  	// Sinais Internos
  	 logic           reset_out;                                // Output do módulo RESET
    logic           enable_keyword;                           // Output do módulo TECLADO
    logic           digitos_valid_keyword;                    // Output do módulo TECLADO
    senhaPac_t      digitos_value_keyword;                    // Output do módulo TECLADO
    bcdPac_t        display_operational;                      // Output do módulo DISPLAY
    bcdPac_t        display_setup;                            // Output do módulo DISPLAY
    logic           display_enable_operational;               // Output do módulo DISPLAY
    logic           display_enable_setup;                     // Output do módulo DISPLAY
    setupPac_t      setup_data;                               // Output do módulo SETUP
    logic           data_setup_finished;                      // Output do módulo SETUP
    logic           setup_online;                             // Output do módulo SETUP
  
  	//assign setup_on = setup_online;
  
  	// Reset
	resetHold5s #(.TIME_TO_RST(5)) Reset(
        .clk(clk),
        .reset_in(rst),
      	.reset_out(reset_out)
    );
      
  	// Teclado
    decodificador_de_teclado Teclado (
        .clk(clk),
        .rst(reset_out),
        .enable(enable_keyword),
        .col_matriz(matricial_col),
        .lin_matriz(matricial_lin),
        .digitos_value(digitos_value_keyword),
        .digitos_valid(digitos_valid_keyword)
    );
    
  	// Display
    display Display(
        .clk(clk),
        .rst(reset_out),
        .enable_o(display_enable_operational),
        .enable_s(display_enable_setup),
        .bcd_packet_operacional(display_operational),
        .bcd_packet_setup(display_setup),
        .HEX0(dispHex0),
        .HEX1(dispHex1),
        .HEX2(dispHex2),
        .HEX3(dispHex3),
        .HEX4(dispHex4),
        .HEX5(dispHex5)
    );
  
  	// Setup
    setup Setup(
        .clk(clk),
        .rst(reset_out),
        .setup_on(setup_online),
        .digitos_value(digitos_value_keyword),
        .digitos_valid(digitos_valid_keyword),
        .display_en(display_enable_setup),
      	.bcd_pac(display_setup),
        .data_setup_new(setup_data),
        .data_setup_ok(data_setup_finished)
    );
  
 	// Operacional 
    operacional Operacional(
        .clk(clk),
        .rst(reset_out),
        .sensor_contato(sensor_de_contato),
        .botao_interno(botao_interno),
        .botao_bloqueio(botao_bloqueio),
        .botao_config(botao_config),
        .data_setup_new(setup_data),
        .data_setup_ok(data_setup_finished),
        .digitos_value(digitos_value_keyword),
        .digitos_valid(digitos_valid_keyword),
      	.bcd_pac(display_operational),
        .teclado_en(enable_keyword),
        .display_en(display_enable_operational),
        .setup_on(setup_online),
        .tranca(tranca),
        .bip(bip)
    );


endmodule