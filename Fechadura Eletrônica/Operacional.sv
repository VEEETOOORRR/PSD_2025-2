`include "Tipos.sv"

module operacional(
    input		logic		clk,
	input		logic		rst,
	input		logic		sensor_contato,
	input		logic		botao_interno,
	input		logic		botao_bloqueio,
	input		logic		botao_config,
    input		setupPac_t 	data_setup_new,
	input		logic		data_setup_ok,
	input		senhaPac_t	digitos_value,
	input		logic		digitos_valid,
	output		bcdPac_t	bcd_pac,
	output 		logic 		teclado_en,
	output		logic		display_en,
	output		logic		setup_on,
    output		logic		tranca,
	output		logic		bip
);
endmodule
