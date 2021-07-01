`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/23 20:32:51
// Design Name: 
// Module Name: Vr7display_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Vr7display_tb(
    );
    reg[3:0] bcd_a,bcd_b,bcd_c,bcd_d,bcd_dp;
    reg clk,rst,ena;
    wire[3:0] led_sel_n;
    wire[6:0] led_segs_n;
    wire led_dp;
    always begin
        #4.5; clk = 0;
        #5; clk = 1;#0.5;
    end
    Vr7display UUT(.bcd_a(1),.bcd_b(2),.bcd_c(3),.bcd_d(4),.bcd_dp(4'b1001),.clk(clk),.rst(rst),.ena(ena),.led_sel_n(led_sel_n),.led_segs_n(led_segs_n),.led_dp(led_dp));
    
    always begin
        rst = 1;ena = 0;
        #5;
        rst = 0;ena = 1;
        #100;
    end
    
    
endmodule
