// file: mac_row_tb.v
`timescale 1ns/1ps
module mac_row_tb;
  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 2;

  reg clk = 0;
  reg reset = 1;
  reg [bw-1:0] in_w = 0;
  reg [1:0] inst_w = 2'b00;
  reg [psum_bw*col-1:0] in_n = 0; // upstream partial sums (tie 0 for simple test)

  // instantiate the DUT: 2 PEs in a row
  mac_row #(.bw(bw), .psum_bw(psum_bw), .col(col)) dut (
    .clk(clk),
    .reset(reset),
    .out_s(),   // we don't use in TB, but dumped by $dumpvars
    .in_w(in_w),
    .in_n(in_n),
    .valid(),
    .inst_w(inst_w)
  );

  // clock: 10ns period (toggle every 5)
  always #5 clk = ~clk;

  initial begin
    // VCD
    $dumpfile("mac_tb.vcd");
    $dumpvars(0, mac_row_tb);

    // reset
    reset = 1;
    #12;
    reset = 0;

    // --- kernel loading phase (inst[0] = 1) ---
    // set inst_w to kernel loading (inst[1:0] = 01)
    inst_w = 2'b01;
    // supply several kernel values (these will be captured into tiles)
    in_w = 4'hA; #10; // cycle 1
    in_w = 4'h3; #10; // cycle 2
    in_w = 4'hF; #10; // cycle 3
    in_w = 4'h1; #10;

    // small idle/bubble cycle
    inst_w = 2'b00;
    in_w = 4'h0; #10;

    // --- execution phase (inst[1] = 1) ---
    // set inst_w to execute
    inst_w = 2'b10;
    // supply input activations that feed through the row
    in_w = 4'h2; #10;
    in_w = 4'h4; #10;
    in_w = 4'h7; #10;
    in_w = 4'hF; #10;

    // finish after a few cycles
    #20;
    $finish;
  end
endmodule