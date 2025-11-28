`include "Tipos.sv"


module validaSenha(
    input       logic           clk,
    input       logic           rst,
    input       logic           enable,
    input       senhaPac_t      senha_input,
    input       senhaPac_t      senha_correta,
    output      logic           senha_valida
);

    senhaPac_t reg_senha_input;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            
        end else begin
        end
    end

    always_comb begin
        
    end

endmodule