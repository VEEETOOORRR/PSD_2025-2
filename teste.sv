`timescale 1ns/1ps

module testbench_submodulo_3;
  
  
  // Sinais
  
  logic clk;
  logic rst;
  logic enable;
  logic infravermelho;
  logic C;
  
  // Instanciando o modulo DUT (Design Under Test)
  
    controladora #(
        .DEBOUNCE_P(300),
        .SWITCH_MODE_MIN_T(5000),
        .AUTO_SHUTDOWN_T(30000)) DUT (
        .clk(clk), 
        .rst(rst),
        .infravermelho(infravermelho),
        .push_button(push_button),
        .led(led),
        .saida(saida)
    );

  // Definição de Tasks (funções que levam em consideração o tempo)
  
  task run_reset(int pulsos);
    
    begin
      
      $display("\n>>> EXECUTANDO TESTE: DE RESET POR %0d PULSOS <<<", pulsos);
      
      // Setando estado de repouso (inicial) 
      enable_infra = 0;
      infravermelho = 1;
      
      // Aplicando e mantendo o reset por pulsos de clock
      rst = 1;
      repeat(pulsos) @(posedge clk);
      
      // Soltando o reset e esperando estabilizar 
      rst = 0;
      repeat(4) @(posedge clk);

      // Verificando o nome do estado se está no inicial
      if (DUT.estado.name() != "INICIAL")
        $error("ERRO: Não está no estado INICIAL após o RESET");
    
    end
  endtask
  

  task initial_to_count();
    begin
      $display("\n>>> EXECUTANDO TESTE: INICIAL -> CONTANDO <<<");
      
      // setando estado de infravermelho para 0
      infravermelho = 0;
      enable = 1;
      @(posedge clk);
      if (DUT.estado.name() == "CONTANDO")
        $display("deu certo");
      else
        $error("FALHA: Não transicionou de estado");
      
    end
  endtask
  
  task infra_or_not_enable();
    begin 
      $display("\n>>> EXECUTANDO TESTE: CONTANDO -> INICIAL <<<");
      
      // setando infra pra 1 e enable pra 0
      enable = 0;
      infravermelho = 1;
      @(posedge clk);
      if (DUT.estado.name() == "INICIAL")
        $display("SHOW");
      else
        $error("FALHA");
    end
  endtask
  

  task verify_timeout;
      begin
          integer i;
          $display("\n>>> EXECUTANDO TESTE: CONTANDO -> TEMP <<<");

          for (i = 0; i < 30000; i = i + 1) begin
              @(posedge clk);
          end

          // --- CORREÇÃO: ESPERA O PULSO DE TRANSIÇÃO ---
          @(posedge clk); 

          if (DUT.estado.name() == "TEMP") begin
              $display("SUCESSO: Transição para TEMP e SAÍDA C=1 ocorreu no tempo esperado.");
          end else begin
              $error("FALHA: Timeout não levou ao estado TEMP. Estado atual: %s", DUT.estado.name());
          end

          // (Opcional, mas recomendado) Espera o retorno automático de TEMP -> INICIAL
          @(posedge clk); 
      end
  endtask
  
  // Oscilaçõs do clock
  
  initial begin 
    clk = 0;
    forever #(10ns/2) clk = ~clk;
  end
   
  // Sequência de teste principal
  
  
  
  
initial begin

  
    // Configurações iniciais de monitoramento
    $timeformat(-9, 1, " ns", 12);
    // Usamos $display como monitor para evitar o problema de limite de linhas do log
    $monitor("Tempo: %t | Estado: %s | Tc: %0d | IR: %b | En: %b | SAÍDA C: %b",
                 $time, DUT.estado.name(), DUT.Tc, infravermelho, enable, C);
    
    $display("\n--- INÍCIO DA SEQUÊNCIA DE TESTES ---\n");
    
    // --- 1. TESTE DE RESET ---
    run_reset(5); // Estado -> INICIAL

    // --- 2. TESTE DE INTERRUPÇÃO IMEDIATA ---
    
    // A. Transiciona para CONTANDO
    initial_to_count(); 
    
    // B. Espera 100 ciclos para garantir que o contador está ativo (Tc=100)
    $display("Esperando 100 ciclos para que Tc avance antes de interromper...");
    repeat(100) @(posedge clk); 
    
    // C. Força o retorno imediato (Contando -> Inicial)
    infra_or_not_enable(); // Estado -> INICIAL
    
    // --- 3. TESTE DE TIMEOUT ---
    
    // A. Re-inicializa (limpa qualquer lixo e garante INICIAL)
    run_reset(2); 

    // B. Transiciona para CONTANDO
    initial_to_count();
    
    // C. Executa o teste de timeout completo (Contando -> Temp -> Inicial)
    verify_timeout(); // Estado -> INICIAL
    
    // 4. Finalização
    #100ns;
    $display("\n--- FIM DA SIMULAÇÃO ---");
    $finish;
end
  
  
endmodule