`timescale 1ns / 1ps

module GamePage_Controller_TB(

    );
    reg Key_C, Key_L, Key_R, Key_U, Key_D, Key_Back, Key_Random;
    reg Clk;
    wire Normal, Continue, Next, Reset, Random;
    wire [3: 0] Display;
    wire [3: 0] Present_State, Next_State;

    GamePage_Controller UTT(.Key_C(Key_C), .Key_L(Key_L), .Key_R(Key_R), .Key_U(Key_U), .Key_D(Key_D), .Key_Back(Key_Back), .Key_Random(Key_Random)
    , .Clk(Clk), .Normal(Normal), .Continue(Continue), .Next(Next), .Reset(Reset), .Random(Random), .Display(Display), .Present_State(Present_State));

    always begin
        Clk = 1;
        #0.55;
        Clk = 0;
        #0.45;
    end


    initial begin
        Key_C = 0;
        Key_C = 0;
        Key_L = 0;
        Key_R = 0;
        Key_U = 0;
        Key_D = 0;
        Key_Back = 0;
        Key_Random = 0;
    end

    always begin
        #3;
        Key_C = 1;
        #1;
        Key_C = 0;

        #5

        Key_R = 1;
        #1;
        Key_R = 0;

        #5;

        Key_L = 1;
        #1;
        Key_L = 0;

        #5;

        Key_L = 1;
        #1;
        Key_L = 0;

        #5;

        Key_R = 1;
        #1;
        Key_R = 0;

        #5;

        Key_C = 1;
        #1;
        Key_C = 0;

        #5;

        Key_C = 1;
        #1;
        Key_C = 0;
        #3
        Key_C = 1;
        #1;
        Key_C = 0;

        #5;

        Key_Back = 1;
        #1;
        Key_Back = 0;
        #5;
    end
endmodule
