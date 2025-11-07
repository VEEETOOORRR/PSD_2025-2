`include "Tipos.sv"

module decodificador_de_teclado (
input 		logic		clk,
input		logic		rst,
input		logic 		enable,
input 		logic [3:0] col_matriz,
output 	    logic [3:0] lin_matriz,
output 	    senhaPac_t	digitos_value,
output		logic 		digitos_valid
);

endmodule
