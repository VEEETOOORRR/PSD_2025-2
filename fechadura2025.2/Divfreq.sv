module divfreq(input rst, clk, output logic clk_i);

  int cont;

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      cont  = 0;
      clk_i = 0;
    end
    else
      if( cont <= 25000 )
        cont++;
      else begin
        clk_i = ~clk_i;
        cont = 0;
      end
  end
endmodule
