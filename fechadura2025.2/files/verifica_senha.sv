module verifica_senha(

    input logic         clk,
    input logic         rst,
    input logic         valid_in,                   // Pulso que indica que há uma nova senha para validar
    input senhaPac_t    senha_teste,                // Senha CORRETA
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
                        size_senha <= 0;
                        pulse_value <= 0;
                    end
                    
                end

                DIMENSAO: begin

                    // Estado para descobrir o tamanho da senha
                    if ((senha_real.digits[3] == 4'hF) || (senha_real.digits == {20{4'hF}}) || (senha_teste.digits == {20{4'hF}})) estado <= INCORRETA; // senha invalida
                    else begin
                        if      (senha_teste.digits[4]  == 4'hF) size_senha <= 4;
                        else if (senha_teste.digits[5]  == 4'hF) size_senha <= 5;
                        else if (senha_teste.digits[6]  == 4'hF) size_senha <= 6;
                        else if (senha_teste.digits[7]  == 4'hF) size_senha <= 7;
                        else if (senha_teste.digits[8]  == 4'hF) size_senha <= 8;
                        else if (senha_teste.digits[9]  == 4'hF) size_senha <= 9;
                        else if (senha_teste.digits[10] == 4'hF) size_senha <= 10;
                        else if (senha_teste.digits[11] == 4'hF) size_senha <= 11;
                        else if (senha_teste.digits[12] == 4'hF) size_senha <= 12;
                        estado <= VALIDANDO_SENHA;
                    end

                end

                VALIDANDO_SENHA: begin
                    if ((pulse_value + size_senha) > 20) estado <= INCORRETA; // senha não se encontra no array
                    else begin
                        if (size_senha == 4) begin
                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3]
                            ) begin
                                estado <= CORRETA;                            
                            end 
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                        end

                        else if (size_senha == 5) begin

                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4]                       
                            ) begin
                                estado <= CORRETA;
                            end else begin
                                pulse_value <= pulse_value + 1;
                            end

                        end

                        else if (size_senha == 6) begin

                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5]                
                            ) begin
                                estado <= CORRETA;
                            end

                            else begin
                                pulse_value <= pulse_value + 1;                            
                            end

                        end

                        else if (size_senha == 7) begin

                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5] &&
                                senha_teste.digits[6] == senha_real.digits[pulse_value+6]
                            ) begin
                                estado <= CORRETA;
                            end

                            else begin
                                pulse_value <= pulse_value + 1;
                            end

                        end

                        else if (size_senha == 8) begin

                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5] &&
                                senha_teste.digits[6] == senha_real.digits[pulse_value+6] &&
                                senha_teste.digits[7] == senha_real.digits[pulse_value+7] 
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end

                        end

                        else if (size_senha == 9) begin
                                
                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5] &&
                                senha_teste.digits[6] == senha_real.digits[pulse_value+6] &&
                                senha_teste.digits[7] == senha_real.digits[pulse_value+7] &&
                                senha_teste.digits[8] == senha_real.digits[pulse_value+8]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                            
                        end

                        else if (size_senha == 10) begin

                            if (senha_teste.digits[0] == senha_real.digits[pulse_value] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5] &&
                                senha_teste.digits[6] == senha_real.digits[pulse_value+6] &&
                                senha_teste.digits[7] == senha_real.digits[pulse_value+7] &&
                                senha_teste.digits[8] == senha_real.digits[pulse_value+8] &&
                                senha_teste.digits[9] == senha_real.digits[pulse_value+9]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                        end

                        else if (size_senha == 11) begin


                            if (senha_teste.digits[0] == senha_real.digits[pulse_value+0] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5] &&
                                senha_teste.digits[6] == senha_real.digits[pulse_value+6] &&
                                senha_teste.digits[7] == senha_real.digits[pulse_value+7] &&
                                senha_teste.digits[8] == senha_real.digits[pulse_value+8] &&
                                senha_teste.digits[9] == senha_real.digits[pulse_value+9] &&
                                senha_teste.digits[10] == senha_real.digits[pulse_value+10]
                            ) begin
                                estado <= CORRETA;
                            end
                            else begin
                                pulse_value <= pulse_value + 1;
                            end
                    
                        end

                        else if (size_senha == 12) begin

                            if (senha_teste.digits[0] == senha_real.digits[pulse_value+0] &&
                                senha_teste.digits[1] == senha_real.digits[pulse_value+1] &&
                                senha_teste.digits[2] == senha_real.digits[pulse_value+2] &&
                                senha_teste.digits[3] == senha_real.digits[pulse_value+3] &&
                                senha_teste.digits[4] == senha_real.digits[pulse_value+4] &&
                                senha_teste.digits[5] == senha_real.digits[pulse_value+5] &&
                                senha_teste.digits[6] == senha_real.digits[pulse_value+6] &&
                                senha_teste.digits[7] == senha_real.digits[pulse_value+7] &&
                                senha_teste.digits[8] == senha_real.digits[pulse_value+8] &&
                                senha_teste.digits[9] == senha_real.digits[pulse_value+9] &&
                                senha_teste.digits[10] == senha_real.digits[pulse_value+10] &&
                                senha_teste.digits[11] == senha_real.digits[pulse_value+11]
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
                    size_senha <= 0;
                    pulse_value <= 0;

                end

                CORRETA: begin
                    estado <= IDLE_SENHA;
                    size_senha <= 0;
                    pulse_value <= 0;
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