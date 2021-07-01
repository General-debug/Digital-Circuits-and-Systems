`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/05/22 00:41:19
// Design Name: StopWatch
// Module Name: controller
// Project Name: Lab3
// Target Devices: Xilinx Artix-7 FPGA (XC7A35T-1CPG236C)
// Tool Versions: Vivado 2020.2
// Description: 状态机程序，实现秒表不同状态的转换。
// 
//////////////////////////////////////////////////////////////////////////////////


module controller(
    input btnc,
    input clk,
    input rst,
    input pulse_10ms,
    output reg work,
    output reg clear
    );
    reg [1:0] PresentS, NextS;
    parameter[1:0] IDLE = 2'b00,WORKING = 2'b01, STOPPING = 2'b11;

    reg PreviousBtnc_0;
    reg PreviousBtnc_1;
    wire btn_out;
    
    initial begin
        PresentS = IDLE;
        NextS = IDLE;
    end
    
    initial begin
        PreviousBtnc_0 = 1'b0;
        PreviousBtnc_1 = 1'b0;
    end
    
    //����
    always @(posedge clk) begin
        if(pulse_10ms)
            PreviousBtnc_1 <= btnc;
        else
            PreviousBtnc_1 <= PreviousBtnc_1;
        
        PreviousBtnc_0 <= PreviousBtnc_1;
    end
    
    assign btn_out = PreviousBtnc_0 & (~PreviousBtnc_1);
    
    //״̬��������ע���ڲ�ͬת����������ö�дTAT������֮ǰֻд��btn_out=1ʱ��ת�����������ȱʡ�������˲���������״̬ת�ƹ��̣�
    always @(btn_out, rst) begin
        if(rst) NextS = IDLE;
        else begin
            case(PresentS)
                IDLE: if(btn_out == 1) NextS = WORKING;else NextS = IDLE;
                WORKING: if(btn_out == 1) NextS = STOPPING; else NextS = WORKING;
                STOPPING: if(btn_out == 1) NextS = IDLE; else NextS = STOPPING;
                default: NextS = IDLE;
            endcase
        end
    end 
    
    always @(posedge clk) begin
        PresentS <= NextS;
    end
    
    always @(PresentS) begin
        case(PresentS)
            IDLE: begin work = 0;clear = 1;end
            WORKING: begin work = 1;clear = 0;end
            STOPPING: begin work = 0;clear = 0; end
            default: begin work = 0;clear = 0; end
        endcase
    end
    
endmodule
