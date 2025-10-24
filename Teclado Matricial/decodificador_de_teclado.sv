module decodificador_de_teclado (
    input 	logic		clk,
    input	logic		rst,
    input 	logic [3:0] 	col_matriz,
    output 	logic [3:0] 	lin_matriz,
    output 	logic [3:0]	tecla_value,
    output	logic 		tecla_valid
);


    parameter qtd_estados = 6;

    enum logic [qtd_estados-1:0] = {
        INIT, 
        SCAN, 
        DEBOUNCE, 
        VALID_KEY, 
        OUTPUT_READY, 
        DECODE
    } estado;

    // Contador de tempo do debounce
    integer Tcont = 0; 
    // Contador pra percorrer as linhas
    integer contLinha = 0; 
    // Salva o valor final
    logic [3:0] RCM = 4'b0000;
    // Corrigir
    // Possiveis valores de botão pressionado (scan)
    logic [3:0] BP [3:0] = {4'b0111, 4'b1011, 4'b1101, 4'b1110};
    // Valor botao sem estar pressionado
    logic [3:0] BS [3:0] = 4'b1111;
    
    always_ff @(posedge clk or posedge rst) begin
        
        // Verificação do RST
        if (rst) begin
            estado <= INIT;
        end

        else begin 

            case (estado)

                INIT: begin
                    if (clk && !rst) begin
                        estado <= SCAN;
                    end
                end
                
                SCAN: begin 
                    lin_matriz = BP[i];
                    if (rst) begin
                        estado <= INIT;
                    end
                    else if (
                       col_matriz == BP[0] 
                    || col_matriz == BP[1]
                    || col_matriz == BP[2]
                    || col_matriz == BP[3]
                    ) begin
                        // fazer um contador cirular
                        RCM <= BP[i]
                        estado <= DEBOUNCE;
                        
                    end
                    else begin
                        estado <= SCAN;
                        contLinha <= contLinha + 1
                    end
                end

                DEBOUNCE: begin
                    if (rst) begin
                        estado <= INIT;
                    end
                    else if (
                       (col_matriz == BP[0] 
                    || col_matriz == BP[1]
                    || col_matriz == BP[2]
                    || col_matriz == BP[3]) && Tcont < 100) begin
                        estado <= DEBOUNCE;
                        Tcont <= Tcont + 1;
                    end
                    else if (col_matriz == BS && Tcont < 100) begin
                        estado <= SCAN;
                    end
                    else if (Tcont >= 100) begin
                        estado <= DECODE;
                    end
                end

                DECODE: begin
                    if (rst) begin
                        estado <= INIT;
                    end
                    else begin
                        estado <= OUTPUT_READY;
                    end
                end

                VALID_KEY: begin
                    if (rst) begin
                        estado <= INIT;
                    end
                    else if (col_matriz == BS) begin
                        estado <= SCAN;
                    end

                end

                OUTPUT_READY: begin
                    if (rst) begin
                        estado <= INIT;
                    end 
                    else begin
                        estado <= VALID_KEY;
                    end
                end

                default:
                    estado <= INIT;        
            endcase

        end

    end


    always_comb begin

        if (rst) begin
            Tcont = 0;
            tecla_valid = 0;
            tecla_value = 0xF;
            lin_matriz = 4'b0111;
            RCM = 4'b0000;
        end

        else begin 

            case (estado)
                INIT: begin
                    Tcont = 0;
                    tecla_valid = 0;
                    tecla_value = 0xF;
                    lin_matriz = 4'b0111;
                    RCM = 4'b0000;
                end
                SCAN: begin
                    Tcont = 0;
                    tecla_valid = 0;
                    tecla_value = 0xF;
                    lin_matriz = // Proxima linha;
                    RCM = 4'b0000;
                    // Valor da linha constante no always comb
                             
                end
                DEBOUNCE: begin
                    tecla_valid = 0;
                    tecla_value = 0xF;
                end
                DECODE: begin
                    Tcont = 0;
                    tecla_valid = 0;
                    tecla_value = 0xF;
                
                end
                VALID_KEY: begin
                    tecla_valid = 1;
                    // value é o valor que queremos obter
                    tecla_value = RCM;
                end
                OUTPUT_READY: begin
                    tecla_valid = 0;
                    // value é o valor que queremos obter
                    tecla_value = RCM;
                
                end

                default:
                    Tcont = 0;
                    tecla_valid = 0;
                    tecla_value = 0xF;
                    lin_matriz = 4'b0111;
                    RCM = 4'b0000;

            endcase
        
        end
    
    end

    // RCM é o valor final?