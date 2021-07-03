`timescale 1ns / 1ps

module Key_Controller_TB(

    );
    reg Clk, Btn_L, Btn_R, Btn_C, Btn_U, Btn_D, SW_0, SW_1;
    wire Pulse_10ms;
    wire Key_C, Key_L, Key_R, Key_U, Key_D, Key_Back, Key_Random;
    wire ld_Key_C, ld_Key_Back;

    wire [30: 0] cnt0, cnt1;
    Key_Controller UTT(.Clk(Clk), .Btn_L(Btn_L), .Btn_R(Btn_R), .Btn_C(Btn_C), .Btn_U(Btn_U), .Btn_D(Btn_D),
    .SW_0(SW_0), .SW_1(SW_1), .Pulse_10ms(Pulse_10ms),
    .Key_C(Key_C), .Key_L(Key_L), .Key_R(Key_R), .Key_U(Key_U), .Key_D(Key_D), .Key_Back(Key_Back), .Key_Random(Key_Random),
    .ld_Key_C(ld_Key_C), .ld_Key_Back(ld_Key_Back), .cnt0(cnt0), .cnt1(cnt1));

    initial begin
        Btn_L = 0;
        Btn_R = 0;
        Btn_C = 0;
        Btn_U = 0;
        Btn_D = 0;
        SW_0 = 0;
        SW_1 = 0;
    end

    always begin
        Clk = 1;
        #0.55;
        Clk = 0;
        #0.45;
    end

    always begin
        Btn_C = 0;
        #3
        Btn_C = 1;
        #20
        Btn_C = 0;
        #3;
        Btn_C = 1;
        #100;
        Btn_C = 0;
        #500;
    end



endmodule
