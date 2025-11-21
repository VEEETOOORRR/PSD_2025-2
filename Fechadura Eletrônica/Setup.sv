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
		VERIFICA_SENHA_MASTER,
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
	senhaPac_t senha_input;
	logic senha_valida;


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
			senha_input <= {20{4'hF}};
			senha_valida <= 0;
		end else begin
			case(estado) // todo: adicionar condição # aos estados
				IDLE: begin
					if(setup_on) estado <= ESPERA_SENHA_MASTER;
					else estado <= IDLE;
				end

				ESPERA_SENHA_MASTER: begin // todo: corrigir senha pra shiftar

					if(digitos_value == {20{4'hB}} && digitos_valid) estado <= HABILITA_BIP;
					else if((digitos_value == reg_data_setup_new.senha_master) && digitos_valid) estado <= HABILITA_BIP;
					else estado <= ESPERA_SENHA_MASTER;

					senha_input <= digitos_value;
				end

				VERIFICA_SENHA_MASTER: begin
					if(senha_input == {20{4'hF}}) begin
						estado <= ESPERA_SENHA_MASTER;
					end else begin
						logic senha_correta = 1;
						
						for(int i = 0; i < 20; i++) begin
							if(reg_data_setup_new.senha_master[i] != 4'hF && 
							reg_data_setup_new.senha_master[i] != senha_input[i]) begin
								senha_correta = 0;
								break;
							end
						end
						
						if(senha_correta) begin
							estado <= HABILITA_BIP;
						end else begin
							estado <= VERIFICA_SENHA_MASTER;
							senha_input <= {4'hF, senha_input[19:1]};
						end
					end
				end

				HABILITA_BIP: begin // todo: ajeitar pra salvar no registrador independente de apertar *
					if((digitos_value[0] == 1 || digitos_value[0] == 0) && digitos_valid) begin
						reg_data_setup_new.bip_status <= digitos_value[0];
						estado <= TEMPO_BIP;
					end else estado <= HABILITA_BIP;
				end

				TEMPO_BIP: begin // todo: ajeitar pra salvar no registrador independente de apertar *. Alem disso, salvar valores padrão caso esteja fora do intervalo.
					if((digitos_value[1]*10 + digitos_value[0] < 60) && (digitos_value[1]*10 + digitos_value[0] > 5) && digitos_valid) begin
						reg_data_setup_new.bip_time <= digitos_value[1]*10 + digitos_value[0];
						estado <= TEMPO_TRC;
					end else estado <= TEMPO_BIP;
				end

				TEMPO_TRC: begin // todo: ajeitar pra salvar no registrador independente de apertar *. Alem disso, salvar valores padrão caso esteja fora do intervalo.
					if((digitos_value[1]*10 + digitos_value[0] < 60) && (digitos_value[1]*10 + digitos_value[0] > 5) && digitos_valid) begin
						reg_data_setup_new.tranca_aut_time <= digitos_value[1]*10 + digitos_value[0];
						estado <= SENHA_MASTER;
					end else estado <= TEMPO_TRC;
				end

				SENHA_MASTER: begin
					if((digitos_value[4] != 4'hF) && digitos_valid) begin
						reg_data_setup_new.senha_master <= digitos_value;
						estado <= SENHA_1;
					end else estado <= SENHA_MASTER;
				end

				SENHA_1: begin
					if((digitos_value[4] != 4'hF) && digitos_valid) begin
						reg_data_setup_new.senha_1 <= digitos_value;
						estado <= SENHA_2;
					end else estado <= SENHA_1;
				end

				SENHA_2: begin
					if((digitos_value[4] != 4'hF) && digitos_valid) begin
						reg_data_setup_new.senha_2 <= digitos_value;
						estado <= SENHA_3;
					end else estado <= SENHA_2;
				end

				SENHA_3: begin
					if((digitos_value[4] != 4'hF) && digitos_valid) begin
						reg_data_setup_new.senha_3 <= digitos_value;
						estado <= SENHA_4;
					end else estado <= SENHA_3;
				end

				SENHA_4: begin
					if((digitos_value[4] != 4'hF) && digitos_valid) begin
						reg_data_setup_new.senha_4 <= digitos_value;
						estado <= SAVE;
					end else estado <= SENHA_4;
				end

				SAVE: begin
					estado <= IDLE;
				end
			endcase
		end
	end

	always_comb begin
		if(rst) begin
		end else begin
			case(estado)
				IDLE: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 0;
				end

				ESPERA_SENHA_MASTER: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h1;
				end

				VERIFICA_SENHA_MASTER: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h1;
				end

				HABILITA_BIP: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = reg_data_setup_new.bip_status;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h1;
				end

				TEMPO_BIP: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = reg_data_setup_new.bip_time % 10;
					bcd_pac.BCD1 = reg_data_setup_new.bip_time / 10;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h2;
				end

				TEMPO_TRC: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = reg_data_setup_new.tranca_aut_time % 10;
					bcd_pac.BCD1 = reg_data_setup_new.tranca_aut_time / 10;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h3;
				end

				SENHA_MASTER: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h4;
				end

				SENHA_1: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h5;
				end

				SENHA_2: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h6;
				end

				SENHA_3: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h7;
				end

				SENHA_4: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'h8;
				end

				SAVE: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 1;
					display_en = 1;
					bcd_pac.BCD0 = 4'hF;
					bcd_pac.BCD1 = 4'hF;
					bcd_pac.BCD2 = 4'hF;
					bcd_pac.BCD3 = 4'hF;
					bcd_pac.BCD4 = 4'hF;
					bcd_pac.BCD5 = 4'hF;
				end
			endcase
		
		end
	end

    function logic verifica_senha(input senhaPac_t senha_salva, senha_input);

        return 1;
    endfunction

endmodule

