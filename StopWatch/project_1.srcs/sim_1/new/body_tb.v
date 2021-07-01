`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/23 22:52:37
// Design Name: 
// Module Name: body_tb
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


module body_tb(
    );
    reg clk,btnc,rst;
    wire[3:0] led_sel_n;
    wire[6:0] led_segs_n;
    wire led_dp, over_flow;
    //wire[3:0] bcd_a;
    //wire[3:0] bcd_b;
    //wire[3:0] bcd_c;
    //wire[3:0] bcd_d;
    //wire pulse_10ms,pulse_1ms,pulse_200hz,pulse_1s,work,clear,btn_out;
    
    body UUT(.btnc(btnc),.clk(clk),.rst(rst),.led_sel_n(led_sel_n),.led_segs_n(led_segs_n),.led_dp(led_dp),.over_flow(over_flow));
    //,.overflow0(overflow0),.bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),.pulse_10ms(pulse_10ms),.pulse_1ms(pulse_1ms),.pulse_200hz(pulse_200hz),.pulse_1s(pulse_1s),.work(work),.clear(clear),.btn_out(btn_out));
    always begin //100ns为一个周期
        #4.5;clk = 1;
        #5; clk = 0;#0.5;  
    end
    
    initial begin
        rst = 0;
        #6; rst = 1;
        #5; rst = 0;
    end
    
    always begin
        #20;
        btnc = 1;#5000;
        btnc = 0;#1500;
        btnc = 1;#1000;
        btnc = 0;#1000;
        btnc = 1;#5000;
        btnc = 0;#1500;
        btnc = 1;#1000;
        btnc = 0;#1000;
        #5000000;
    end
endmodule
