`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 8:05:07
// Design Name: StopWatch
// Module Name: body
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 主体top程序，调用其他模块实现功能。
// 
//////////////////////////////////////////////////////////////////////////////////


module body(
    input btnc,
    input clk,
    input rst,
    output [3:0] led_sel_n,
    output [6:0] led_segs_n,
    output led_dp,
    output over_flow
    );
    
    wire work,clear,pulse_10ms,pulse_1ms,pulse_200hz,btn_out;
    wire[3:0] bcd_a;
    wire[3:0] bcd_b;
    wire[3:0] bcd_c;
    wire[3:0] bcd_d;
    
    entime#(.N(1000_000)) ENTIME1(.clk(clk),.pulse_output(pulse_10ms));//10ms1000_000
    entime#(.N(100_000)) ENTIME2(.clk(clk),.pulse_output(pulse_1ms));//1ms100_000
    entime#(.N(500_000)) ENTIME3(.clk(clk),.pulse_output(pulse_200hz));//200Hz50_000
        
    counter COUNTER(.work(work),.clear(clear),.pulse_1ms(pulse_1ms),.bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),.over_flow(over_flow));
    controller CONTROLLER(.btnc(btnc),.rst(rst),.clk(clk),.pulse_10ms(pulse_10ms),.work(work),.clear(clear));
    Vr7display DISPLAY(.bcd_a(bcd_a),.bcd_b(bcd_b),.bcd_c(bcd_c),.bcd_d(bcd_d),.bcd_dp(4'b1011),.clk(pulse_200hz),.rst(0),.ena(1),.led_sel_n(led_sel_n),.led_segs_n(led_segs_n),.led_dp(led_dp));
    
endmodule
