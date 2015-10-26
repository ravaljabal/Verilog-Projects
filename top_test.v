
module test_top; 
   reg clk, write; 
   reg [7:0] wrData1,wrData2; 
   wire [4:0] rdAddr1,rdAddr2;
   wire [7:0] rdData1,rdData2;
   reg [7:0] 	 memory [0:31];
   reg [7:0] 	 sorted [0:31];
   reg [7:0] 	 pen_sorted [0:31];
   reg [7:0] 	 memory1 [0:31];
   reg reset;
   integer i;
   reg flag;
   
   controller_top U0 ( 
   .clk    (clk), 
   .reset  (reset),
   .writeback1(writeback1),.writeback2(writeback2),
   .wrData1  (wrData1),.wrData2(wrData2),
   .rdAddr1 (rdAddr1), .rdAddr2 (rdAddr2), 
   .rdData1  (rdData1),.rdData2(rdData2)
   ); 
     
   initial begin
     clk = 0; 
     write = 0; 
     flag =0;
     
   end 
   
   always  
      #5  clk =  ! clk; 
   always @(posedge clk)
		begin
  		if(writeback1 | writeback2)
    			memory1[rdAddr1]=rdData1;
			memory1[rdAddr2]=rdData2;
  		end
    always @(negedge writeback1)
		begin
		 $display("Writeback1");
		 for(i=0;i<32;i=i+1)begin
		 	if(memory1[i]!=pen_sorted[i]) begin
			flag =1;
			$display("error at %d",i);
			end
		 
			end
  		 $writememh("memory1.dat", memory1,0,31);
		 //flag =0;
  		end
     always @(negedge writeback2)
		begin
		 $display("Writeback2");
		 for(i=0;i<32;i=i+1)begin
		 	if(memory1[i]!=sorted[i]) begin
			flag =1;
			$display("error at %d",i);
			end
		 	end
  		 $writememh("memory2.dat", memory1,0,31);
		 //flag =0;
  		end
   initial  begin
	      $readmemh("list5.dat", memory);
	      $readmemh("Sorted5.dat", sorted);
	        $readmemh("penUltimate5.dat", pen_sorted);

     
     #1 reset=1;
     #4 wrData1=memory[rdAddr1];
        wrData2=memory[rdAddr2];
     #1 reset=0;
     
    
              #4 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
	
		  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
        #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
#5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
        #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
    
	#5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
        #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
       
     #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
      
  #5 wrData1=memory[rdAddr1];
		 wrData2=memory[rdAddr2];
  $display("Initial I load the sorted*.dat and penUltimate*.dat with xx values.");
     $display("Note please don't consider the initial output showing error.");
     $display("The final error are reported after thid point");
  #6110 $finish;


  
   end 
     
   
     
  //Rest of testbench code after this line 
     
 endmodule