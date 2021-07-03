`timescale 1ns / 1ps

module Body(
    input Clk, Btn_L, Btn_R, Btn_C, Btn_U, Btn_D, SW_0, SW_1, SW_2,
    // output [0: 4 * 4 - 1] Map
    output reg [0: 4] ld,
    output Next, Random,
    output hsync,	      //行同步信号
    output vsync,	      //列同步信号
    output[3:0] vga_r,    //vga红色输出
    output[3:0] vga_g,     //vga绿色输出
    output[3:0] vga_b,      //vga蓝色输出
    inout PS2_CLK, PS2_DATA
    );


    wire Key_C, Key_L, Key_R, Key_U, Key_D, Key_Back, Key_Random, Key_Add;
    wire Normal, Continue, Reset;// Next, Random
    wire [3: 0] Display, Present_State;
    wire [16 * 16 - 1: 0] Map;
    wire [3: 0] Xcoord, Ycoord, Xgrid, Ygrid;
    wire Update, Add, Twinkle;
    wire Left, Right, Roller, Cursor_Valid;
    wire Single_Left, Single_Right, Single_Roller;
    wire pulse_tmp, pulse_Update, pulse_Twinkle;


    TimeDivider#(.N(10000_0000)) TimeDivider1(.pulse_input(Clk), .pulse_output(pulse_Update));//10ms1000_000
    // TimeDivider#(.N(10000)) TimeDivider2(.Clk(Clk), .pulse_input(pulse_tmp), .pulse_output(pulse_Update));//10ms1000_000
    TimeDivider50#(.N(10000_0000 / 5)) TimeDivider2(.pulse_input(Clk), .pulse_output(pulse_Twinkle));

    Key_Controller Key_Controller(.Clk(Clk), .Btn_L(Btn_L), .Btn_R(Btn_R), .Btn_C(Btn_C), .Btn_U(Btn_U), .Btn_D(Btn_D), .SW_0(SW_0), .SW_1(SW_1), .SW_2(SW_2), 
    .Left(Left), .Right(Right), .Roller(Roller),
    .Key_C(Key_C), .Key_L(Key_L), .Key_R(Key_R), .Key_U(Key_U), .Key_D(Key_D), .Key_Back(Key_Back), .Key_Random(Key_Random), .Key_Add(Key_Add), 
    .Single_Left(Single_Left), .Single_Right(Single_Right), .Single_Roller(Single_Roller));

    GamePage_Controller GamePage_Controller(.Clk(Clk), .Key_C(Key_C), .Key_L(Key_L), .Key_R(Key_R), .Key_U(Key_U), .Key_D(Key_D), .Key_Back(Key_Back), .Key_Random(Key_Random),
    .Single_Left(Single_Left), .Single_Right(Single_Right), .Single_Roller(Single_Roller),
    .Normal(Normal), .Continue(Continue), .Next(Next), .Reset(Reset), .Random(Random), .Display(Display), .Present_State(Present_State));

    Mode_Controller Mode_Controller(.Clk(Clk), .pulse_Update(pulse_Update), .Reset(Reset), .Normal(Normal), .Continue(Continue), .Next(Next), .Key_C(Key_C), .Key_L(Key_L), .Key_R(Key_R), .Key_U(Key_U), .Key_D(Key_D), .Key_Add(Key_Add),
    .Xgrid(Xgrid), .Ygrid(Ygrid), .Cursor_Valid(Cursor_Valid), .Left(Left), .Single_Left(Single_Left),
    .Update(Update), .Add(Add), .Twinkle(Twinkle), .Xcoord(Xcoord), .Ycoord(Ycoord));

    Map_Controller Map_Controller(.Clk(Clk), .Random(Random), .Reset(Reset), .Update(Update), .Add(Add), .Xcoord(Xcoord), .Ycoord(Ycoord), 
    .Map(Map));

    Vga_Controller Vga_Controller(.clk(Clk), .rst_n(1), .display(Display), .map(Map), .Twinkle_pulse(pulse_Twinkle), .Xcoord(Xcoord), .Ycoord(Ycoord), .Twinkle(Twinkle),
    .Left(Left), .Right(Right), .Middle(Roller),
    .PS2_CLK(PS2_CLK), .PS2_DATA(PS2_DATA), .Xgrid(Xgrid), .Ygrid(Ygrid), .Cursor_valid(Cursor_Valid),
    .hsync(hsync), .vsync(vsync), .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b));


    parameter [3: 0] KSYX_State = 3'b000;
    parameter [3: 0] PTMS_State = 3'b001;
    parameter [3: 0] LXYH_State = 3'b010;
    parameter [3: 0] Normal_State = 3'b011;
    parameter [3: 0] Continue_State = 3'b100;

    always @(posedge Clk) begin
        case (Present_State)
            KSYX_State: 
                ld = 5'b10000;
            PTMS_State: 
                ld = 5'b01000;
            LXYH_State: 
                ld = 5'b00100;
            Normal_State: 
                ld = 5'b00010;
            Continue_State:
                ld = 5'b00001;
        endcase
    end


    // Vga_Controller

endmodule
