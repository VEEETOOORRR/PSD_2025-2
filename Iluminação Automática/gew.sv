module controladora #(
  	parameter DEBOUNCE_P = 300,
	parameter SWITCH_MODE_MIN_T = 5000,
	parameter AUTO_SHUTDOWN_T = 30000) 
(input 	logic 	clk, 
input	logic	rst,
input	logic	infravermelho,
input	logic	push_button,
output 	logic	led,
output	logic	saida );

  bit a,b,c,enable_sub_3;
  
  
  modulo_1 s1(.clk(clk),
              .rst(rst),
              .c(module_3()),
              .a(a),
              .b(b),
              .c(c),
              .d(infravermelho),
              .enable_sub_3(enable_sub_3),
              .led(led),
              .saida(saida)
          );
  
  module_2#(.DEBOUNCE_P(300),
    		.SWITCH_MODE_MIN_T(5000)
           )s2(.clk(clk),
               .rst(rst),
               .push_button(push_button),
               .A(a),
               .B(a));
  module_3#(.AUTO_SHUTDOWN_T(30000)
           )s3(.clk(clk),
           	   .rst(rst),
               .enable(enable_sub_3),
               .infravermelho(infravermelho),
               .C(c)
              );
               
        
endmodule;

*******

module submodulo_1(
input	logic 	clk,
input	logic	rst,
input	logic 	a, 
input	logic 	b,
input	logic 	c,
input	logic	d,
output	logic	enable_sub_3,
output 	logic 	led, 
output	logic	saida);

  enum logic [0:4] {LampLigadaAut, LampDesligadaAut, LampLigadaManu, LampDesligadaManu}estado;
  
  always_ff @ (negedge rst or posedge clk)
    if(rst == 0) estado<=LampDesligadaAut;
  	
    else 
      case(estado)
        LampDesligadaAut: begin
          if (d) estado<=LampLigadaAut;
          else if (a) estado<=LampDesligadaManu;
        end
        LampLigadaAut: begin
          if (c) estado<=LampDesligadaAut;
          else if(a) <=LampDesligadaManu;
        end
        LampDesligadaManu: begin
          if (a) estado<=LampLigadaAut;
          else if (b) estado<=LampLigadaManu;
        end
        LampLigadaManu: begin
          if (a) estado<=LampLigadaAut;
          else if (b) estado<=LampDesligadaManu;
        end
        default: estado<=LampDesligadaAut;
      endcase

    always_comb begin
      case(estado)
         LampDesligadaAut: begin
          led <= 0;
          saida <= 0;
          enable_sub_3 <= 0;
        end
        LampLigadaAut: begin
          led <= 0;
          saida <= 1;
          enable_sub_3 <= 1;

        end
        LampDesligadaManu: begin
          led <= 1;
          saida <= 0;
          enable_sub_3 <= 0;
        end
        LampLigadaManu: begin
          led <= 1;
          saida <= 1;
          enable_sub_3 <= 0;
        end
    endcase
      
endmodule;

*******

module submodulo_2 #(
	parameter DEBOUNCE_P = 300,
	parameter SWITCH_MODE_MIN_T = 5000)
(input 	logic 	clk, 
input	  logic	  rst,
input	  logic	  push_button,
output 	logic   A,
output	logic	  B);
  
  bit [15:0] Tp = 0;
  enum logic [4:0] { inicial, db, a, b, temp } estado;
  
  always_ff @ (negedge rst or posedge clk)
    if (rst == 0) begin
      Tp = 0;
      estado <= inicial;
    end else
      case (estado)
        inicial: begin
          Tp <= 0;
          if (push_button == 1) estado <= db;
        end
        db: begin
          Tp <= Tp + 1;
          if (Tp >= 300) estado <= b;
          else if (push_button == 0) estado <= inicial;
        end
        b: begin
          Tp <= Tp + 1;
          if (Tp >= 5000) estado <= a;
          else if (push_button == 0) begin
            estado <= temp;
            B <= 1;
          end 
        end
        a: begin
          Tp <= Tp + 1;
          if (push_button == 0) begin
            estado <= temp;
            A <= 1;
          end 
        temp: begin
          Tp <= 0;
          estado <= inicial;
        end
        default: estado <= inicial;
      endcase
    
    always_comb begin
      case (estado)
        inicial: begin
          A <= 0;
          B <= 0;
        end
        db: begin
          A <= 0;
          B <= 0;
        end
        b: begin
          A <= 0;
          B <= 0;
        end
        a: begin
          A <= 0;
          B <= 0;
        end
        temp: begin
          Tp <= 0;
        end
        default: begin
          A <= 0;
          B <= 0;
        end
      endcase
    end

endmodule;

******

module submodulo_3  #(
	parameter AUTO_SHUTDOWN_T = 30000)
(input 	logic 	clk,
input	logic	rst,
input 	logic	enable,
input 	logic	infravermelho,
output 	logic 	C);
  
  bit [15:0] Tc = 0;
  enum logic [2:0] {inicial, contando, temp} estado;
  
  always_ff @ (negedge rst or posedge clk)
    if (rst == 0) begin
      Tc <= 0;
      estado <= inicial;
    end
  	else
      case (estado)
        inicial: begin
		  Tc <= 0;
          if (!infra && enable) estado <= contando;
        end
        contando: begin
          Tc <= Tc + 1;
		  if (infravermelho) estado <= inicial;
          else if (Tc >= AUTO_SHUTDOWN_T) estado <= temp;
        end
        temp: begin
          Tc <= 0;
          estado <= inicial;
        end
		default: begin
          Tc <= 0;
          estado <= inicial;
        end
      endcase

  always_comb begin
    case (estado)
      inicial: C <= 0;
      contando: C <= 0;
      temp: C <= 1;
      default: C <= 0;
    endcase
  end
endmodule;