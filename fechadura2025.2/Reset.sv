module resetHold5s #(parameter TIME_TO_RST = 5000)(
    input logic clk, reset_in,
    output logic reset_out);


    logic [19:0] cont;

    always_ff @(posedge clk) begin
        if(reset_in) begin
            if(cont <= TIME_TO_RST) cont <= cont + 1;
        end else cont <= 0; 

    end

    always_comb begin
        if(cont >= TIME_TO_RST) reset_out = 1;
        else reset_out = 0;
    end


endmodule