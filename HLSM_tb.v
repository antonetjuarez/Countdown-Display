`timescale 1ns / 1ps


module HLSM_tb();

reg go, Clk, Rst;
wire [7:0] A;
wire [7:0] sum;
wire done;
//HLSM (Clk, Rst, go, sum, done, R_Data);
HLSM a1(Clk, Rst, go, sum, done, A);

always begin
    Clk <= 0;
    #200;
    Clk <=1;
    #200;
end

initial begin
    Rst <= 1; go <= 0;
    @(posedge Clk);
    #25; Rst <= 0;
    go <= 1;
    @(posedge Clk);
    #25 go <= 0;
end
endmodule
