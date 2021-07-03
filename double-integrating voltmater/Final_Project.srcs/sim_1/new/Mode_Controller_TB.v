`timescale 1ns / 1ps

module Mode_Controller_TB(
    );
    // input
    reg Reset, Normal, Continue, Next, Clk, pulse_Update;
    reg Key_Add, Key_C, Key_L, Key_R, Key_U, Key_D;
    // output
    wire Update, Add, Twinkle;
    wire [3: 0] Xcoord, Ycoord;

    wire [30: 0] cnt;
    wire [2: 0] Present_State;

    

    always begin
        Clk = 1;
        #0.55;
        Clk = 0;
        #0.45;
    end

    always begin
        pulse_Update = 0;
        #9;
        pulse_Update = 1;
        #1;
    end

    
    Mode_Controller UTT(.Clk(Clk), .pulse_Update(pulse_Update), .Reset(Reset), .Normal(Normal), .Continue(Continue), .Next(Next), .Key_C(Key_C), .Key_L(Key_L), .Key_R(Key_R), .Key_U(Key_U), .Key_D(Key_D), .Key_Add(Key_Add),
    .Update(Update), .Add(Add), .Twinkle(Twinkle), .Xcoord(Xcoord), .Ycoord(Ycoord), .Present_State(Present_State));

    initial begin
        Reset = 1;
        Normal = 0;
        Continue = 0;
        Next = 0;
        Key_Add = 0;
        Key_C = 0;
        Key_L = 0;
        Key_R = 0;
        Key_U = 0;
        Key_D = 0;
    end

    always begin
        Reset = 1;
        # 8;

        Reset = 0; // Idel

        Normal = 1;
        Continue = 0; // Normal

        Next = 0; # 1;
        Next = 1; # 1;
        Next = 0; # 1;
        Next = 1; # 1;
        Next = 0;

        Key_Add = 1;# 1;
        Key_Add = 0;# 1;
        Key_R = 1;# 1;
        Key_R = 0;# 1;
        Key_L = 1;# 1;
        Key_L = 0;# 1;
        Key_L = 1;# 1;
        Key_L = 0;# 1;
        Key_D = 1;# 1;
        Key_D = 0;# 1;
        Key_Add = 1;# 1;
        Key_Add = 0;# 1;

        Next = 0; # 1;
        Next = 1; # 1;
        Next = 0; # 1;
        Next = 1; # 1;
        Next = 0;

        # 8;

        Normal = 0;
        Continue = 1; // Continue_NoUpdate

        #5;
        Key_Add = 1;# 1;
        Key_Add = 0;# 1;
        Key_R = 1;# 1;
        Key_R = 0;# 1;
        Key_L = 1;# 1;
        Key_L = 0;# 1;
        Key_L = 1;# 1;
        Key_L = 0;# 1;
        Key_D = 1;# 1;
        Key_D = 0;# 1;
        Key_Add = 1;# 1;
        Key_Add = 0;# 1;



        # 20;

        Normal = 0;
        Continue = 1;// #2 时 Continue_Update #3 返回Continue_NoUpdate

        # 8;

        

        # 8;

        Reset = 1; // Idle

        # 8;
    end
endmodule
