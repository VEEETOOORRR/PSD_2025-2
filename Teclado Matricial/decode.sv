module decodificador_de_teclado (
    input 	logic		clk,
    input	logic		rst,
    input 	logic [3:0] col_matriz,
    output 	logic [3:0] lin_matriz,
    output 	logic [3:0]	tecla_value,
    output	logic 		tecla_valid
);

    enum logic [2:0] {
        INIT, 
        SCAN, 
        DEBOUNCE, 
        VALID_KEY, 
        OUTPUT_READY, 
        DECODE
    } estado;

    logic [6:0] Tcont;
    logic [3:0] Tcont_tecla_valid;
    logic [3:0] reg_linha;
    logic [3:0] reg_coluna;
    logic [3:0] value;

    logic BP;
    logic BS;

    assign lin_matriz = reg_linha;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            estado <= INIT;
            reg_linha <= 4'b0111;
            reg_coluna <= 4'b0000;
            value <= 4'hF;

        end else begin
            case (estado)
                INIT: begin
                    estado <= SCAN;
                end

                SCAN: begin
                    if(BP) begin
                        estado <= DEBOUNCE;
                        reg_coluna <= col_matriz;
                        Tcont <= 0;
                        Tcont_tecla_valid <= 0;
                    end else begin
                        reg_linha <= {reg_linha[0], reg_linha[3:1]};
                        reg_coluna <= 4'b0000;
                    end
                end

                DEBOUNCE: begin
                    if(BS) begin
                        estado <= SCAN;
                        Tcont <= 0;
                    end else if (Tcont >= 100)begin
                        estado <= DECODE;
                    end else if (BP) begin
                        estado <= DEBOUNCE;
                        Tcont <= Tcont + 1;
                    end else estado <= DEBOUNCE;
                end

                DECODE: begin
                    value <= decoder(reg_linha, reg_coluna);
                    estado <= OUTPUT_READY;
                    Tcont <= 0;
                end

                OUTPUT_READY: begin
                    estado <= VALID_KEY;
                end

                VALID_KEY: begin
                    if(BS) estado <= SCAN;
                    else begin
                        estado <= VALID_KEY;
                        Tcont_tecla_valid <= Tcont_tecla_valid + 1;
                    end
                end

            endcase
        end
    end


    always_comb begin
        case (estado)

            INIT: begin
                tecla_valid = 0;
                tecla_value = 4'hF;
            end

            SCAN: begin
                tecla_valid = 0;
                tecla_value = 4'hF;
            end
            DEBOUNCE: begin
                tecla_valid = 0;
                tecla_value = 4'hF;
            end
            DECODE: begin
                tecla_valid = 0;
                tecla_value = 4'hF;
            end

            OUTPUT_READY: begin
                tecla_value = value;
                tecla_valid = 0;
            end

            VALID_KEY: begin
                tecla_value = value;
                if(Tcont_tecla_valid < 7) begin
                    tecla_valid = 1;
                end else tecla_valid = 0;
            end

            default: begin
                tecla_value = 4'hF;
                tecla_valid = 0;
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
            8'b01111110: decoder = 4'hA;
            8'b10110111: decoder = 4'h4;
            8'b10111011: decoder = 4'h5;
            8'b10111101: decoder = 4'h6;
            8'b10111110: decoder = 4'hB;
            8'b11010111: decoder = 4'h7;
            8'b11011011: decoder = 4'h8;
            8'b11011101: decoder = 4'h9;
            8'b11011110: decoder = 4'hC;
            8'b11100111: decoder = 4'hF;
            8'b11101011: decoder = 4'h0;
            8'b11101101: decoder = 4'hE;
            8'b11101110: decoder = 4'hD;
            default: decoder = 4'hF;
        endcase
    endfunction

endmodule