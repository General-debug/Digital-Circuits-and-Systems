`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 11:41:19
// Design Name: StopWatch
// Module Name: entime
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 使能发生模块
//
//////////////////////////////////////////////////////////////////////////////////

module entime(
    input clk,
    output reg pulse_output
    );
    
    reg[28:0] cnt;
    parameter N = 10;//���������ź�
    parameter pulse = 1;//����ʱ��
    
    always @(posedge clk) begin 
        if(cnt < N-1)
            cnt <= cnt + 1;
        else cnt <= 0;
    end
    
    always @(posedge clk) begin//
        if(cnt < pulse)
            pulse_output <= 1;
        else pulse_output <= 0;
    end
endmodule
