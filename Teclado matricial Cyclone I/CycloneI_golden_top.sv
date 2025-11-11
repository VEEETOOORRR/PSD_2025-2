module CycloneI_golden_top(
    input  logic        CLOCK_50, // 50MHZ
    output logic        BUZZER,   // PNP
    output logic [3:0]  HEX_EN,   // 4, 3, 2, 1
    output logic [7:0]  HEX_LED,  // A, B, C, D, E, F, G, POINT
    output logic [5:0]  LED,      // D2, D3, D4, D5, D6
    input  logic [3:0]  BUTTON,   // K1, K2, K3, K4 (PULLUP)
    input  logic [5:0]  DIP_U5,   // PULLUP
    input  logic [5:0]  DIP_U6,   // PULLDOWN
    //inout  logic [27:0] GPIO
    input logic [3:0] GPIO_I,
    output logic [3:0] GPIO_O
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

    // Correcoes de assignment SAIDA = ~ENTRADA
	assign BUZZER     = ~BUZZER_INV;
	assign HEX_EN     = ~HEX_EN_INV;
	assign HEX_LED    = ~HEX_LED_INV;
	assign LED        = ~LED_INV;
	assign BUTTON_INV = ~BUTTON;

    logic clk_slow, tecla_valid;
    logic [3:0] tecla_value;

    df #(.DIV(25000)) divfreq (.reset(BUTTON_INV[3]), .clock(CLOCK_50), .clk_i(clk_slow));

    decodificador_de_teclado dt (
        .clk(clk_slow),
        .rst(BUTTON_INV[3]),
        .col_matriz({GPIO_I[0], GPIO_I[1], GPIO_I[2], GPIO_I[3]}), //126, 124, 122, 120
        .lin_matriz({GPIO_O[0], GPIO_O[1], GPIO_O[2], GPIO_O[3]}), //134, 132, 130, 128
        .tecla_valid(LED_INV[4]),
        .tecla_value(LED_INV[3:0])
    );

endmodule