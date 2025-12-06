module FechaduraTop (
    input 	logic clk, rst, sensor_de_contato, botao_interno, botao_bloqueio, botao_config,
    input	logic [3:0] matricial_col,
    output	logic [3:0] matricial_lin,
    output 	logic [6:0] dispHex0, dispHex1, dispHex2, dispHex3, dispHex4, dispHex5,
    output logic tranca, bip );

    // Sinais Internos (nomes consistentes com as instâncias abaixo)
    logic           reset_out;                      // saída do resetHold5s
    logic           enable_keyword;
    logic           digitos_valid_keyword;
    senhaPac_t      digitos_value_keyword;
    bcdPac_t        bcd_packet_operacional;
    bcdPac_t        bcd_packet_setup;
    logic           display_enable_operational;
    logic           display_enable_setup;
    setupPac_t      setup_data;
    logic           data_setup_finished;
    logic           setup_online;
	 logic			  clk_div;
	 


	divfreq  div(
		.rst(reset_out),
		.clk(clk),
		.clk_i(clk_div)
		);	 

    // Reset (gera reset_out)
    resetHold5s #(.TIME_TO_RST(5000)) Reset (
        .clk(clk_div),
        .reset_in(rst),
      	.reset_out(reset_out)
    );

    // Teclado
    decodificador_de_teclado Teclado (
        .clk(clk_div),
        .rst(rst),
        .enable(enable_keyword),
        .col_matriz(matricial_col),
        .lin_matriz(matricial_lin),
        .digitos_value(digitos_value_keyword),
        .digitos_valid(digitos_valid_keyword)
    );

    // Display
    display Display(
        .clk(clk_div),
        .rst(rst),
        .enable_o(display_enable_operational),
        .enable_s(display_enable_setup),
        .bcd_packet_operacional(bcd_packet_operacional),
        .bcd_packet_setup(bcd_packet_setup),
        .HEX0(dispHex0),
        .HEX1(dispHex1),
        .HEX2(dispHex2),
        .HEX3(dispHex3),
        .HEX4(dispHex4),
        .HEX5(dispHex5)
    );

    // Setup
    setup Setup(
        .clk(clk_div),
        .rst(rst),
        .setup_on(setup_online),
        .digitos_value(digitos_value_keyword),
        .digitos_valid(digitos_valid_keyword),
        .display_en(display_enable_setup),
        .bcd_pac(bcd_packet_setup),
        .data_setup_new(setup_data),
        .data_setup_ok(data_setup_finished)
    );

    // Operacional 
    operacional Operacional(
        .clk(clk_div),
        .rst(rst),
        .sensor_contato(sensor_de_contato),
        .botao_interno(botao_interno),
        .botao_bloqueio(botao_bloqueio),
        .botao_config(botao_config),
        .data_setup_new(setup_data),
        .data_setup_ok(data_setup_finished),
        .digitos_value(digitos_value_keyword),
        .digitos_valid(digitos_valid_keyword),
        .bcd_pac(bcd_packet_operacional),
        .teclado_en(enable_keyword),
        .display_en(display_enable_operational),
        .setup_on(setup_online),
        .tranca(tranca),
        .bip(bip)
    );



endmodule