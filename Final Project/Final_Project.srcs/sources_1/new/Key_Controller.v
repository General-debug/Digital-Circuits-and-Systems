`timescale 1ns / 1ps

module Key_Controller(
    input Clk, Btn_L, Btn_R, Btn_C, Btn_U, Btn_D, SW_0, SW_1, SW_2,
    input Left, Right, Roller, 
    output reg Pulse_10ms,
    output Key_C, Key_L, Key_R, Key_U, Key_D, Key_Back, Key_Random, Key_Add,
    output Single_Left, Single_Right, Single_Roller,
    output ld_Key_C, ld_Key_Back
    );


    // parameter N0 = 1000000;
    parameter N = 1000000;
    reg [30: 0] cnt;

    initial begin
        cnt = 0;
    end

    always @(posedge Clk) begin
        if(cnt + 1 == N)
            cnt = 0;
        else 
            cnt = cnt + 1;
    end

    always @(cnt) begin
        Pulse_10ms = (cnt == N - 1) ? 1 : 0;
    end


    reg Previous_Btn_L_0, Previous_Btn_L_1;
    reg Previous_Btn_R_0, Previous_Btn_R_1;
    reg Previous_Btn_U_0, Previous_Btn_U_1;
    reg Previous_Btn_D_0, Previous_Btn_D_1;
    reg Previous_Btn_C_0, Previous_Btn_C_1; 
    reg Previous_SW_0_0, Previous_SW_0_1; 
    reg Previous_SW_1_0, Previous_SW_1_1; 
    reg Previous_SW_2_0, Previous_SW_2_1; 
    reg Previous_Left_0, Previous_Left_1; 
    reg Previous_Right_0, Previous_Right_1; 
    reg Previous_Roller_0, Previous_Roller_1; 

    initial begin
        Previous_Btn_L_0 = 0; Previous_Btn_L_1 = 0;
        Previous_Btn_R_0 = 0; Previous_Btn_R_1 = 0; 
        Previous_Btn_U_0 = 0; Previous_Btn_U_1 = 0; 
        Previous_Btn_D_0 = 0; Previous_Btn_D_1 = 0; 
        Previous_Btn_C_0 = 0; Previous_Btn_C_1 = 0;  
        Previous_SW_0_0 = 0;  Previous_SW_0_1 = 0;
        Previous_SW_1_0 = 0;  Previous_SW_1_1 = 0;
        Previous_SW_2_0 = 0;  Previous_SW_2_1 = 0;
        
        Previous_Left_0 = 0;  Previous_Left_1 = 0;
        Previous_Right_0 = 0;  Previous_Right_1 = 0;
        Previous_Roller_0 = 0;  Previous_Roller_1 = 0;
    end


    always @(posedge Clk) begin
        if(Pulse_10ms) begin
            Previous_Btn_L_1 <= Btn_L;
            Previous_Btn_R_1 <= Btn_R;
            Previous_Btn_U_1 <= Btn_U;
            Previous_Btn_D_1 <= Btn_D;
            Previous_Btn_C_1 <= Btn_C;
            Previous_SW_0_1 <= SW_0;
            Previous_SW_1_1 <= SW_1;
            Previous_SW_2_1 <= SW_2;
            Previous_Left_1 <= Left;
            Previous_Right_1 <= Right;
            Previous_Roller_1 <= Roller;
        end
            
        Previous_Btn_L_0 <= Previous_Btn_L_1;
        Previous_Btn_R_0 <= Previous_Btn_R_1;
        Previous_Btn_U_0 <= Previous_Btn_U_1;
        Previous_Btn_D_0 <= Previous_Btn_D_1;
        Previous_Btn_C_0 <= Previous_Btn_C_1;
        Previous_SW_0_0 <= Previous_SW_0_1;
        Previous_SW_1_0 <= Previous_SW_1_1;
        Previous_SW_2_0 <= Previous_SW_2_1;

        Previous_Left_0 <= Previous_Left_1;
        Previous_Right_0 <= Previous_Right_1;
        Previous_Roller_0 <= Previous_Roller_1;
    end
    
    assign Key_L = Previous_Btn_L_0 & (~Previous_Btn_L_1);
    assign Key_R = Previous_Btn_R_0 & (~Previous_Btn_R_1);
    assign Key_U = Previous_Btn_U_0 & (~Previous_Btn_U_1);
    assign Key_D = Previous_Btn_D_0 & (~Previous_Btn_D_1);
    assign Key_C = Previous_Btn_C_0 & (~Previous_Btn_C_1);
    assign Key_Back = (~Previous_SW_0_0) & Previous_SW_0_1;
    assign Key_Random = (~Previous_SW_1_0) & Previous_SW_1_1;
    assign Key_Add = (~Previous_SW_2_0) & Previous_SW_2_1;

    assign Single_Left = (~Previous_Left_0) & Previous_Left_1;
    assign Single_Right = (~Previous_Right_0) & Previous_Right_1;
    assign Single_Roller = (~Previous_Roller_0) & Previous_Roller_1;


    reg [30:0] cnt0, cnt1;
    initial begin
        cnt0 = 0;
        cnt1 = 0;
    end
    always @(posedge Clk) begin
        if(Key_Back) 
            cnt0 <= N * 5;
        if(Key_C)
            cnt1 <= N * 5;
        if(cnt0 > 0)
            cnt0 = cnt0 - 1;
        if(cnt1 > 0)
            cnt1 = cnt1 - 1;
    end
    
    assign ld_Key_Back = cnt0 > 0;
    assign ld_Key_C = cnt1 > 0;
    
endmodule
