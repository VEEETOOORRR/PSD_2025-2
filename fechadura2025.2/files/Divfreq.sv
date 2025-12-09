module divfreq(
	input logic rst,
	input logic clk,
	output logic clk_i);

  logic [15:0] cont;

  always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
      cont  <= 0;
      clk_i <= 0;
    end
    else
      if( cont < 25000 )
        cont <= cont + 1;
      else begin
        clk_i <= ~clk_i;
        cont <= 0;
      end
  end
endmodule
