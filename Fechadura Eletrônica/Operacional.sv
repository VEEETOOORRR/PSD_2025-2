`include "Tipos.sv"
`include "verifica_senha.sv" // REMOVER AO COLOCAR NO EDAPLAYGROUND!!!!!!

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
    parameter INTERVAL_BETWEEN_READINGS = 1000;                 // 1s
    parameter TIME_BLOCKED = 30000;                             // 30s
    parameter TIME_CLOSE_DOOR_AUTO = 5000;                      // 5s

    // VARIAVEIS INTERNAS (CONTADORAS)
    logic [2:0] number_of_attempts;                             // Número de tentativas de senha (abrir porta) - 5 tentativas
    logic [14:0] close_door_cont;                               // Contagem de tempo para fechar/bipar a porta - 5s - 5000
    logic [14:0] block_cont;                                    // Contagem de tempo para block - 30s - 30000
    logic [12:0] cont_bip_time;                                 // Contagem para BIPAR a porta
    logic [6:0] cont_db_np;                                     // Contagem debounce não perturbe - 100ms
    logic [6:0] cont_db_dtrc;                                   // Contagem debounce destrancar lingueta - 100ms
    logic [6:0] cont_db_trc;                                    // Contagem debounce trancar lingueta - 100ms
    logic [6:0] cont_db_setup;                                  // Contagem debounce setup - 100ms

	setupPac_t reg_data_setup;                                  // registrador pra guardar os dados de configuração da fechadura

    logic senha_valid_in, senha_ok, senha_done;                 // sinais para se comunicar com o verifica_senha
    senhaPac_t senha_teste, senha_real;                         // sinais para se comunicar com o verifica_senha


    verifica_senha vs(                                          // submódulo que realiza a verificação da senha
        .clk(clk),
        .rst(rst),
        .valid_in(senha_valid_in),
        .senha_teste(senha_teste),
        .senha_real(senha_real),
        .senha_ok(senha_ok),
        .done(senha_done)
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
            cont_db_np <= 0;
            cont_db_dtrc <= 0;
            cont_db_trc <= 0;
            cont_db_setup <= 0;

			reg_data_setup.bip_status <= 1;
			reg_data_setup.bip_time <= 5;
			reg_data_setup.tranca_aut_time <= 5;
			reg_data_setup.senha_master <= {{16{4'hF}}, 4'h1, 4'h2, 4'h3, 4'h4};
			reg_data_setup.senha_1 <= {20{4'hF}};
			reg_data_setup.senha_2 <= {20{4'hF}};
			reg_data_setup.senha_3 <= {20{4'hF}};
			reg_data_setup.senha_4 <= {20{4'hF}};

        end

        else begin

            case(estado)

                INIT: begin
                    if (!sensor_contato) begin
                        estado <= PORTA_FECHADA;
                        number_of_attempts <= 0;
                    end else begin
                        estado <= INIT;
                    end
                end

                PORTA_FECHADA: begin

                    // Entrada inválida - timeout do teclado
                    if (digitos_valid == 1 && (digitos_value.digits[0] == 4'hE)) begin
                        estado <= BIP_TIMEOUT;
                    end

                    // Botão de bloqueio para desativar entrada pelo teclado
                    else if (botao_bloqueio) begin
                        cont_db_np <= 0;
                        estado <= DEBOUNCE_NP;
                    end

                    // Botão interno para destrancar
                    else if (botao_interno) begin
                        estado <= DEBOUNCE_DTRC;
                        cont_db_dtrc <= 0;
                    end

                    // Entrada válida - verificar
                    else if (digitos_valid == 1 && ((digitos_value.digits[0] != 4'hE) && (digitos_value.digits[0] != 4'hB))) begin
                        estado <= VALIDAR_SENHA;
                    end
                end

                PORTA_ESCORADA: begin

                    // Se a porta estiver escorada e o sensor de contato desativado - a porta será aberta
                    if (sensor_contato) begin   
                        estado <= PORTA_ABERTA;
                    end

                    // Se a porta estiver escorada e o botao_interno for ativo ela sera trancada
                    else if (botao_interno) begin
                        estado <= DEBOUNCE_TRC;
                    end

                    // Mantém na porta escorada se n tiver nenhum estimulo
                    else begin
                        estado <= PORTA_ESCORADA;
                    end
                end

                PORTA_ABERTA: begin

                    // Debounce e leitura da senha master
                    if (botao_config) begin
                        estado <= PRE_SETUP;
                        cont_db_setup <= 0;
                    end 
                    
                    // ?
                    else if (!sensor_contato) begin
                        estado <= PORTA_ESCORADA;
                        // close_door_cont <= 0;
                    end

                    // Se o contador do tempo de bip for maior que o armazenado, BIPAR porta aberta
                    else if (cont_bip_time >= data_setup_new.bip_time) begin
                        estado <= BIP_PORTA_O;
                    end

                    // Mantém no porta aberta
                    else begin
                        estado <= PORTA_ABERTA;
                    end

                    // Incrementa o contador do tempo do bip
                    cont_bip_time <= cont_bip_time + 1;
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
                    if (cont_db_setup >= DEBOUNCE_BUTTON) begin
                        estado <= VALIDAR_SENHA_MASTER;
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
                    estado <= VALIDAR_SENHA_WAIT;
                    // Se errado jogar para o estado SENHA_ERROR 
                end

                VALIDAR_SENHA_WAIT: begin
                    // Aguarda o verifica_senha retornar algum resultado.
                end

                VALIDAR_SENHA_MASTER: begin
                    // Validar senha master com digitos_value e valid
                    // Se ocorrer tudo certo, - ESTADO DE SETUP

                    // Se errar - se mantem nesse estado

                    // Se quiser sair digitar o botão no teclado - ESTADO ABERTA

                end

                VALIDAR_SENHA_MASTER_WAIT: begin
                    // Validar senha master com digitos_value e valid
                    // Se ocorrer tudo certo, - ESTADO DE SETUP

                    // Se errar - se mantem nesse estado

                    // Se quiser sair digitar o botão no teclado - ESTADO ABERTA

                end

                SENHA_ERROR: begin
                    // Toda vez que entra nesse estado - incrementa em um a quantidade de tentativas
                    number_of_attempts <= number_of_attempts + 1;

                    // Se for maior que 5 já manda para o estado de bloqueio para aguardar 30s
                    if (number_of_attempts > 5) begin
                        estado <= BLOQUEIO;
                    end

                    // Se não, retorna para outra tentativa
                    else begin
                        estado <= PORTA_FECHADA;
                    end
                end

                BLOQUEIO: begin
                    // Verifica o limite de tempo de 30s e habilita a entrada novamente
                    if (block_cont >= TIME_BLOCKED) begin
                        estado <= PORTA_FECHADA;
                    end

                    // Conta os 30s
                    else begin
                        estado <= BLOQUEIO;
                        block_cont <= block_cont + 1;
                    end
                end

                DEBOUNCE_DTRC: begin
                    // Vence o debounce de destrancamento
                    if (cont_db_dtrc >= DEBOUNCE_BUTTON) begin
                        estado <= PORTA_ESCORADA;
                        cont_db_dtrc <= 0;
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
                    if (cont_db_trc >= DEBOUNCE_BUTTON) begin
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
                    if (cont_db_np >= DEBOUNCE_NP) begin
                        estado <= NAO_PERTURBE;
                        cont_db_np <= 0;
                    end

                    else if (botao_bloqueio) begin
                        cont_db_np <= cont_db_np + 1;
                    end

                    else estado <= PORTA_FECHADA;
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
                        estado <= PORTA_FECHADA;
                        // close_door_cont <= 0;
                    end

                    // Se o contador do tempo de bip for maior que o armazenado, BIPAR porta aberta
                    else if (cont_bip_time >= data_setup_new.bip_time) begin
                        estado <= BIP_PORTA_O;
                    end

                    // Mantém no porta aberta
                    else begin
                        estado <= PORTA_ABERTA;
                    end

                    // Incrementa o contador do tempo do bip
                    cont_bip_time <= cont_bip_time + 1;
                end

                NAO_PERTURBE: begin
                    estado <= PORTA_FECHADA;
                end

                default: begin
                    estado <= INIT;
                end

            endcase

        end
        
    end


    always_comb begin

        if (rst) begin
            bcd_pac = 'hBBBBBB;
            teclado_en = 0;
            display_en = 1;
            setup_on = 0;
            tranca = 0;
            bip = 0;
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
                end

                PORTA_ABERTA: begin
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
                end

                SETUP: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 0; // Quem manda no display nesse estado é o módulo setup.
                    setup_on = 1;
                    tranca = 0;
                    bip = 0;
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
                    bip = 0;*/
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
                end

                VALIDAR_SENHA_MASTER: begin
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
                end

                SENHA_ERROR: begin
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
                            bcd_pac.BCD5 = 4'hA;
                        end
                    endcase

                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
                end

                BLOQUEIO: begin
					bcd_pac.BCD0 = 4'hA;
					bcd_pac.BCD1 = 4'hA;
					bcd_pac.BCD2 = 4'hA;
					bcd_pac.BCD3 = 4'hA;
					bcd_pac.BCD4 = 4'hA;
					bcd_pac.BCD5 = 4'hA;
                    teclado_en = 0;
                    display_en = 1;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
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
                end

                BIP_PORTA_O: begin
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
                    bip = 1;
                end

                NAO_PERTURBE: begin
					bcd_pac.BCD0 = 4'hB;
					bcd_pac.BCD1 = 4'hB;
					bcd_pac.BCD2 = 4'hB;
					bcd_pac.BCD3 = 4'hB;
					bcd_pac.BCD4 = 4'hB;
					bcd_pac.BCD5 = 4'hB;
                    teclado_en = 0;
                    display_en = 0;
                    setup_on = 0;
                    tranca = 1;
                    bip = 0;
                end

                default: begin
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
                end

            endcase

        end

    end

endmodule: operacional