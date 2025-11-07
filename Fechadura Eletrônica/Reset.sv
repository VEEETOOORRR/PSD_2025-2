module reset (
    input logic clk,
    input logic rst,
    input logic botao_rst,
    output logic rst_db
);

    logic [12:0] cont;

    typedef enum logic [1:0] {IDLE, DB, R, TEMP} estado_t;

    estado_t estado;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            cont <= 0;
            estado <= IDLE;
        end else begin
            case(estado)
                IDLE: begin
                    cont <= 0;
                    if(botao_rst) estado <= DB;
                    else estado <= IDLE;
                end

                DB: begin
                    if(!botao_rst) estado <= IDLE;
                    else begin
                        if(cont < 5000) begin
                            cont <= cont + 1;
                            estado <= DB;
                        end else estado <= R;
                    end
                end

                R: begin
                    estado <= TEMP;
                end

                TEMP: begin
                    if(!botao_rst) estado <= IDLE;
                    else estado <= TEMP;
                end

            endcase
        end
    end

    always_comb begin
        if(rst) begin
            rst_db = 0;
        end else begin
            if(estado == R) rst_db = 1;
            else rst_db = 0;
        end
    end


endmodule