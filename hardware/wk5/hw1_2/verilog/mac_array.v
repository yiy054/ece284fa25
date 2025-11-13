// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;

  wire [col-1:0] row_valid [row-1:0];
  wire [psum_bw*col-1:0] row_out_s [row-1:0];

  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
        .clk(clk),
        .reset(reset),
        .in_w(in_w[bw*(i+1)-1:bw*i]),
        .in_n(in_n),
        .valid(row_valid[i]),
        .inst_w(inst_w),
        .out_s(row_out_s[i])
      );
  end

  // always @ (posedge clk) begin


  //  // inst_w flows to row0 to row7
 
  // end
  assign out_s = row_out_s[row-1];
  assign valid = row_valid[row-1];

endmodule
