//`timescale 1ns / 1ns

/***************************************************************************
Top module: wires regfile8x32,comp_cont and address_gen together and 
			also defines the input/output of the merge sort engine

***************************************************************************/
module controller_top
  (input clk,input reset,
	output [4:0] rdAddr1,output [4:0] rdAddr2,
	input [7:0] wrData1,input [7:0] wrData2,
	output [7:0] rdData1,output [7:0] rdData2,
	output writeback1,output writeback2);

 wire[4:0] index1;  
 wire [4:0] index2;
 wire write,read;
 wire [7:0] write_to_reg2,write_to_reg1;
 wire [4:0] wrAddr1,wrAddr2;
 wire clk_dist,read_from_test;
/***************************************************************************
wiring for regfile8x32 module
***************************************************************************/
regfile8x32 registers
  (.clk(clk), .write(write),
   .wrAddr1(wrAddr1),.wrAddr2(wrAddr2),
   .wrData1(write_to_reg1),.wrData2(write_to_reg2),
   .rdAddr1(rdAddr1),.rdAddr2(rdAddr2),
   .rdData1(rdData1),.rdData2(rdData2));
/***************************************************************************
wiring for address_gen module
***************************************************************************/
address_gen index_generators
  (.clk(clk_dist),.signal(!read_from_test),.reset(reset),.index1(index1),. 
   index2(index2),.writeback2(writeback2),.writeback1(writeback1));
/***************************************************************************
wiring for comp_cont module
***************************************************************************/
Comp_Control comp_cont
  (.clk(clk),.reset(reset),.writeback1(writeback1),.writeback2(writeback2),
	.rdAddr1(rdAddr1),.rdAddr2(rdAddr2),
	.wrAddr1(wrAddr1),.wrAddr2(wrAddr2),
	.write_to_reg1(write_to_reg1),.write_to_reg2(write_to_reg2),
	.index1(index1),.index2(index2),
	.rdData1(rdData1),.rdData2(rdData2),
	.wrData1(wrData1),.wrData2(wrData2),
	.write(write),.clk_dist(clk_dist),.read_from_test(read_from_test));

endmodule
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

/***************************************************************************
Comp_Control: -	Compares and swaps values of register before writing them 
				back to the register file using the index from address_gen
				module
			  -	It also takes care of initial data read from the test-
				fixture
			  -	Generates write signal for regfile8x32 and clk_dist for 
				address_gen

***************************************************************************/


module Comp_Control
  (input clk,input reset,
	input writeback1,input writeback2,
	output [4:0] rdAddr1,output [4:0] rdAddr2,
	output reg [4:0] wrAddr1,output reg [4:0] wrAddr2,
	output reg [7:0] write_to_reg1,output reg [7:0] write_to_reg2,
	input [4:0] index1,input [4:0] index2,
	input [7:0] rdData1,input [7:0] rdData2,
	input [7:0] wrData1,input [7:0] wrData2,
	output write,
	output reg clk_dist,
	output reg read_from_test);
   
   

   reg [4:0] count_16;
   reg [7:0] count_dist;
   reg clk_16;
   parameter [1:0] // synopsys enum states 
   S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
   reg [1:0]  /* synopsys enum states */current_state, next_state;
   




assign write= (count_dist== 1'b1) | read_from_test ?1'b1:1'b0; 
assign read= (count_dist!= 1'b0)?1'b0:1'b1; 
// Generate clk_dist for the address_gen module
   always @(posedge clk)begin 
    if (reset) begin // active high reset
    	count_dist <= 5'b0 ;
	clk_dist <= 1'b1;
    end else if (count_dist == 2'b01)begin
    	count_dist <= 1'b0;
        clk_dist <=~clk_dist;
     end else begin
	clk_dist <= 0;
	count_dist <= count_dist+1'b1;
    end

   end
   
   // regfile8x32 read addresses to read data from the test-fixture
   always @(posedge clk)begin
    if (reset) begin // active high reset
    	count_16 <= 5'b0 ;
	clk_16 = 1;
    end else if (count_16 == 5'd30)begin
    	count_16 <= 0;
        clk_16 =~clk_16;
     end else begin
	count_16 <= count_16+2'b10;
    end
   end

// regfile8x32 read addresses.
assign rdAddr1=read_from_test?count_16:index1;
assign rdAddr2=read_from_test?count_16+1'b1:index2;


// Compare - swap data and forward it to the write ports for regfile8x32 
always@(*) begin
if (read_from_test) begin // read data from test-fixture->compare swap -> write to regfile8x32
  write_to_reg1 = wrData1>wrData2?wrData1:wrData2;
  write_to_reg2 = wrData1>wrData2?wrData2:wrData1;
   wrAddr1=count_16+1'b1;
  wrAddr2=count_16;
end else if (write == 1'b1 ) begin // read data from regfile8x32->compare swap -> write to regfile8x32
   write_to_reg1 = rdData1<rdData2?rdData1:rdData2;
   write_to_reg2 = rdData1<rdData2?rdData2:rdData1;
   wrAddr1=index1;
   wrAddr2=index2;
end else if (writeback1 |  writeback2) begin // read data from regfile8x32->compare swap -> write to test-fixture
   write_to_reg1 = rdData1<rdData2?rdData1:rdData2;
   write_to_reg2 = rdData1<rdData2?rdData2:rdData1;
   wrAddr1=index1;
   wrAddr2=index2;
end
end

	/*------- Sequential Logic ----*/ 
always@(posedge clk ) 
if (reset) current_state <= S0; 
else current_state <= next_state;
// State machine to control read from the test-fixture
always@(current_state or clk_16) begin
case (current_state) 
S0: begin    
read_from_test <=1'b1;

if (clk_16==1'b0 & read_from_test == 1'b1)
begin next_state = S1; read_from_test <=1'b0; end
else next_state = S0; end
// dummy states all operations are handled by the index generated by address_gen
S1: begin 
next_state = S2; 
end
S2 : begin  next_state = S1; end
default : next_state = S1; 
endcase
end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

/***************************************************************************
regfile8x32: -	store the data.
***************************************************************************/

module regfile8x32
  (input clk,
   input write,
   input  [4:0] wrAddr1,wrAddr2,
   input [7:0] wrData1,wrData2,
   input [4:0] rdAddr1,rdAddr2,
   output reg [7:0] rdData1,rdData2);
// a register file of 32 elements each 8-bit wide
   reg [7:0] 	 regfile [0:31];
// read data when no other write operation is being performed
   always @(posedge clk) begin
      if (!write) begin
	rdData1 <= regfile[rdAddr1];
	rdData2 <= regfile[rdAddr2];
      end
   end
// write data when write is logic high
   always @(posedge clk) begin
      if (write) begin
	regfile[wrAddr1] <= wrData1;
	regfile[wrAddr2] <= wrData2;
	end
   end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

/***************************************************************************
address_gen: -	generate the address indexes for sorting, penultimate and
				final sorted write back stages.
***************************************************************************/


module address_gen
  (input clk,input signal,input reset,
	output wire [4:0] index1,output wire [4:0] index2,
	output reg writeback2,output reg writeback1);
   reg [4:0] count_wb;
   reg [8:0] count;
   
   reg [4:0] loop2_count,loop2_count_temp;
  
   wire [4:0] loop3_count;
   reg [7:0] dist,l1,l2,dist_temp;
   //wire [4:0] index1,index2;
   reg [4:0] loop1_count;
   reg [7:0] count_l2,count_temp;
   reg init_zero,clk_l2,next;
    
   always @(posedge clk)begin
    if (reset | !signal) begin // active high reset
    	count_l2 <= 5'b0 ;
	clk_l2 = 1;
    end else if (count_l2 == l2-1)begin
    	count_l2 <= 0;
        clk_l2 =~clk_l2;
     end else begin
	//clk5 =~clk5;
	count_l2 <= count_l2+1'b1;
    end
   end
	// the count which controls the state machine to update the loop controlling variables
   always @(posedge clk)begin
    if (reset | !signal) begin 
    	count <= 5'b0 ;
    end else begin
    	count <= count + 1;
    end
   end
   // counter to generate the writeback to test-fixture counts
   always @(posedge clk)begin
    if (reset | !signal ) begin // active high reset
    	count_wb <= 5'b0 ;
    end else if (writeback1 | writeback2)begin
    	count_wb <= count_wb + 2;
    end
   end
   // code to control the loop1_count which is being used to generate the loop2_count
   // which in turn generates the indexes
  always @(posedge clk)begin
    if (reset) begin // active high reset
    	loop1_count <= 5'd0 ;
    end else  if (!init_zero | !signal) begin // active high reset
    	loop1_count <= 5'd0 ;
    end else if (count_l2 == l2 -1 & loop1_count+2'b10*dist<32 && count_l2 == l2-1'b1) begin
    	loop1_count<=loop1_count+2'b10*dist;
    end
   end
	// Code to generate the index 1
   always @(posedge clk)begin
	if (reset | !init_zero  | !signal) begin
		next = 5'd0;
        dist_temp = dist;
		count_temp = dist;
		loop2_count=5'd0;
		loop2_count_temp=5'd0;
	end else  begin

	if(count_l2 == 5'd0) begin
		next = 5'b1;
		dist_temp = dist;
		count_temp = dist_temp;
		loop2_count=loop1_count;
		loop2_count_temp=loop1_count;
	end else if(count_temp == 5'b1) begin
		next = 5'b0;
		dist_temp = dist_temp-5'b1;
		count_temp = dist_temp;
		loop2_count_temp=loop2_count_temp +5'b1 ;
		loop2_count=loop2_count_temp;
	end else begin 
	    count_temp =count_temp-5'b1;
		loop2_count =loop2_count+5'b1;
    end end
end

   // temp variable to store index2
   assign loop3_count = loop2_count+dist_temp;
   // check if penultimate or final sorted writeback operation and select
   // the appropriate address indexes
   assign index1 = (writeback1|writeback2)?count_wb:loop2_count;
   assign index2 = (writeback1|writeback2)?count_wb+1'd1:loop3_count;

  // state machine based on the count variable to control index generating counters
  always @(posedge clk)begin
    if (reset | !signal) begin // active high reset
    	//  dist 2
		dist <= 8'd2 ;
		l1 <= 8'd2;
		l2 <= 8'd3;
		init_zero <= 5'b1;
		writeback2 <=5'b0;
		writeback1 <=5'b0;
    end else if (count==9'd23) begin
	//  dist 4
    	dist <= 8'd4;
		l1 <= 8'd4;
		l2 <= 8'd10;
		init_zero <= 5'b0;
		writeback2 <=5'b0;
		writeback1 <=5'b0;
    end else if (count==9'd63) begin
	// dist 8
    	dist <= 8'd8;
		l1 <= 8'd2;
		l2 <= 8'd36;
		init_zero <= 5'b0;
		writeback2 <=5'b0;
		writeback1 <=5'b0;
    end else if (count==9'd136) begin
	// writeback1
    	dist <= 8'd1;
		l1 <= 8'd1;
		l2 <= 8'd1;
		init_zero <= 5'b0;
		writeback2 <=5'b0;
		writeback1 <=5'b1;
    end else if (count==9'd152) begin
	// dist 16
    	dist <= 8'd16;
		l1 <= 8'd1;
		l2 <= 8'd153;
		init_zero <= 5'b0;
		writeback2 <=5'b0;
		writeback1 <=5'b0;
    end else if (count==9'd289) begin
	// writeback2
    	dist <= 8'd1 ;
		l1 <= 8'd1;
		l2 <= 8'd1;
		init_zero <= 5'b0;
		writeback2 <=5'b1;
		writeback1 <=5'b0;
	end else if (count==9'd305) begin
    		writeback2 <=5'b0;
    	end else begin
		init_zero <= 1'b1;
	end
   end
 
 
endmodule