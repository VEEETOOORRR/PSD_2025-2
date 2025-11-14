`include "Tipos.sv"

module setup (
	input		logic		clk,
	input		logic		rst,
	input		logic		setup_on,
	input		senhaPac_t	digitos_value,
	input		logic		digitos_valid,
	output		logic		display_en,
	output		bcdPac_t	bcd_pac,
	output		setupPac_t 	data_setup_new,
	output		logic		data_setup_ok
	);

	typedef enum logic [3:0] {
		IDLE,
		ESPERA_SENHA_MASTER,
		HABILITA_BIP,
		TEMPO_BIP,
		TEMPO_TRC,
		SENHA_MASTER,
		SENHA_1,
		SENHA_2,
		SENHA_3,
		SENHA_4,
		SAVE
	} estado_t;

	estado_t estado;

	setupPac_t reg_data_setup_new;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			estado <= IDLE;
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
				IDLE: begin
					if(setup_on) estado <= ESPERA_SENHA_MASTER;
					else estado <= IDLE;
				end

				ESPERA_SENHA_MASTER: begin
					if((digitos_value == reg_data_setup_new.senha_master) && digitos_valid) estado <= HABILITA_BIP;
					else estado <= ESPERA_SENHA_MASTER;
				end

				HABILITA_BIP: begin
					if((digitos_value[0] == 1 || digitos_valid[0] == 0) && digitos_valid) begin
						reg_data_setup_new.bip_status <= digitos_value[0];
						estado <= TEMPO_BIP;
					end else estado <= HABILITA_BIP;
				end

				TEMPO_BIP: begin
					if()
				end

				TEMPO_TRC: begin
				end

				SENHA_MASTER: begin
				end

				SENHA_1: begin
				end

				SENHA_2: begin
				end

				SENHA_3: begin
				end

				SENHA_4: begin
				end
			endcase
		end
	end

	always_comb begin
		if(rst) begin
		end else begin
			case(estado)
				IDLE: begin
				end

				ESPERA_SENHA_MASTER: begin
				end

				HABILITA_BIP: begin
				end

				TEMPO_BIP: begin
				end

				TEMPO_TRC: begin
				end

				SENHA_MASTER: begin
				end

				SENHA_1: begin
				end

				SENHA_2: begin
				end

				SENHA_3: begin
				end

				SENHA_4: begin
				end
			endcase
		
		end
	end
endmodule
