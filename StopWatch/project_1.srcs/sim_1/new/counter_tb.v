`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/23 20:01:49
// Design Name: 
// Module Name: counter_tb
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


module counter_tb(
    );
    reg work,clear,pulse_1ms;
    wire [3:0] bcd_a;
    wire [3:0] bcd_b;
    wire [3:0] bcd_c;
    wire [3:0] bcd_d;
    wire over_flow;
    counter UUT(.work(work),.clear(clear),.pulse_1ms(pulse_1ms),.bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),.over_flow(over_flow));
    always begin
        #5;pulse_1ms=0;
        #5;pulse_1ms=1;
    end
    
    always begin
        #15;
        clear = 0; work = 1;
        #1000000;
        clear = 0; work = 0;
        #100;
        work = 1;
        #1000;

    end
endmodule
