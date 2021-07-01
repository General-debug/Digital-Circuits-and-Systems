`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/24 10:26:10
// Design Name: 
// Module Name: test_tb
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


module test_tb(
    );
    reg clk;
    wire pulse_10ms,pulse_1ms,pulse_200hz;
    wire [3:0] bcd_a;
    wire [3:0] bcd_b;
    wire [3:0] bcd_c;
    wire [3:0] bcd_d;
    wire over_flow;
    reg btnc,rst;
    wire work,clear;
    entime#(.N(100)) ENTIME1(.clk(clk),.pulse_output(pulse_10ms));//10ms1000_000
    entime#(.N(10)) ENTIME2(.clk(clk),.pulse_output(pulse_1ms));//1ms100_000
    entime#(.N(50)) ENTIME3(.clk(clk),.pulse_output(pulse_200hz));//200Hz50_000

    counter COUNTER(.work(work),.clear(clear),.pulse_1ms(pulse_1ms),.bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),.over_flow(over_flow));
    controller CONTROLLER(.btnc(btnc),.clk(clk),.pulse_10ms(pulse_10ms),.work(work),.clear(clear),.rst(rst));

    always begin
        #4.5; clk = 0;
        #5; clk = 1;#0.5;
    end
    initial begin
        rst = 1;#5;
        rst = 0;
    end 
    always begin
        #20;
        rst = 0;
        btnc = 1;#2000;
        btnc = 0;#15000;
        btnc = 1;#100;
        btnc = 0;#10;
        btnc = 1;#200;
        btnc = 0;#15;
        btnc = 1;#150;        
        btnc = 0;#150;
        btnc = 1;#100;
        btnc = 0;#10;
        btnc = 1;#200;
        btnc = 0;#15;
        btnc = 1;#150;
        btnc = 0;  
    end
    
endmodule
