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
	output 	    logic 		teclado_en,
	output		logic		display_en,
	output		logic		setup_on,
    output		logic		tranca,
	output		logic		bip

);

    // ESTADOS
    typedef enum logic [4:0] {
        INIT,                                                   // Estado Inicial
        PORTA_FECHADA,                                          // Quando a porta está completamente fechada (com tranca)
        PORTA_ESCORADA,                                         // Lingueta da porta não está ativada
        PORTA_ABERTA,                                           // Lingueta desativada e porta aberta
        SETUP,                                                  // Estado de configuração da porta
        PRE_SETUP,                                              // Debounce do botão config
        VALIDAR_SENHA,                                          // Inicializa verifica_senha com um pulso em senha_valid_in
        VALIDAR_SENHA_WAIT,                                     // Aguarda retorno do verifica_senha
        VALIDAR_SENHA_MASTER,                                   // Inicializa verifica_senha com um pulso em senha_valid_in
        VALIDAR_SENHA_MASTER_IDLE,                              // Aguarda alguma senha ser digitada antes de mandar verificar
        VALIDAR_SENHA_MASTER_WAIT,                              // Aguarda retorno do verifica_senha
        SENHA_ERROR,                                            // Conta a quantidade de tentativas de senha
        BLOQUEIO,                                               // Deixa o sistema inoperante por 30s
        DEBOUNCE_DTRC,                                          // Debounce para destrancar a porta (lingueta)
        DEBOUNCE_TRC,                                           // Debounce para trancar a porta
        DEBOUNCE_NP,                                            // Debounce do botão bloqueio
        BIP_TIMEOUT,                                            // Bip da porta por 0xE (timeout)
        BIP_PORTA_O,                                            // Bip de aviso (porta aberta)
        NAO_PERTURBE                                            // Estado com entrada via teclado desabilitada
    } estado_t;


    estado_t estado;

    // CONSTANTES 
    parameter DEBOUNCE_BUTTON = 100;                            // 100 ms
    parameter DEBOUNCE_NAO_PERTURBE = 3000;                     // 3s
    parameter INTERVAL_BETWEEN_READINGS = 1000;                 // 1s
    parameter TIME_BLOCKED = 30000;                             // 30s

    // VARIAVEIS INTERNAS (CONTADORAS)
    logic [10:0] number_of_attempts;                             // Número de tentativas de senha (abrir porta) - 5 tentativas
    logic [14:0] close_door_cont;                               // Contagem de tempo para fechar/bipar a porta - 5s - 5000
    logic [14:0] block_cont;                                    // Contagem de tempo para block - 30s - 30000
    logic [15:0] cont_bip_time;                                 // Contagem para BIPAR a porta
    logic [15:0] cont_tranca_aut;                               // Contagem para trancar a porta automaticamente
  	logic [15:0] cont_db_np;                                     // Contagem debounce não perturbe - 100ms
  	logic [15:0] cont_db_dtrc;                                   // Contagem debounce destrancar lingueta - 100ms
  	logic [15:0] cont_db_trc;                                    // Contagem debounce trancar lingueta - 100ms
  	logic [15:0] cont_db_setup;                                  // Contagem debounce setup - 100ms
  	logic [15:0] cont_senhas;                                    // registrador para armazenar quantas senhas foram testadas

	setupPac_t reg_data_setup;                                  // registrador pra guardar os dados de configuração da fechadura

    logic senha_valid_in, senha_ok, senha_done;                 // sinais para se comunicar com o verifica_senha
    senhaPac_t senha_teste, senha_real, senha_digitada;         // sinais para se comunicar com o verifica_senha

    logic reg_np;                                               // registrador para armazenar estado do não perturbe

    verifica_senha vs(                                          // submódulo que realiza a verificação da senha
        .clk(clk), //input
        .rst(rst), //input
        .valid_in(senha_valid_in), //input
        .senha_teste(senha_teste), //input
        .senha_real(senha_real), //input
        .senha_ok(senha_ok), //output
        .done(senha_done) //output
    );

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            // Estado conhecido 
            estado <= INIT;

            // Zerando os contadores
            number_of_attempts <= 0;
            close_door_cont <= 0;
            block_cont <= 0;
            cont_bip_time <= 0;
            cont_tranca_aut <= 0;
            cont_db_np <= 0;
            cont_db_dtrc <= 0;
            cont_db_trc <= 0;
            cont_db_setup <= 0;
            cont_senhas <= 0;

			reg_data_setup.bip_status <= 1;
			reg_data_setup.bip_time <= 5;
			reg_data_setup.tranca_aut_time <= 5;
			reg_data_setup.senha_master <= {{16{4'hF}}, 4'h1, 4'h2, 4'h3, 4'h4};
			reg_data_setup.senha_1 <= {20{4'hF}};
			reg_data_setup.senha_2 <= {20{4'hF}};
			reg_data_setup.senha_3 <= {20{4'hF}};
			reg_data_setup.senha_4 <= {20{4'hF}};

            senha_digitada <= {20{4'hF}};

            reg_np <= 0;

        end

        else begin

            case(estado)

                INIT: begin
                    if (!sensor_contato) begin
                        estado <= PORTA_FECHADA;
                    end else begin
                        estado <= INIT;
                    end
                end

                PORTA_FECHADA: begin
                    if (botao_bloqueio) begin
                        cont_db_np <= 0;
                        estado <= DEBOUNCE_NP;
                    end

                    // Botão interno para destrancar
                    else if (botao_interno) begin
                        estado <= DEBOUNCE_DTRC;
                        cont_db_dtrc <= 0;
                    end

                    else if (!reg_np) begin
                        if(digitos_valid) begin
                            case(digitos_value.digits[0])
                                4'hB: begin // Apertou #
                                    estado <= PORTA_FECHADA;
                                end

                                4'hE: begin // Timeout
                                    estado <= BIP_TIMEOUT;
                                end

                                4'hF: begin // Digitos_value vazio
                                    estado <= PORTA_FECHADA;
                                end

                                default: begin // Tem alguma senha aí
                                    senha_digitada.digits <= digitos_value.digits;
                                    estado <= VALIDAR_SENHA;
                                end
                            endcase
                        end else estado <= PORTA_FECHADA;
                    end else estado <= PORTA_FECHADA;
                end

                PORTA_ESCORADA: begin

                    // Se a porta estiver escorada e o sensor de contato desativado - a porta será aberta
                    if (sensor_contato) begin
                        estado <= PORTA_ABERTA;
                    end

                    // Se a porta estiver escorada e o botao_interno for ativo ela sera trancada
                    else if (botao_interno) begin
                      	cont_db_trc <= 0;							// Ok?
                        estado <= DEBOUNCE_TRC;
                    end

                    // Se a porta estiver escorada e passar do tempo de trancamento automático
                  else if(cont_tranca_aut >= (reg_data_setup.tranca_aut_time * 1000 - 1)) begin
                        estado <= PORTA_FECHADA;
                    end

                    // Mantém na porta escorada se n tiver nenhum estimulo
                    else begin
                        estado <= PORTA_ESCORADA;
                      if(cont_tranca_aut < (reg_data_setup.tranca_aut_time * 1000 - 1)) begin
                           cont_tranca_aut <= cont_tranca_aut + 1;
                        end
                    end
                end

                PORTA_ABERTA: begin

                    // Debounce e leitura da senha master
                    if (botao_config) begin
                        estado <= PRE_SETUP;
                        cont_db_setup <= 0;
                    end 
                    
                    // caso feche a porta
                    else if (!sensor_contato) begin
                        estado <= PORTA_ESCORADA;
                        cont_tranca_aut <= 0;
                    end

                    // Se o contador do tempo de bip for maior que o armazenado, BIPAR porta aberta
                  	// Multiplica o bip time por 1000 para ficar em ms
                  	else if ((reg_data_setup.bip_status) && (cont_bip_time >= (reg_data_setup.bip_time * 1000 - 1))) begin
                        estado <= BIP_PORTA_O;
                    end

                    // Mantém no porta aberta
                    else begin
                        estado <= PORTA_ABERTA;
                        // Incrementa o contador do tempo do bip
                        if((reg_data_setup.bip_status) && (cont_bip_time < (reg_data_setup.bip_time * 1000 - 1))) begin
                            cont_bip_time <= cont_bip_time + 1;
                        end
                    end

                end

                SETUP: begin
                    // Define as novas configurações do dispositivo  

					if(data_setup_ok) begin
						reg_data_setup <= data_setup_new;
						estado <= PORTA_ABERTA;
					end else estado <= SETUP;
                end

                PRE_SETUP: begin
                    // Se vencer o debounce do botao config
                    if (cont_db_setup >= DEBOUNCE_BUTTON - 1) begin
                        estado <= VALIDAR_SENHA_MASTER_IDLE;
                        cont_db_setup <= 0;
                    end

                    // Até vencer o debounce
                    else if (botao_config) begin
                        estado <= PRE_SETUP;
                        cont_db_setup <= cont_db_setup + 1;
                    end

                    else estado <= PORTA_ABERTA;
                end

                VALIDAR_SENHA: begin

                    // Validar senhas 1, 2, 3, 4
                    // Se correto jogar para o estado PORTA_ESCORADA
                    if(cont_senhas <= 3) begin
                        estado <= VALIDAR_SENHA_WAIT;
                    end else begin
                        estado <= SENHA_ERROR;
                        //cont_tempo_entre_leituras <= 0;
                    end
                    // Se errado jogar para o estado SENHA_ERROR 
                end

                VALIDAR_SENHA_WAIT: begin
                    // Aguarda o verifica_senha retornar algum resultado.
                    if(senha_done) begin
                        if(senha_ok) begin
                             estado <= PORTA_ESCORADA;
                             number_of_attempts <= 0;
                        end
                        else begin
                            estado <= VALIDAR_SENHA;
                            cont_senhas <= cont_senhas + 1;
                        end
                    end
                end

                VALIDAR_SENHA_MASTER: begin
                    // Validar senha master com digitos_value e valid
                    // Se ocorrer tudo certo, - ESTADO DE SETUP
                  //$display("OIEEEEEEEEEEEEEEEEEEEEEEEE"); --------------------------------------------------
                    estado <= VALIDAR_SENHA_MASTER_WAIT;

                end

				VALIDAR_SENHA_MASTER_IDLE: begin
                    if(digitos_valid) begin
                        if(digitos_value == {20{4'hB}}) begin // digita # para sair do senha_master
                            estado <= PORTA_ABERTA;
                        end else if(digitos_value == {20{4'hE}}) begin
                            estado <= VALIDAR_SENHA_MASTER_IDLE;
                        end else begin
                            estado <= VALIDAR_SENHA_MASTER;
                            senha_digitada.digits <= digitos_value.digits;
                        end

                    end
                end

                VALIDAR_SENHA_MASTER_WAIT: begin
                    // Aguarda o verifica_senha retornar algum resultado.
                    if(senha_done) begin
                        if(senha_ok) estado <= SETUP;
                        else begin
                            estado <= VALIDAR_SENHA_MASTER_IDLE;
                        end
                    end
                end

                SENHA_ERROR: begin
                    // Toda vez que entra nesse estado - incrementa em um a quantidade de tentativas
                    number_of_attempts <= number_of_attempts + 1;
                    estado <= BLOQUEIO;
                end

                BLOQUEIO: begin
                    // Verifica o limite de tempo de 30s e habilita a entrada novamente
                    if(number_of_attempts > 5) begin
                        if (block_cont >= TIME_BLOCKED - 1) begin
                            estado <= PORTA_FECHADA;
                        end

                        // Conta os 30s
                        else begin
                            estado <= BLOQUEIO;
                            block_cont <= block_cont + 1;
                        end

                    end else begin
                        if (block_cont >= INTERVAL_BETWEEN_READINGS + 1) begin
                            estado <= PORTA_FECHADA;
                        end

                        else begin
                            estado <= BLOQUEIO;
                            block_cont <= block_cont + 1;
                        end
                    end
                end

                DEBOUNCE_DTRC: begin
                    // Vence o debounce de destrancamento
                    if ((cont_db_dtrc >= DEBOUNCE_BUTTON - 1) && (!botao_interno)) begin
                        estado <= PORTA_ESCORADA;
                        reg_np <= 0;
                        cont_db_dtrc <= 0;
                        cont_tranca_aut <= 0;
                    end 
                    
                    // Botao interno abrir/fechar
                    else if (!botao_interno) begin
                        estado <= PORTA_FECHADA;
                    end

                    // Incrementa contador de debounce
                    else begin
                        cont_db_dtrc <= cont_db_dtrc + 1; 
                    end
                end

                DEBOUNCE_TRC: begin
                    // Vence o debounce para trancar
                  	if (cont_db_trc >= DEBOUNCE_BUTTON - 1) begin
                        estado <= PORTA_FECHADA;
                        cont_db_trc <= 0;
                    end

                    else if(!botao_interno) begin
                        estado <= PORTA_ABERTA;
                    end

                    // Incrementa o contador de debounce
                    else begin
                        cont_db_trc <= cont_db_trc + 1;
                    end
                end

				DEBOUNCE_NP: begin
                    // Vence o debounce para entrar no não perturbe
                    if(!botao_bloqueio) begin
                        if(cont_db_np >= DEBOUNCE_NAO_PERTURBE - 1) begin
                            estado <= NAO_PERTURBE;
                            cont_db_np <= 0;
                        end else begin
                            estado <= PORTA_FECHADA;
                            cont_db_np <= 0;
                        end
                    end else begin
                        if(cont_db_np < DEBOUNCE_NAO_PERTURBE - 1) begin
                            estado <= DEBOUNCE_NP;
                            cont_db_np <= cont_db_np + 1;
                        end else begin
                            estado <= DEBOUNCE_NP;
                            cont_db_np <= DEBOUNCE_NAO_PERTURBE;
                        end
                    end
                end

                BIP_TIMEOUT: begin
                    // Bipa por 1 pulso
                    estado <= PORTA_FECHADA;
                end

                BIP_PORTA_O: begin

                    // Debounce e leitura da senha master
                    if (botao_config) begin
                        estado <= PRE_SETUP;
                    end 
                    
                    // ?
                    else if (!sensor_contato) begin
                        estado <= PORTA_ESCORADA;     // Porta Escorada ou Trancada
                    end
                end

                NAO_PERTURBE: begin
                    estado <= PORTA_FECHADA;
                    reg_np <= 1;
                end

                default: begin
                    estado <= INIT;
                end

            endcase

        end
        
    end


    always_comb begin

        if (rst) begin
            bcd_pac.BCD0 = 4'hB;
            bcd_pac.BCD1 = 4'hB;
            bcd_pac.BCD2 = 4'hB;
            bcd_pac.BCD3 = 4'hB;
            bcd_pac.BCD4 = 4'hB;
            bcd_pac.BCD5 = 4'hB;
            teclado_en = 0;
            display_en = 0;
            setup_on = 0;
            tranca = 0;
            bip = 0;

            senha_valid_in = 0;
            senha_teste = {20{4'hF}};
            senha_real = {20{4'hF}};
        end

        else begin

            case(estado)

                INIT: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

				PORTA_FECHADA: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end
              	
                PORTA_ESCORADA: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                PORTA_ABERTA: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                SETUP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;					// HABILITA O SINAL DO TECLADO
                    display_en = 0; // Quem manda no display nesse estado é o módulo setup.
                    setup_on = 1;	
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                PRE_SETUP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;   
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                VALIDAR_SENHA: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    case(cont_senhas)
                        0: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_1;
                            senha_real = senha_digitada;
                        end
                        1: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_2;
                            senha_real = senha_digitada;
                        end
                        2: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_3;
                            senha_real = senha_digitada;
                        end
                        3: begin
                            senha_valid_in = 1;
                            senha_teste = reg_data_setup.senha_4;
                            senha_real = senha_digitada;
                        end
                        default: begin // se cont_senhas chegar a 4, significa que todas as senhas foram testadas e nenhuma passou.
                            senha_valid_in = 0;
                            senha_teste = {20{4'hF}};
                            senha_real = {20{4'hF}};
                        end
                    endcase
                end

                VALIDAR_SENHA_WAIT: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
                    
                    senha_valid_in = 0;

                    case(cont_senhas)
                        0: begin
                            senha_teste = reg_data_setup.senha_1;
                            senha_real = senha_digitada;
                        end
                        1: begin
                            senha_teste = reg_data_setup.senha_2;
                            senha_real = senha_digitada;
                        end
                        2: begin
                            senha_teste = reg_data_setup.senha_3;
                            senha_real = senha_digitada;
                        end
                        3: begin
                            senha_teste = reg_data_setup.senha_4;
                            senha_real = senha_digitada;
                        end
                        default: begin // se cont_senhas chegar a 4, significa que todas as senhas foram testadas e nenhuma passou.
                            senha_teste = {20{4'hF}};
                            senha_real = {20{4'hF}};
                        end
                    endcase
                end

                VALIDAR_SENHA_MASTER: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 1;
                    senha_teste = senha_digitada;
                    senha_real = reg_data_setup.senha_master;
                end

                VALIDAR_SENHA_MASTER_IDLE: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = senha_digitada;
                    senha_real = reg_data_setup.senha_master;
                end

                VALIDAR_SENHA_MASTER_WAIT: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = senha_digitada;
                    senha_real = reg_data_setup.senha_master;
                end

                SENHA_ERROR: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;

                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                BLOQUEIO: begin
                    case (number_of_attempts)
                        1: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hB;
                            bcd_pac.BCD2 = 4'hB;
                            bcd_pac.BCD3 = 4'hB;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        2: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hB;
                            bcd_pac.BCD3 = 4'hB;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        3: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hB;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        4: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hA;
                            bcd_pac.BCD4 = 4'hB;
                            bcd_pac.BCD5 = 4'hB;
                        end
                        5: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hA;
                            bcd_pac.BCD4 = 4'hA;
                            bcd_pac.BCD5 = 4'hB;
                        end

                        default: begin
                            bcd_pac.BCD0 = 4'hA;
                            bcd_pac.BCD1 = 4'hA;
                            bcd_pac.BCD2 = 4'hA;
                            bcd_pac.BCD3 = 4'hA;
                            bcd_pac.BCD4 = 4'hA;
                            bcd_pac.BCD5 = 4'hA;
                        end
                    endcase
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                DEBOUNCE_DTRC: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                DEBOUNCE_TRC: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;    
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                DEBOUNCE_NP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                BIP_TIMEOUT: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 1;
                    
                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                BIP_PORTA_O: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 1;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 0;
                    bip = 1;
                    
                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                NAO_PERTURBE: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
                    
                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

                default: begin
                    bcd_pac.BCD0 = 4'hB;
                    bcd_pac.BCD1 = 4'hB;
                    bcd_pac.BCD2 = 4'hB;
                    bcd_pac.BCD3 = 4'hB;
                    bcd_pac.BCD4 = 4'hB;
                    bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 0;
                    setup_on = 0;
                    tranca = 0;
                    bip = 0;

                    senha_valid_in = 0;
                    senha_teste = {20{4'hF}};
                    senha_real = {20{4'hF}};
                end

            endcase

        end

    end

endmodule