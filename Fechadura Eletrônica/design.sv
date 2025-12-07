// ============================================================
//                        TIPOS
// ============================================================

typedef struct packed {
    logic [19:0] [3:0] digits;
} senhaPac_t;

typedef struct packed {
	logic [3:0] BCD0;
    logic [3:0] BCD1;
    logic [3:0] BCD2;
    logic [3:0] BCD3;
    logic [3:0] BCD4;
    logic [3:0] BCD5;
} bcdPac_t;

typedef struct packed {
	logic bip_status;
	logic [5:0] bip_time;
	logic [5:0] tranca_aut_time;
    senhaPac_t  senha_master;
 	senhaPac_t  senha_1;
    senhaPac_t  senha_2;
    senhaPac_t  senha_3;
    senhaPac_t  senha_4;
} setupPac_t;

// ============================================================
//                        FIM TIPOS
// ============================================================

// ============================================================
//               MÓDULO DE VALIDAÇÃO DE SENHA
// ============================================================

module verifica_senha(

    input logic         clk,
    input logic         rst,
    input logic         valid_in,                   // Pulso que indica que há uma nova senha para validar
    input senhaPac_t    senha_teste,                // Senha usada para testar
    input senhaPac_t    senha_real,                 // senha que deve ser testada
    output logic        senha_ok,                   // senha correta 1, senha incorreta 0
    output logic        done                        // verificação finalizada

);

    typedef enum logic [4:0] {

        IDLE_SENHA,
        DIMENSAO,
        VALIDANDO_SENHA,
        INCORRETA,
        CORRETA

    } estado_t;

    estado_t estado;
    logic [4:0] size_senha, pulse_value;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            estado <= IDLE_SENHA;
            size_senha <= 0;
            pulse_value <= 0;
        end

        else begin
            case(estado)

                IDLE_SENHA: begin
                    if (valid_in) begin
                        estado <= DIMENSAO;
                    end else begin 
                        estado <= IDLE_SENHA;
                    end
                    
                end

                DIMENSAO: begin

                    // Estado para descobrir o tamanho da senha
                    if ((senha_real.digits[3] == 4'hF) || (senha_real.digits == {20{4'hF}})) estado <= INCORRETA; // senha invalida
                    else begin
                        if      (senha_real.digits[4]  == 4'hF) size_senha <= 4;
                        else if (senha_real.digits[5]  == 4'hF) size_senha <= 5;
                        else if (senha_real.digits[6]  == 4'hF) size_senha <= 6;
                        else if (senha_real.digits[7]  == 4'hF) size_senha <= 7;
                        else if (senha_real.digits[8]  == 4'hF) size_senha <= 8;
                        else if (senha_real.digits[9]  == 4'hF) size_senha <= 9;
                        else if (senha_real.digits[10] == 4'hF) size_senha <= 10;
                        else if (senha_real.digits[11] == 4'hF) size_senha <= 11;
                        else if (senha_real.digits[12] == 4'hF) size_senha <= 12;
                        estado <= VALIDANDO_SENHA;
                    end

                end

                VALIDANDO_SENHA: begin
                    if ((pulse_value + size_senha) > 20) estado <= INCORRETA; // senha não se encontra no array
                    else begin
                        if (size_senha == 4) begin
                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3]
                            ) begin
                                estado <= CORRETA;                            
                            end 
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                        end

                        else if (size_senha == 5) begin

                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4]                       
                            ) begin
                                estado <= CORRETA;
                            end else begin
                                pulse_value <= pulse_value + 1;
                            end

                        end

                        else if (size_senha == 6) begin

                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5]                
                            ) begin
                                estado <= CORRETA;
                            end

                            else begin
                                pulse_value <= pulse_value + 1;                            
                            end

                        end

                        else if (size_senha == 7) begin

                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5] &&
                                senha_real.digits[6] == senha_teste.digits[pulse_value+6]
                            ) begin
                                estado <= CORRETA;
                            end

                            else begin
                                pulse_value <= pulse_value + 1;
                            end

                        end

                        else if (size_senha == 8) begin

                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5] &&
                                senha_real.digits[6] == senha_teste.digits[pulse_value+6] &&
                                senha_real.digits[7] == senha_teste.digits[pulse_value+7] 
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end

                        end

                        else if (size_senha == 9) begin
                                
                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5] &&
                                senha_real.digits[6] == senha_teste.digits[pulse_value+6] &&
                                senha_real.digits[7] == senha_teste.digits[pulse_value+7] &&
                                senha_real.digits[8] == senha_teste.digits[pulse_value+8]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                            
                        end

                        else if (size_senha == 10) begin

                            if (senha_real.digits[0] == senha_teste.digits[pulse_value] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5] &&
                                senha_real.digits[6] == senha_teste.digits[pulse_value+6] &&
                                senha_real.digits[7] == senha_teste.digits[pulse_value+7] &&
                                senha_real.digits[8] == senha_teste.digits[pulse_value+8] &&
                                senha_real.digits[9] == senha_teste.digits[pulse_value+9]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                        end

                        else if (size_senha == 11) begin


                            if (senha_real.digits[0] == senha_teste.digits[pulse_value+0] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5] &&
                                senha_real.digits[6] == senha_teste.digits[pulse_value+6] &&
                                senha_real.digits[7] == senha_teste.digits[pulse_value+7] &&
                                senha_real.digits[8] == senha_teste.digits[pulse_value+8] &&
                                senha_real.digits[9] == senha_teste.digits[pulse_value+9] &&
                                senha_real.digits[10] == senha_teste.digits[pulse_value+10]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                    
                        end

                        else if (size_senha == 12) begin

                            if (senha_real.digits[0] == senha_teste.digits[pulse_value+0] &&
                                senha_real.digits[1] == senha_teste.digits[pulse_value+1] &&
                                senha_real.digits[2] == senha_teste.digits[pulse_value+2] &&
                                senha_real.digits[3] == senha_teste.digits[pulse_value+3] &&
                                senha_real.digits[4] == senha_teste.digits[pulse_value+4] &&
                                senha_real.digits[5] == senha_teste.digits[pulse_value+5] &&
                                senha_real.digits[6] == senha_teste.digits[pulse_value+6] &&
                                senha_real.digits[7] == senha_teste.digits[pulse_value+7] &&
                                senha_real.digits[8] == senha_teste.digits[pulse_value+8] &&
                                senha_real.digits[9] == senha_teste.digits[pulse_value+9] &&
                                senha_real.digits[10] == senha_teste.digits[pulse_value+10] &&
                                senha_real.digits[11] == senha_teste.digits[pulse_value+11]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                        end
                    end

                end

                INCORRETA: begin
                    estado <= IDLE_SENHA;
                end

                CORRETA: begin
                    estado <= IDLE_SENHA;
                end

            endcase         
        end
    end

    always_comb begin

        if (rst) begin
            senha_ok = 0;
            done = 0;
        end else begin
            case(estado)
                IDLE_SENHA: begin
                    senha_ok = 0;
                    done = 0;
                end

                DIMENSAO: begin
                    senha_ok = 0;
                    done = 0;
                end

                VALIDANDO_SENHA: begin
                    senha_ok = 0;
                    done = 0;
                end

                INCORRETA: begin
                    senha_ok = 0;
                    done = 1;
                end

                CORRETA: begin
                    senha_ok = 1;
                    done = 1;
                end

                default: begin
                    senha_ok = 0;
                    done = 0;
                end
            
            endcase

        end
    end

endmodule

// ============================================================
//              FIM MÓDULO DE VALIDAÇÃO DE SENHA
// ============================================================

// ============================================================
//                      MÓDULO DO RESET
// ============================================================

module resetHold5s #(parameter TIME_TO_RST = 5)(
    input logic clk, reset_in,
    output logic reset_out);


    logic [19:0] cont;

    always_ff @(posedge clk) begin
        if(reset_in) begin
            if(cont <= TIME_TO_RST*1000) cont <= cont + 1;
        end else cont <= 0; 

    end

    always_comb begin
        if(cont >= TIME_TO_RST*1000) reset_out = 1;
        else reset_out = 0;
    end


endmodule

// ============================================================
//                     FIM - MÓDULO DO RESET
// ============================================================

// ============================================================
//                      MÓDULO DO DISPLAY
// ============================================================

module display (
    input 		logic 		clk, 
    input 		logic 		rst,
    input 		logic 		enable_o, enable_s,
    input 		bcdPac_t 	bcd_packet_operacional, bcd_packet_setup,
    output 		logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    bcdPac_t bcd_packet_operacional_reg, bcd_packet_setup_reg;

    logic flag_enable; // Qual enable foi ativado por último, para razões de debug. 0 -> Operacional, 1 -> Setup

    always_ff @(posedge clk or posedge rst) begin
      
        if(rst) begin
            bcd_packet_operacional_reg.BCD0 <= 4'hF;
            bcd_packet_operacional_reg.BCD1 <= 4'hF;
            bcd_packet_operacional_reg.BCD2 <= 4'hF;
            bcd_packet_operacional_reg.BCD3 <= 4'hF;
            bcd_packet_operacional_reg.BCD4 <= 4'hF;
            bcd_packet_operacional_reg.BCD5 <= 4'hF;
            bcd_packet_setup_reg.BCD0 <= 4'hF;
            bcd_packet_setup_reg.BCD1 <= 4'hF;
            bcd_packet_setup_reg.BCD2 <= 4'hF;
            bcd_packet_setup_reg.BCD3 <= 4'hF;
            bcd_packet_setup_reg.BCD4 <= 4'hF;
            bcd_packet_setup_reg.BCD5 <= 4'hF;

            flag_enable <= 0;

        end else begin
            if(enable_o) begin
                bcd_packet_operacional_reg <= bcd_packet_operacional;
                flag_enable <= 0;
            end else if (enable_s) begin
                bcd_packet_setup_reg <= bcd_packet_setup;
                flag_enable <= 1;
            end else begin
                bcd_packet_operacional_reg <= bcd_packet_operacional_reg;
                bcd_packet_setup_reg <= bcd_packet_setup_reg;
                flag_enable <= flag_enable;
            end
        end
    end

    always_comb begin
        if(rst) begin
            HEX0 = 7'b1111111;
            HEX1 = 7'b1111111;
            HEX2 = 7'b1111111;
            HEX3 = 7'b1111111;
            HEX4 = 7'b1111111;
            HEX5 = 7'b1111111;
        end else begin
            if(enable_o == enable_s) begin
                HEX0 = 7'b1111111;
                HEX1 = 7'b1111111;
                HEX2 = 7'b1111111;
                HEX3 = 7'b1111111;
                HEX4 = 7'b1111111;
                HEX5 = 7'b1111111;
            end else if(enable_o) begin
                HEX0 = bcd_7seg(bcd_packet_operacional_reg.BCD0);
                HEX1 = bcd_7seg(bcd_packet_operacional_reg.BCD1);
                HEX2 = bcd_7seg(bcd_packet_operacional_reg.BCD2);
                HEX3 = bcd_7seg(bcd_packet_operacional_reg.BCD3);
                HEX4 = bcd_7seg(bcd_packet_operacional_reg.BCD4);
                HEX5 = bcd_7seg(bcd_packet_operacional_reg.BCD5);
            end else begin
                HEX0 = bcd_7seg(bcd_packet_setup_reg.BCD0);
                HEX1 = bcd_7seg(bcd_packet_setup_reg.BCD1);
                HEX2 = bcd_7seg(bcd_packet_setup_reg.BCD2);
                HEX3 = bcd_7seg(bcd_packet_setup_reg.BCD3);
                HEX4 = bcd_7seg(bcd_packet_setup_reg.BCD4);
                HEX5 = bcd_7seg(bcd_packet_setup_reg.BCD5);
            end
        end
    end

function logic [6:0] bcd_7seg(input logic [3:0] BCD); // segmento 'a' é LSB
    case (BCD)
        4'h0: bcd_7seg = 7'b1000000; // 0
        4'h1: bcd_7seg = 7'b1111001; // 1
        4'h2: bcd_7seg = 7'b0100100; // 2
        4'h3: bcd_7seg = 7'b0110000; // 3
        4'h4: bcd_7seg = 7'b0011001; // 4
        4'h5: bcd_7seg = 7'b0010010; // 5
        4'h6: bcd_7seg = 7'b0000010; // 6
        4'h7: bcd_7seg = 7'b1111000; // 7
        4'h8: bcd_7seg = 7'b0000000; // 8
        4'h9: bcd_7seg = 7'b0010000; // 9
        4'hA: bcd_7seg = 7'b0111111; // traço (segmento central aceso)
        4'hB: bcd_7seg = 7'b1111111; // apagado
        default: bcd_7seg = 7'b1111111;
    endcase 
endfunction

endmodule: display

// ============================================================
//                    FIM - MÓDULO DO DISPLAY
// ============================================================


// ============================================================
//                      MÓDULO DO TECLADO
// ============================================================

module decodificador_de_teclado (
input 		logic		clk,
input		logic		rst,
input		logic 		enable,
input 		logic [3:0] col_matriz,
output 	    logic [3:0] lin_matriz,
output 	    senhaPac_t	digitos_value,
output		logic 		digitos_valid
);

    enum logic [3:0] {
        INIT, 
        SCAN, 
        DEBOUNCE, 
        VALID_KEY, 
        OUTPUT_READY, 
        DECODE,
        TIMEOUT,
        TIMEOUT_VALID,
        HOLD,
        LIMPA
    } estado;

    logic [9:0] Tcont_db;
    logic [12:0] Tcont_timeout;
    logic [3:0] reg_linha;
    logic [3:0] reg_coluna;
    logic [3:0] value;

    senhaPac_t reg_digitos_value;


    logic BP;
    logic BS;

    assign lin_matriz = reg_linha;

    always_ff @(posedge clk or posedge rst) begin
        if(rst || !enable) begin
            estado <= INIT;
            reg_linha <= 4'b0111;
            reg_coluna <= 4'b1111;
            value <= 4'hF;
            Tcont_db <= 0;
            Tcont_timeout <= 0;
            reg_digitos_value.digits <= {20{4'hF}};

        end else begin
            case (estado)
                INIT: begin
                    estado <= SCAN;
                end

                SCAN: begin
                    if(Tcont_timeout >= 5000 - 1) estado <= TIMEOUT;
                    else begin
                        Tcont_timeout <= Tcont_timeout + 1;
                        if(BP) begin
                            estado <= DEBOUNCE;
                            reg_coluna <= col_matriz;
                            Tcont_db <= 0;
                        end else begin
                            reg_linha <= {reg_linha[0], reg_linha[3:1]};
                            reg_coluna <= 4'b1111;
                        end
                    end
                end

                DEBOUNCE: begin
                    if(Tcont_timeout >= 5000 - 1) estado <= TIMEOUT;
                    else begin 
                        Tcont_timeout <= Tcont_timeout + 1;
                        if(BS) begin
                            estado <= SCAN;
                            Tcont_db <= 0;
                        end else if (Tcont_db >= 50 - 1)begin
                            estado <= DECODE;
                        end else if (BP) begin
                            estado <= DEBOUNCE;
                            Tcont_db <= Tcont_db + 1;
                        end else estado <= DEBOUNCE;
                    end
                end

                TIMEOUT: begin
                    reg_digitos_value.digits <= {20{4'hE}};
                    estado <= TIMEOUT_VALID;
                    Tcont_timeout <= 0;
                end

                TIMEOUT_VALID: begin
                    reg_digitos_value.digits <= {20{4'hF}};
                    estado <= SCAN;
                end

                DECODE: begin
                    value <= decoder(reg_linha, reg_coluna);
                    estado <= OUTPUT_READY;
                    Tcont_timeout <= 0;
                    Tcont_db <= 0;

                end

                OUTPUT_READY: begin
                  if((value != 4'hA) && (value != 4'hB)) begin
                        reg_digitos_value.digits <= {reg_digitos_value.digits[18:0], value};
                        estado <= HOLD;
                    end else if(value == 4'hA) begin // Digito *
                        estado <= VALID_KEY; 
                  	end
                  	else if(value == 4'hB) begin // Digito #
                        estado <= VALID_KEY;
                        reg_digitos_value.digits <= {20{4'hB}};
                    end
                end

                VALID_KEY: begin
                    estado <= LIMPA;
                end

                HOLD: begin
                    if(BS) estado <= SCAN;
                    else estado <= HOLD;
                end

                LIMPA: begin
                    reg_digitos_value.digits <= {20{4'hF}};
                    estado <= HOLD;
                end

            endcase
        end
    end


    always_comb begin
        case (estado)

            INIT: begin
                digitos_valid = 0;
                digitos_value = {20{4'hF}};
            end

            SCAN: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end
            DEBOUNCE: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end
            DECODE: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end

            OUTPUT_READY: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end

            VALID_KEY: begin
                digitos_valid = 1;
                digitos_value = reg_digitos_value;
            end

            TIMEOUT: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end

            TIMEOUT_VALID: begin
                digitos_valid = 1;
                digitos_value = reg_digitos_value;
            end

            HOLD: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end

            LIMPA: begin
                digitos_valid = 0;
              	digitos_value = {20{4'hF}};
            end

            default: begin
                digitos_valid = 0;
              	digitos_value = {20{4'hF}};
            end
        endcase
    end

    always_comb begin
        if( col_matriz == 4'b0111 ||
            col_matriz == 4'b1011 ||
            col_matriz == 4'b1101 ||
            col_matriz == 4'b1110) BP = 1;
        else BP = 0;

        if(col_matriz == 4'b1111) BS = 1;
        else BS = 0;
    end


    function logic [3:0] decoder(input logic [3:0] linha, input logic [3:0] coluna);
        case ((linha << 4 | coluna))
            8'b01110111: decoder = 4'h1;
            8'b01111011: decoder = 4'h2;
            8'b01111101: decoder = 4'h3;
            8'b10110111: decoder = 4'h4;
            8'b10111011: decoder = 4'h5;
            8'b10111101: decoder = 4'h6;
            8'b11010111: decoder = 4'h7;
            8'b11011011: decoder = 4'h8;
            8'b11011101: decoder = 4'h9;
            8'b11101011: decoder = 4'h0;
            8'b11100111: decoder = 4'hA; // Dígito *
            8'b11101101: decoder = 4'hB; // Dígito #
            default: decoder = 4'hF;
        endcase
    endfunction

endmodule

// ============================================================
//                    FIM - MÓDULO DO TECLADO
// ============================================================


// ============================================================
//                    MÓDULO DO OPERACIONAL
// ============================================================

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
	output 	    logic 		teclado_en,
	output		logic		display_en,
	output		logic		setup_on,
    output		logic		tranca,
	output		logic		bip

);

    // ESTADOS
    typedef enum logic [4:0] {
        INIT,                                                   // Estado Inicial
        PORTA_FECHADA,                                          // Quando a porta está completamente fechada (com tranca)
        PORTA_ESCORADA,                                         // Lingueta da porta não está ativada
        PORTA_ABERTA,                                           // Lingueta desativada e porta aberta
        SETUP,                                                  // Estado de configuração da porta
        PRE_SETUP,                                              // Debounce do botão config
        VALIDAR_SENHA,                                          // Inicializa verifica_senha com um pulso em senha_valid_in
        VALIDAR_SENHA_WAIT,                                     // Aguarda retorno do verifica_senha
        VALIDAR_SENHA_MASTER,                                   // Inicializa verifica_senha com um pulso em senha_valid_in
        VALIDAR_SENHA_MASTER_IDLE,                              // Aguarda alguma senha ser digitada antes de mandar verificar
        VALIDAR_SENHA_MASTER_WAIT,                              // Aguarda retorno do verifica_senha
        SENHA_ERROR,                                            // Conta a quantidade de tentativas de senha
        BLOQUEIO,                                               // Deixa o sistema inoperante por 30s
        DEBOUNCE_DTRC,                                          // Debounce para destrancar a porta (lingueta)
        DEBOUNCE_TRC,                                           // Debounce para trancar a porta
        DEBOUNCE_NP,                                            // Debounce do botão bloqueio
        BIP_TIMEOUT,                                            // Bip da porta por 0xE (timeout)
        BIP_PORTA_O,                                            // Bip de aviso (porta aberta)
        NAO_PERTURBE                                            // Estado com entrada via teclado desabilitada
    } estado_t;


    estado_t estado;

    // CONSTANTES 
    parameter DEBOUNCE_BUTTON = 100;                            // 100 ms
    parameter DEBOUNCE_NAO_PERTURBE = 3000;                     // 3s
    parameter INTERVAL_BETWEEN_READINGS = 1000;                 // 1s
    parameter TIME_BLOCKED = 30000;                             // 30s

    // VARIAVEIS INTERNAS (CONTADORAS)
    logic [2:0] number_of_attempts;                             // Número de tentativas de senha (abrir porta) - 5 tentativas
    logic [14:0] close_door_cont;                               // Contagem de tempo para fechar/bipar a porta - 5s - 5000
    logic [14:0] block_cont;                                    // Contagem de tempo para block - 30s - 30000
    logic [15:0] cont_bip_time;                                 // Contagem para BIPAR a porta
    logic [15:0] cont_tranca_aut;                               // Contagem para trancar a porta automaticamente
  	logic [15:0] cont_db_np;                                     // Contagem debounce não perturbe - 100ms
  	logic [15:0] cont_db_dtrc;                                   // Contagem debounce destrancar lingueta - 100ms
  	logic [15:0] cont_db_trc;                                    // Contagem debounce trancar lingueta - 100ms
  	logic [15:0] cont_db_setup;                                  // Contagem debounce setup - 100ms
  	logic [15:0] cont_senhas;                                    // registrador para armazenar quantas senhas foram testadas

	setupPac_t reg_data_setup;                                  // registrador pra guardar os dados de configuração da fechadura

    logic senha_valid_in, senha_ok, senha_done;                 // sinais para se comunicar com o verifica_senha
    senhaPac_t senha_teste, senha_real, senha_digitada;         // sinais para se comunicar com o verifica_senha

    logic reg_np;                                               // registrador para armazenar estado do não perturbe

    verifica_senha vs(                                          // submódulo que realiza a verificação da senha
        .clk(clk), //input
        .rst(rst), //input
        .valid_in(senha_valid_in), //input
        .senha_teste(senha_teste), //input
        .senha_real(senha_real), //input
        .senha_ok(senha_ok), //output
        .done(senha_done) //output
    );

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            // Estado conhecido 
            estado <= INIT;

            // Zerando os contadores
            number_of_attempts <= 0;
            close_door_cont <= 0;
            block_cont <= 0;
            cont_bip_time <= 0;
            cont_tranca_aut <= 0;
            cont_db_np <= 0;
            cont_db_dtrc <= 0;
            cont_db_trc <= 0;
            cont_db_setup <= 0;
            cont_senhas <= 0;

			reg_data_setup.bip_status <= 1;
			reg_data_setup.bip_time <= 5;
			reg_data_setup.tranca_aut_time <= 5;
			reg_data_setup.senha_master <= {{16{4'hF}}, 4'h1, 4'h2, 4'h3, 4'h4};
			reg_data_setup.senha_1 <= {20{4'hF}};
			reg_data_setup.senha_2 <= {20{4'hF}};
			reg_data_setup.senha_3 <= {20{4'hF}};
			reg_data_setup.senha_4 <= {20{4'hF}};

            senha_digitada <= {20{4'hF}};

            reg_np <= 0;

        end

        else begin

            case(estado)

                INIT: begin
                    if (!sensor_contato) begin
                        estado <= PORTA_FECHADA;
                    end else begin
                        estado <= INIT;
                    end
                end

                PORTA_FECHADA: begin
                    if (botao_bloqueio) begin
                        cont_db_np <= 0;
                        estado <= DEBOUNCE_NP;
                    end

                    // Botão interno para destrancar
                    else if (botao_interno) begin
                        estado <= DEBOUNCE_DTRC;
                        cont_db_dtrc <= 0;
                    end

                    else if (!reg_np) begin
                        if(digitos_valid) begin
                            case(digitos_value.digits[0])
                                4'hB: begin // Apertou #
                                    estado <= PORTA_FECHADA;
                                end

                                4'hE: begin // Timeout
                                    estado <= BIP_TIMEOUT;
                                end

                                4'hF: begin // Digitos_value vazio
                                    estado <= PORTA_FECHADA;
                                end

                                default: begin // Tem alguma senha aí
                                    estado <= VALIDAR_SENHA;
                                end
                            endcase
                        end else estado <= PORTA_FECHADA;
                    end else estado <= PORTA_FECHADA;
                end

                PORTA_ESCORADA: begin

                    // Se a porta estiver escorada e o sensor de contato desativado - a porta será aberta
                    if (sensor_contato) begin
                        estado <= PORTA_ABERTA;
                    end

                    // Se a porta estiver escorada e o botao_interno for ativo ela sera trancada
                    else if (botao_interno) begin
                      	cont_db_trc <= 0;							// Ok?
                        estado <= DEBOUNCE_TRC;
                    end

                    // Se a porta estiver escorada e passar do tempo de trancamento automático
                  else if(cont_tranca_aut >= (reg_data_setup.tranca_aut_time * 1000 - 1)) begin
                        estado <= PORTA_FECHADA;
                    end

                    // Mantém na porta escorada se n tiver nenhum estimulo
                    else begin
                        estado <= PORTA_ESCORADA;
                      if(cont_tranca_aut < (reg_data_setup.tranca_aut_time * 1000 - 1)) begin
                           cont_tranca_aut <= cont_tranca_aut + 1;
                        end
                    end
                end

                PORTA_ABERTA: begin

                    // Debounce e leitura da senha master
                    if (botao_config) begin
                        estado <= PRE_SETUP;
                        cont_db_setup <= 0;
                    end 
                    
                    // caso feche a porta
                    else if (!sensor_contato) begin
                        estado <= PORTA_ESCORADA;
                        cont_tranca_aut <= 0;
                    end

                    // Se o contador do tempo de bip for maior que o armazenado, BIPAR porta aberta
                  	// Multiplica o bip time por 1000 para ficar em ms
                  	else if ((reg_data_setup.bip_status) && (cont_bip_time >= (reg_data_setup.bip_time * 1000 - 1))) begin
                        estado <= BIP_PORTA_O;
                    end

                    // Mantém no porta aberta
                    else begin
                        estado <= PORTA_ABERTA;
                        // Incrementa o contador do tempo do bip
                        if((reg_data_setup.bip_status) && (cont_bip_time < (reg_data_setup.bip_time * 1000 - 1))) begin
                            cont_bip_time <= cont_bip_time + 1;
                        end
                    end

                end

                SETUP: begin
                    // Define as novas configurações do dispositivo  

					if(data_setup_ok) begin
						reg_data_setup <= data_setup_new;
						estado <= PORTA_ABERTA;
					end else estado <= SETUP;
                end

                PRE_SETUP: begin
                    // Se vencer o debounce do botao config
                    if (cont_db_setup >= DEBOUNCE_BUTTON - 1) begin
                        estado <= VALIDAR_SENHA_MASTER_IDLE;
                        cont_db_setup <= 0;
                    end

                    // Até vencer o debounce
                    else if (botao_config) begin
                        estado <= PRE_SETUP;
                        cont_db_setup <= cont_db_setup + 1;
                    end

                    else estado <= PORTA_ABERTA;
                end

                VALIDAR_SENHA: begin

                    // Validar senhas 1, 2, 3, 4
                    // Se correto jogar para o estado PORTA_ESCORADA
                    if(cont_senhas <= 3) begin
                        estado <= VALIDAR_SENHA_WAIT;
                    end else begin
                        estado <= SENHA_ERROR;
                    end
                    // Se errado jogar para o estado SENHA_ERROR 
                end

                VALIDAR_SENHA_WAIT: begin
                    // Aguarda o verifica_senha retornar algum resultado.
                    if(senha_done) begin
                        if(senha_ok) estado <= PORTA_ESCORADA;
                        else begin
                            estado <= VALIDAR_SENHA;
                            cont_senhas <= cont_senhas + 1;
                        end
                    end
                end

                VALIDAR_SENHA_MASTER: begin
                    // Validar senha master com digitos_value e valid
                    // Se ocorrer tudo certo, - ESTADO DE SETUP
                  //$display("OIEEEEEEEEEEEEEEEEEEEEEEEE"); --------------------------------------------------
                    estado <= VALIDAR_SENHA_MASTER_WAIT;

                end

				VALIDAR_SENHA_MASTER_IDLE: begin
                    if(digitos_valid) begin
                        if(digitos_value == {20{4'hB}}) begin // digita # para sair do senha_master
                            estado <= PORTA_ABERTA;
                        end else if(digitos_value == {20{4'hE}}) begin
                            estado <= VALIDAR_SENHA_MASTER_IDLE;
                        end else begin
                            estado <= VALIDAR_SENHA_MASTER;
                            senha_digitada.digits <= digitos_value.digits;
                        end

                    end
                end

                VALIDAR_SENHA_MASTER_WAIT: begin
                    // Aguarda o verifica_senha retornar algum resultado.
                    if(senha_done) begin
                        if(senha_ok) estado <= SETUP;
                        else begin
                            estado <= VALIDAR_SENHA_MASTER_IDLE;
                        end
                    end
                end

                SENHA_ERROR: begin
                    // Toda vez que entra nesse estado - incrementa em um a quantidade de tentativas
                    number_of_attempts <= number_of_attempts + 1;

                    // Se for maior que 5 já manda para o estado de bloqueio para aguardar 30s
                    if (number_of_attempts > 5) begin
                        estado <= BLOQUEIO;
                    end

                    // Se não, retorna para outra tentativa
                    else begin
                        estado <= PORTA_FECHADA;
                    end
                end

                BLOQUEIO: begin
                    // Verifica o limite de tempo de 30s e habilita a entrada novamente
                    if (block_cont >= TIME_BLOCKED - 1) begin
                        estado <= PORTA_FECHADA;
                    end

                    // Conta os 30s
                    else begin
                        estado <= BLOQUEIO;
                        block_cont <= block_cont + 1;
                    end
                end

                DEBOUNCE_DTRC: begin
                    // Vence o debounce de destrancamento
                    if ((cont_db_dtrc >= DEBOUNCE_BUTTON - 1) && (!botao_interno)) begin
                        estado <= PORTA_ESCORADA;
                        reg_np <= 0;
                        cont_db_dtrc <= 0;
                        cont_tranca_aut <= 0;
                    end 
                    
                    // Botao interno abrir/fechar
                    else if (!botao_interno) begin
                        estado <= PORTA_FECHADA;
                    end

                    // Incrementa contador de debounce
                    else begin
                        cont_db_dtrc <= cont_db_dtrc + 1; 
                    end
                end

                DEBOUNCE_TRC: begin
                    // Vence o debounce para trancar
                  	if (cont_db_trc >= DEBOUNCE_BUTTON - 1) begin
                        estado <= PORTA_FECHADA;
                        cont_db_trc <= 0;
                    end

                    else if(!botao_interno) begin
                        estado <= PORTA_ABERTA;
                    end

                    // Incrementa o contador de debounce
                    else begin
                        cont_db_trc <= cont_db_trc + 1;
                    end
                end

				DEBOUNCE_NP: begin
                    // Vence o debounce para entrar no não perturbe
                    if(!botao_bloqueio) begin
                        if(cont_db_np >= DEBOUNCE_NAO_PERTURBE - 1) begin
                            estado <= NAO_PERTURBE;
                            cont_db_np <= 0;
                        end else begin
                            estado <= PORTA_FECHADA;
                            cont_db_np <= 0;
                        end
                    end else begin
                        if(cont_db_np < DEBOUNCE_NAO_PERTURBE - 1) begin
                            estado <= DEBOUNCE_NP;
                            cont_db_np <= cont_db_np + 1;
                        end else begin
                            estado <= DEBOUNCE_NP;
                            cont_db_np <= DEBOUNCE_NAO_PERTURBE;
                        end
                    end
                end

                BIP_TIMEOUT: begin
                    // Bipa por 1 pulso
                    estado <= PORTA_FECHADA;
                end

                BIP_PORTA_O: begin

                    // Debounce e leitura da senha master
                    if (botao_config) begin
                        estado <= PRE_SETUP;
                    end 
                    
                    // ?
                    else if (!sensor_contato) begin
                        estado <= PORTA_ESCORADA;     // Porta Escorada ou Trancada
                    end
                end

                NAO_PERTURBE: begin
                    estado <= PORTA_FECHADA;
                    reg_np <= 1;
                end

                default: begin
                    estado <= INIT;
                end

            endcase

        end
        
    end


    always_comb begin

        if (rst) begin
            bcd_pac.BCD0 = 4'hB;
            bcd_pac.BCD1 = 4'hB;
            bcd_pac.BCD2 = 4'hB;
            bcd_pac.BCD3 = 4'hB;
            bcd_pac.BCD4 = 4'hB;
            bcd_pac.BCD5 = 4'hB;
            teclado_en = 0;
            display_en = 0;
            setup_on = 0;
            tranca = 0;
            bip = 0;

            senha_valid_in = 0;
            senha_teste = {20{4'hF}};
            senha_real = {20{4'hF}};
        end

        else begin

            case(estado)

                INIT: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

				PORTA_FECHADA: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end
              	
                PORTA_ESCORADA: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                PORTA_ABERTA: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                SETUP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;					// HABILITA O SINAL DO TECLADO
                    display_en = 0; // Quem manda no display nesse estado é o módulo setup.
                    setup_on = 1;	
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                PRE_SETUP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;   
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                VALIDAR_SENHA: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    case(cont_senhas)
                        0: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_1;
                            senha_real = senha_digitada;
                        end
                        1: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_2;
                            senha_real = senha_digitada;
                        end
                        2: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_3;
                            senha_real = senha_digitada;
                        end
                        3: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_4;
                            senha_real = senha_digitada;
                        end
                        default: begin // se cont_senhas chegar a 4, significa que todas as senhas foram testadas e nenhuma passou.
                            senha_valid_in = 0;
                            senha_teste = {20{4'hF}};
                            senha_real = {20{4'hF}};
                        end
                    endcase
                end

                VALIDAR_SENHA_WAIT: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
                    
                    senha_valid_in = 0;

                    case(cont_senhas)
                        0: begin
                            senha_teste = reg_data_setup.senha_1;
                            senha_real = senha_digitada;
                        end
                        1: begin
                            senha_teste = reg_data_setup.senha_2;
                            senha_real = senha_digitada;
                        end
                        2: begin
                            senha_teste = reg_data_setup.senha_3;
                            senha_real = senha_digitada;
                        end
                        3: begin
                            senha_teste = reg_data_setup.senha_4;
                            senha_real = senha_digitada;
                        end
                        default: begin // se cont_senhas chegar a 4, significa que todas as senhas foram testadas e nenhuma passou.
                            senha_teste = {20{4'hF}};
                            senha_real = {20{4'hF}};
                        end
                    endcase
                end

                VALIDAR_SENHA_MASTER: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 1;
                    senha_teste = senha_digitada;
                    senha_real = reg_data_setup.senha_master;
                end

                VALIDAR_SENHA_MASTER_IDLE: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = senha_digitada;
                    senha_real = reg_data_setup.senha_master;
                end

                VALIDAR_SENHA_MASTER_WAIT: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = senha_digitada;
                    senha_real = reg_data_setup.senha_master;
                end

                SENHA_ERROR: begin
                    case (number_of_attempts)
                        1: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hB;
                            bcd_pac.BCD2 = 4'hB;
                            bcd_pac.BCD3 = 4'hB;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        2: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hB;
                            bcd_pac.BCD3 = 4'hB;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        3: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hB;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        4: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hA;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        5: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hA;
                            bcd_pac.BCD4 = 4'hA;
                            bcd_pac.BCD5 = 4'hB;
                        end
                    endcase

                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                BLOQUEIO: begin
					bcd_pac.BCD0 = 4'hA;
					bcd_pac.BCD1 = 4'hA;
					bcd_pac.BCD2 = 4'hA;
					bcd_pac.BCD3 = 4'hA;
					bcd_pac.BCD4 = 4'hA;
					bcd_pac.BCD5 = 4'hA;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                DEBOUNCE_DTRC: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                DEBOUNCE_TRC: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;    
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                DEBOUNCE_NP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                BIP_TIMEOUT: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 1;
                    
                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                BIP_PORTA_O: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 1;
                    
                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                NAO_PERTURBE: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
                    
                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                default: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 0;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

            endcase

        end

    end

endmodule

// ============================================================
//                 FIM - MÓDULO DO OPERACIONAL
// ============================================================


// ============================================================
//                    MÓDULO DO SETUP
// ============================================================

module setup (
	input		logic		clk,
	input		logic		rst,
	input		logic		setup_on,
	input		senhaPac_t	digitos_value,
	input		logic		digitos_valid,
	output		logic		display_en,
	output		bcdPac_t	bcd_pac,
	output		setupPac_t 	data_setup_new,
	output		logic		data_setup_ok
	);

	typedef enum logic [3:0] {
		IDLE,
		HABILITA_BIP,
		TEMPO_BIP,
		TEMPO_TRC,
		SENHA_MASTER,
		SENHA_1,
		SENHA_2,
		SENHA_3,
		SENHA_4,
		SAVE
	} estado_t;

	estado_t estado;

	setupPac_t reg_data_setup_new;


	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			estado <= IDLE;
			reg_data_setup_new.bip_status <= 1;
			reg_data_setup_new.bip_time <= 5;
			reg_data_setup_new.tranca_aut_time <= 5;
			reg_data_setup_new.senha_master <= {{16{4'hF}}, 4'h1, 4'h2, 4'h3, 4'h4};
			reg_data_setup_new.senha_1 <= {20{4'hF}};
			reg_data_setup_new.senha_2 <= {20{4'hF}};
			reg_data_setup_new.senha_3 <= {20{4'hF}};
			reg_data_setup_new.senha_4 <= {20{4'hF}};
		end else begin
			case(estado)
				IDLE: begin
					if(setup_on) begin
						estado <= HABILITA_BIP;
					end
					else estado <= IDLE;

				end

				HABILITA_BIP: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) estado <= TEMPO_BIP;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[0] == 0 || digitos_value.digits[0] == 1) begin
								reg_data_setup_new.bip_status <= digitos_value.digits[0];
								estado <= TEMPO_BIP;
							end else begin
								estado <= HABILITA_BIP;
							end
						end
					end else begin 
						estado <= HABILITA_BIP;
					end
				end

				TEMPO_BIP: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) begin
							estado <= TEMPO_TRC;
						end else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if((digitos_value.digits[1]*10 + digitos_value.digits[0] <= 60) && (digitos_value.digits[1]*10 + digitos_value.digits[0] >= 5)) begin
								reg_data_setup_new.bip_time <= digitos_value.digits[1]*10 + digitos_value.digits[0];
								estado <= TEMPO_TRC;
							end else begin
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] < 5) reg_data_setup_new.bip_time <= 5;
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] > 60) reg_data_setup_new.bip_time <= 60;
								estado <= TEMPO_TRC;
							end
						end
					end else estado <= TEMPO_BIP;
				end

				TEMPO_TRC: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) begin
							estado <= SENHA_MASTER;
						end
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if((digitos_value.digits[1]*10 + digitos_value.digits[0] <= 60) && (digitos_value.digits[1]*10 + digitos_value.digits[0] >= 5)) begin
								reg_data_setup_new.tranca_aut_time <= digitos_value.digits[1]*10 + digitos_value.digits[0];
								estado <= SENHA_MASTER;
							end else begin
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] < 5) reg_data_setup_new.tranca_aut_time <= 5;
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] > 60) reg_data_setup_new.tranca_aut_time <= 60;
								estado <= SENHA_MASTER;
							end
						end
					end else begin
						estado <= TEMPO_TRC;
					end
				end

				SENHA_MASTER: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_1;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_master.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_1;
							end
						end
					end else estado <= SENHA_MASTER;
				end
				SENHA_1: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_2;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_1.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_2;
							end
						end
					end else estado <= SENHA_1;
				end

				SENHA_2: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_3;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_2.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_3;
							end
						end
					end else estado <= SENHA_2;
				end

				SENHA_3: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_4;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_3.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_4;
							end
						end
					end else estado <= SENHA_3;
				end

				SENHA_4: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SAVE;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_4.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SAVE;
							end
						end
					end else estado <= SENHA_4;
				end

				SAVE: begin
					estado <= IDLE;
				end
			endcase
		end
	end

	always_comb begin
		if(rst) begin
            data_setup_new = reg_data_setup_new;
            data_setup_ok = 0;
            display_en = 0;
            bcd_pac.BCD0 = 4'hB;
            bcd_pac.BCD1 = 4'hB;
            bcd_pac.BCD2 = 4'hB;
            bcd_pac.BCD3 = 4'hB;
            bcd_pac.BCD4 = 4'hB;
            bcd_pac.BCD5 = 4'hB;
		end else begin
			case(estado)
				IDLE: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 0;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
				end

				HABILITA_BIP: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
                    bcd_pac.BCD0 = digitos_value.digits[0];
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h1;
				end

				TEMPO_BIP: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
                	bcd_pac.BCD0 = digitos_value.digits[0];
                	bcd_pac.BCD1 = digitos_value.digits[1];
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h2;
				end

				TEMPO_TRC: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = digitos_value.digits[0];
					bcd_pac.BCD1 = digitos_value.digits[1];
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h3;
				end

				SENHA_MASTER: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h4;
				end

				SENHA_1: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h5;
				end

				SENHA_2: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h6;
				end

				SENHA_3: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h7;
				end

				SENHA_4: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h8;
				end

				SAVE: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 1;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
				end
			endcase
		
		end
	end

endmodule: setup

// ============================================================
//                   FIM - MÓDULO DO SETUP
// ============================================================

// ============================================================
//                 MÓDULO DA FECHADURA TOP
// ============================================================

module FechaduraTop (
	
  
  	input 	logic clk, 
  	input 	logic rst, 
  	input 	logic sensor_de_contato, 
  	input 	logic botao_interno, 
  	input 	logic botao_bloqueio, 
  	input 	logic botao_config,
	input	logic [3:0] matricial_col,
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
  
  	assign setup_on = setup_online;
  
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