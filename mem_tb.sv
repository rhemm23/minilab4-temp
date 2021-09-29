`include "mem_tc.svh"

module mem_tb();

  localparam BITS_AB = 8;
  localparam BITS_C = 16;
  localparam DIM = 8;

  bit signed [BITS_AB-1:0][DIM-1:0] row;

  logic clk, rst_n, en, wren;

  logic signed [BITS_AB-1:0] Bin [DIM-1:0];
  logic signed [BITS_AB-1:0] Ain [DIM-1:0];
  logic [$clog2(DIM)-1:0] Arow;

  wire [BITS_AB-1:0] Aout [DIM-1:0];
  wire [BITS_AB-1:0] Bout [DIM-1:0];

  mem_tc #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) mtc;

  memA #(BITS_AB, DIM) mem_a (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .WrEn(wren),
    .Ain(Ain),
    .Arow(Arow),
    .Aout(Aout)
  );

  memB #(BITS_AB, DIM) mem_b (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .Bin(Bin),
    .Bout(Bout)
  );

  always
    #5 clk = ~clk;

  initial begin
    rst_n = 1;
    wren = 0;
    clk = 0;
    en = 0;

    // Reset module
    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    wren = 1;
    @(posedge clk);

    mtc = new();
    for (int i = 0; i < DIM; i++) begin
      Arow = i;
      $cast(Ain, mtc.A[i]);
      @(posedge clk);
    end

    wren = 0;
    @(posedge clk)

    en = 1;
    @(posedge clk);

    for (int i = DIM - 1; i >= 0; i--) begin
      $cast(Bin, mtc.B[i]);
      @(posedge clk);
    end

    en = 0;
    @(posedge clk);

    for (int i = 0; i < DIM * 2 - 1; i++) begin
      row = mtc.get_next_B(i);
      for (int j = 0; j < DIM; j++) begin
        $write("%4d ", row[j]);
      end
      $write("\n");
    end
  end
endmodule
