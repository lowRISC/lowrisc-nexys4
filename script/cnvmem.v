module cnvmem;

   integer i, fd, first, last;

   reg [7:0] mem[32'h40000000:32'h42000000];
   reg [127:0] mem2[0:'hfff];

   initial
     begin
        $readmemh("cnvmem.mem", mem);
        i = 32'h40000000;
	while ((i < 32'h42000000) && (1'bx === ^mem[i]))
	  i=i+16;
        first = i;
        i = 32'h42000000;
	while ((i >= 32'h40000000) && (1'bx === ^mem[i]))
	  i=i-16;
        last = (i+16);
        if (last < first + 'H10000)
             last = first + 'H10000;
        for (i = i+1; i < last; i=i+1)
          mem[i] = 0;
        $display("First = %X, Last = %X", first, last-1);
        for (i = first; i < last; i=i+1)
          if (1'bx === ^mem[i]) mem[i] = 0;
        
        for (i = first; i < last; i=i+16)
          begin
             mem2[(i/16)&'hFFF] = {mem[i+15],mem[i+14],mem[i+13],mem[i+12],
                                   mem[i+11],mem[i+10],mem[i+9],mem[i+8],
                                   mem[i+7],mem[i+6],mem[i+5],mem[i+4],
                                   mem[i+3],mem[i+2],mem[i+1],mem[i+0]};
          end
        fd = $fopen("cnvmem.hex", "w");
        for (i = 0; i <= 'hfff; i=i+1)
          $fdisplay(fd, "%32x", mem2[i]);
        $fclose(fd);
        fd = $fopen("cnvmem.coe", "w");
        $fdisplay(fd, "memory_initialization_radix=16;");
        $fdisplay(fd, "memory_initialization_vector=");
        for (i = 0; i <= 'hfff; i=i+1)
          $fdisplay(fd, "%32x", mem2[i]);
        $fclose(fd);
     end
   
endmodule // cnvmem
