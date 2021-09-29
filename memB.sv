module memB
  #(
    parameter BITS_AB=8,
    parameter DIM=8
  )
  (
    input clk, rst_n, en,
    input signed [BITS_AB-1:0] Bin [DIM-1:0],
    output signed [BITS_AB-1:0] Bout [DIM-1:0]
  );
  
  logic [$clog2(DIM * 2)-1:0] counter;

  wire [BITS_AB-1:0] in [DIM-1:0];
  
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      counter <= 0;
    else if (en) begin
      counter <= counter + 1;
    end
  end
  
  generate
    genvar col;
    for (col = 0; col < DIM; col = col + 1) begin : iter
      fifo #(DIM + col, BITS_AB) queue (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .d(in[col]),
        .q(Bout[col])
      );

      assign in[col] = (counter < DIM) ? Bin[col] : { BITS_AB{ 1'b0 } };
    end
  endgenerate
endmodule
  