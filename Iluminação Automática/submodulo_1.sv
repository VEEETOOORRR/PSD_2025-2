module submodulo_1(

    input logic clk,
    input logic rst,
    input logic a,
    input logic b,
    input logic c,
    input logic d,
    output logic enable_sub_3,
    output logic led,
    output logic saida

);

    parameter qtd_estados_module1 = 4;

    // Lampada_(Ligada/Desligada)_(Automatico/Manual)
    enum logic [qtd_estados_module1-1:0] = {LAMP_L_A, LAMP_D_A, LAMP_L_M, LAMP_D_M} estado;
    

    // Condições
    // a = Tp >= 5s
    // b = 300ms < Tp < 5s
    // c = Tc == 30s
    // d = nivel 1 em infra

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            estado <= LAMP_D_A;
        end

        else begin

            case(estado)

                LAMP_L_A:

                    if (a) begin 
                        estado <= LAMP_D_M;
                    end
                    else if (c) begin
                        estado <= LAMP_D_A;
                    end
                    else if (d) begin
                        estado <= LAMP_L_A;
                    end

                LAMP_D_A:
                    
                    if (a) begin
                        estado <= LAMP_D_M;
                    end
                    else if (d) begin
                        estado <= LAMP_L_A;
                    end
                    
                LAMP_L_M:
                    
                    if (a) begin
                        estado <= LAMP_L_A;
                    end
                    else if (b) begin
                        estado <= LAMP_D_M;
                    end

                LAMP_D_M:
                    
                    if (a) begin
                        estado <= LAMP_L_A;
                    end
                    else if (b) begin
                        estado <= LAMP_L_M;
                    end
                
                default:
                    estado <= LAMP_D_A;

            endcase

        end
                
    end


    always_comb begin
        // O always comb é modelado olhando para o próximo estado? (usar next state??)

        if (rst) begin
            led = 0;
            saida = 0;
            enable_sub_3 = 0;
        end

        else begin
            case

                LAMP_L_A: begin
                    led = 0;
                    saida = 1;
                    enable_sub_3 = 1;
                end

                LAMP_D_A: begin
                    led = 0;
                    saida = 0;
                    enable_sub_3 = 0;
                end

                LAMP_L_M: begin
                    led = 1;
                    saida = 1;
                    enable_sub_3 = 0;
                end

                LAMP_D_M: begin
                    led = 1;
                    saida = 0;
                    enable_sub_3 = 0;
                end

                default: begin
                    led = 0;
                    saida = 0;
                    enable_sub_3 = 0
                end
            
            endcase
        end

    end


endmodule: submodulo_1