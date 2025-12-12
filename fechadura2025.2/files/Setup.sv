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
	logic reg_bip;
	int reg_tempo_bip, reg_tempo_trc;


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

			reg_bip <= 1;
			reg_tempo_bip <= 5;
			reg_tempo_trc <= 5;


		end else begin
			case(estado)
				IDLE: begin
					if(setup_on) begin
						estado <= HABILITA_BIP;
						reg_bip <= reg_data_setup_new.bip_status;
						reg_tempo_bip <= reg_data_setup_new.bip_time;
						reg_tempo_trc <= reg_data_setup_new.tranca_aut_time;
					end
					else estado <= IDLE;

				end

				HABILITA_BIP: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) estado <= TEMPO_BIP;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= HABILITA_BIP;
						else begin
							if(digitos_value.digits[0] == 0 || digitos_value.digits[0] == 1) begin
								reg_data_setup_new.bip_status <= reg_bip;
								estado <= TEMPO_BIP;
							end else begin
								estado <= HABILITA_BIP;
							end
						end
					end else begin
						estado <= HABILITA_BIP;
						if(digitos_value.digits[0] == 0 || digitos_value.digits[0] == 1) reg_bip <= digitos_value.digits[0];
						else reg_bip <= reg_bip;
					end
				end

				TEMPO_BIP: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) begin
							estado <= TEMPO_TRC;
						end else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= TEMPO_BIP;
						else begin
							if((reg_tempo_bip <= 60) && (reg_tempo_bip >= 5)) begin
								reg_data_setup_new.bip_time <= reg_tempo_bip;
								estado <= TEMPO_TRC;
							end else begin
								if(reg_tempo_bip < 5) reg_data_setup_new.bip_time <= 5;
								if(reg_tempo_bip > 60) reg_data_setup_new.bip_time <= 60;
								estado <= TEMPO_TRC;
							end
						end
					end else begin
						estado <= TEMPO_BIP;
						if(digitos_value.digits[1] == 4'hF && digitos_value.digits[0] == 4'hF) begin
							reg_tempo_bip <= reg_data_setup_new.bip_time;
						end

						else if(digitos_value.digits[1] == 4'hF) begin
							reg_tempo_bip <= (((reg_data_setup_new.bip_time % 10) * 10) + digitos_value.digits[0]);
						end

						else reg_tempo_bip <= digitos_value.digits[1]*10 + digitos_value.digits[0];
					end
				end

				TEMPO_TRC: begin
					if(digitos_valid) begin
						if(digitos_value == {20{4'hF}}) begin
							estado <= SENHA_MASTER;
						end else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= TEMPO_TRC;
						else begin
							if((reg_tempo_trc <= 60) && (reg_tempo_trc >= 5)) begin
								reg_data_setup_new.tranca_aut_time <= reg_tempo_trc;
								estado <= SENHA_MASTER;
							end else begin
								if(reg_tempo_trc < 5) reg_data_setup_new.tranca_aut_time <= 5;
								if(reg_tempo_trc > 60) reg_data_setup_new.tranca_aut_time <= 60;
								estado <= SENHA_MASTER;
							end
						end
					end else begin
						estado <= TEMPO_TRC;
						if(digitos_value.digits[1] == 4'hF && digitos_value.digits[0] == 4'hF) begin
							reg_tempo_trc <= reg_data_setup_new.tranca_aut_time;
						end

						else if(digitos_value.digits[1] == 4'hF) begin
							reg_tempo_trc <= (((reg_data_setup_new.tranca_aut_time % 10) * 10) + digitos_value.digits[0]);
						end

						else reg_tempo_trc <= digitos_value.digits[1]*10 + digitos_value.digits[0];
					end
				end

				SENHA_MASTER: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_1;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= SENHA_MASTER;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_master.digits <= {{8{4'hF}}, digitos_value.digits[11:0]};
								estado <= SENHA_1;
							end
						end
					end else estado <= SENHA_MASTER;
				end
				SENHA_1: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_2;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= SENHA_1;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_1.digits <= {{8{4'hF}}, digitos_value.digits[11:0]};
								estado <= SENHA_2;
							end
						end
					end else estado <= SENHA_1;
				end

				SENHA_2: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_3;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= SENHA_2;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_2.digits <= {{8{4'hF}}, digitos_value.digits[11:0]};
								estado <= SENHA_3;
							end
						end
					end else estado <= SENHA_2;
				end

				SENHA_3: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SENHA_4;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= SENHA_3;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_3.digits <= {{8{4'hF}}, digitos_value.digits[11:0]};
								estado <= SENHA_4;
							end
						end
					end else estado <= SENHA_3;
				end

				SENHA_4: begin
					if(digitos_valid && digitos_value != {20{4'hE}}) begin
						if(digitos_value == {20{4'hF}}) estado <= SAVE;
						else if(digitos_value == {20{4'hB}}) estado <= SAVE;
						else if(digitos_value == {20{4'hE}}) estado <= SENHA_4;
						else begin
							if(digitos_value.digits[3] != 4'hF) begin
								reg_data_setup_new.senha_4.digits <= {{8{4'hF}}, digitos_value.digits[11:0]};
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
            data_setup_new = reg_data_setup_new;
            data_setup_ok = 0;
            display_en = 0;
            bcd_pac.BCD0 = 4'hB;
            bcd_pac.BCD1 = 4'hB;
            bcd_pac.BCD2 = 4'hB;
            bcd_pac.BCD3 = 4'hB;
            bcd_pac.BCD4 = 4'hB;
            bcd_pac.BCD5 = 4'hB;
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
               bcd_pac.BCD0 = reg_bip;
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
                	bcd_pac.BCD0 = reg_tempo_bip % 10;
                	bcd_pac.BCD1 = reg_tempo_bip / 10;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'h2;
				end

				TEMPO_TRC: begin
					data_setup_new = reg_data_setup_new;
					data_setup_ok = 0;
					display_en = 1;
					bcd_pac.BCD0 = reg_tempo_trc % 10;
					bcd_pac.BCD1 = reg_tempo_trc / 10;
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

endmodule: setup