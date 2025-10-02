
module submodulo_2 #(
	parameter DEBOUNCE_P = 300,
	parameter SWITCH_MODE_MIN_T = 5000)(
    input   logic   clk, 
    input   logic   rst,
	input   logic   push_button,
	output  logic   A,
    output  logic   B
);

    typedef enum logic [2:0] {inicial, db, b, a, temp} estado_t;

    estado_t estado;
    logic [15:0] cont;
    logic reg_A, reg_B;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            estado <= inicial;
            cont <= 0;
            reg_A <= 0;
            reg_B <= 0;
        end else begin
            case(estado)
                inicial: begin
                    if(push_button) estado <= db;
                    else begin
                         estado <= inicial;
                         reg_A <= 0;
                         reg_B <= 0;
                    end
                end

                db: begin
                    if(!push_button) begin
                        estado <= inicial;
                        cont <= 0;
                    end else if(cont >= DEBOUNCE_P) begin
                        estado <= b;
                    end else begin
                        estado <= db;
                        cont <= cont + 1;
                    end
                end

                b: begin
                    if(!push_button) begin
                        estado <= temp;
                        cont <= 0;
                        reg_B <= 1;
                    end else if(cont >= SWITCH_MODE_MIN_T) begin
                        estado <= a;
                    end else begin
                        estado <= b;
                        cont <= cont + 1;   
                    end
                end

                a: begin
                    if(!push_button) begin
                        estado <= temp;
                        cont <= 0;
                        reg_A <= 1;
                    end else begin
                        estado <= a;
                        cont <= cont;
                    end
                end

                temp: begin
                    reg_A <= reg_A;
                    reg_B <= reg_B;
                    estado <= inicial;
                end

                default: estado <= inicial;

            endcase
        end
    end
    
    always_comb begin
        case(estado)
            inicial: begin
                A = 0;
                B = 0;
            end

            db: begin
                A = 0;
                B = 0;
            end

            b: begin
                A = 0;
                B = 0;
            end

            a: begin
                A = 0;
                B = 0;
            end

            temp: begin
                if(reg_A == 1) A = 1;
                else A = 0;
                if(reg_B == 1) B = 1;
                else B = 0;
            end

            default: begin
                A = 0;
                B = 0;
            end
        endcase

    end



endmodule
