module controladora #( parameter DEBOUNCE_P = 300,
   parameter SWITCH_MODE_MIN_T = 5000,
   parameter AUTO_SHUTDOWN_T = 30000) 
(input 		logic 	clk, 
input		logic	rst,
input		logic	infravermelho,
input		logic	push_button,
output 	    logic	led,
output		logic	saida );

logic A, B, C, D, enable_infra;

submodulo_1 sm1 (
    .clk(clk),
    .rst(rst),
    .a(A),
    .b(B),
    .c(C),
    .d(infravermelho),
	.led(led),
	.saida(saida),
    .enable_sub_3(enable_infra)
);


submodulo_2 #(.DEBOUNCE_P(DEBOUNCE_P), .SWITCH_MODE_MIN_T(SWITCH_MODE_MIN_T)) sm2 (
    .clk(clk),
    .rst(rst),
    .push_button(push_button),
    .A(A),
    .B(B)
);

submodulo_3 #(.AUTO_SHUTDOWN_T(AUTO_SHUTDOWN_T)) sm3 (
    .clk(clk),
    .rst(rst),
    .infravermelho(infravermelho),
    .C(C),
    .enable(enable_infra)
);

endmodule
