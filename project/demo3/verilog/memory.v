/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (
	// system inputs
	clk, rst,
	// input from Decode
   data2, Mem_read, Mem_wrt, Halt,
	// inputs from Execute
	result, zero, neg, BTR, SLBI, Cout, Alu_result, 
	// outputs to WB
	data_mem, data_exe, err,
   // global output
   Stall_dmem
   );

   // TODO: Your code here
   input [15:0] data2; 
   input [15:0] result, BTR, SLBI, Cout;
   input [2:0] Alu_result;
   input zero, neg, Mem_read, Mem_wrt, clk, rst, Halt;

   output err, Stall_dmem;
   output [15:0] data_mem, data_exe;

   // use a 8-1 mux to choose desired result from Execute stage
   wire zero_or_neg;
   assign zero_or_neg = zero | neg;

   assign data_exe = Alu_result[2] ? (Alu_result[1] ? (Alu_result[0] ? 16'bx : SLBI) : (Alu_result[0] ? BTR : {15'b0, zero_or_neg})) : 
                      (Alu_result[1] ? (Alu_result[0] ? {15'b0, neg} : {15'b0, zero}) : (Alu_result[0] ? Cout : result));
   
   wire Done, CacheHit, stall_temp;
   // create a data memory
   //memory2c_align mem_data(.data_out(data_mem), .data_in(data2), .addr(data_exe), .enable(~Halt & (Mem_wrt | Mem_read)), .wr(Mem_wrt), .createdump(Halt), .clk(clk), .rst(rst), .err(err));
   // stallmem mem_data(.DataOut(data_mem), .Done(Done), .Stall(Stall_dmem), .CacheHit(CacheHit), .err(err), .Addr(data_exe), .DataIn(data2), .Rd(~Halt & (Mem_wrt | Mem_read)), .Wr(Mem_wrt), .createdump(Halt), .clk(clk), .rst(rst));
   mem_system #(.memtype(0))mem_data(.DataOut(data_mem), .Done(Done), .Stall(stall_temp), .CacheHit(CacheHit), .err(err), .Addr(data_exe), .DataIn(data2), .Rd((~Halt) & Mem_read), .Wr(Mem_wrt), .createdump(Halt), .clk(clk), .rst(rst));
   assign Stall_dmem = stall_temp & ~Done;

endmodule
