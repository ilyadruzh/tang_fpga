module dtrigger();

reg q;

always @(posedge clk or negedge reset) begin
    if (!reset)
        q <= 0;
    else
        q <= d;
end
    
endmodule