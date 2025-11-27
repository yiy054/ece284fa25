// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);

   parameter row  = 8;
   parameter bw = 4;

   input  clk;
   input  wr;
   input  rd;
   input  reset;
   input  [row*bw-1:0] in;
   output [row*bw-1:0] out;
   output o_full;
   output o_ready;
   // read_mode: 1 => read all rows at once; 2 => read one row at a time (rotating)
   parameter read_mode = 1;
  
   wire [row-1:0] empty;
   wire [row-1:0] full;
   reg [row-1:0] rd_en;
   reg [31:0] rd_ptr; // pointer for version2 (only lower bits used)
  
   genvar i;
  
   // o_ready: at least one FIFO has room (not full)
   assign o_ready = |(~full);
   // o_full: enabled if any of the slots are full
   assign o_full  = |(full);
  
  
   for (i=0; i<row ; i=i+1) begin : row_num
         fifo_depth64 #(.bw(bw)) fifo_instance (
 	 .rd_clk(clk),
 	 .wr_clk(clk),
 	 .rd(rd_en[i]),
 	 .wr(wr),
               .o_empty(empty[i]),
               .o_full(full[i]),
 	 .in(in[ i*bw +: bw ]),
 	 .out(out[ i*bw +: bw ]),
               .reset(reset));
   end
  
  
   always @ (posedge clk) begin
    if (reset) begin
         rd_en <= 8'b00000000;
         rd_ptr <= 0;
    end
    else begin
         if (read_mode == 1) begin
            // version1: read all rows at a time when rd asserted
            if (rd)
               rd_en <= 8'b11111111;
            else
               rd_en <= 8'b00000000;
         end
         else begin
            // version2: rotate a one-hot read enable across rows while rd is asserted
            if (rd) begin
               // enable current row
               rd_en <= (1 << rd_ptr) & (8'b11111111);
               // increment pointer (wrap)
               if (rd_ptr == row-1)
                  rd_ptr <= 0;
               else
                  rd_ptr <= rd_ptr + 1;
            end
            else begin
               // when rd deasserted, disable all and reset pointer
               rd_en <= 8'b00000000;
               rd_ptr <= 0;
            end
         end
    end
   end
  
endmodule
