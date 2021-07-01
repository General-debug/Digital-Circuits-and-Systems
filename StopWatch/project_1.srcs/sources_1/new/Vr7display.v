`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 11:19:01
// Design Name: StopWatch
// Module Name: Vr7display
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 显示模块，驱动七段数码管
// 
//////////////////////////////////////////////////////////////////////////////////
module Vr7display(
    input [3:0] bcd_a,
    input [3:0] bcd_b,
    input [3:0] bcd_c,
    input [3:0] bcd_d,
    input [3:0] bcd_dp,
    input clk,
    input rst,
    input ena,
    output reg [3:0] led_sel_n,//片选信号
    output reg [6:0] led_segs_n,//段选信号
    output reg led_dp
    );
    
    reg [1:0] cnt;
    reg [3:0] num;
    
    initial begin
        cnt = 0;
        num = 0;
        led_sel_n = 4'b1111;
        led_segs_n=7'b0000001;
    end
    
    //片选模块
    always @(posedge clk) begin
        if(rst) begin
            led_sel_n <= 4'b1111;
            cnt <= 0;
            led_dp <= 1;
        end
        else if(ena) begin
            case(cnt)
                0: begin led_sel_n <= 4'b1110; num <= bcd_d; end
                1: begin led_sel_n <= 4'b1101; num <= bcd_c; end
                2: begin led_sel_n <= 4'b1011; num <= bcd_b; end
                3: begin led_sel_n <= 4'b0111; num <= bcd_a; end
                default led_sel_n <= 4'b1111;
            endcase
            led_dp <= bcd_dp[cnt];
            cnt <= cnt + 1;
        end
        else led_sel_n <= 4'b1111;
    end
        
    //段选模块
    always @(*) begin
        if(ena) begin
            case(num)
                4'd0:led_segs_n=7'b0000001;
                4'd1:led_segs_n=7'b1001111;
                4'd2:led_segs_n=7'b0010010;
                4'd3:led_segs_n=7'b0000110;
                4'd4:led_segs_n=7'b1001100;
                4'd5:led_segs_n=7'b0100100;
                4'd6:led_segs_n=7'b0100000;
                4'd7:led_segs_n=7'b0001111;
                4'd8:led_segs_n=7'b0000000;
                4'd9:led_segs_n=7'b0000100;
                default led_segs_n=7'b1111111;
           endcase
       end
       else led_segs_n = 7'b1111111;
    end
    
endmodule
