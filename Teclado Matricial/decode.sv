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
    logic [3:0] reg_linha;
    logic [3:0] reg_coluna;
    logic [3:0] value;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            estado <= INIT;
            reg_linha <= 4'b0111;
            reg_coluna <= 4'b0000;

        end else begin
            case (estado)
                INIT: begin
                    estado <= SCAN;
                end

                SCAN: begin
                    if(BP) begin
                        estado <= DEBOUNCE;
                        RCM <= col_matriz;
                    end else begin
                        reg_linha <= {reg_linha[0], reg_linha[3:0]};
                        reg <= 4'b0000;
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
                    value <= decoder(lin_matriz, RCM);
                    estado <= OUTPUT_READY;
                end

                OUTPUT_READY: begin
                    estado <= VALID_KEY;
                end

                VALID_KEY: begin
                    estado <= SCAN;
                end

            endcase
        end
    end


    always_comb begin
        case (estado)

            INIT:

            SCAN:
            DEBOUNCE:
            DECODE:

            OUTPUT_READY: begin
                tecla_value = value;
                tecla_valid = 0;
            end

            VALID_KEY: begin
                tecla_value = value;
                tecla_valid = 1;
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
        case ({linha, coluna})
            8'b0111_0111: decoder = 4'h1;
            8'b0111_1011: decoder = 4'h2;
            8'b0111_1101: decoder = 4'h3;
            8'b0111_1110: decoder = 4'hA;
            8'b1011_0111: decoder = 4'h4;
            8'b1011_1011: decoder = 4'h5;
            8'b1011_1101: decoder = 4'h6;
            8'b1011_1110: decoder = 4'hB;
            8'b1101_0111: decoder = 4'h7;
            8'b1101_1011: decoder = 4'h8;
            8'b1101_1101: decoder = 4'h9;
            8'b1101_1110: decoder = 4'hc;
            8'b1110_0111: decoder = 4'hD;
            8'b1110_1011: decoder = 4'h0;
            8'b1110_1101: decoder = 4'hE;
            8'b1110_1110: decoder = 4'hF;
            default: decoder = 4'hF;
        endcase
    endfunction

endmodule