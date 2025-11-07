module reset (
    input logic clk,
    input logic botao_rst,
    output logic rst_db
);

    logic [12:0] cont;

    //typedef enum logic [1:0] {IDLE, DB, R, TEMP} estado_t;
    //estado_t estado;

    always_ff @(posedge clk) begin
        if(botao_rst) begin
            if(cont <= 5) cont <= cont + 1;
        end else cont <= 0;

    end

    always_comb begin
        if(cont == 5) rst_db = 1;
        else rst_db = 0;
    end


endmodule