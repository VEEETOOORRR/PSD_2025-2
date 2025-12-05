module FechaduraTop (
    input 	logic clk, rst, sensor_de_contato, botao_interno, botao_bloqueio, botao_config,
    input	logic [3:0] matricial_col,
    output	logic [3:0] matricial_lin,
    output 	logic [6:0] dispHex0, dispHex1, dispHex2, dispHex3, dispHex4, dispHex5,
    output logic tranca, bip );

    logic rst_5s;

    resetHold5s ResetHold #(TIME_TO_RST = 5)(
        .clk(clk),
        .reset_in(rst),
        .reset_out(rst_5s),
       );


    operacional Operacional(
        .clk(clk),
        .rst(rst_5s),
        .sensor_contato(sensor_de_contato),
        .botao_bloqueio(botao_bloqueio),
        .botao_config(botao_config),
        .data_setup_new(),
        .data_setup_ok(),
        .digitos_value(),
        .digitos_valid(),
        .bcd_pac(),
        .teclado_en(),
        .display_en(),
        .setup_on(),
        .tranca(tranca),
        .bip(bip)
    );

    setup Setup(
        .clk(clk),
        .rst(rst_5s),
        .setup_on(),
        .digitos_value(),
        .digitos_valid(),
        
    )




endmodule