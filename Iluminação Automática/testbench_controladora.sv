module testbench_controladora;
    
    logic clk;
    logic rst;
    logic infravermelho;
    logic push_button;
    logic led;
    logic saida;

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

    initial begin
      $display("Teste");
      infravermelho = 1;
      #1
      $display("LED: SAÍDA:")
    end
    
    initial begin  
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    always #1 clk = ~clk;
endmodule