module submodulo_3 #(
    parameter AUTO_SHUTDOWN_T = 30000
)(
    input logic clk,
    input logic rst, 
    input logic enable, 
    input logic infravermelho,
    output logic C
);

    parameter qtd_estados_module3 = 3;
    enum logic [qtd_estados_module3-1:0] {INICIAL, CONTANDO, TEMP} estado;
    logic [15:0] Tc;


    // Precisa colocar as autotransições?
    // Porque no primeiro exemplo ele coloca a autotransição e no segundo não?


    always_ff @(posedge clk or posedge rst) begin

        if (rst == 1) begin
            estado <= INICIAL;
            Tc <= 0;
        end 

        else begin 

            case (estado)
                INICIAL: begin
                    Tc <= 0;
                    if (!infravermelho && enable) begin
                        estado <= CONTANDO;
                    end
                    else begin 
                         estado <= INICIAL;
                    end
                end

                CONTANDO: begin
                    if (infravermelho) begin
                        estado <= INICIAL;
                        // Precisa fazer Tc = 0 ? nmo INICIAL eu faço
                        Tc <= 0;
                    end
                    else if (Tc >= AUTO_SHUTDOWN_T) begin
                        estado <= TEMP;
                        Tc <= 0;
                    end
                    else begin
                        estado <= CONTANDO;
                        Tc <= Tc + 1;
                    end
                end

                TEMP: begin
                    estado <= INICIAL;
                end

                default: begin 
                    estado <= INICIAL;
                    // Preciso zerar o contador?
                    Tc <= 0;
                end
            endcase

        end    

    end

    always_comb begin

        if (rst) begin 
            C = 0;
        end 

        else begin
            case(estado)

                // Preciso implementar uma varivel para o proximo estado?

                INICIAL  : C = 0;
                CONTANDO : C = 0;
                TEMP     : C = 1;
                default  : C = 0;

            endcase
        end
        
    end

endmodule: submodulo_3


