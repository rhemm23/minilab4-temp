class mem_tc
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8
  );

  bit signed [BITS_AB-1:0] A [DIM-1:0][DIM-1:0];
  bit signed [BITS_AB-1:0] B [DIM-1:0][DIM-1:0];
  bit signed [BITS_C-1:0] C [DIM-1:0][DIM-1:0];

  function new();
    int Aval, Bval;
    for(int Row = 0; Row < DIM; ++Row) begin
      for(int Col = 0; Col < DIM; ++Col) begin
        Aval = $urandom();
        A[Row][Col] = { Aval[7:0] };
        Bval = $urandom();
        B[Row][Col] = { Bval[7:0] };
      end
    end
    for(int Row = 0; Row < DIM; ++Row) begin
      for(int Col = 0; Col < DIM; ++Col) begin
        C[Row][Col] = { BITS_C{1'b0} };
        for(int i = 0; i < DIM; ++i) begin
          C[Row][Col] = C[Row][Col] + A[Row][i] * B[i][Col];
        end
      end
    end
  endfunction: new

  function bit signed [BITS_AB-1:0][DIM-1:0] get_next_B(int row);
    bit signed [BITS_AB-1:0][DIM-1:0] ret;
    for (int i = 0; i < DIM; i++) begin
      int low = DIM - 1 - i;
      if (row < low || row > low + DIM - 1) begin
        ret[i] = '0;
      end else begin
        ret[i] = B[row - low][i];
      end
    end
    return ret;
  endfunction: get_next_B

  function bit signed [BITS_AB-1:0][DIM-1:0] get_next_A(int col);
    bit signed [BITS_AB-1:0][DIM-1:0] ret;
    for (int i = 0; i < DIM; i++) begin
      if (col < i || col > i + DIM - 1) begin
        ret[i] = '0;
      end else begin
        ret[i] = A[i][col - i];
      end
    end
    return ret;
  endfunction: get_next_A
endclass;