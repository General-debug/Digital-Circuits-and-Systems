`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/20 16:41:25
// Design Name: StopWatch
// Module Name: counter
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 实现计时功能，将计数的bcd结果传给七段数码管，产生over_flow信号。
// 
//////////////////////////////////////////////////////////////////////////////////


module counter(
    input work,
    input clear,
    input pulse_1ms,
    output reg[3:0] bcd_a,
    output reg[3:0] bcd_b,
    output reg[3:0] bcd_c,
    output reg[3:0] bcd_d,
    output reg over_flow
    );
    reg[16:0] cnt;//��ʱ����Ϊ1ms
    parameter TIME = 9;
    initial begin
        cnt = 0;
        bcd_a = 0;
        bcd_b = 0;
        bcd_c = 0;
        bcd_d = 0;
        over_flow = 0;
    end 
    //��Ƶ��10ms�ź�
    always @(posedge pulse_1ms) begin
        if(clear) 
            cnt <= 0;
        else if(work)
            if(cnt < TIME)
                cnt <= cnt + 1;
            else cnt <= 0;
        else cnt <= cnt;
    end          
        
    always @(posedge pulse_1ms) begin
        if(clear) begin
            bcd_c <= 0;
            bcd_d <= 0;
        end
        else if(work & cnt == TIME) begin
            if(bcd_d < 9) begin
                bcd_d <= bcd_d + 1;
            end 
            else begin
                bcd_c <= bcd_c + 1;
                bcd_d <= 0;
                if(bcd_c == 9) begin
                    bcd_c <= 0;
                end
            end
       end
       else begin 
            bcd_d <= bcd_d;
            bcd_c <= bcd_c;
       end
    end

    always @(posedge pulse_1ms) begin
        if(clear) begin
            bcd_a <= 0;
            bcd_b <= 0;
            over_flow <= 0;
        end
        else if(work & bcd_c==9 & bcd_d == 9 & cnt == TIME) begin
            if(bcd_b < 9) begin
                bcd_b <= bcd_b + 1;
                over_flow <= 0;
            end
            else begin
                bcd_a <= bcd_a + 1;
                bcd_b <= 0;
                if(bcd_a == 5) begin
                    bcd_a <= 0;
                    over_flow <= 1;
                end  
            end
        end
        else begin
            bcd_a <= bcd_a;
            bcd_b <= bcd_b;
        end
    end
                 
endmodule