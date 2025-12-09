module display (
    input 		logic 		clk, 
    input 		logic 		rst,
    input 		logic 		enable_o, enable_s,
    input 		bcdPac_t 	bcd_packet_operacional, bcd_packet_setup,
    output 		logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    bcdPac_t bcd_packet_operacional_reg, bcd_packet_setup_reg;

    logic flag_enable; // Qual enable foi ativado por último, para razões de debug. 0 -> Operacional, 1 -> Setup

    always_ff @(posedge clk or posedge rst) begin
      
        if(rst) begin
            bcd_packet_operacional_reg.BCD0 <= 4'hF;
            bcd_packet_operacional_reg.BCD1 <= 4'hF;
            bcd_packet_operacional_reg.BCD2 <= 4'hF;
            bcd_packet_operacional_reg.BCD3 <= 4'hF;
            bcd_packet_operacional_reg.BCD4 <= 4'hF;
            bcd_packet_operacional_reg.BCD5 <= 4'hF;
            bcd_packet_setup_reg.BCD0 <= 4'hF;
            bcd_packet_setup_reg.BCD1 <= 4'hF;
            bcd_packet_setup_reg.BCD2 <= 4'hF;
            bcd_packet_setup_reg.BCD3 <= 4'hF;
            bcd_packet_setup_reg.BCD4 <= 4'hF;
            bcd_packet_setup_reg.BCD5 <= 4'hF;

            flag_enable <= 0;

        end else begin
            if(enable_o) begin
                bcd_packet_operacional_reg <= bcd_packet_operacional;
                flag_enable <= 0;
            end else if (enable_s) begin
                bcd_packet_setup_reg <= bcd_packet_setup;
                flag_enable <= 1;
            end else begin
                bcd_packet_operacional_reg <= bcd_packet_operacional_reg;
                bcd_packet_setup_reg <= bcd_packet_setup_reg;
                flag_enable <= flag_enable;
            end
        end
    end

    always_comb begin
        if(rst) begin
            HEX0 = 7'b0000000;
            HEX1 = 7'b1111111;
            HEX2 = 7'b1111111;
            HEX3 = 7'b1111111;
            HEX4 = 7'b1111111;
            HEX5 = 7'b1111111;
        end else begin
            if(enable_o == enable_s) begin
                HEX0 = 7'b1111111;
                HEX1 = 7'b1111111;
                HEX2 = 7'b1111111;
                HEX3 = 7'b1111111;
                HEX4 = 7'b1111111;
                HEX5 = 7'b1111111;
            end else if(enable_o) begin
                HEX0 = bcd_7seg(bcd_packet_operacional_reg.BCD0);
                HEX1 = bcd_7seg(bcd_packet_operacional_reg.BCD1);
                HEX2 = bcd_7seg(bcd_packet_operacional_reg.BCD2);
                HEX3 = bcd_7seg(bcd_packet_operacional_reg.BCD3);
                HEX4 = bcd_7seg(bcd_packet_operacional_reg.BCD4);
                HEX5 = bcd_7seg(bcd_packet_operacional_reg.BCD5);
            end else begin
                HEX0 = bcd_7seg(bcd_packet_setup_reg.BCD0);
                HEX1 = bcd_7seg(bcd_packet_setup_reg.BCD1);
                HEX2 = bcd_7seg(bcd_packet_setup_reg.BCD2);
                HEX3 = bcd_7seg(bcd_packet_setup_reg.BCD3);
                HEX4 = bcd_7seg(bcd_packet_setup_reg.BCD4);
                HEX5 = bcd_7seg(bcd_packet_setup_reg.BCD5);
            end
        end
    end

function logic [6:0] bcd_7seg(input logic [3:0] BCD); // segmento 'a' é LSB
    case (BCD)
        4'h0: bcd_7seg = 7'b1000000; // 0
        4'h1: bcd_7seg = 7'b1111001; // 1
        4'h2: bcd_7seg = 7'b0100100; // 2
        4'h3: bcd_7seg = 7'b0110000; // 3
        4'h4: bcd_7seg = 7'b0011001; // 4
        4'h5: bcd_7seg = 7'b0010010; // 5
        4'h6: bcd_7seg = 7'b0000010; // 6
        4'h7: bcd_7seg = 7'b1111000; // 7
        4'h8: bcd_7seg = 7'b0000000; // 8
        4'h9: bcd_7seg = 7'b0010000; // 9
        4'hA: bcd_7seg = 7'b0111111; // traço (segmento central aceso)
        4'hB: bcd_7seg = 7'b1111111; // apagado
        default: bcd_7seg = 7'b1111111;
    endcase 
endfunction

endmodule: display