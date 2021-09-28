// memA and memB testbench

`include "systolic_array_tc.svh"

module memAB_tb();

   localparam BITS_AB=8;
   localparam DIM=8;
   localparam EN_CYCLES=(DIM*3 - 2);
   localparam AROWBITS=$clog2(DIM);
   
   localparam TESTS=10;
   
   // Clock
   logic clk;
   logic rst_n;
   logic en;
   logic WrEn;
   logic [$clog2(DIM)-1:0] Arow;
   logic signed [BITS_AB-1:0] Ain [DIM-1:0];
   logic signed [BITS_AB-1:0] Aout [DIM-1:0];
   logic signed [BITS_AB-1:0] Bin [DIM-1:0];
   logic signed [BITS_AB-1:0] Bout [DIM-1:0];
   
   always #5 clk = ~clk; 
   
	memA #(	.BITS_AB(BITS_AB),
			.DIM(DIM)) DUT_A (.*);

	memB #(	.BITS_AB(BITS_AB),
			.DIM(DIM)) DUT_B (.*); 
   
	systolic_array_tc #(.BITS_AB(BITS_AB),
                       .DIM(DIM)
                       ) satc;
	
	
	initial begin
		clk = 1'b0;
		rst_n = 1'b1;
		en = 1'b0;
		WrEn = 1'b0;
		Arow = {AROWBITS{1'b0}};
	end //initial begin
    
   // register Cout values
   always @(posedge clk) begin
      Coutreg <= Cout;
   end
   
   initial begin
	  clk = 1'b0;
	  rst_n = 1'b1;
	  en = 1'b0;
	  WrEn = 1'b0;
	  errors = 0;
      //initialize Ain and Bin as 0, so that no weird values are forced in during Aout Bout checks
      for(int rowcol=0;rowcol<DIM;++rowcol) begin
         Ain[rowcol] = {BITS_AB{1'b0}};
         Bin[rowcol] = {BITS_AB{1'b0}};
      end 
      
	  // reset and check Aout and Bout
	  @(posedge clk) begin end
	  rst_n = 1'b0; // active low reset
      @(posedge clk) begin end
      rst_n = 1'b1; // reset finished

      // check that A and B was properly reset
      for(int Row=0;Row<DIM;++Row) begin
        @(posedge clk) begin end
        if(|Aout !== 0 || |Bout !== 0) begin
            errors++;
            $display("Error! Reset was not conducted properly. Expected: 0, Got: Aout = %p and Bout %p for Row %d", Aout,Bout,Row); 
         end
      end
      

      for(int test=0;test<TESTS;++test) begin

         // instantiate test case
         satc = new();
         
         @(posedge clk) begin end
         // load C with 0 one row at a time
         for(int rowcol=0;rowcol<DIM;++rowcol) begin
            Cin[rowcol] = {BITS_C{1'b0}};
         end
         @(posedge clk) begin end
         WrEn = 1'b1;
         for(int Row=0;Row<DIM;++Row) begin
            Crow = {Row[ROWBITS-1:0]};
            @(posedge clk) begin end
         end
         WrEn = 1'b0;
         
         @(posedge clk) begin end
         // check that C was properly initialized to zero
         for(int Row=0;Row<DIM;++Row) begin
            Crow = {Row[ROWBITS-1:0]};
            @(posedge clk) begin end
            for(int Col=0;Col<DIM;++Col) begin
               if(Coutreg[Col] !== 0) begin
		          errors++;
		          $display("Error! C Init was not conducted properly. Expected: 0, Got: %d for Row %d Col %d", Coutreg[Col],Row, Col); 
	           end
            end
         end
         
         @(posedge clk) begin end
         en = 1'b1; // enabled throughout following DIM*3 cycles      
         // DIM cycles to fill, DIM cycles to compute, DIM cycles to drain
         for(int cyc=0;cyc<(DIM*3-2);++cyc) begin
            // set A, B values from the testcase
            for(int rowcol=0;rowcol<DIM;++rowcol) begin
               A[rowcol] = satc.get_next_A(rowcol);
               B[rowcol] = satc.get_next_B(rowcol);
            end
            @(posedge clk) begin end
            mycycle = satc.next_cycle();
         end
         
         @(posedge clk) begin end
         // compute is done
         en = 1'b0;
         
         @(posedge clk) begin end
         // read Cout row by row and check against test case
         for(int Row=0;Row<DIM;++Row) begin
            Crow = {Row[ROWBITS-1:0]};
            @(posedge clk) begin end
            errors = errors + satc.check_row_C(Row,Cout);
            @(posedge clk) begin end
         end
         
         if (errors > 0) begin
            $display("Errors found: %d, dumping test case\n",errors);
            satc.dump();
            $display("Dumping result");
            @(posedge clk) begin end
            for(int Row=0;Row<DIM;++Row) begin
               Crow = {Row[ROWBITS-1:0]};
               @(posedge clk) begin end
               for(int Col=0;Col<DIM;++Col) begin
                  $write("%5d ",Cout[Col]);
               end
               $display("");
               @(posedge clk) begin end
            end
         end
         else begin
            $display("No errors, testcase passed\n");
         end

         satc = null;
         
      end // for (int test=0;test<TESTS;++test)
               
	  $stop;
   end // initial begin



endmodule
