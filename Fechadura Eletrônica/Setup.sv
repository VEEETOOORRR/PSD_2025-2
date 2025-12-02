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
			reg_data_setup_new.senha_master <= {{16{4'hF}}, 4'h1, 4'h2, 4'h3, 4'h4};
			reg_data_setup_new.senha_1 <= {20{4'hF}};
			reg_data_setup_new.senha_2 <= {20{4'hF}};
			reg_data_setup_new.senha_3 <= {20{4'hF}};
			reg_data_setup_new.senha_4 <= {20{4'hF}};
		end else begin
			case(estado)
				IDLE: begin
					if(setup_on) begin
						estado <= HABILITA_BIP;
					end
					else estado <= IDLE;

				end

				HABILITA_BIP: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) estado <= TEMPO_BIP;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[0] == 0 || digitos_value.digits[0] == 1) begin
								reg_data_setup_new.bip_status <= digitos_value.digits[0];
								estado <= TEMPO_BIP;
							end else begin
								estado <= HABILITA_BIP;
							end
						end
					end else begin 
						estado <= HABILITA_BIP;
					end
				end

				TEMPO_BIP: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) begin
							estado <= TEMPO_TRC;
						end else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if((digitos_value.digits[1]*10 + digitos_value.digits[0] <= 60) && (digitos_value.digits[1]*10 + digitos_value.digits[0] >= 5)) begin
								reg_data_setup_new.bip_time <= digitos_value.digits[1]*10 + digitos_value.digits[0];
								estado <= TEMPO_TRC;
							end else begin
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] < 5) reg_data_setup_new.bip_time <= 5;
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] > 60) reg_data_setup_new.bip_time <= 60;
								estado <= TEMPO_TRC;
							end
						end
					end else estado <= TEMPO_BIP;
				end

				TEMPO_TRC: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) begin
							estado <= SENHA_MASTER;
						end
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if((digitos_value.digits[1]*10 + digitos_value.digits[0] <= 60) && (digitos_value.digits[1]*10 + digitos_value.digits[0] >= 5)) begin
								reg_data_setup_new.tranca_aut_time <= digitos_value.digits[1]*10 + digitos_value.digits[0];
								estado <= SENHA_MASTER;
							end else begin
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] < 5) reg_data_setup_new.tranca_aut_time <= 5;
								if(digitos_value.digits[1]*10 + digitos_value.digits[0] > 60) reg_data_setup_new.tranca_aut_time <= 60;
								estado <= SENHA_MASTER;
							end
						end
					end else begin
						estado <= TEMPO_TRC;
					end
				end

				SENHA_MASTER: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_1;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_master.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_1;
							end
						end
					end else estado <= SENHA_MASTER;
				end
				SENHA_1: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_2;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_1.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_2;
							end
						end
					end else estado <= SENHA_1;
				end

				SENHA_2: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_3;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_2.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_3;
							end
						end
					end else estado <= SENHA_2;
				end

				SENHA_3: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_4;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_3.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SENHA_4;
							end
						end
					end else estado <= SENHA_3;
				end

				SENHA_4: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SAVE;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_4.digits[11:0] <= digitos_value.digits[11:0];
								estado <= SAVE;
							end
						end
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
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
				end

				HABILITA_BIP: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
                    bcd_pac.BCD0 = digitos_value.digits[0];
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h1;
				end

				TEMPO_BIP: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
                	bcd_pac.BCD0 = digitos_value.digits[0];
                	bcd_pac.BCD1 = digitos_value.digits[1];
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h2;
				end

				TEMPO_TRC: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = digitos_value.digits[0];
					bcd_pac.BCD1 = digitos_value.digits[1];
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h3;
				end

				SENHA_MASTER: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h4;
				end

				SENHA_1: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h5;
				end

				SENHA_2: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h6;
				end

				SENHA_3: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h7;
				end

				SENHA_4: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h8;
				end

				SAVE: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 1;
					display_en = 1;
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
				end
			endcase
		
		end
	end

endmodule