module controladora #( parameter DEBOUNCE_P = 300,
   parameter SWITCH_MODE_MIN_T = 5000,
   parameter AUTO_SHUTDOWN_T = 30000) 
(input 		logic 	clk, 
input		logic	rst,
input		logic	infravermelho,
input		logic	push_button,
output 	    logic	led,
output		logic	saida );

logic clk_1khz;
logic A, B, C, D;

divfreq df(
    .clk(clk),
    .rst(rst),
    .clk_i(clk_1khz)
);

submodulo_1 sm1 (
    .clk(clk_1khz),
    .rst(rst),
    .push_button(push_button),
    .a(A),
    .b(B),
    .c(C),
    .d(infravermelho)
);


submodulo_2 #(.DEBOUNCE_P(DEBOUNCE_P), .SWITCH_MODE_MIN_T(SWITCH_MODE_MIN_T)) sm2 (
    .clk(clk_1khz),
    .rst(rst),
    .push_button(push_button),
    .A(A),
    .B(B)
);

submodulo_3 #(.AUTO_SHUTDOWN_T(AUTO_SHUTDOWN_T)) sm3 (
    .clk(clk_1khz),
    .rst(rst),
    .push_button(push_button),
    .C(C)
);





endmodule
