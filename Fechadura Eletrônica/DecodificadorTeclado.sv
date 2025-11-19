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

    enum logic [3:0] {
        INIT, 
        SCAN, 
        DEBOUNCE, 
        VALID_KEY, 
        OUTPUT_READY, 
        DECODE,
        TIMEOUT,
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
                    if(Tcont_timeout >= 5000) estado <= TIMEOUT;
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
                    if(Tcont_timeout >= 5000) estado <= TIMEOUT;
                    else begin 
                        Tcont_timeout <= Tcont_timeout + 1;
                        if(BS) begin
                            estado <= SCAN;
                            Tcont_db <= 0;
                        end else if (Tcont_db >= 50)begin
                            estado <= DECODE;
                        end else if (BP) begin
                            estado <= DEBOUNCE;
                            Tcont_db <= Tcont_db + 1;
                        end else estado <= DEBOUNCE;
                    end
                end

                TIMEOUT: begin
                    reg_digitos_value.digits <= {20{4'hF}};
                    estado <= SCAN;
                    Tcont_timeout <= 0;
                end

                DECODE: begin
                    value <= decoder(reg_linha, reg_coluna);
                    estado <= OUTPUT_READY;
                    Tcont_timeout <= 0;
                    Tcont_db <= 0;

                end

                OUTPUT_READY: begin
                    //if((reg_digitos_value.digits[19] == 4'hF) && (value != 4'hA) && (value != 4'hB)) // todo: SABER SE O ARRAY CONTINUA SHIFTANDO DEPOIS DE CHEIO
                    if((value != 4'hA) && (value != 4'hB))
                        reg_digitos_value.digits <= {reg_digitos_value.digits[18:0], value};
                        estado <= HOLD;
                    else if(value == 4'hA) // Dígito *
                        estado <= VALID_KEY; 
                    else if(value == 4'hB) begin // Dígito #
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
                digitos_valid = 1;
                digitos_value = {20{4'hE}};
            end

            HOLD: begin
                digitos_valid = 0;
                digitos_value = reg_digitos_value;
            end

            LIMPA: begin
                digitos_valid = 0;
                digitos_value = {20{4'hF}}
            end

            default: begin
                digitos_vlaid = 0;
                digitos_value = {20{4'hF}}
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