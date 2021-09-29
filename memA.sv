module memA
  #(
    parameter BITS_AB=8,
    parameter DIM=8
  )
  (
    input clk, rst_n, en, WrEn,
    input signed [BITS_AB-1:0] Ain [DIM-1:0],
    input [$clog2(DIM)-1:0] Arow,
    output signed [BITS_AB-1:0] Aout [DIM-1:0]
  );
  
  generate
    genvar row;
    for (row = 0; row < DIM; row = row + 1) begin : iter
      transpose_fifo #(DIM + row, BITS_AB) queue (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .WrEn((Arow == row) && WrEn),
        .d({ Ain, { row{ BITS_AB{ 1'b0 } } } }),
        .q(Aout[row])
      );
    end
  endgenerate
endmodule