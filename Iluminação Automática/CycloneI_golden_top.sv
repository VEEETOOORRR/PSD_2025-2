module CycloneI_golden_top(
    input  logic        CLOCK_50, // 50MHZ
    output logic        BUZZER,   // PNP
    output logic [3:0]  HEX_EN,   // 4, 3, 2, 1
    output logic [7:0]  HEX_LED,  // A, B, C, D, E, F, G, POINT
    output logic [5:0]  LED,      // D2, D3, D4, D5, D6
    input  logic [3:0]  BUTTON,   // K1, K2, K3, K4 (PULLUP)
    input  logic [5:0]  DIP_U5,   // PULLUP
    input  logic [5:0]  DIP_U6,   // PULLDOWN
    inout  logic [27:0] GPIO
);

    // Inicializacao
    initial begin
    BUZZER  = 1;
    HEX_EN  = 4'b1111;
    HEX_LED = 8'b11111111;
    LED     = 6'b111111;
    end

    // Sinais internos
	logic       BUZZER_INV  = 0;
	logic [5:0] LED_INV     = 6'b000000;
	logic [3:0] HEX_EN_INV  = 4'b0000;
	logic [7:0] HEX_LED_INV = 8'b00000000;
	logic [3:0] BUTTON_INV  = 4'b0000;



    // Corre��es de assignment SAIDA = ~ENTRADA
	assign BUZZER     = ~BUZZER_INV;
	assign HEX_EN     = ~HEX_EN_INV;
	assign HEX_LED    = ~HEX_LED_INV;
	assign LED        = ~LED_INV;
	assign BUTTON_INV = ~BUTTON;

	controladora #(
	.DEBOUNCE_P(300),
   .SWITCH_MODE_MIN_T(5000),
   .AUTO_SHUTDOWN_T(30000)) control (
	.clk(CLOCK_50), 
	.rst(BUTTON_INV[0]),
	.infravermelho(BUTTON_INV[1]),
	.push_button(BUTTON_INV[2]),
	.led(LED_INV[0]),
	.saida(LED_INV[1]));

endmodule