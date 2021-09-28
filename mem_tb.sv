`include "mem_tc.svh"

module mem_tb();

  localparam BITS_AB = 8;
  localparam BITS_C = 16;
  localparam DIM = 8;

  mem_tc #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) mtc;

  initial begin
    mtc = new();
    for (int i = 0; i < DIM * 2 - 1; i++) begin
      bit signed [BITS_AB-1:0][DIM-1:0] row = mtc.get_next_A(i);
      for (int j = 0; j < DIM; j++) begin
        $write("%4d ", row[j]);
      end
      $write("\n");
    end
  end
endmodule
