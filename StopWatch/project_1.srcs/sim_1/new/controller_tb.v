`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/21 23:52:08
// Design Name: 
// Module Name: controller_tb
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


module controller_tb(
    );
    reg btnc, pulse_10ms,rst,clk;
    wire work,clear,w,out;
    
    always begin //100ns为一个周期
        #90;pulse_10ms = 1;
        #10;pulse_10ms = 0;
    end
    
    always begin
        #5; clk=0;
        #5;clk = 1; 
    end
    
    controller UUT(.btnc(btnc),.clk(clk),.pulse_10ms(pulse_10ms),.work(work),.clear(clear),.rst(rst));
    initial begin 
        rst = 0;
        #6; rst = 1;
    end
    always begin
        #20;
        rst = 0;
        btnc = 1;#5;
        btnc = 0;#150;
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
