`include "Tipos.sv"

module operacional(
    input		logic		clk,
	input		logic		rst,
	input		logic		sensor_contato,
	input		logic		botao_interno,
	input		logic		botao_bloqueio,
	input		logic		botao_config,
    input		setupPac_t 	data_setup_new,
	input		logic		data_setup_ok,
	input		senhaPac_t	digitos_value,
	input		logic		digitos_valid,
	output		bcdPac_t	bcd_pac,
	output 		logic 		teclado_en,
	output		logic		display_en,
	output		logic		setup_on,
    output		logic		tranca,
	output		logic		bip
);

	setupPac_t reg_data_setup;
	bcdPac_t reg_bcd_pac;
	
	logic [11:0] cont_np;
	logic [2:0] cont_tentativas;
	logic [15:0] cont_bloqueio;


	typedef enum logic [3:0] {
		INIT,
		PORTA_TRANCADA,
		PORTA_ENCOSTADA,
		PORTA_ABERTA,
		PORTA_BIPANDO,
		VALIDAR_SENHA,
		BLOQUEADO,
		BIP_TIMEOUT,
		CONT_NP,
		NP,
		SETUP,
	} estado_t;

	estado_t estado; 

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			estado <= INIT;
			reg_data_setup_new.bip_status <= 1;
			reg_data_setup_new.bip_time <= 5;
			reg_data_setup_new.tranca_aut_time <= 5;
			reg_data_setup_new.senha_master <= {16{4'hF}, 4'h1, 4'h2, 4'h3, 4'h4};
			reg_data_setup_new.senha_1 <= {20{4'hF}};
			reg_data_setup_new.senha_2 <= {20{4'hF}};
			reg_data_setup_new.senha_3 <= {20{4'hF}};
			reg_data_setup_new.senha_4 <= {20{4'hF}};
		end else begin
			case(estado)
				INIT: begin
				end

				PORTA_TRANCADA: begin
				end

				VALIDAR_SENHA: begin
				end

				BLOQUEADO: begin
				end

				CONT_NP: begin
				end

				NP: begin
				end

				BIP_TIMEOUT: begin
				end

				PORTA_ENCOSTADA: begin
				end

				PORTA_ABERTA: begin
				end

				PORTA_BIPANDO: begin
				end

				SETUP: begin
				end
			
			endcase
		end
	end

	always_comb begin
		case(estado)
			INIT: begin
			end

			PORTA_TRANCADA: begin
			end

			VALIDAR_SENHA: begin
			end

			BLOQUEADO: begin
			end

			CONT_NP: begin
			end

			NP: begin
			end

			BIP_TIMEOUT: begin
			end

			PORTA_ENCOSTADA: begin
			end

			PORTA_ABERTA: begin
			end

			PORTA_BIPANDO: begin
			end

			SETUP: begin
			end
	
		endcase
	end

endmodule
