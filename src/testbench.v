`timescale 1 ns / 100 ps

module testbench();

reg clk = 1'b0;
always begin
    #1 clk = ~clk;
end

wire clk1;

lab00_test lab00_test(.clk(clk), .clk1(clk1));

initial begin
    $dumpvars;
    $display("Test started...");
    #10 $finish;
end

endmodule